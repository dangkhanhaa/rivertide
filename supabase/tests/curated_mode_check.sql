-- P2-61 curated-mode check. Run after 0008_curated_mode.sql, e.g. in the
-- Supabase SQL editor or: psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/curated_mode_check.sql
-- Everything runs inside BEGIN … ROLLBACK: it leaves no data behind.
-- Success = the last notice is "ALL CURATED-MODE CHECKS PASSED"; any failure
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

-- No IP header (like local dev): only the per-device limits apply. now() is
-- fixed inside a transaction, so the gaps between two writes are switched off.
select set_config('request.headers', '', true);
update public.rate_limits set min_gap_s = 0;
update public.curation set pre_moderate = true;

-- au = author, ow = verified pond owner, rd = another reader.
insert into public.devices (device_hash, first_seen)
select pg_temp.hash(n), now() - interval '2 days' from unnest(array['au', 'ow', 'rd']) n;

create temp table ids (name text primary key, id uuid);

-- ── 1. existing content counts as approved ──
with x as (
  insert into public.public_spots (owner_hash, title, location)
  values (pg_temp.hash('rd'), 'Điểm cũ', extensions.st_makepoint(106.70, 10.77)::extensions.geography)
  returning id)
insert into ids select 'old_spot', id from x;
with x as (
  insert into public.ponds (name, location, source, created_by_hash)
  values ('Hồ cũ', extensions.st_makepoint(106.60, 10.80)::extensions.geography, 'seed', null)
  returning id)
insert into ids select 'old_pond', id from x;
select pg_temp.ok((select mod_status = 'approved' from public.public_spots
                    where id = (select id from ids where name = 'old_spot')), 'old rows default to approved');
select pg_temp.ok(exists (select 1 from public.nearby_spots(10.77, 106.70, 5, '')
                           where id = (select id from ids where name = 'old_spot')),
                  'approved spot visible to anonymous readers');

-- ── 2. new spot: pending, author only ──
insert into ids values ('spot', public.publish_spot('Bến mới', 'Cá rô nhiều', 'Rô', 10.771, 106.701, '{}',
                                                    pg_temp.sec('au')));
select pg_temp.ok((select mod_status = 'pending' from public.public_spots
                    where id = (select id from ids where name = 'spot')), 'new spot is pending');
select pg_temp.ok(exists (select 1 from public.nearby_spots(10.77, 106.70, 5, pg_temp.sec('au'))
                           where id = (select id from ids where name = 'spot') and mine),
                  'pending spot visible to its author');
select pg_temp.ok(not exists (select 1 from public.nearby_spots(10.77, 106.70, 5, pg_temp.sec('rd'))
                               where id = (select id from ids where name = 'spot')),
                  'pending spot hidden from others');
select pg_temp.ok(not exists (select 1 from public.nearby_spots(10.77, 106.70, 5, '')
                               where id = (select id from ids where name = 'spot')),
                  'pending spot hidden from anonymous readers');
select pg_temp.ok((select status = 'pending' from public.my_pending(pg_temp.sec('au'))
                    where kind = 'spot' and item_id = (select id from ids where name = 'spot')),
                  'my_pending reports the pending spot');
select pg_temp.ok(not exists (select 1 from public.my_pending(pg_temp.sec('rd'))
                               where item_id = (select id from ids where name = 'spot')),
                  'my_pending shows nothing of others');
select pg_temp.ok(not exists (select 1 from public.my_pending('')), 'my_pending empty without a secret');
do $$
begin
  perform public.add_comment((select id from ids where name = 'spot'), 'Cho hỏi đường', '', pg_temp.sec('rd'));
  raise exception 'FAIL: comment on a pending spot accepted';
exception when others then
  if sqlerrm like 'FAIL%' then raise; end if;
  raise notice 'PASS others cannot comment on a pending spot (%)', sqlerrm;
end $$;

-- Owner: listed, approved, then public.
select pg_temp.ok(exists (select 1 from public.mod_pending(100)
                           where kind = 'spot' and change = 'new'
                             and item_id = (select id from ids where name = 'spot')
                             and author_hash = pg_temp.hash('au') and approve_sql like 'select public.mod_approve(%'),
                  'mod_pending lists the spot');
select pg_temp.ok(exists (select 1 from public.mod_pending_summary() where kind = 'spot' and items >= 1),
                  'mod_pending_summary counts it');
select pg_temp.ok(public.mod_approve('spot', (select id from ids where name = 'spot')) = 1, 'mod_approve spot');
select pg_temp.ok(exists (select 1 from public.nearby_spots(10.77, 106.70, 5, pg_temp.sec('rd'))
                           where id = (select id from ids where name = 'spot')),
                  'approved spot visible to others');
select pg_temp.ok(not exists (select 1 from public.my_pending(pg_temp.sec('au'))
                               where item_id = (select id from ids where name = 'spot')),
                  'approved spot leaves my_pending');

-- ── 3. edit of an approved spot: others keep the approved version ──
select pg_temp.ok(public.update_spot((select id from ids where name = 'spot'), 'Bến mới (đã sửa)', 'Nước sâu',
                                     'Rô', '{}', pg_temp.sec('au')), 'update_spot accepted');
select pg_temp.ok((select title = 'Bến mới (đã sửa)' from public.nearby_spots(10.77, 106.70, 5, pg_temp.sec('au'))
                    where id = (select id from ids where name = 'spot')), 'author sees the edit');
select pg_temp.ok((select title = 'Bến mới' from public.nearby_spots(10.77, 106.70, 5, pg_temp.sec('rd'))
                    where id = (select id from ids where name = 'spot')), 'others keep the approved title');
select pg_temp.ok((select status = 'edit_pending' from public.my_pending(pg_temp.sec('au'))
                    where item_id = (select id from ids where name = 'spot')), 'my_pending: edit_pending');
select pg_temp.ok(exists (select 1 from public.mod_pending(100) where kind = 'spot' and change = 'edit'),
                  'mod_pending lists the edit');
select pg_temp.ok(public.mod_reject('spot', (select id from ids where name = 'spot'), 'sai chỗ') = 1,
                  'mod_reject edit');
select pg_temp.ok((select title = 'Bến mới' from public.nearby_spots(10.77, 106.70, 5, pg_temp.sec('au'))
                    where id = (select id from ids where name = 'spot')), 'rejected edit dropped for the author');
select pg_temp.ok((select status = 'edit_rejected' and reason = 'sai chỗ' from public.my_pending(pg_temp.sec('au'))
                    where item_id = (select id from ids where name = 'spot')), 'my_pending: edit_rejected');
select public.update_spot((select id from ids where name = 'spot'), 'Bến mới 2', 'Nước sâu', 'Rô', '{}',
                          pg_temp.sec('au'));
select pg_temp.ok(public.mod_approve('spot', (select id from ids where name = 'spot')) = 1, 'mod_approve edit');
select pg_temp.ok((select title = 'Bến mới 2' and updated_at is not null
                     from public.nearby_spots(10.77, 106.70, 5, pg_temp.sec('rd'))
                    where id = (select id from ids where name = 'spot')), 'approved edit public');

-- ── 4. comments: pending, reject, resubmit ──
insert into ids values ('cmt', public.add_comment((select id from ids where name = 'spot'), 'Sáng nay dính 3 con',
                                                   'Rd', pg_temp.sec('rd')));
select pg_temp.ok((select count(*) = 0 from public.list_comments((select id from ids where name = 'spot'),
                                                                 pg_temp.sec('au'))), 'pending comment hidden');
select pg_temp.ok((select count(*) = 1 from public.list_comments((select id from ids where name = 'spot'),
                                                                 pg_temp.sec('rd'))), 'pending comment for author');
select pg_temp.ok((select comment_count = 0 from public.nearby_spots(10.77, 106.70, 5, pg_temp.sec('au'))
                    where id = (select id from ids where name = 'spot')), 'comment_count skips pending');
select pg_temp.ok(public.mod_reject('comment', (select id from ids where name = 'cmt'), 'spam', null, true) = 1,
                  'mod_reject comment with strike');
select pg_temp.ok((select strikes = 1 from public.devices where device_hash = pg_temp.hash('rd')),
                  'reject strike recorded');
select pg_temp.ok((select status = 'rejected' and reason = 'spam' from public.my_pending(pg_temp.sec('rd'))
                    where item_id = (select id from ids where name = 'cmt')), 'author sees rejected comment');
select pg_temp.ok((select count(*) = 1 from public.list_comments((select id from ids where name = 'spot'),
                                                                 pg_temp.sec('rd'))), 'rejected comment for author');
select pg_temp.ok((select count(*) = 0 from public.list_comments((select id from ids where name = 'spot'), '')),
                  'rejected comment hidden from all');
select pg_temp.ok(public.edit_comment((select id from ids where name = 'cmt'), 'Sáng nay dính 4 con',
                                      pg_temp.sec('rd')), 'edit rejected comment');
select pg_temp.ok((select mod_status = 'pending' from public.spot_comments
                    where id = (select id from ids where name = 'cmt')), 'edited rejected comment pending again');
select public.mod_approve('comment', (select id from ids where name = 'cmt'));
select pg_temp.ok((select body = 'Sáng nay dính 4 con' from public.list_comments(
                     (select id from ids where name = 'spot'), '')), 'approved comment public');
select public.edit_comment((select id from ids where name = 'cmt'), 'Sáng nay dính 5 con', pg_temp.sec('rd'));
select pg_temp.ok((select body = 'Sáng nay dính 4 con' from public.list_comments(
                     (select id from ids where name = 'spot'), '')), 'comment edit waits');
select pg_temp.ok((select body = 'Sáng nay dính 5 con' from public.list_comments(
                     (select id from ids where name = 'spot'), pg_temp.sec('rd'))), 'author sees comment edit');

-- ── 5. trips ──
insert into ids values ('trip', public.create_trip('Đi câu sáng mai', 'Mang mồi trùn', 'Bến Ninh Kiều',
  10.03, 105.78, now() + interval '1 day', now() + interval '1 day 4 hours', 5, '', 'Au', pg_temp.sec('au')));
select pg_temp.ok(not exists (select 1 from public.nearby_trips(10.03, 105.78, 5, pg_temp.sec('rd'))
                               where id = (select id from ids where name = 'trip')), 'pending trip hidden');
select pg_temp.ok(exists (select 1 from public.nearby_trips(10.03, 105.78, 5, pg_temp.sec('au'))
                           where id = (select id from ids where name = 'trip') and mine), 'pending trip for owner');
select pg_temp.ok(public.join_trip((select id from ids where name = 'trip'), 'Rd', pg_temp.sec('rd')) = 'closed',
                  'cannot join a pending trip');
select public.mod_approve('trip', (select id from ids where name = 'trip'));
select pg_temp.ok(public.join_trip((select id from ids where name = 'trip'), 'Rd', pg_temp.sec('rd')) = 'joined',
                  'join an approved trip');
select pg_temp.ok(public.update_trip((select id from ids where name = 'trip'), 'Đi câu chiều mai', 'Mang mồi trùn',
  now() + interval '1 day', now() + interval '1 day 2 hours', 6, '', pg_temp.sec('au')), 'update_trip');
select pg_temp.ok((select title = 'Đi câu sáng mai' and max_people = 6
                     from public.nearby_trips(10.03, 105.78, 5, pg_temp.sec('rd'))
                    where id = (select id from ids where name = 'trip')), 'trip title waits, size changes');
select pg_temp.ok((select title = 'Đi câu chiều mai' from public.nearby_trips(10.03, 105.78, 5, pg_temp.sec('au'))
                    where id = (select id from ids where name = 'trip')), 'owner sees the new title');
select public.mod_approve('trip', (select id from ids where name = 'trip'));
select pg_temp.ok((select title = 'Đi câu chiều mai' from public.nearby_trips(10.03, 105.78, 5, '')
                    where id = (select id from ids where name = 'trip')), 'approved trip title public');
-- Chat is not held.
select public.post_trip_message((select id from ids where name = 'trip'), 'Mấy giờ đi anh', 'Rd', pg_temp.sec('rd'));
select pg_temp.ok((select count(*) = 1 from public.trip_messages_for((select id from ids where name = 'trip'),
                                                                     pg_temp.sec('au'))), 'trip chat not held');

-- ── 6. ponds, releases, reviews ──
insert into ids values ('pond', public.add_pond('Hồ Thanh Tâm', 'Ấp 3', 10.9, 106.7, '0912345678', '50k/giờ',
  '6h–18h', array['Chép'], 'Có mái che', '{}', pg_temp.sec('au')));
select pg_temp.ok(not exists (select 1 from public.nearby_ponds(10.9, 106.7, 5, pg_temp.sec('rd'))
                               where id = (select id from ids where name = 'pond')), 'pending pond hidden');
select pg_temp.ok(exists (select 1 from public.nearby_ponds(10.9, 106.7, 5, pg_temp.sec('au'))
                           where id = (select id from ids where name = 'pond')), 'pending pond for its creator');
select pg_temp.ok(not public.update_pond((select id from ids where name = 'pond'), 'Hồ khác', '', 10.9, 106.7, '',
  '', '', '{}', '', '{}', pg_temp.sec('rd')), 'others cannot edit a pending pond');
select pg_temp.ok(not public.review_pond((select id from ids where name = 'pond'), 5, 'Tốt', '', pg_temp.sec('rd')),
                  'others cannot review a pending pond');
select pg_temp.ok(public.update_pond((select id from ids where name = 'pond'), 'Hồ Thanh Tâm 2', 'Ấp 3', 10.9,
  106.7, '0912345678', '50k/giờ', '6h–18h', array['Chép'], 'Có mái che', '{}', pg_temp.sec('au')),
  'creator edits own pending pond in place');
select pg_temp.ok((select name = 'Hồ Thanh Tâm 2' and mod_status = 'pending' from public.ponds
                    where id = (select id from ids where name = 'pond')), 'pond still pending after own edit');
select pg_temp.ok((select status = 'pending' from public.my_pending(pg_temp.sec('au'))
                    where kind = 'pond' and item_id = (select id from ids where name = 'pond')),
                  'my_pending: pending pond');
select public.mod_approve('pond', (select id from ids where name = 'pond'));
-- Someone else's edit of an approved pond is a proposal.
select pg_temp.ok(public.update_pond((select id from ids where name = 'pond'), 'Hồ Thanh Tâm 2', 'Ấp 3, Tân Phú',
  10.9, 106.7, '0912345678', '60k/giờ', '6h–18h', array['Chép'], 'Có mái che', '{}', pg_temp.sec('rd')),
  'pond edit by another device accepted');
select pg_temp.ok((select price_note = '50k/giờ' from public.ponds where id = (select id from ids where name = 'pond')),
                  'pond edit not applied yet');
select pg_temp.ok((select status = 'edit_pending' from public.my_pending(pg_temp.sec('rd'))
                    where kind = 'pond' and item_id = (select id from ids where name = 'pond')),
                  'my_pending: pond edit_pending');
select pg_temp.ok((select preview like '%price: 50k/giờ → 60k/giờ%' from public.mod_pending(100)
                    where kind = 'pond_edit'), 'mod_pending shows the pond diff');
select pg_temp.ok(public.mod_approve('pond_edit', (select id from ids where name = 'pond'), pg_temp.hash('rd')) = 1,
                  'mod_approve pond_edit');
select pg_temp.ok((select price_note = '60k/giờ' and address = 'Ấp 3, Tân Phú' from public.ponds
                    where id = (select id from ids where name = 'pond')), 'pond edit applied');
-- Verified owner: releases and edits are public at once.
update public.ponds set owner_hash = pg_temp.hash('ow') where id = (select id from ids where name = 'pond');
select public.post_release((select id from ids where name = 'pond'), now() + interval '1 day',
  '[{"species":"Chép","kg":300}]', 'Xả chiều', '', pg_temp.sec('ow'));
select pg_temp.ok((select count(*) = 1 from public.releases_for(array[(select id from ids where name = 'pond')],
                                                                 pg_temp.sec('rd'))), 'owner release public at once');
select pg_temp.ok(public.update_pond((select id from ids where name = 'pond'), 'Hồ Thanh Tâm', 'Ấp 3, Tân Phú',
  10.9, 106.7, '0912345678', '70k/giờ', '6h–18h', array['Chép'], 'Có mái che', '{}', pg_temp.sec('ow')),
  'owner edit');
select pg_temp.ok((select price_note = '70k/giờ' from public.ponds where id = (select id from ids where name = 'pond')),
                  'owner edit applied at once');
-- A relayed release waits.
insert into ids values ('rel', public.post_release((select id from ids where name = 'old_pond'),
  now() + interval '2 days', '[{"species":"Trắm","kg":100}]', '', 'Mai xả 100kg trắm', pg_temp.sec('rd')));
select pg_temp.ok((select count(*) = 0 from public.releases_for(array[(select id from ids where name = 'old_pond')],
                                                                 pg_temp.sec('au'))), 'relayed release hidden');
select pg_temp.ok((select next_release_kg is null from public.nearby_ponds(10.8, 106.6, 5, pg_temp.sec('au'))
                    where id = (select id from ids where name = 'old_pond')), 'next release skips pending');
select pg_temp.ok((select next_release_kg = 100 from public.nearby_ponds(10.8, 106.6, 5, pg_temp.sec('rd'))
                    where id = (select id from ids where name = 'old_pond')), 'next release for its author');
select public.mod_approve('release', (select id from ids where name = 'rel'));
select pg_temp.ok((select count(*) = 1 from public.releases_for(array[(select id from ids where name = 'old_pond')],
                                                                 pg_temp.sec('au'))), 'approved release public');
-- Reviews.
select pg_temp.ok(public.review_pond((select id from ids where name = 'old_pond'), 4, 'Hồ sạch', 'Rd',
                                     pg_temp.sec('rd')), 'review_pond');
select pg_temp.ok((select count(*) = 0 from public.reviews_for((select id from ids where name = 'old_pond'),
                                                                pg_temp.sec('au'))), 'pending review hidden');
select pg_temp.ok((select review_count = 0 from public.nearby_ponds(10.8, 106.6, 5, pg_temp.sec('au'))
                    where id = (select id from ids where name = 'old_pond')), 'review_count skips pending');
select pg_temp.ok((select status = 'pending' from public.my_pending(pg_temp.sec('rd'))
                    where kind = 'review' and item_id = (select id from ids where name = 'old_pond')),
                  'my_pending: pending review');
select pg_temp.ok(public.mod_approve('review', (select id from ids where name = 'old_pond'), pg_temp.hash('rd')) = 1,
                  'mod_approve review');
select public.review_pond((select id from ids where name = 'old_pond'), 2, 'Hơi đông', 'Rd', pg_temp.sec('rd'));
select pg_temp.ok((select rating = 4 from public.reviews_for((select id from ids where name = 'old_pond'), '')),
                  'review edit waits');
select pg_temp.ok((select rating = 2 from public.reviews_for((select id from ids where name = 'old_pond'),
                                                              pg_temp.sec('rd'))), 'author sees review edit');

-- ── 7. not held: check-ins, bites, pulses ──
select public.check_in(10.03, 105.78, true, pg_temp.sec('rd'));
select pg_temp.ok((select sum(people) >= 1 from public.nearby_checkins(10.03, 105.78, 5, pg_temp.sec('au'))),
                  'check-ins not held');
select pg_temp.ok(public.pulse_pond((select id from ids where name = 'old_pond'), 'busy', pg_temp.sec('rd')),
                  'pulse_pond');
select pg_temp.ok((select count(*) = 1 from public.pond_pulse((select id from ids where name = 'old_pond'))),
                  'pulses not held');

-- ── 8. approve all from one device; switch off ──
insert into ids values ('spot2', public.publish_spot('Điểm hai', '', '', 10.772, 106.702, '{}', pg_temp.sec('au')));
insert into ids values ('spot3', public.publish_spot('Điểm ba', '', '', 10.773, 106.703, '{}', pg_temp.sec('au')));
select pg_temp.ok(public.mod_approve_all_from(pg_temp.hash('au')) >= 2, 'mod_approve_all_from');
select pg_temp.ok((select count(*) = 2 from public.nearby_spots(10.77, 106.70, 5, '')
                    where id in (select id from ids where name in ('spot2', 'spot3'))), 'all approved');
update public.curation set pre_moderate = false where kind = 'spot';
insert into ids values ('spot4', public.publish_spot('Điểm bốn', '', '', 10.774, 106.704, '{}', pg_temp.sec('au')));
select pg_temp.ok(exists (select 1 from public.nearby_spots(10.77, 106.70, 5, '')
                           where id = (select id from ids where name = 'spot4')), 'curation off → public at once');

-- ── 9. privileges ──
select pg_temp.ok(not has_function_privilege('anon', 'public.mod_pending(int)', 'execute'),
                  'anon cannot call mod_pending');
select pg_temp.ok(not has_function_privilege('anon', 'public.mod_approve(text, uuid, text)', 'execute'),
                  'anon cannot call mod_approve');
select pg_temp.ok(not has_function_privilege('anon', 'public.mod_reject(text, uuid, text, text, boolean)',
                                             'execute'), 'anon cannot call mod_reject');
select pg_temp.ok(not has_function_privilege('anon', 'public.held(text)', 'execute'), 'anon cannot call held');
select pg_temp.ok(not has_table_privilege('anon', 'public.curation', 'select'), 'anon cannot read curation');
select pg_temp.ok(has_function_privilege('anon', 'public.my_pending(text)', 'execute'), 'anon can call my_pending');

do $$ begin raise notice 'ALL CURATED-MODE CHECKS PASSED'; end $$;

rollback;
