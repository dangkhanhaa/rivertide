-- P2-57 block-user check. Run after 0006_block_user.sql, e.g. in the Supabase
-- SQL editor or: psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/block_user_check.sql
-- Everything runs inside BEGIN … ROLLBACK: it leaves no data behind.
-- Success = the last notice is "ALL BLOCK-USER CHECKS PASSED"; any failure
-- stops with an error that starts with "FAIL".

begin;

create function pg_temp.ok(p_cond boolean, p_label text) returns void
language plpgsql as $$
begin
  if p_cond is distinct from true then raise exception 'FAIL: %', p_label; end if;
  raise notice 'PASS %', p_label;
end $$;

create function pg_temp.sec(p_name text) returns text
language sql immutable as $$ select md5(p_name) || md5(p_name || '#') $$;

create function pg_temp.hash(p_name text) returns text
language sql immutable as $$ select public.secret_hash(pg_temp.sec(p_name)) $$;

-- No IP header (like local dev): only the per-device limits apply.
select set_config('request.headers', '', true);

-- now() is fixed inside a transaction, so the 2 s gap between two blocks
-- would always trip; the daily cap is checked separately at the end.
update public.rate_limits set min_gap_s = 0 where action = 'block';

-- me = the blocker, bad = the author to block, ok = someone else.
insert into public.devices (device_hash, first_seen)
select pg_temp.hash(n), now() - interval '2 days' from unnest(array['me', 'bad', 'ok']) n;

create temp table ids (name text primary key, id uuid);

with s as (
  insert into public.public_spots (owner_hash, title, location)
  values (pg_temp.hash('bad'), 'Spot of bad', extensions.st_makepoint(106.70, 10.77)::extensions.geography),
         (pg_temp.hash('ok'), 'Spot of ok', extensions.st_makepoint(106.71, 10.77)::extensions.geography)
  returning id, title
)
insert into ids select case when title like '%bad' then 'spot_bad' else 'spot_ok' end, id from s;

with c as (
  insert into public.spot_comments (spot_id, author_hash, body)
  values ((select id from ids where name = 'spot_ok'), pg_temp.hash('bad'), 'comment by bad'),
         ((select id from ids where name = 'spot_ok'), pg_temp.hash('ok'), 'comment by ok')
  returning id, body
)
insert into ids select case when body like '%bad' then 'cmt_bad' else 'cmt_ok' end, id from c;

with t as (
  insert into public.trips (owner_hash, title, location, starts_at, ends_at, max_people)
  values (pg_temp.hash('bad'), 'Trip of bad', extensions.st_makepoint(106.70, 10.77)::extensions.geography,
          now() + interval '1 hour', now() + interval '3 hours', 5),
         (pg_temp.hash('ok'), 'Trip of ok', extensions.st_makepoint(106.70, 10.77)::extensions.geography,
          now() + interval '1 hour', now() + interval '3 hours', 5)
  returning id, title
)
insert into ids select case when title like '%bad' then 'trip_bad' else 'trip_ok' end, id from t;

insert into public.trip_members (trip_id, member_hash)
select (select id from ids where name = 'trip_ok'), pg_temp.hash(n) from unnest(array['me', 'bad', 'ok']) n;

with m as (
  insert into public.trip_messages (trip_id, author_hash, body)
  values ((select id from ids where name = 'trip_ok'), pg_temp.hash('bad'), 'msg by bad'),
         ((select id from ids where name = 'trip_ok'), pg_temp.hash('ok'), 'msg by ok')
  returning id, body
)
insert into ids select case when body like '%bad' then 'msg_bad' else 'msg_ok' end, id from m;

with p as (
  insert into public.ponds (name, location)
  values ('Hồ thử', extensions.st_makepoint(106.70, 10.77)::extensions.geography)
  returning id
)
insert into ids select 'pond', id from p;

-- now() is fixed in a transaction: give the two reviews distinct times.
insert into public.pond_reviews (pond_id, author_hash, rating, body, created_at)
values ((select id from ids where name = 'pond'), pg_temp.hash('bad'), 1, 'review by bad',
        now() - interval '2 hours'),
       ((select id from ids where name = 'pond'), pg_temp.hash('ok'), 5, 'review by ok',
        now() - interval '1 hour');

-- ── before blocking: everything visible ──
select pg_temp.ok((select count(*) from public.nearby_spots(10.77, 106.70, 30, pg_temp.sec('me'))) = 2,
                  'me sees 2 spots before blocking');
select pg_temp.ok((select count(*) from public.list_comments((select id from ids where name = 'spot_ok'),
                                                             pg_temp.sec('me'))) = 2,
                  'me sees 2 comments before blocking');

-- ── blocking ──
select pg_temp.ok(public.block_author('comment', (select id from ids where name = 'cmt_bad'),
                                      pg_temp.sec('me')), 'block via comment');
select pg_temp.ok(not public.block_author('comment', (select id from ids where name = 'cmt_bad'),
                                          pg_temp.sec('bad')), 'cannot block yourself');
select pg_temp.ok(not public.block_author('spot', gen_random_uuid(), pg_temp.sec('me')),
                  'unknown item blocks nobody');
select pg_temp.ok(public.block_author('review', (select id from ids where name = 'pond'),
                                      pg_temp.sec('ok'),
                                      (select created_at from public.pond_reviews
                                        where author_hash = pg_temp.hash('bad'))),
                  'block via review (pond id + created_at)');
select pg_temp.ok(not public.block_author('review', (select id from ids where name = 'pond'),
                                          pg_temp.sec('ok'), now() - interval '5 hours'),
                  'review with a wrong time blocks nobody');
select pg_temp.ok((select count(*) from public.user_blocks) = 2, '2 block rows');
select pg_temp.ok((select count(*) from public.user_blocks
                    where blocker_hash = pg_temp.hash('ok') and blocked_hash = pg_temp.hash('bad')) = 1,
                  'review block resolved the right author');

do $$
begin
  perform public.block_author('x', gen_random_uuid(), pg_temp.sec('me'));
  raise exception 'FAIL: unknown kind accepted';
exception when sqlstate '22023' then raise notice 'PASS unknown kind refused';
end $$;

-- ── after blocking: bad's content gone for me only ──
select pg_temp.ok((select count(*) from public.nearby_spots(10.77, 106.70, 30, pg_temp.sec('me'))) = 1,
                  'blocked author''s spot hidden');
select pg_temp.ok((select comment_count from public.nearby_spots(10.77, 106.70, 30, pg_temp.sec('me'))
                    where title = 'Spot of ok') = 1, 'comment count excludes blocked author');
select pg_temp.ok((select count(*) from public.list_comments((select id from ids where name = 'spot_ok'),
                                                             pg_temp.sec('me'))) = 1,
                  'blocked author''s comment hidden');
select pg_temp.ok((select count(*) from public.nearby_trips(10.77, 106.70, 30, pg_temp.sec('me'))) = 1,
                  'blocked author''s trip hidden');
select pg_temp.ok((select count(*) from public.trip_messages_for((select id from ids where name = 'trip_ok'),
                                                                 pg_temp.sec('me'))) = 1,
                  'blocked author''s trip message hidden');
select pg_temp.ok((select count(*) from public.reviews_for((select id from ids where name = 'pond'),
                                                           pg_temp.sec('me'))) = 1,
                  'blocked author''s review hidden');
select pg_temp.ok((select count(*) from public.nearby_spots(10.77, 106.70, 30, '')) = 2,
                  'anonymous callers still see everything');
select pg_temp.ok((select count(*) from public.nearby_spots(10.77, 106.70, 30, pg_temp.sec('bad'))) = 2,
                  'the blocked author still sees everything');

-- ── unblock ──
select pg_temp.ok(public.unblock_all(pg_temp.sec('me')) = 1, 'unblock_all removes my 1 block');
select pg_temp.ok((select count(*) from public.list_comments((select id from ids where name = 'spot_ok'),
                                                             pg_temp.sec('me'))) = 2,
                  'comments back after unblock');
select pg_temp.ok((select count(*) from public.user_blocks) = 1, 'other device''s block kept');

-- ── daily cap (30 blocks a day per device) ──
update public.rate_limits set device_day = 3 where action = 'block';
do $$
begin
  for i in 1..5 loop
    perform public.block_author('spot', gen_random_uuid(), pg_temp.sec('me'));
  end loop;
  raise exception 'FAIL: block daily cap not enforced';
exception when others then
  if sqlerrm like 'FAIL%' then raise; end if;
  raise notice 'PASS block daily cap enforced (%)', sqlerrm;
end $$;

-- ── privileges ──
select pg_temp.ok(not has_table_privilege('anon', 'public.user_blocks', 'select'),
                  'anon cannot read user_blocks');
select pg_temp.ok(has_function_privilege('anon', 'public.block_author(text, uuid, text, timestamptz)',
                                         'execute'), 'anon can call block_author');

do $$ begin raise notice 'ALL BLOCK-USER CHECKS PASSED'; end $$;

rollback;
