-- P2-60 "Xoá dữ liệu của tôi" check. Run after 0007_delete_my_data.sql, e.g.
-- in the Supabase SQL editor or:
--   psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/delete_my_data_check.sql
-- Everything runs inside BEGIN … ROLLBACK: it leaves no data behind.
-- Success = the last notice is "ALL DELETE-MY-DATA CHECKS PASSED"; any
-- failure stops with an error that starts with "FAIL".

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

-- Every row that still carries [p_hash], in any table that stores a device hash.
create function pg_temp.rows_of(p_hash text) returns bigint
language sql as $$
  select (select count(*) from public.public_spots where owner_hash = p_hash)
       + (select count(*) from public.spot_reports where reporter_hash = p_hash)
       + (select count(*) from public.spot_comments where author_hash = p_hash)
       + (select count(*) from public.comment_reports where reporter_hash = p_hash)
       + (select count(*) from public.trips where owner_hash = p_hash)
       + (select count(*) from public.trip_members where member_hash = p_hash)
       + (select count(*) from public.trip_messages where author_hash = p_hash)
       + (select count(*) from public.trip_reports where reporter_hash = p_hash)
       + (select count(*) from public.checkins where owner_hash = p_hash)
       + (select count(*) from public.ponds where created_by_hash = p_hash or owner_hash = p_hash)
       + (select count(*) from public.pond_confirms where device_hash = p_hash)
       + (select count(*) from public.pond_reports where device_hash = p_hash)
       + (select count(*) from public.pond_edits where editor_hash = p_hash)
       + (select count(*) from public.pond_releases where created_by_hash = p_hash)
       + (select count(*) from public.pond_reviews where author_hash = p_hash)
       + (select count(*) from public.pond_pulses where device_hash = p_hash)
       + (select count(*) from public.pond_claims where claimant_hash = p_hash)
       + (select count(*) from public.bite_reports where owner_hash = p_hash)
       + (select count(*) from public.item_votes where device_hash = p_hash)
       + (select count(*) from public.user_blocks where blocker_hash = p_hash or blocked_hash = p_hash)
       + (select count(*) from public.rate_events where device_hash = p_hash)
       + (select count(*) from public.devices where device_hash = p_hash)
$$;

select set_config('request.headers', '', true);

-- me = erases; other = keeps everything.
insert into public.devices (device_hash, first_seen)
select pg_temp.hash(n), now() - interval '2 days' from unnest(array['me', 'other']) n;

create temp table ids (name text primary key, id uuid);
create function pg_temp.id(p_name text) returns uuid
language sql as $$ select id from ids where name = p_name $$;

-- Spots: mine (with a comment by other), other's (with my comment + my report).
with s as (
  insert into public.public_spots (owner_hash, title, location)
  values (pg_temp.hash('me'), 'Spot me', extensions.st_makepoint(106.70, 10.77)::extensions.geography),
         (pg_temp.hash('other'), 'Spot other', extensions.st_makepoint(106.71, 10.77)::extensions.geography)
  returning id, title
)
insert into ids select case when title = 'Spot me' then 'spot_me' else 'spot_other' end, id from s;
insert into public.spot_comments (spot_id, author_hash, body) values
  (pg_temp.id('spot_me'), pg_temp.hash('other'), 'other on my spot'),
  (pg_temp.id('spot_other'), pg_temp.hash('me'), 'me on other spot'),
  (pg_temp.id('spot_other'), pg_temp.hash('other'), 'other on own spot');
insert into public.spot_reports (spot_id, reporter_hash) values (pg_temp.id('spot_other'), pg_temp.hash('me'));
insert into public.item_votes (kind, item_id, device_hash, weight) values
  ('spot', pg_temp.id('spot_other'), pg_temp.hash('me'), 1),
  ('spot', pg_temp.id('spot_me'), pg_temp.hash('other'), 1);
insert into public.comment_reports (comment_id, reporter_hash)
select id, pg_temp.hash('me') from public.spot_comments where body = 'other on own spot';

-- Trips: mine (other joined + wrote), other's (I joined + wrote + reported).
with t as (
  insert into public.trips (owner_hash, title, location, starts_at, ends_at, max_people, contact)
  values (pg_temp.hash('me'), 'Trip me', extensions.st_makepoint(106.70, 10.77)::extensions.geography,
          now() + interval '1 hour', now() + interval '3 hours', 5, '0901234567'),
         (pg_temp.hash('other'), 'Trip other', extensions.st_makepoint(106.70, 10.77)::extensions.geography,
          now() + interval '1 hour', now() + interval '3 hours', 5, '')
  returning id, title
)
insert into ids select case when title = 'Trip me' then 'trip_me' else 'trip_other' end, id from t;
insert into public.trip_members (trip_id, member_hash) values
  (pg_temp.id('trip_me'), pg_temp.hash('me')), (pg_temp.id('trip_me'), pg_temp.hash('other')),
  (pg_temp.id('trip_other'), pg_temp.hash('other')), (pg_temp.id('trip_other'), pg_temp.hash('me'));
insert into public.trip_messages (trip_id, author_hash, body) values
  (pg_temp.id('trip_me'), pg_temp.hash('other'), 'other in my trip'),
  (pg_temp.id('trip_other'), pg_temp.hash('me'), 'me in other trip'),
  (pg_temp.id('trip_other'), pg_temp.hash('other'), 'other in own trip');
insert into public.trip_reports (trip_id, reporter_hash) values (pg_temp.id('trip_other'), pg_temp.hash('me'));

insert into public.checkins (owner_hash, cell_lat, cell_lon, expires_at) values
  (pg_temp.hash('me'), 10.77, 106.70, now() + interval '4 hours'),
  (pg_temp.hash('other'), 10.77, 106.70, now() + interval '4 hours');
insert into public.bite_reports (owner_hash, cell_lat, cell_lon, bite) values
  (pg_temp.hash('me'), 10.77, 106.70, true), (pg_temp.hash('other'), 10.77, 106.70, false);

-- Ponds: solo (only me), shared (mine but other confirmed + reviewed),
-- owned (other created, I am the approved owner), other's (I edited, confirmed,
-- reviewed, reported, pulsed, posted a release, claimed with a phone).
with p as (
  insert into public.ponds (name, location, source, created_by_hash, owner_hash, confirmations)
  values ('Pond solo', extensions.st_makepoint(106.60, 10.80)::extensions.geography, 'user', pg_temp.hash('me'), null, 1),
         ('Pond shared', extensions.st_makepoint(106.61, 10.80)::extensions.geography, 'user', pg_temp.hash('me'), null, 2),
         ('Pond owned', extensions.st_makepoint(106.62, 10.80)::extensions.geography, 'user', pg_temp.hash('other'), pg_temp.hash('me'), 1),
         ('Pond other', extensions.st_makepoint(106.63, 10.80)::extensions.geography, 'user', pg_temp.hash('other'), null, 2)
  returning id, name
)
insert into ids select lower(replace(name, ' ', '_')), id from p;
insert into public.pond_confirms (pond_id, device_hash) values
  (pg_temp.id('pond_solo'), pg_temp.hash('me')),
  (pg_temp.id('pond_shared'), pg_temp.hash('me')), (pg_temp.id('pond_shared'), pg_temp.hash('other')),
  (pg_temp.id('pond_owned'), pg_temp.hash('other')),
  (pg_temp.id('pond_other'), pg_temp.hash('other')), (pg_temp.id('pond_other'), pg_temp.hash('me'));
insert into public.item_votes (kind, item_id, device_hash, weight)
select 'pond_confirm', pond_id, device_hash, 1 from public.pond_confirms;
insert into public.pond_reviews (pond_id, author_hash, rating, body) values
  (pg_temp.id('pond_shared'), pg_temp.hash('other'), 5, 'good'),
  (pg_temp.id('pond_other'), pg_temp.hash('me'), 4, 'mine');
insert into public.pond_edits (pond_id, editor_hash, before) values
  (pg_temp.id('pond_other'), pg_temp.hash('me'), '{}'::jsonb);
insert into public.pond_reports (pond_id, device_hash) values (pg_temp.id('pond_other'), pg_temp.hash('me'));
insert into public.pond_pulses (pond_id, device_hash, kind) values
  (pg_temp.id('pond_other'), pg_temp.hash('me'), 'busy'), (pg_temp.id('pond_other'), pg_temp.hash('other'), 'quiet');
insert into public.pond_releases (pond_id, starts_at, created_by_hash, by_owner) values
  (pg_temp.id('pond_owned'), now() + interval '1 day', pg_temp.hash('me'), true),
  (pg_temp.id('pond_other'), now() + interval '1 day', pg_temp.hash('other'), false);
insert into public.pond_claims (pond_id, claimant_hash, contact) values
  (pg_temp.id('pond_other'), pg_temp.hash('me'), '0909999999');

insert into public.user_blocks (blocker_hash, blocked_hash) values
  (pg_temp.hash('me'), pg_temp.hash('other')), (pg_temp.hash('other'), pg_temp.hash('me'));
insert into public.rate_events (action, device_hash) values ('comment', pg_temp.hash('me'));

select pg_temp.ok(pg_temp.rows_of(pg_temp.hash('me')) > 25, 'fixture: me has rows everywhere');

-- ── input checks ──
do $$
begin
  perform public.delete_my_data('not-a-secret');
  raise exception 'FAIL: bad secret accepted';
exception when sqlstate '22023' then raise notice 'PASS bad secret refused';
end $$;
select pg_temp.ok(public.delete_my_data(pg_temp.sec('never-posted'))->>'device' = '0',
                  'unknown device: nothing to delete, no error');

-- ── erase ──
create temp table res as select public.delete_my_data(pg_temp.sec('me')) as r;
select pg_temp.ok((select (r->>'spots')::int = 1 and (r->>'comments')::int = 1
                          and (r->>'trips')::int = 1 and (r->>'trip_joins')::int = 1
                          and (r->>'trip_messages')::int = 1 and (r->>'checkins')::int = 1
                          and (r->>'bite_reports')::int = 1 and (r->>'device')::int = 1
                     from res), 'counts of own items');
select pg_temp.ok((select (r->>'ponds_deleted')::int = 1 and (r->>'ponds_anonymised')::int = 1
                          and (r->>'pond_edits_anonymised')::int = 1 and (r->>'pond_claims')::int = 1
                          and (r->>'pond_reviews')::int = 1 and (r->>'pond_releases')::int = 1
                     from res), 'pond counts');
select pg_temp.ok((select (r->>'reports')::int = 4 from res), '4 reports removed');
select pg_temp.ok(pg_temp.rows_of(pg_temp.hash('me')) = 0, 'no row carries my hash any more');

-- ── what stays for others ──
select pg_temp.ok(not exists (select 1 from public.ponds where name = 'Pond solo'), 'solo pond deleted');
select pg_temp.ok((select created_by_hash is null and confirmations = 1 from public.ponds
                    where name = 'Pond shared'), 'shared pond kept, anonymised, my confirmation gone');
select pg_temp.ok((select owner_hash is null and created_by_hash = pg_temp.hash('other')
                     from public.ponds where name = 'Pond owned'), 'owned pond loses me as owner');
select pg_temp.ok((select confirmations = 1 from public.ponds where name = 'Pond other'),
                  'other pond count drops by my confirmation');
select pg_temp.ok((select editor_hash = public.erased_hash() from public.pond_edits
                    where pond_id = pg_temp.id('pond_other')), 'edit history kept, editor erased');
select pg_temp.ok(exists (select 1 from public.public_spots where title = 'Spot other'), 'other spot kept');
select pg_temp.ok((select count(*) from public.spot_comments) = 1, 'only other''s comment on own spot left');
select pg_temp.ok(exists (select 1 from public.trips where title = 'Trip other'), 'other trip kept');
select pg_temp.ok((select count(*) from public.trip_messages) = 1, 'only other''s message in own trip left');
select pg_temp.ok((select count(*) from public.checkins) = 1, 'other check-in kept');
select pg_temp.ok((select count(*) from public.pond_reviews) = 1, 'other review kept');
select pg_temp.ok(not exists (select 1 from public.item_votes where item_id = pg_temp.id('spot_me')),
                  'votes on my deleted spot removed');
select pg_temp.ok(exists (select 1 from public.devices where device_hash = pg_temp.hash('other')),
                  'other device kept');
select pg_temp.ok((select count(*) from public.rate_events where action = 'delete_data'
                     and device_hash = public.erased_hash()) = 2, 'call logged under the erased hash');
select pg_temp.ok(public.delete_my_data(pg_temp.sec('me'))->>'device' = '0', 'second call is a no-op');

-- ── orphan photos (owner tool) ──
update public.public_spots set photos = array['11111111-1111-1111-1111-111111111111/a.jpg']
 where title = 'Spot other';
insert into storage.objects (bucket_id, name) values
  ('spot-photos', '11111111-1111-1111-1111-111111111111/a.jpg'),
  ('spot-photos', '22222222-2222-2222-2222-222222222222/b.jpg');
select pg_temp.ok((select array_agg(name) from public.mod_orphan_photos())
                    = array['22222222-2222-2222-2222-222222222222/b.jpg'],
                  'orphan photo listed, used photo not');

-- ── IP rate limit ──
select set_config('request.headers', '{"cf-connecting-ip": "203.0.113.9"}', true);
update public.rate_limits set ip_hour = 2 where action = 'delete_data';
do $$
begin
  for i in 1..4 loop
    perform public.delete_my_data(md5('x' || i) || md5('y' || i));
  end loop;
  raise exception 'FAIL: delete_data IP limit not enforced';
exception when others then
  if sqlerrm like 'FAIL%' then raise; end if;
  raise notice 'PASS delete_data IP limit enforced (%)', sqlerrm;
end $$;
select set_config('request.headers', '', true);

-- ── privileges ──
select pg_temp.ok(has_function_privilege('anon', 'public.delete_my_data(text)', 'execute'),
                  'anon can call delete_my_data');
select pg_temp.ok(not has_function_privilege('anon', 'public.delete_my_pond_data(text)', 'execute'),
                  'anon cannot call the pond helper');
select pg_temp.ok(not has_function_privilege('anon', 'public.mod_orphan_photos()', 'execute'),
                  'anon cannot list orphan photos');

do $$ begin raise notice 'ALL DELETE-MY-DATA CHECKS PASSED'; end $$;

rollback;
