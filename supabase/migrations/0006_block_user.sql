-- Purpose: "Chặn người này" (block user) for the community features, as App
-- Store guideline 1.2 and Google Play's UGC policy require: a device hides
-- every spot, comment, trip, trip message and pond review of one author.
--   * public.user_blocks: blocker → blocked device hashes; no client access
--     (RLS on, no policies); author hashes never leave the server
--   * block_author(kind, item, secret[, at]): the server finds the author of
--     the item; pond reviews have no id, so they are found by pond id + the
--     review's created_at (± 1 ms)
--   * unblock_all(secret)
--   * list_comments, nearby_spots, nearby_trips, trip_messages_for,
--     reviews_for: same signatures and return types as 0005, now without
--     blocked authors' rows for the caller
-- Blocks are limited per device/IP through public.guard('block').
-- Task: P2-57

-- ───────────────────────── table ─────────────────────────

create table if not exists public.user_blocks (
  blocker_hash text not null check (blocker_hash ~ '^[0-9a-f]{64}$'),
  blocked_hash text not null check (blocked_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  primary key (blocker_hash, blocked_hash),
  check (blocker_hash <> blocked_hash)
);
comment on table public.user_blocks is
  'Who hid whom (device hashes), read only by the list functions (P2-57).';
alter table public.user_blocks enable row level security;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on table public.user_blocks from anon, authenticated;
  end if;
end $$;

insert into public.rate_limits
  (action, min_gap_s, device_day, new_device_day, ip_minute, ip_hour, ip_day, note) values
  ('block', 2, 30, 10, null, 100, 500, 'block_author')
on conflict (action) do nothing;

-- ───────────────────────── block / unblock ─────────────────────────

-- True when the caller now hides this author; false for an unknown item or
-- the caller's own content. 'review' takes the pond id and the review's
-- created_at in [p_at].
create or replace function public.block_author(
  p_kind text, p_item_id uuid, p_secret text, p_at timestamptz default null
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  v_author text;
begin
  if p_kind not in ('spot', 'comment', 'trip', 'trip_msg', 'review') then
    raise exception 'unknown kind' using errcode = '22023';
  end if;
  perform public.guard('block', h);
  if p_kind = 'spot' then
    select s.owner_hash into v_author from public.public_spots s where s.id = p_item_id;
  elsif p_kind = 'comment' then
    select c.author_hash into v_author from public.spot_comments c where c.id = p_item_id;
  elsif p_kind = 'trip' then
    select t.owner_hash into v_author from public.trips t where t.id = p_item_id;
  elsif p_kind = 'trip_msg' then
    select m.author_hash into v_author from public.trip_messages m where m.id = p_item_id;
  elsif p_at is not null then
    select r.author_hash into v_author from public.pond_reviews r
     where r.pond_id = p_item_id
       and r.created_at between p_at - interval '1 millisecond' and p_at + interval '1 millisecond'
     order by abs(extract(epoch from r.created_at - p_at))
     limit 1;
  end if;
  if v_author is null or v_author = h then return false; end if;
  insert into public.user_blocks (blocker_hash, blocked_hash) values (h, v_author)
  on conflict do nothing;
  return true;
end $$;

-- Undoes every block of the caller; returns how many were removed.
create or replace function public.unblock_all(p_secret text)
returns int language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  n int;
begin
  delete from public.user_blocks b where b.blocker_hash = h;
  get diagnostics n = row_count;
  return n;
end $$;

-- ───────────────────────── lists (0005 + blocks) ─────────────────────────

create or replace function public.list_comments(p_spot_id uuid, p_secret text default '')
returns table (
  id uuid, author_name text, body text, created_at timestamptz, updated_at timestamptz, mine boolean
)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  )
  select c.id, c.author_name, c.body, c.created_at, c.updated_at,
         coalesce(c.author_hash = me.h, false)
    from public.spot_comments c, me
   where c.spot_id = p_spot_id and not c.hidden
     and (not c.shadow or c.author_hash = me.h)
     and not exists (select 1 from public.user_blocks b
                      where b.blocker_hash = me.h and b.blocked_hash = c.author_hash)
   order by c.created_at desc
   limit 200
$$;

create or replace function public.nearby_spots(
  lat double precision, lon double precision, radius_km double precision default 30,
  owner_secret text default ''
)
returns table (
  id uuid, title text, note text, species text,
  lat double precision, lon double precision, photos text[],
  created_at timestamptz, distance_km double precision, mine boolean,
  updated_at timestamptz, comment_count bigint
)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(owner_secret) then public.secret_hash(owner_secret) end as h
  )
  select s.id, s.title, s.note, s.species,
         extensions.st_y(s.location::extensions.geometry),
         extensions.st_x(s.location::extensions.geometry),
         s.photos, s.created_at,
         extensions.st_distance(s.location, extensions.st_makepoint(lon, lat)::extensions.geography) / 1000,
         coalesce(s.owner_hash = me.h, false),
         s.updated_at,
         (select count(*) from public.spot_comments c
           where c.spot_id = s.id and not c.hidden and (not c.shadow or c.author_hash = me.h)
             and not exists (select 1 from public.user_blocks b
                              where b.blocker_hash = me.h and b.blocked_hash = c.author_hash))
    from public.public_spots s, me
   where not s.hidden
     and (not s.shadow or s.owner_hash = me.h)
     and not exists (select 1 from public.user_blocks b
                      where b.blocker_hash = me.h and b.blocked_hash = s.owner_hash)
     and extensions.st_dwithin(s.location, extensions.st_makepoint(lon, lat)::extensions.geography,
                               least(greatest(radius_km, 1), 100) * 1000)
   order by 9
   limit 100
$$;

create or replace function public.nearby_trips(
  p_lat double precision, p_lon double precision, p_radius_km double precision default 30,
  p_secret text default ''
)
returns table (
  id uuid, title text, note text, place_name text, lat double precision, lon double precision,
  starts_at timestamptz, ends_at timestamptz, max_people int, member_count bigint,
  owner_name text, mine boolean, joined boolean, cancelled boolean, distance_km double precision
)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  )
  select t.id, t.title, t.note, t.place_name,
         extensions.st_y(t.location::extensions.geometry),
         extensions.st_x(t.location::extensions.geometry),
         t.starts_at, t.ends_at, t.max_people,
         (select count(*) from public.trip_members m where m.trip_id = t.id),
         t.owner_name,
         coalesce(t.owner_hash = me.h, false),
         exists (select 1 from public.trip_members m where m.trip_id = t.id and m.member_hash = me.h),
         t.cancelled,
         extensions.st_distance(t.location, extensions.st_makepoint(p_lon, p_lat)::extensions.geography) / 1000
    from public.trips t, me
   where not t.hidden
     and (not t.shadow or t.owner_hash = me.h)
     and not exists (select 1 from public.user_blocks b
                      where b.blocker_hash = me.h and b.blocked_hash = t.owner_hash)
     and t.ends_at > now()
     and (not t.cancelled
          or exists (select 1 from public.trip_members m where m.trip_id = t.id and m.member_hash = me.h))
     and extensions.st_dwithin(t.location, extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
                               least(greatest(p_radius_km, 1), 100) * 1000)
   order by t.starts_at
   limit 100
$$;

create or replace function public.trip_messages_for(p_trip_id uuid, p_secret text)
returns table (id uuid, author_name text, body text, created_at timestamptz, mine boolean)
language sql stable security definer set search_path = '' as $$
  select x.id, x.author_name, x.body, x.created_at, x.author_hash = public.secret_hash(p_secret)
    from public.trip_messages x
   where x.trip_id = p_trip_id
     and public.valid_secret(p_secret)
     and (not x.shadow or x.author_hash = public.secret_hash(p_secret))
     and not exists (select 1 from public.user_blocks b
                      where b.blocker_hash = public.secret_hash(p_secret)
                        and b.blocked_hash = x.author_hash)
     and exists (select 1 from public.trip_members m
                  where m.trip_id = p_trip_id and m.member_hash = public.secret_hash(p_secret))
   order by x.created_at
   limit 300
$$;

create or replace function public.reviews_for(p_pond_id uuid, p_secret text default '')
returns table (author_name text, rating int, body text, created_at timestamptz,
               updated_at timestamptz, mine boolean)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  )
  select r.author_name, r.rating, r.body, r.created_at, r.updated_at,
         coalesce(r.author_hash = me.h, false)
    from public.pond_reviews r, me
   where r.pond_id = p_pond_id and not r.hidden
     and (not r.shadow or r.author_hash = me.h)
     and not exists (select 1 from public.user_blocks b
                      where b.blocker_hash = me.h and b.blocked_hash = r.author_hash)
   order by coalesce(r.updated_at, r.created_at) desc
   limit 100
$$;

-- Callable by the app like the other RPCs (same pattern as 0002–0004).
revoke all on function public.block_author(text, uuid, text, timestamptz) from public;
revoke all on function public.unblock_all(text) from public;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    grant execute on function public.block_author(text, uuid, text, timestamptz) to anon, authenticated;
    grant execute on function public.unblock_all(text) to anon, authenticated;
  end if;
end $$;
