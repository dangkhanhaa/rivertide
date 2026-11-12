-- Purpose: community fishing spots ("điểm câu cộng đồng"), no login needed.
-- Each device keeps a random secret; only its SHA-256 is stored, and editing
-- or deleting a spot needs that secret. Tables are not readable or writable
-- through the REST API directly: everything goes through the functions below,
-- which validate input. Reports from 3 devices hide a spot.
-- Task: P2-19

create extension if not exists postgis with schema extensions;
create extension if not exists pgcrypto with schema extensions;

create table if not exists public.public_spots (
  id uuid primary key default gen_random_uuid(),
  owner_hash text not null check (owner_hash ~ '^[0-9a-f]{64}$'),
  title text not null check (char_length(title) between 2 and 80),
  note text not null default '' check (char_length(note) <= 500),
  species text not null default '' check (char_length(species) <= 100),
  -- Vietnam incl. Hoàng Sa / Trường Sa (same box as the app).
  location extensions.geography(Point, 4326) not null
    check (
      extensions.st_y(location::extensions.geometry) between 7.5 and 23.6
      and extensions.st_x(location::extensions.geometry) between 102 and 118
    ),
  -- Storage paths in bucket spot-photos, "<uuid folder>/<file>.jpg", at most 3.
  photos text[] not null default '{}' check (cardinality(photos) <= 3),
  report_count int not null default 0 check (report_count >= 0),
  hidden boolean not null default false,
  created_at timestamptz not null default now()
);

comment on table public.public_spots is
  'Fishing spots users chose to make public; hidden after 3 reports (P2-19).';

create index if not exists public_spots_location_gix on public.public_spots using gist (location);
create index if not exists public_spots_owner_hash_idx on public.public_spots (owner_hash);
create index if not exists public_spots_created_at_idx on public.public_spots (created_at desc);

-- RLS on and no policies: anon/authenticated cannot touch the table directly.
alter table public.public_spots enable row level security;

create table if not exists public.spot_reports (
  spot_id uuid not null references public.public_spots (id) on delete cascade,
  reporter_hash text not null check (reporter_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  primary key (spot_id, reporter_hash)
);

comment on table public.spot_reports is 'One abuse report per device per spot (P2-19).';

alter table public.spot_reports enable row level security;

create or replace function public.secret_hash(secret text)
returns text language sql immutable set search_path = '' as $$
  select encode(extensions.digest(secret, 'sha256'), 'hex')
$$;

-- A device secret: 64 hex chars generated with a secure RNG on the device.
create or replace function public.valid_secret(secret text)
returns boolean language sql immutable set search_path = '' as $$
  select coalesce(secret ~ '^[0-9a-f]{64}$', false)
$$;

create or replace function public.publish_spot(
  title text, note text, species text, lat double precision, lon double precision,
  photos text[], owner_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  new_id uuid;
begin
  if not public.valid_secret(owner_secret) then
    raise exception 'invalid owner secret' using errcode = '22023';
  end if;
  if photos is not null and exists (
    select 1 from unnest(photos) p where p !~ '^[0-9a-f-]{36}/[0-9a-z_]{1,40}\.jpg$'
  ) then
    raise exception 'invalid photo path' using errcode = '22023';
  end if;
  insert into public.public_spots (owner_hash, title, note, species, location, photos)
  values (
    public.secret_hash(owner_secret), btrim(title), coalesce(note, ''), coalesce(species, ''),
    extensions.st_makepoint(lon, lat)::extensions.geography, coalesce(photos, '{}')
  )
  returning id into new_id;
  return new_id;
end $$;

create or replace function public.delete_spot(spot_id uuid, owner_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  if not public.valid_secret(owner_secret) then return false; end if;
  delete from public.public_spots s
   where s.id = spot_id and s.owner_hash = public.secret_hash(owner_secret);
  return found;
end $$;

-- False when this device already reported the spot.
create or replace function public.report_spot(spot_id uuid, reporter_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  if not public.valid_secret(reporter_secret) then
    raise exception 'invalid reporter secret' using errcode = '22023';
  end if;
  insert into public.spot_reports (spot_id, reporter_hash)
  values (spot_id, public.secret_hash(reporter_secret))
  on conflict do nothing;
  if not found then return false; end if;
  update public.public_spots
     set report_count = report_count + 1,
         hidden = (report_count + 1) >= 3
   where id = spot_id;
  return true;
end $$;

-- Visible spots near a point, nearest first; `mine` = posted by this device.
create or replace function public.nearby_spots(
  lat double precision, lon double precision, radius_km double precision default 30,
  owner_secret text default ''
)
returns table (
  id uuid, title text, note text, species text,
  lat double precision, lon double precision, photos text[],
  created_at timestamptz, distance_km double precision, mine boolean
)
language sql stable security definer set search_path = '' as $$
  select s.id, s.title, s.note, s.species,
         extensions.st_y(s.location::extensions.geometry),
         extensions.st_x(s.location::extensions.geometry),
         s.photos, s.created_at,
         extensions.st_distance(s.location, extensions.st_makepoint(lon, lat)::extensions.geography) / 1000,
         public.valid_secret(owner_secret) and s.owner_hash = public.secret_hash(owner_secret)
    from public.public_spots s
   where not s.hidden
     and extensions.st_dwithin(s.location, extensions.st_makepoint(lon, lat)::extensions.geography,
                               least(greatest(radius_km, 1), 100) * 1000)
   order by 9
   limit 100
$$;

revoke all on function public.publish_spot(text, text, text, double precision, double precision, text[], text) from public;
revoke all on function public.delete_spot(uuid, text) from public;
revoke all on function public.report_spot(uuid, text) from public;
revoke all on function public.nearby_spots(double precision, double precision, double precision, text) from public;
grant execute on function public.publish_spot(text, text, text, double precision, double precision, text[], text) to anon, authenticated;
grant execute on function public.delete_spot(uuid, text) to anon, authenticated;
grant execute on function public.report_spot(uuid, text) to anon, authenticated;
grant execute on function public.nearby_spots(double precision, double precision, double precision, text) to anon, authenticated;

-- Photos: public read; upload only into a uuid folder, ≤ 1 MB JPEG. Files of
-- deleted spots are left in place (no delete without a login).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('spot-photos', 'spot-photos', true, 1048576, array['image/jpeg'])
on conflict (id) do update
  set public = true, file_size_limit = 1048576, allowed_mime_types = array['image/jpeg'];

drop policy if exists "upload spot photos" on storage.objects;
create policy "upload spot photos" on storage.objects
  for insert to anon, authenticated
  with check (
    bucket_id = 'spot-photos'
    and name ~ '^[0-9a-f-]{36}/[0-9a-z_]{1,40}\.jpg$'
  );
