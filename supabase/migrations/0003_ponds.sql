-- Purpose: "Hồ câu dịch vụ" (P2-28): a directory of fishing ponds with release
-- ("xả cá") schedules. Same model as 0001/0002: no login, a device secret
-- (server keeps its SHA-256), RLS on with no policies, every action through
-- SECURITY DEFINER functions that validate input and limit spam.
--   * ponds come from a web-research seed (source 'seed'), anglers ('user')
--     or owners; 3 confirmations from different devices mark a pond verified
--   * an owner claims a pond; the project admin approves the claim in the
--     Supabase table editor (pond_claims.status = 'approved'), a trigger then
--     makes that device the owner
--   * releases posted by the owner are "official"; anglers may relay one they
--     saw (shown as "người dùng báo") until the owner posts
-- Task: P2-28

create table if not exists public.ponds (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 100),
  address text not null default '' check (char_length(address) <= 200),
  location extensions.geography(Point, 4326) not null
    check (
      extensions.st_y(location::extensions.geometry) between 7.5 and 23.6
      and extensions.st_x(location::extensions.geometry) between 102 and 118
    ),
  -- Position derived from the address only (seed): the UI asks for a fix.
  approx_location boolean not null default false,
  phone text not null default '' check (char_length(phone) <= 30),
  price_note text not null default '' check (char_length(price_note) <= 120),
  hours_note text not null default '' check (char_length(hours_note) <= 80),
  species text[] not null default '{}' check (cardinality(species) <= 12),
  note text not null default '' check (char_length(note) <= 500),
  photos text[] not null default '{}' check (cardinality(photos) <= 3),
  source text not null default 'user' check (source in ('seed', 'user')),
  source_urls text[] not null default '{}' check (cardinality(source_urls) <= 5),
  created_by_hash text check (created_by_hash ~ '^[0-9a-f]{64}$'),
  owner_hash text check (owner_hash ~ '^[0-9a-f]{64}$'),
  confirmations int not null default 0 check (confirmations >= 0),
  report_count int not null default 0 check (report_count >= 0),
  hidden boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);
comment on table public.ponds is 'Fishing ponds (hồ câu dịch vụ), P2-28.';
create index if not exists ponds_location_gix on public.ponds using gist (location);
create index if not exists ponds_creator_idx on public.ponds (created_by_hash, created_at desc);
alter table public.ponds enable row level security;

create table if not exists public.pond_confirms (
  pond_id uuid not null references public.ponds (id) on delete cascade,
  device_hash text not null check (device_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  primary key (pond_id, device_hash)
);
alter table public.pond_confirms enable row level security;

create table if not exists public.pond_reports (
  pond_id uuid not null references public.ponds (id) on delete cascade,
  device_hash text not null check (device_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  primary key (pond_id, device_hash)
);
alter table public.pond_reports enable row level security;

-- Who changed what (wiki-style edits stay accountable).
create table if not exists public.pond_edits (
  id bigint generated always as identity primary key,
  pond_id uuid not null references public.ponds (id) on delete cascade,
  editor_hash text not null check (editor_hash ~ '^[0-9a-f]{64}$'),
  before jsonb not null,
  created_at timestamptz not null default now()
);
create index if not exists pond_edits_editor_idx on public.pond_edits (editor_hash, created_at desc);
alter table public.pond_edits enable row level security;

create table if not exists public.pond_releases (
  id uuid primary key default gen_random_uuid(),
  pond_id uuid not null references public.ponds (id) on delete cascade,
  starts_at timestamptz not null,
  -- [{"species": "Chép", "kg": 500}, …]; kg may be null.
  fish jsonb not null default '[]'::jsonb check (jsonb_typeof(fish) = 'array' and jsonb_array_length(fish) <= 10),
  total_kg int check (total_kg between 0 and 100000),
  note text not null default '' check (char_length(note) <= 300),
  -- The owner's original post, kept so anyone can check the parsed numbers.
  source_text text not null default '' check (char_length(source_text) <= 1000),
  created_by_hash text not null check (created_by_hash ~ '^[0-9a-f]{64}$'),
  by_owner boolean not null default false,
  cancelled boolean not null default false,
  report_count int not null default 0 check (report_count >= 0),
  created_at timestamptz not null default now()
);
create index if not exists pond_releases_pond_idx on public.pond_releases (pond_id, starts_at);
create index if not exists pond_releases_creator_idx on public.pond_releases (created_by_hash, created_at desc);
alter table public.pond_releases enable row level security;

create table if not exists public.pond_reviews (
  pond_id uuid not null references public.ponds (id) on delete cascade,
  author_hash text not null check (author_hash ~ '^[0-9a-f]{64}$'),
  author_name text not null default '' check (char_length(author_name) <= 30),
  rating int not null check (rating between 1 and 5),
  body text not null default '' check (char_length(body) <= 300),
  report_count int not null default 0 check (report_count >= 0),
  hidden boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  primary key (pond_id, author_hash)
);
alter table public.pond_reviews enable row level security;

-- Quick on-site reports: busy / quiet / biting / just released.
create table if not exists public.pond_pulses (
  id bigint generated always as identity primary key,
  pond_id uuid not null references public.ponds (id) on delete cascade,
  device_hash text not null check (device_hash ~ '^[0-9a-f]{64}$'),
  kind text not null check (kind in ('busy', 'quiet', 'biting', 'released')),
  created_at timestamptz not null default now()
);
create index if not exists pond_pulses_pond_idx on public.pond_pulses (pond_id, created_at desc);
alter table public.pond_pulses enable row level security;

create table if not exists public.pond_claims (
  id uuid primary key default gen_random_uuid(),
  pond_id uuid not null references public.ponds (id) on delete cascade,
  claimant_hash text not null check (claimant_hash ~ '^[0-9a-f]{64}$'),
  -- Phone / Zalo the admin calls to verify; never returned by any function.
  contact text not null check (char_length(contact) between 6 and 60),
  note text not null default '' check (char_length(note) <= 300),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  decided_at timestamptz
);
create index if not exists pond_claims_status_idx on public.pond_claims (status, created_at);
alter table public.pond_claims enable row level security;

-- ───────────────────────── helpers ─────────────────────────

create or replace function public.clean_short(p_text text, p_max int)
returns text language sql immutable set search_path = '' as $$
  select left(btrim(regexp_replace(coalesce(p_text, ''), '[[:cntrl:]]', ' ', 'g')), p_max)
$$;

create or replace function public.clean_species(p_species text[])
returns text[] language sql immutable set search_path = '' as $$
  select coalesce(array(
    select distinct left(btrim(s), 30) from unnest(coalesce(p_species, '{}')) s
     where char_length(btrim(s)) between 1 and 30 limit 12), '{}')
$$;

create or replace function public.check_photos(p_photos text[])
returns void language plpgsql immutable set search_path = '' as $$
begin
  if p_photos is not null and (cardinality(p_photos) > 3 or exists (
    select 1 from unnest(p_photos) p where p !~ '^[0-9a-f-]{36}/[0-9a-z_]{1,40}\.jpg$'
  )) then
    raise exception 'invalid photo path' using errcode = '22023';
  end if;
end $$;

create or replace function public.pond_snapshot(p public.ponds)
returns jsonb language sql immutable set search_path = '' as $$
  select jsonb_build_object('name', p.name, 'address', p.address, 'phone', p.phone,
    'price', p.price_note, 'hours', p.hours_note, 'species', p.species, 'note', p.note,
    'lat', extensions.st_y(p.location::extensions.geometry),
    'lon', extensions.st_x(p.location::extensions.geometry), 'photos', p.photos)
$$;

-- ───────────────────────── ponds ─────────────────────────

create or replace function public.add_pond(
  p_name text, p_address text, p_lat double precision, p_lon double precision, p_phone text,
  p_price text, p_hours text, p_species text[], p_note text, p_photos text[], p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  pt extensions.geography := extensions.st_makepoint(p_lon, p_lat)::extensions.geography;
  near_id uuid;
  new_id uuid;
begin
  if char_length(btrim(coalesce(p_name, ''))) < 2 then
    raise exception 'invalid name' using errcode = '22023';
  end if;
  perform public.check_photos(p_photos);
  if (select count(*) from public.ponds x
       where x.created_by_hash = h and x.created_at > now() - interval '1 day') >= 5 then
    raise exception 'too many ponds today' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  -- Same place already listed: point the user to it instead of a duplicate.
  select x.id into near_id from public.ponds x
   where not x.hidden and extensions.st_dwithin(x.location, pt, 80) limit 1;
  if near_id is not null then
    raise exception 'pond exists' using errcode = 'P0001', hint = 'duplicate', detail = near_id::text;
  end if;
  insert into public.ponds (name, address, location, phone, price_note, hours_note, species,
                            note, photos, source, created_by_hash)
  values (public.clean_short(p_name, 100), public.clean_short(p_address, 200), pt,
          public.clean_short(p_phone, 30), public.clean_short(p_price, 120),
          public.clean_short(p_hours, 80), public.clean_species(p_species),
          left(coalesce(p_note, ''), 500), coalesce(p_photos, '{}'), 'user', h)
  returning id into new_id;
  -- The person who adds it vouches for it.
  insert into public.pond_confirms (pond_id, device_hash) values (new_id, h);
  update public.ponds set confirmations = 1 where id = new_id;
  return new_id;
end $$;

-- Anyone may correct a pond nobody owns (logged in pond_edits); once an owner
-- is approved only the owner edits. 20 edits per device per day.
create or replace function public.update_pond(
  p_pond_id uuid, p_name text, p_address text, p_lat double precision, p_lon double precision,
  p_phone text, p_price text, p_hours text, p_species text[], p_note text, p_photos text[],
  p_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  p public.ponds%rowtype;
begin
  if char_length(btrim(coalesce(p_name, ''))) < 2 then
    raise exception 'invalid name' using errcode = '22023';
  end if;
  perform public.check_photos(p_photos);
  select * into p from public.ponds x where x.id = p_pond_id and not x.hidden for update;
  if not found then return false; end if;
  if p.owner_hash is not null and p.owner_hash <> h then return false; end if;
  if (select count(*) from public.pond_edits e
       where e.editor_hash = h and e.created_at > now() - interval '1 day') >= 20 then
    raise exception 'too many edits today' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  insert into public.pond_edits (pond_id, editor_hash, before) values (p.id, h, public.pond_snapshot(p));
  update public.ponds x
     set name = public.clean_short(p_name, 100), address = public.clean_short(p_address, 200),
         location = extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
         approx_location = x.approx_location
           and extensions.st_distance(x.location, extensions.st_makepoint(p_lon, p_lat)::extensions.geography) < 1,
         phone = public.clean_short(p_phone, 30), price_note = public.clean_short(p_price, 120),
         hours_note = public.clean_short(p_hours, 80), species = public.clean_species(p_species),
         note = left(coalesce(p_note, ''), 500), photos = coalesce(p_photos, '{}'), updated_at = now()
   where x.id = p_pond_id;
  return true;
end $$;

-- False when already confirmed from this device. 3 devices → verified.
create or replace function public.confirm_pond(p_pond_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  insert into public.pond_confirms (pond_id, device_hash)
  select p_pond_id, h where exists (select 1 from public.ponds x where x.id = p_pond_id)
  on conflict do nothing;
  if not found then return false; end if;
  update public.ponds x set confirmations = x.confirmations + 1 where x.id = p_pond_id;
  return true;
end $$;

create or replace function public.report_pond(p_pond_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  if exists (select 1 from public.ponds x where x.id = p_pond_id and x.owner_hash = h) then
    return false;
  end if;
  insert into public.pond_reports (pond_id, device_hash)
  select p_pond_id, h where exists (select 1 from public.ponds x where x.id = p_pond_id)
  on conflict do nothing;
  if not found then return false; end if;
  -- An owned pond is only hidden by the admin; others after 3 reports.
  update public.ponds x
     set report_count = x.report_count + 1,
         hidden = x.owner_hash is null and (x.report_count + 1) >= 3
   where x.id = p_pond_id;
  return true;
end $$;

-- Ponds near a point with what the list and map need, nearest first.
create or replace function public.nearby_ponds(
  p_lat double precision, p_lon double precision, p_radius_km double precision default 30,
  p_secret text default ''
)
returns table (
  id uuid, name text, address text, lat double precision, lon double precision,
  approx_location boolean, phone text, price_note text, hours_note text, species text[],
  note text, photos text[], source text, source_urls text[], verified boolean,
  has_owner boolean, mine_owner boolean, confirmed_by_me boolean, confirmations int,
  rating numeric, review_count bigint, next_release_at timestamptz, next_release_kg int,
  next_release_by_owner boolean, distance_km double precision, updated_at timestamptz
)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  ),
  here as (select extensions.st_makepoint(p_lon, p_lat)::extensions.geography as g)
  select p.id, p.name, p.address,
         extensions.st_y(p.location::extensions.geometry),
         extensions.st_x(p.location::extensions.geometry),
         p.approx_location, p.phone, p.price_note, p.hours_note, p.species, p.note, p.photos,
         p.source, p.source_urls,
         p.owner_hash is not null or p.confirmations >= 3,
         p.owner_hash is not null,
         coalesce(p.owner_hash = me.h, false),
         exists (select 1 from public.pond_confirms c where c.pond_id = p.id and c.device_hash = me.h),
         p.confirmations,
         (select round(avg(r.rating)::numeric, 1) from public.pond_reviews r
           where r.pond_id = p.id and not r.hidden),
         (select count(*) from public.pond_reviews r where r.pond_id = p.id and not r.hidden),
         nr.starts_at, nr.total_kg, nr.by_owner,
         extensions.st_distance(p.location, here.g) / 1000,
         p.updated_at
    from public.ponds p
   cross join me
   cross join here
    left join lateral (
      select r.starts_at, r.total_kg, r.by_owner from public.pond_releases r
       where r.pond_id = p.id and not r.cancelled and r.report_count < 3
         and r.starts_at > now() - interval '6 hours'
       order by r.by_owner desc, r.starts_at limit 1
    ) nr on true
   where not p.hidden
     and extensions.st_dwithin(p.location, here.g, least(greatest(p_radius_km, 1), 150) * 1000)
   order by 25
   limit 300
$$;

-- ───────────────────────── releases ("xả cá") ─────────────────────────

create or replace function public.post_release(
  p_pond_id uuid, p_starts_at timestamptz, p_fish jsonb, p_note text, p_source_text text,
  p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  v_owner boolean;
  fish jsonb;
  total int;
  new_id uuid;
begin
  select coalesce(x.owner_hash = h, false) into v_owner
    from public.ponds x where x.id = p_pond_id and not x.hidden;
  if not found then raise exception 'pond not found' using errcode = 'P0002'; end if;
  if p_starts_at is null or p_starts_at < now() - interval '1 day'
     or p_starts_at > now() + interval '60 days' then
    raise exception 'invalid time' using errcode = '22023';
  end if;
  if (select count(*) from public.pond_releases r
       where r.created_by_hash = h and r.created_at > now() - interval '1 day') >= 10 then
    raise exception 'too many releases today' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  -- Keep only well-formed entries: {"species": 1–30 chars, "kg": 0–100000 or null}.
  select coalesce(jsonb_agg(jsonb_build_object('species', left(btrim(e->>'species'), 30),
                                               'kg', round((e->>'kg')::numeric)::int)), '[]'::jsonb),
         sum(round((e->>'kg')::numeric)::int)
    into fish, total
    from (select e from jsonb_array_elements(
            case when jsonb_typeof(p_fish) = 'array' then p_fish else '[]'::jsonb end) e
          limit 10) x
   where jsonb_typeof(e) = 'object'
     and char_length(btrim(coalesce(e->>'species', ''))) between 1 and 30
     and (e->'kg' is null or jsonb_typeof(e->'kg') = 'null'
          or (jsonb_typeof(e->'kg') = 'number' and (e->>'kg')::numeric between 0 and 100000));
  insert into public.pond_releases (pond_id, starts_at, fish, total_kg, note, source_text,
                                    created_by_hash, by_owner)
  values (p_pond_id, p_starts_at, fish, total, left(coalesce(p_note, ''), 300),
          left(coalesce(p_source_text, ''), 1000), h, v_owner)
  returning id into new_id;
  return new_id;
end $$;

-- The poster or the pond owner.
create or replace function public.cancel_release(p_release_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  update public.pond_releases r set cancelled = true
   where r.id = p_release_id and not r.cancelled
     and (r.created_by_hash = h
          or exists (select 1 from public.ponds x where x.id = r.pond_id and x.owner_hash = h));
  return found;
end $$;

-- Anglers can flag a wrong relayed release; 3 flags hide it (owner posts excepted).
create or replace function public.report_release(p_release_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  update public.pond_releases r set report_count = r.report_count + 1
   where r.id = p_release_id and not r.by_owner and r.created_by_hash <> h;
  return found;
end $$;

-- Upcoming (and last 30 days of) releases of some ponds, soonest upcoming first.
create or replace function public.releases_for(p_pond_ids uuid[], p_secret text default '')
returns table (
  id uuid, pond_id uuid, starts_at timestamptz, fish jsonb, total_kg int, note text,
  source_text text, by_owner boolean, cancelled boolean, mine boolean, created_at timestamptz
)
language sql stable security definer set search_path = '' as $$
  select r.id, r.pond_id, r.starts_at, r.fish, r.total_kg, r.note, r.source_text, r.by_owner,
         r.cancelled,
         public.valid_secret(p_secret) and r.created_by_hash = public.secret_hash(p_secret),
         r.created_at
    from public.pond_releases r
   where r.pond_id = any (p_pond_ids[1:50])
     and r.report_count < 3
     and r.starts_at > now() - interval '30 days'
   order by (r.starts_at < now() - interval '6 hours'), r.starts_at
   limit 200
$$;

-- ───────────────────────── reviews and on-site pulses ─────────────────────────

create or replace function public.review_pond(
  p_pond_id uuid, p_rating int, p_body text, p_name text, p_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  if p_rating is null or p_rating not between 1 and 5 then
    raise exception 'invalid rating' using errcode = '22023';
  end if;
  if not exists (select 1 from public.ponds x where x.id = p_pond_id and not x.hidden) then
    return false;
  end if;
  insert into public.pond_reviews (pond_id, author_hash, author_name, rating, body)
  values (p_pond_id, h, public.clean_name(p_name), p_rating, left(btrim(coalesce(p_body, '')), 300))
  on conflict (pond_id, author_hash) do update
     set rating = excluded.rating, body = excluded.body, author_name = excluded.author_name,
         updated_at = now();
  return true;
end $$;

create or replace function public.delete_review(p_pond_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  delete from public.pond_reviews r where r.pond_id = p_pond_id and r.author_hash = h;
  return found;
end $$;

create or replace function public.reviews_for(p_pond_id uuid, p_secret text default '')
returns table (author_name text, rating int, body text, created_at timestamptz,
               updated_at timestamptz, mine boolean)
language sql stable security definer set search_path = '' as $$
  select r.author_name, r.rating, r.body, r.created_at, r.updated_at,
         public.valid_secret(p_secret) and r.author_hash = public.secret_hash(p_secret)
    from public.pond_reviews r
   where r.pond_id = p_pond_id and not r.hidden
   order by coalesce(r.updated_at, r.created_at) desc
   limit 100
$$;

-- One quick report per pond per device every 30 minutes.
create or replace function public.pulse_pond(p_pond_id uuid, p_kind text, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  if p_kind not in ('busy', 'quiet', 'biting', 'released') then
    raise exception 'invalid kind' using errcode = '22023';
  end if;
  if exists (select 1 from public.pond_pulses x where x.pond_id = p_pond_id and x.device_hash = h
              and x.created_at > now() - interval '30 minutes') then
    raise exception 'too fast' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  insert into public.pond_pulses (pond_id, device_hash, kind)
  select p_pond_id, h, p_kind where exists (select 1 from public.ponds x where x.id = p_pond_id);
  return found;
end $$;

-- Counts of the last 6 hours (no identities).
create or replace function public.pond_pulse(p_pond_id uuid)
returns table (kind text, people bigint, latest timestamptz)
language sql stable security definer set search_path = '' as $$
  select x.kind, count(distinct x.device_hash), max(x.created_at)
    from public.pond_pulses x
   where x.pond_id = p_pond_id and x.created_at > now() - interval '6 hours'
   group by x.kind
$$;

-- ───────────────────────── owner claims ─────────────────────────

-- 'sent' | 'pending' (already waiting) | 'owned' (already has an owner) | 'yours'.
create or replace function public.claim_pond(p_pond_id uuid, p_contact text, p_note text, p_secret text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  v_owner text;
begin
  select x.owner_hash into v_owner from public.ponds x where x.id = p_pond_id and not x.hidden;
  if not found then raise exception 'pond not found' using errcode = 'P0002'; end if;
  if v_owner = h then return 'yours'; end if;
  if v_owner is not null then return 'owned'; end if;
  if exists (select 1 from public.pond_claims c where c.pond_id = p_pond_id
              and c.claimant_hash = h and c.status = 'pending') then
    return 'pending';
  end if;
  if char_length(btrim(coalesce(p_contact, ''))) < 6 then
    raise exception 'invalid contact' using errcode = '22023';
  end if;
  if (select count(*) from public.pond_claims c where c.claimant_hash = h
       and c.created_at > now() - interval '1 day') >= 3 then
    raise exception 'too many claims today' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  insert into public.pond_claims (pond_id, claimant_hash, contact, note)
  values (p_pond_id, h, public.clean_short(p_contact, 60), public.clean_short(p_note, 300));
  return 'sent';
end $$;

-- The admin approves in the table editor; this makes the claimant the owner.
create or replace function public.apply_pond_claim()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.status = 'approved' and old.status is distinct from 'approved' then
    update public.ponds set owner_hash = new.claimant_hash, updated_at = now() where id = new.pond_id;
    update public.pond_claims set status = 'rejected', decided_at = now()
     where pond_id = new.pond_id and id <> new.id and status = 'pending';
  end if;
  if new.status <> old.status then new.decided_at := now(); end if;
  return new;
end $$;

drop trigger if exists pond_claim_decided on public.pond_claims;
create trigger pond_claim_decided before update of status on public.pond_claims
  for each row execute function public.apply_pond_claim();

-- ───────────────────────── grants ─────────────────────────

do $$
declare
  f text;
begin
  foreach f in array array[
    'public.add_pond(text, text, double precision, double precision, text, text, text, text[], text, text[], text)',
    'public.update_pond(uuid, text, text, double precision, double precision, text, text, text, text[], text, text[], text)',
    'public.confirm_pond(uuid, text)',
    'public.report_pond(uuid, text)',
    'public.nearby_ponds(double precision, double precision, double precision, text)',
    'public.post_release(uuid, timestamptz, jsonb, text, text, text)',
    'public.cancel_release(uuid, text)',
    'public.report_release(uuid, text)',
    'public.releases_for(uuid[], text)',
    'public.review_pond(uuid, int, text, text, text)',
    'public.delete_review(uuid, text)',
    'public.reviews_for(uuid, text)',
    'public.pulse_pond(uuid, text, text)',
    'public.pond_pulse(uuid)',
    'public.claim_pond(uuid, text, text, text)'
  ] loop
    execute format('revoke all on function %s from public', f);
    execute format('grant execute on function %s to anon, authenticated', f);
  end loop;
  foreach f in array array[
    'public.clean_short(text, int)', 'public.clean_species(text[])', 'public.check_photos(text[])',
    'public.pond_snapshot(public.ponds)', 'public.apply_pond_claim()'
  ] loop
    execute format('revoke all on function %s from public, anon, authenticated', f);
  end loop;
end $$;
