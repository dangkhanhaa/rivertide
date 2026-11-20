-- Purpose: "Xoá dữ liệu của tôi" — a device erases everything the server
-- links to its secret hash (right to erasure: Nghị định 13/2023/NĐ-CP and the
-- 2025 personal data protection law; Google Play user data / account deletion
-- policy; App Store guideline 5.1.1(v)). No login: the device proves it is the
-- author with its secret, exactly like delete_spot / delete_comment.
--
-- What happens to each kind of row of the caller (h = sha256(secret)):
--   deleted     public_spots (+ others' comments/reports on them, by cascade —
--               same as delete_spot), spot_comments, spot/comment/trip/pond
--               reports, trips (+ members/messages/reports, by cascade; trips
--               last ≤ 24 h), trip_members, trip_messages, checkins,
--               pond_releases, pond_reviews, pond_pulses, pond_confirms (the
--               pond's count goes down by the confirmation's weight), pond_claims
--               (they hold a phone number), bite_reports, item_votes,
--               user_blocks (both directions), rate_events, devices
--   ponds       a pond only this device worked on (no confirmation, review,
--               release, pulse or claim from anyone else, no other owner) is
--               deleted; any other pond stays for the people who confirmed or
--               reviewed it, with created_by_hash set to null (anonymised).
--               Its facts (name, address, business phone, prices) describe a
--               business, not the person who typed them.
--               A pond this device owns (approved claim) loses its owner.
--   pond_edits  kept for the edit history of shared ponds; editor_hash is
--               replaced by the all-zero hash (no device can have it).
--   kept        moderation outcomes already taken (report_count, hidden) and
--               IP blocks (keyed by IP hash, not by device, ≤ 7 days).
-- Photos in Storage (bucket spot-photos) cannot be deleted from SQL on
-- Supabase (direct deletes on storage.objects are refused); paths are random
-- UUIDs no row points to any more. The owner removes such orphans with
-- public.mod_orphan_photos() + the Storage dashboard (docs/release/legal-checklist.md).
--
-- Rate limit: per IP only (the device's own rows are gone afterwards), action
-- 'delete_data'; the accepted call is logged under the all-zero hash so the IP
-- count survives. Banned devices may still erase their data.
-- Task: P2-60

insert into public.rate_limits
  (action, min_gap_s, device_day, new_device_day, ip_minute, ip_hour, ip_day, note) values
  ('delete_data', 0, null, null, null, 10, 30, 'delete_my_data (per IP only)')
on conflict (action) do nothing;

-- Stands for "a device that erased its data" in rows kept for others.
create or replace function public.erased_hash()
returns text language sql immutable set search_path = '' as $$
  select repeat('0', 64)
$$;

create or replace function public.delete_my_data(p_secret text)
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  z text := public.erased_hash();
  glob public.rate_limits%rowtype;
  v_ip text;
  v_src text;
  n int;
  res jsonb := '{}'::jsonb;
begin
  if h = z then raise exception 'invalid secret' using errcode = '22023'; end if;
  select c.ip_hash, c.ip_source into v_ip, v_src from public.client_ip() c;
  perform pg_advisory_xact_lock(hashtextextended('guard:' || h, 0));
  if v_ip is not null then
    select * into glob from public.rate_limits r where r.action = 'all';
    if (select count(*) from public.rate_events e
         where e.ip_hash = v_ip and e.created_at > now() - interval '1 minute') >= glob.ip_minute then
      perform public.raise_limit('burst');
    end if;
    perform public.check_ip_rate(v_ip, 'delete_data');
  end if;

  -- Votes on items this device authored, before the items go.
  delete from public.item_votes v
   where (v.kind = 'spot' and v.item_id in (select s.id from public.public_spots s where s.owner_hash = h))
      or (v.kind = 'comment' and v.item_id in (
            select c.id from public.spot_comments c
             where c.author_hash = h
                or c.spot_id in (select s.id from public.public_spots s where s.owner_hash = h)))
      or (v.kind = 'trip' and v.item_id in (select t.id from public.trips t where t.owner_hash = h))
      or (v.kind = 'release' and v.item_id in (
            select r.id from public.pond_releases r where r.created_by_hash = h));

  delete from public.public_spots x where x.owner_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('spots', n);
  delete from public.spot_comments x where x.author_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('comments', n);
  delete from public.trips x where x.owner_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('trips', n);
  delete from public.trip_members x where x.member_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('trip_joins', n);
  delete from public.trip_messages x where x.author_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('trip_messages', n);
  delete from public.checkins x where x.owner_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('checkins', n);
  delete from public.bite_reports x where x.owner_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('bite_reports', n);

  res := res || public.delete_my_pond_data(h);

  with a as (delete from public.spot_reports x where x.reporter_hash = h returning 1),
       b as (delete from public.comment_reports x where x.reporter_hash = h returning 1),
       c as (delete from public.trip_reports x where x.reporter_hash = h returning 1),
       d as (delete from public.pond_reports x where x.device_hash = h returning 1)
  select (select count(*) from a) + (select count(*) from b) + (select count(*) from c)
         + (select count(*) from d) into n;
  res := res || jsonb_build_object('reports', n);
  delete from public.item_votes x where x.device_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('votes', n);
  delete from public.user_blocks x where x.blocker_hash = h or x.blocked_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('blocks', n);
  delete from public.rate_events x where x.device_hash = h;
  delete from public.devices x where x.device_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('device', n);

  insert into public.rate_events (action, device_hash, ip_hash, ip_source)
  values ('delete_data', z, v_ip, coalesce(v_src, 'none'));
  return res;
end $$;

-- Pond part of delete_my_data (kept apart so each function stays short).
create or replace function public.delete_my_pond_data(h text)
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  n int;
  res jsonb := '{}'::jsonb;
begin
  -- My confirmation no longer vouches for the pond.
  update public.ponds p set confirmations = greatest(p.confirmations - 1, 0)
   where p.id in (select v.item_id from public.item_votes v
                   where v.kind = 'pond_confirm' and v.device_hash = h and v.weight > 0);
  delete from public.pond_confirms x where x.device_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('pond_confirms', n);
  delete from public.pond_releases x where x.created_by_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('pond_releases', n);
  delete from public.pond_reviews x where x.author_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('pond_reviews', n);
  delete from public.pond_pulses x where x.device_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('pond_pulses', n);
  delete from public.pond_claims x where x.claimant_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('pond_claims', n);
  update public.ponds p set owner_hash = null, updated_at = now() where p.owner_hash = h;

  -- Ponds nobody else touched go; the others stay, without my hash.
  delete from public.item_votes v
   where v.kind = 'pond' and v.item_id in (select p.id from public.ponds p
                                            where p.created_by_hash = h and public.pond_is_only_mine(p.id, h));
  delete from public.ponds p where p.created_by_hash = h and public.pond_is_only_mine(p.id, h);
  get diagnostics n = row_count; res := res || jsonb_build_object('ponds_deleted', n);
  update public.ponds p set created_by_hash = null where p.created_by_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('ponds_anonymised', n);
  update public.pond_edits e set editor_hash = public.erased_hash() where e.editor_hash = h;
  get diagnostics n = row_count; res := res || jsonb_build_object('pond_edits_anonymised', n);
  return res;
end $$;

-- Called after the device's own confirms/reviews/releases/pulses/claims are
-- gone: anything left on the pond comes from someone else.
create or replace function public.pond_is_only_mine(p_pond uuid, h text)
returns boolean language sql stable security definer set search_path = '' as $$
  select not exists (select 1 from public.ponds p
                      where p.id = p_pond and (p.source <> 'user' or p.owner_hash is not null))
     and not exists (select 1 from public.pond_confirms c where c.pond_id = p_pond)
     and not exists (select 1 from public.pond_reviews r where r.pond_id = p_pond)
     and not exists (select 1 from public.pond_releases r where r.pond_id = p_pond)
     and not exists (select 1 from public.pond_pulses u where u.pond_id = p_pond)
     and not exists (select 1 from public.pond_claims c where c.pond_id = p_pond)
     and not exists (select 1 from public.pond_edits e where e.pond_id = p_pond and e.editor_hash <> h)
$$;

-- Owner tool: photo files no row points to (deleted spots/ponds, erased
-- data, abandoned uploads). A photo uploaded seconds ago may not be attached
-- yet: delete only files older than a day (created_at in the dashboard), in the Storage
-- dashboard or with the Storage API (service role, owner's machine only).
create or replace function public.mod_orphan_photos()
returns table (name text)
language sql stable security definer set search_path = '' as $$
  select o.name from storage.objects o
   where o.bucket_id = 'spot-photos'
     and not exists (select 1 from public.public_spots s where o.name = any (s.photos))
     and not exists (select 1 from public.ponds p where o.name = any (p.photos))
   order by o.name
$$;

revoke all on function public.erased_hash() from public;
revoke all on function public.delete_my_data(text) from public;
revoke all on function public.delete_my_pond_data(text) from public;
revoke all on function public.pond_is_only_mine(uuid, text) from public;
revoke all on function public.mod_orphan_photos() from public;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on function public.erased_hash() from anon, authenticated;
    revoke all on function public.delete_my_pond_data(text) from anon, authenticated;
    revoke all on function public.pond_is_only_mine(uuid, text) from anon, authenticated;
    revoke all on function public.mod_orphan_photos() from anon, authenticated;
    grant execute on function public.mod_orphan_photos() to service_role;
    grant execute on function public.delete_my_data(text) to anon, authenticated;
  end if;
end $$;
