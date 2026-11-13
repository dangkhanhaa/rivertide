-- Purpose: community features for anglers, still without login (same device
-- secret as 0001; the server stores only its SHA-256):
--   P2-25 edit own spot, comments on spots (nobody can remove someone else's
--         comment; 3 reports hide it), spam limits on spots and comments
--   P2-26 "kèo câu": fishing trips others can join, members-only contact and chat
--   P2-27 "đang câu ở đây": short-lived check-ins, shown only as counts per
--         ~200 m cell (never a device's exact position or identity)
-- Tables have RLS on and no policies: the REST API cannot read or write them
-- directly; every action goes through the SECURITY DEFINER functions below.
-- Task: P2-25, P2-26, P2-27

-- ───────────────────────── helpers ─────────────────────────

-- Display names are optional, trimmed, ≤ 30 chars, no control characters.
create or replace function public.clean_name(p_name text)
returns text language sql immutable set search_path = '' as $$
  select left(btrim(regexp_replace(coalesce(p_name, ''), '[[:cntrl:]]', '', 'g')), 30)
$$;

create or replace function public.require_secret(p_secret text)
returns text language plpgsql immutable set search_path = '' as $$
begin
  if not public.valid_secret(p_secret) then
    raise exception 'invalid secret' using errcode = '22023';
  end if;
  return public.secret_hash(p_secret);
end $$;

-- ───────────────────────── P2-25 spots: edit + limits ─────────────────────────

alter table public.public_spots add column if not exists updated_at timestamptz;

-- Same signature as 0001: adds a limit of 10 new spots per device per day.
create or replace function public.publish_spot(
  title text, note text, species text, lat double precision, lon double precision,
  photos text[], owner_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  new_id uuid;
  h text := public.require_secret(owner_secret);
begin
  if (select count(*) from public.public_spots s
       where s.owner_hash = h and s.created_at > now() - interval '1 day') >= 10 then
    raise exception 'too many spots today' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  if photos is not null and exists (
    select 1 from unnest(photos) p where p !~ '^[0-9a-f-]{36}/[0-9a-z_]{1,40}\.jpg$'
  ) then
    raise exception 'invalid photo path' using errcode = '22023';
  end if;
  insert into public.public_spots (owner_hash, title, note, species, location, photos)
  values (
    h, btrim(title), coalesce(note, ''), coalesce(species, ''),
    extensions.st_makepoint(lon, lat)::extensions.geography, coalesce(photos, '{}')
  )
  returning id into new_id;
  return new_id;
end $$;

-- Owner only. Photos are the full new list (kept + newly uploaded paths).
create or replace function public.update_spot(
  p_spot_id uuid, p_title text, p_note text, p_species text, p_photos text[], p_owner_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_owner_secret);
begin
  if p_photos is not null and exists (
    select 1 from unnest(p_photos) p where p !~ '^[0-9a-f-]{36}/[0-9a-z_]{1,40}\.jpg$'
  ) then
    raise exception 'invalid photo path' using errcode = '22023';
  end if;
  update public.public_spots s
     set title = btrim(p_title),
         note = coalesce(p_note, ''),
         species = coalesce(p_species, ''),
         photos = coalesce(p_photos, '{}'),
         updated_at = now()
   where s.id = p_spot_id and s.owner_hash = h;
  return found;
end $$;

create table if not exists public.spot_comments (
  id uuid primary key default gen_random_uuid(),
  spot_id uuid not null references public.public_spots (id) on delete cascade,
  author_hash text not null check (author_hash ~ '^[0-9a-f]{64}$'),
  author_name text not null default '' check (char_length(author_name) <= 30),
  body text not null check (char_length(body) between 1 and 300),
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  report_count int not null default 0 check (report_count >= 0),
  hidden boolean not null default false
);

comment on table public.spot_comments is
  'Comments on community spots; only the author edits/deletes; 3 reports hide (P2-25).';

create index if not exists spot_comments_spot_idx on public.spot_comments (spot_id, created_at desc);
create index if not exists spot_comments_author_idx on public.spot_comments (author_hash, created_at desc);
alter table public.spot_comments enable row level security;

create table if not exists public.comment_reports (
  comment_id uuid not null references public.spot_comments (id) on delete cascade,
  reporter_hash text not null check (reporter_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  primary key (comment_id, reporter_hash)
);
alter table public.comment_reports enable row level security;

-- Shared spam limit for short texts (comments, trip chat): one per 15 s,
-- 30 per day per device and table.
create or replace function public.check_text_rate(p_last timestamptz, p_today bigint)
returns void language plpgsql stable set search_path = '' as $$
begin
  if p_last is not null and p_last > now() - interval '15 seconds' then
    raise exception 'too fast' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  if p_today >= 30 then
    raise exception 'too many today' using errcode = 'P0001', hint = 'rate_limit';
  end if;
end $$;

create or replace function public.clean_body(p_body text)
returns text language plpgsql immutable set search_path = '' as $$
declare
  b text := btrim(regexp_replace(coalesce(p_body, ''), '[\x01-\x09\x0B-\x1F\x7F]', '', 'g'));
begin
  if char_length(b) < 1 or char_length(b) > 300 then
    raise exception 'invalid text length' using errcode = '22023';
  end if;
  return b;
end $$;

create or replace function public.add_comment(
  p_spot_id uuid, p_body text, p_author_name text, p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  b text := public.clean_body(p_body);
  new_id uuid;
begin
  if not exists (select 1 from public.public_spots s where s.id = p_spot_id and not s.hidden) then
    raise exception 'spot not found' using errcode = 'P0002';
  end if;
  perform public.check_text_rate(
    (select max(c.created_at) from public.spot_comments c where c.author_hash = h),
    (select count(*) from public.spot_comments c
      where c.author_hash = h and c.created_at > now() - interval '1 day')
  );
  insert into public.spot_comments (spot_id, author_hash, author_name, body)
  values (p_spot_id, h, public.clean_name(p_author_name), b)
  returning id into new_id;
  return new_id;
end $$;

create or replace function public.edit_comment(p_comment_id uuid, p_body text, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  update public.spot_comments c
     set body = public.clean_body(p_body), updated_at = now()
   where c.id = p_comment_id and c.author_hash = h;
  return found;
end $$;

-- Only the author: nobody, not even the spot owner, removes someone else's comment.
create or replace function public.delete_comment(p_comment_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  delete from public.spot_comments c where c.id = p_comment_id and c.author_hash = h;
  return found;
end $$;

-- False when this device already reported it (or it is its own comment).
create or replace function public.report_comment(p_comment_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  if exists (select 1 from public.spot_comments c where c.id = p_comment_id and c.author_hash = h) then
    return false;
  end if;
  insert into public.comment_reports (comment_id, reporter_hash)
  select p_comment_id, h where exists (select 1 from public.spot_comments c where c.id = p_comment_id)
  on conflict do nothing;
  if not found then return false; end if;
  update public.spot_comments c
     set report_count = c.report_count + 1, hidden = (c.report_count + 1) >= 3
   where c.id = p_comment_id;
  return true;
end $$;

create or replace function public.list_comments(p_spot_id uuid, p_secret text default '')
returns table (
  id uuid, author_name text, body text, created_at timestamptz, updated_at timestamptz, mine boolean
)
language sql stable security definer set search_path = '' as $$
  select c.id, c.author_name, c.body, c.created_at, c.updated_at,
         public.valid_secret(p_secret) and c.author_hash = public.secret_hash(p_secret)
    from public.spot_comments c
   where c.spot_id = p_spot_id and not c.hidden
   order by c.created_at desc
   limit 200
$$;

-- 0001's nearby_spots plus comment count and last edit (return type changes).
drop function if exists public.nearby_spots(double precision, double precision, double precision, text);
create function public.nearby_spots(
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
  select s.id, s.title, s.note, s.species,
         extensions.st_y(s.location::extensions.geometry),
         extensions.st_x(s.location::extensions.geometry),
         s.photos, s.created_at,
         extensions.st_distance(s.location, extensions.st_makepoint(lon, lat)::extensions.geography) / 1000,
         public.valid_secret(owner_secret) and s.owner_hash = public.secret_hash(owner_secret),
         s.updated_at,
         (select count(*) from public.spot_comments c where c.spot_id = s.id and not c.hidden)
    from public.public_spots s
   where not s.hidden
     and extensions.st_dwithin(s.location, extensions.st_makepoint(lon, lat)::extensions.geography,
                               least(greatest(radius_km, 1), 100) * 1000)
   order by 9
   limit 100
$$;

-- ───────────────────────── P2-26 trips ("kèo câu") ─────────────────────────

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  owner_hash text not null check (owner_hash ~ '^[0-9a-f]{64}$'),
  owner_name text not null default '' check (char_length(owner_name) <= 30),
  title text not null check (char_length(title) between 2 and 80),
  note text not null default '' check (char_length(note) <= 500),
  place_name text not null default '' check (char_length(place_name) <= 80),
  location extensions.geography(Point, 4326) not null
    check (
      extensions.st_y(location::extensions.geometry) between 7.5 and 23.6
      and extensions.st_x(location::extensions.geometry) between 102 and 118
    ),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  max_people int not null check (max_people between 2 and 30),
  -- Zalo/Facebook link or phone: shown only to the owner and members.
  contact text not null default '' check (char_length(contact) <= 120),
  cancelled boolean not null default false,
  report_count int not null default 0 check (report_count >= 0),
  hidden boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  check (ends_at > starts_at and ends_at <= starts_at + interval '24 hours')
);

comment on table public.trips is 'Fishing trips others can join (P2-26).';
create index if not exists trips_location_gix on public.trips using gist (location);
create index if not exists trips_ends_idx on public.trips (ends_at);
create index if not exists trips_owner_idx on public.trips (owner_hash, created_at desc);
alter table public.trips enable row level security;

create table if not exists public.trip_members (
  trip_id uuid not null references public.trips (id) on delete cascade,
  member_hash text not null check (member_hash ~ '^[0-9a-f]{64}$'),
  member_name text not null default '' check (char_length(member_name) <= 30),
  joined_at timestamptz not null default now(),
  primary key (trip_id, member_hash)
);
alter table public.trip_members enable row level security;

create table if not exists public.trip_messages (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips (id) on delete cascade,
  author_hash text not null check (author_hash ~ '^[0-9a-f]{64}$'),
  author_name text not null default '' check (char_length(author_name) <= 30),
  body text not null check (char_length(body) between 1 and 300),
  created_at timestamptz not null default now()
);
create index if not exists trip_messages_trip_idx on public.trip_messages (trip_id, created_at);
create index if not exists trip_messages_author_idx on public.trip_messages (author_hash, created_at desc);
alter table public.trip_messages enable row level security;

create table if not exists public.trip_reports (
  trip_id uuid not null references public.trips (id) on delete cascade,
  reporter_hash text not null check (reporter_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  primary key (trip_id, reporter_hash)
);
alter table public.trip_reports enable row level security;

create or replace function public.check_trip_input(
  p_title text, p_starts timestamptz, p_ends timestamptz, p_max int
) returns void language plpgsql stable set search_path = '' as $$
begin
  if char_length(btrim(coalesce(p_title, ''))) not between 2 and 80 then
    raise exception 'invalid title' using errcode = '22023';
  end if;
  if p_starts is null or p_ends is null or p_starts < now() - interval '1 hour'
     or p_starts > now() + interval '30 days'
     or p_ends <= p_starts or p_ends > p_starts + interval '24 hours' then
    raise exception 'invalid time' using errcode = '22023';
  end if;
  if p_max is null or p_max not between 2 and 30 then
    raise exception 'invalid size' using errcode = '22023';
  end if;
end $$;

create or replace function public.create_trip(
  p_title text, p_note text, p_place_name text, p_lat double precision, p_lon double precision,
  p_starts_at timestamptz, p_ends_at timestamptz, p_max_people int, p_contact text,
  p_owner_name text, p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  new_id uuid;
begin
  perform public.check_trip_input(p_title, p_starts_at, p_ends_at, p_max_people);
  if (select count(*) from public.trips t
       where t.owner_hash = h and t.created_at > now() - interval '1 day') >= 5 then
    raise exception 'too many trips today' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  insert into public.trips (owner_hash, owner_name, title, note, place_name, location,
                            starts_at, ends_at, max_people, contact)
  values (h, public.clean_name(p_owner_name), btrim(p_title), left(coalesce(p_note, ''), 500),
          left(btrim(coalesce(p_place_name, '')), 80),
          extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
          p_starts_at, p_ends_at, p_max_people, left(btrim(coalesce(p_contact, '')), 120))
  returning id into new_id;
  -- The owner is the first member.
  insert into public.trip_members (trip_id, member_hash, member_name)
  values (new_id, h, public.clean_name(p_owner_name));
  return new_id;
end $$;

create or replace function public.update_trip(
  p_trip_id uuid, p_title text, p_note text, p_starts_at timestamptz, p_ends_at timestamptz,
  p_max_people int, p_contact text, p_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  members int;
begin
  perform public.check_trip_input(p_title, p_starts_at, p_ends_at, p_max_people);
  select count(*) into members from public.trip_members m where m.trip_id = p_trip_id;
  if p_max_people < members then
    raise exception 'fewer places than members' using errcode = '22023';
  end if;
  update public.trips t
     set title = btrim(p_title), note = left(coalesce(p_note, ''), 500),
         starts_at = p_starts_at, ends_at = p_ends_at, max_people = p_max_people,
         contact = left(btrim(coalesce(p_contact, '')), 120), updated_at = now()
   where t.id = p_trip_id and t.owner_hash = h and not t.cancelled;
  return found;
end $$;

create or replace function public.cancel_trip(p_trip_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  update public.trips t set cancelled = true, updated_at = now()
   where t.id = p_trip_id and t.owner_hash = h and not t.cancelled;
  return found;
end $$;

-- 'joined' | 'already' | 'full' | 'closed' (ended, cancelled, hidden or missing).
create or replace function public.join_trip(p_trip_id uuid, p_name text, p_secret text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  t public.trips%rowtype;
  members int;
begin
  select * into t from public.trips x where x.id = p_trip_id for update;
  if not found or t.cancelled or t.hidden or t.ends_at <= now() then return 'closed'; end if;
  if exists (select 1 from public.trip_members m where m.trip_id = p_trip_id and m.member_hash = h) then
    return 'already';
  end if;
  select count(*) into members from public.trip_members m where m.trip_id = p_trip_id;
  if members >= t.max_people then return 'full'; end if;
  insert into public.trip_members (trip_id, member_hash, member_name)
  values (p_trip_id, h, public.clean_name(p_name));
  return 'joined';
end $$;

-- The owner cannot leave (cancel instead).
create or replace function public.leave_trip(p_trip_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  delete from public.trip_members m
   where m.trip_id = p_trip_id and m.member_hash = h
     and not exists (select 1 from public.trips t where t.id = p_trip_id and t.owner_hash = h);
  return found;
end $$;

create or replace function public.report_trip(p_trip_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  if exists (select 1 from public.trips t where t.id = p_trip_id and t.owner_hash = h) then
    return false;
  end if;
  insert into public.trip_reports (trip_id, reporter_hash)
  select p_trip_id, h where exists (select 1 from public.trips t where t.id = p_trip_id)
  on conflict do nothing;
  if not found then return false; end if;
  update public.trips t
     set report_count = t.report_count + 1, hidden = (t.report_count + 1) >= 3
   where t.id = p_trip_id;
  return true;
end $$;

-- Upcoming and running trips near a point, soonest first. Cancelled trips
-- stay listed for their owner and members (to see "Đã hủy"), not for others.
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
     and t.ends_at > now()
     and (not t.cancelled
          or exists (select 1 from public.trip_members m where m.trip_id = t.id and m.member_hash = me.h))
     and extensions.st_dwithin(t.location, extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
                               least(greatest(p_radius_km, 1), 100) * 1000)
   order by t.starts_at
   limit 100
$$;

-- Contact and member names: owner and members only (empty for others).
create or replace function public.trip_private(p_trip_id uuid, p_secret text)
returns table (contact text, member_names text[])
language sql stable security definer set search_path = '' as $$
  select t.contact,
         array(select m.member_name from public.trip_members m
                where m.trip_id = t.id order by m.joined_at)
    from public.trips t
   where t.id = p_trip_id
     and public.valid_secret(p_secret)
     and exists (select 1 from public.trip_members m
                  where m.trip_id = t.id and m.member_hash = public.secret_hash(p_secret))
$$;

create or replace function public.post_trip_message(
  p_trip_id uuid, p_body text, p_name text, p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  b text := public.clean_body(p_body);
  new_id uuid;
begin
  if not exists (select 1 from public.trip_members m where m.trip_id = p_trip_id and m.member_hash = h) then
    raise exception 'not a member' using errcode = '42501';
  end if;
  perform public.check_text_rate(
    (select max(x.created_at) from public.trip_messages x where x.author_hash = h),
    (select count(*) from public.trip_messages x
      where x.author_hash = h and x.created_at > now() - interval '1 day')
  );
  insert into public.trip_messages (trip_id, author_hash, author_name, body)
  values (p_trip_id, h, public.clean_name(p_name), b)
  returning id into new_id;
  return new_id;
end $$;

-- Members only; oldest first (a chat).
create or replace function public.trip_messages_for(p_trip_id uuid, p_secret text)
returns table (id uuid, author_name text, body text, created_at timestamptz, mine boolean)
language sql stable security definer set search_path = '' as $$
  select x.id, x.author_name, x.body, x.created_at, x.author_hash = public.secret_hash(p_secret)
    from public.trip_messages x
   where x.trip_id = p_trip_id
     and public.valid_secret(p_secret)
     and exists (select 1 from public.trip_members m
                  where m.trip_id = p_trip_id and m.member_hash = public.secret_hash(p_secret))
   order by x.created_at
   limit 300
$$;

-- ───────────────────────── P2-27 check-ins ("đang câu ở đây") ─────────────────────────

create table if not exists public.checkins (
  owner_hash text primary key check (owner_hash ~ '^[0-9a-f]{64}$'),
  -- Snapped to a ~200 m grid before storing: the exact position never reaches the server.
  cell_lat double precision not null check (cell_lat between 7.5 and 23.6),
  cell_lon double precision not null check (cell_lon between 102 and 118),
  biting boolean,
  started_at timestamptz not null default now(),
  expires_at timestamptz not null
);
create index if not exists checkins_cell_idx on public.checkins (cell_lat, cell_lon);
alter table public.checkins enable row level security;

-- One active check-in per device; 4 hours, renewed when updated.
create or replace function public.check_in(
  p_lat double precision, p_lon double precision, p_biting boolean, p_secret text
) returns timestamptz
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  la double precision := round((p_lat / 0.002)::numeric) * 0.002;
  lo double precision := round((p_lon / 0.002)::numeric) * 0.002;
  until_at timestamptz := now() + interval '4 hours';
begin
  if p_lat is null or p_lon is null or la not between 7.5 and 23.6 or lo not between 102 and 118 then
    raise exception 'outside Vietnam' using errcode = '22023';
  end if;
  insert into public.checkins as c (owner_hash, cell_lat, cell_lon, biting, started_at, expires_at)
  values (h, la, lo, p_biting, now(), until_at)
  on conflict (owner_hash) do update
     set cell_lat = excluded.cell_lat, cell_lon = excluded.cell_lon,
         biting = excluded.biting, expires_at = excluded.expires_at,
         started_at = case when c.expires_at > now() then c.started_at else now() end;
  return until_at;
end $$;

create or replace function public.check_out(p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  delete from public.checkins c where c.owner_hash = h;
  return found;
end $$;

-- Counts per cell, never identities. `mine` = this device is in that cell.
create or replace function public.nearby_checkins(
  p_lat double precision, p_lon double precision, p_radius_km double precision default 30,
  p_secret text default ''
)
returns table (
  lat double precision, lon double precision, people bigint, biting bigint,
  latest timestamptz, mine boolean, my_expires_at timestamptz
)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  )
  select c.cell_lat, c.cell_lon, count(*), count(*) filter (where c.biting),
         max(c.started_at), bool_or(c.owner_hash = me.h),
         max(c.expires_at) filter (where c.owner_hash = me.h)
    from public.checkins c, me
   where c.expires_at > now()
     and extensions.st_dwithin(
           extensions.st_makepoint(c.cell_lon, c.cell_lat)::extensions.geography,
           extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
           least(greatest(p_radius_km, 1), 100) * 1000)
   group by c.cell_lat, c.cell_lon
   order by 3 desc
   limit 200
$$;

-- ───────────────────────── grants ─────────────────────────

do $$
declare
  f text;
begin
  foreach f in array array[
    'public.update_spot(uuid, text, text, text, text[], text)',
    'public.add_comment(uuid, text, text, text)',
    'public.edit_comment(uuid, text, text)',
    'public.delete_comment(uuid, text)',
    'public.report_comment(uuid, text)',
    'public.list_comments(uuid, text)',
    'public.nearby_spots(double precision, double precision, double precision, text)',
    'public.create_trip(text, text, text, double precision, double precision, timestamptz, timestamptz, int, text, text, text)',
    'public.update_trip(uuid, text, text, timestamptz, timestamptz, int, text, text)',
    'public.cancel_trip(uuid, text)',
    'public.join_trip(uuid, text, text)',
    'public.leave_trip(uuid, text)',
    'public.report_trip(uuid, text)',
    'public.nearby_trips(double precision, double precision, double precision, text)',
    'public.trip_private(uuid, text)',
    'public.post_trip_message(uuid, text, text, text)',
    'public.trip_messages_for(uuid, text)',
    'public.check_in(double precision, double precision, boolean, text)',
    'public.check_out(text)',
    'public.nearby_checkins(double precision, double precision, double precision, text)'
  ] loop
    execute format('revoke all on function %s from public', f);
    execute format('grant execute on function %s to anon, authenticated', f);
  end loop;
  -- Internal helpers: not callable through the API.
  foreach f in array array[
    'public.clean_name(text)', 'public.require_secret(text)', 'public.clean_body(text)',
    'public.check_text_rate(timestamptz, bigint)',
    'public.check_trip_input(text, timestamptz, timestamptz, int)'
  ] loop
    execute format('revoke all on function %s from public, anon, authenticated', f);
  end loop;
end $$;
