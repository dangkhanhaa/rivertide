-- Purpose: curated mode ("duyệt trước") for public community content, so the
-- app can run without phone-number verification (Decree 147/2024): new public
-- posts are held as 'pending' and shown only to their author until the
-- project owner approves them; rejected ones stay visible only to their
-- author (as "Không được duyệt").
--   * held: spots, spot comments, trips (listing), ponds added by users, pond
--     edits by users, releases, pond reviews
--   * not held: trip chat (members only), check-ins, bite reports, pulses,
--     confirmations, reports, blocks (private or anonymous counts)
--   * a verified pond owner (claim approved after a phone call) posts
--     releases and edits their pond without waiting
--   * existing rows count as approved
--   * an edit of approved content is kept in pending_edit (ponds: a pending
--     row in pond_edits); everyone else keeps seeing the approved version,
--     the author sees the edit
--   * public.curation switches holding on/off per kind
--   * my_pending(secret): the caller's pending / rejected items (app badges)
--   * mod_pending, mod_pending_summary, mod_approve, mod_reject,
--     mod_approve_all_from: owner only (SQL editor / service_role)
-- Every existing RPC keeps its exact signature and return type; 0006's
-- block filters are kept.
-- Task: P2-61

-- ───────────────────────── columns and settings ─────────────────────────

do $$
declare
  t text;
begin
  foreach t in array array['public_spots', 'spot_comments', 'trips', 'ponds', 'pond_releases',
                           'pond_reviews'] loop
    -- Default 'approved': existing rows and the owner's own seed imports stay
    -- public; the writing RPCs set 'pending' explicitly.
    execute format('alter table public.%I add column if not exists mod_status text not null'
                   ' default ''approved'' check (mod_status in (''pending'', ''approved'', ''rejected''))', t);
    execute format('alter table public.%I add column if not exists mod_note text not null'
                   ' default '''' check (char_length(mod_note) <= 300)', t);
    execute format('alter table public.%I add column if not exists mod_at timestamptz', t);
  end loop;
  foreach t in array array['public_spots', 'spot_comments', 'trips', 'pond_reviews'] loop
    -- The author's edit of approved content, waiting for review ({"at": …, fields…}).
    execute format('alter table public.%I add column if not exists pending_edit jsonb'
                   ' check (pending_edit is null or jsonb_typeof(pending_edit) = ''object'')', t);
    execute format('alter table public.%I add column if not exists edit_rejected_at timestamptz', t);
  end loop;
end $$;

-- pond_edits was an audit log (every row applied); it now also holds
-- proposals by people other than the verified owner.
alter table public.pond_edits add column if not exists proposed jsonb
  check (proposed is null or jsonb_typeof(proposed) = 'object');
alter table public.pond_edits add column if not exists status text not null default 'applied'
  check (status in ('applied', 'pending', 'rejected', 'superseded'));
alter table public.pond_edits add column if not exists mod_note text not null default ''
  check (char_length(mod_note) <= 300);
alter table public.pond_edits add column if not exists decided_at timestamptz;

create index if not exists public_spots_mod_idx on public.public_spots (created_at)
  where mod_status <> 'approved' or pending_edit is not null;
create index if not exists spot_comments_mod_idx on public.spot_comments (created_at)
  where mod_status <> 'approved' or pending_edit is not null;
create index if not exists trips_mod_idx on public.trips (created_at)
  where mod_status <> 'approved' or pending_edit is not null;
create index if not exists ponds_mod_idx on public.ponds (created_at) where mod_status <> 'approved';
create index if not exists pond_releases_mod_idx on public.pond_releases (created_at)
  where mod_status <> 'approved';
create index if not exists pond_reviews_mod_idx on public.pond_reviews (author_hash)
  where mod_status <> 'approved' or pending_edit is not null or edit_rejected_at is not null;
create index if not exists pond_edits_status_idx on public.pond_edits (status, created_at)
  where status <> 'applied';

create table if not exists public.curation (
  kind text primary key check (kind in ('spot', 'comment', 'trip', 'pond', 'release', 'review')),
  pre_moderate boolean not null default true,
  note text not null default ''
);
comment on table public.curation is 'Which kinds of public content wait for approval (P2-61).';
alter table public.curation enable row level security;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on table public.curation from anon, authenticated;
  end if;
end $$;
insert into public.curation (kind, note) values
  ('spot', 'publish_spot / update_spot'), ('comment', 'add_comment / edit_comment'),
  ('trip', 'create_trip / update_trip (title, note)'), ('pond', 'add_pond / update_pond'),
  ('release', 'post_release (not by the verified owner)'), ('review', 'review_pond')
on conflict (kind) do nothing;

-- True when new content of [p_kind] waits for approval (unknown kind: true).
create or replace function public.held(p_kind text)
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce((select c.pre_moderate from public.curation c where c.kind = p_kind), true)
$$;

create or replace function public.new_status(p_kind text)
returns text language sql stable security definer set search_path = '' as $$
  select case when public.held(p_kind) then 'pending' else 'approved' end
$$;

-- Status after the author changes an item in place: a rejected item is
-- submitted again, a pending one keeps waiting.
create or replace function public.resubmit_status(p_kind text, p_status text)
returns text language sql stable security definer set search_path = '' as $$
  select case when p_status = 'approved' then 'approved' else public.new_status(p_kind) end
$$;

-- ───────────────────────── spots and comments ─────────────────────────

create or replace function public.publish_spot(
  title text, note text, species text, lat double precision, lon double precision,
  photos text[], owner_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  new_id uuid;
  h text := public.require_secret(owner_secret);
  v_shadow boolean;
begin
  perform public.check_photos(photos);
  v_shadow := public.guard('spot', h,
    public.text_fingerprint(coalesce(title, '') || ' ' || coalesce(note, '')));
  perform public.check_content(title, 'title');
  perform public.check_content(note, 'text');
  perform public.check_content(species, 'title');
  insert into public.public_spots (owner_hash, title, note, species, location, photos, shadow, mod_status)
  values (
    h, btrim(title), coalesce(note, ''), coalesce(species, ''),
    extensions.st_makepoint(lon, lat)::extensions.geography, coalesce(photos, '{}'), v_shadow,
    public.new_status('spot')
  )
  returning id into new_id;
  return new_id;
end $$;

create or replace function public.update_spot(
  p_spot_id uuid, p_title text, p_note text, p_species text, p_photos text[], p_owner_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_owner_secret);
  s public.public_spots%rowtype;
  v_shadow boolean;
begin
  perform public.check_photos(p_photos);
  select * into s from public.public_spots x where x.id = p_spot_id and x.owner_hash = h for update;
  if not found then return false; end if;
  v_shadow := public.guard('spot_edit', h);
  perform public.check_content(p_title, 'title');
  perform public.check_content(p_note, 'text');
  perform public.check_content(p_species, 'title');
  if s.mod_status = 'approved' and public.held('spot') then
    -- Same limits as the table's checks (they do not apply inside jsonb).
    if char_length(btrim(coalesce(p_title, ''))) not between 2 and 80
       or char_length(coalesce(p_note, '')) > 500 or char_length(coalesce(p_species, '')) > 100 then
      raise exception 'invalid input' using errcode = '23514';
    end if;
    update public.public_spots x
       set pending_edit = jsonb_build_object('at', now(), 'title', btrim(p_title),
             'note', coalesce(p_note, ''), 'species', coalesce(p_species, ''),
             'photos', to_jsonb(coalesce(p_photos, '{}'::text[]))),
           edit_rejected_at = null, shadow = x.shadow or v_shadow
     where x.id = p_spot_id;
    return true;
  end if;
  update public.public_spots x
     set title = btrim(p_title), note = coalesce(p_note, ''), species = coalesce(p_species, ''),
         photos = coalesce(p_photos, '{}'), shadow = x.shadow or v_shadow, updated_at = now(),
         pending_edit = null, mod_status = public.resubmit_status('spot', x.mod_status)
   where x.id = p_spot_id;
  return true;
end $$;

create or replace function public.add_comment(
  p_spot_id uuid, p_body text, p_author_name text, p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  b text := public.clean_body(p_body);
  v_name text := public.clean_name(p_author_name);
  v_shadow boolean;
  new_id uuid;
begin
  if not exists (select 1 from public.public_spots s where s.id = p_spot_id and not s.hidden
                  and (not s.shadow or s.owner_hash = h)
                  and (s.mod_status = 'approved' or s.owner_hash = h)) then
    raise exception 'spot not found' using errcode = 'P0002';
  end if;
  v_shadow := public.guard('comment', h, public.text_fingerprint(b));
  perform public.check_content(b, 'text');
  perform public.check_content(v_name, 'name');
  insert into public.spot_comments (spot_id, author_hash, author_name, body, shadow, mod_status)
  values (p_spot_id, h, v_name, b, v_shadow, public.new_status('comment'))
  returning id into new_id;
  return new_id;
end $$;

create or replace function public.edit_comment(p_comment_id uuid, p_body text, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  b text := public.clean_body(p_body);
  c public.spot_comments%rowtype;
  v_shadow boolean;
begin
  select * into c from public.spot_comments x where x.id = p_comment_id and x.author_hash = h for update;
  if not found then return false; end if;
  v_shadow := public.guard('comment_edit', h);
  perform public.check_content(b, 'text');
  if c.mod_status = 'approved' and public.held('comment') then
    update public.spot_comments x
       set pending_edit = jsonb_build_object('at', now(), 'body', b), edit_rejected_at = null,
           shadow = x.shadow or v_shadow
     where x.id = p_comment_id;
    return true;
  end if;
  update public.spot_comments x
     set body = b, updated_at = now(), shadow = x.shadow or v_shadow, pending_edit = null,
         mod_status = public.resubmit_status('comment', x.mod_status)
   where x.id = p_comment_id;
  return true;
end $$;

-- Others see approved comments only; the author also sees their own pending
-- or rejected ones, with their pending edit.
create or replace function public.list_comments(p_spot_id uuid, p_secret text default '')
returns table (
  id uuid, author_name text, body text, created_at timestamptz, updated_at timestamptz, mine boolean
)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  )
  select c.id, c.author_name,
         coalesce(case when c.author_hash = me.h then c.pending_edit->>'body' end, c.body),
         c.created_at, c.updated_at,
         coalesce(c.author_hash = me.h, false)
    from public.spot_comments c, me
   where c.spot_id = p_spot_id and not c.hidden
     and (not c.shadow or c.author_hash = me.h)
     and (c.mod_status = 'approved' or c.author_hash = me.h)
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
  select s.id,
         coalesce(pe.e->>'title', s.title), coalesce(pe.e->>'note', s.note),
         coalesce(pe.e->>'species', s.species),
         extensions.st_y(s.location::extensions.geometry),
         extensions.st_x(s.location::extensions.geometry),
         case when pe.e is null then s.photos
              else array(select jsonb_array_elements_text(pe.e->'photos')) end,
         s.created_at,
         extensions.st_distance(s.location, extensions.st_makepoint(lon, lat)::extensions.geography) / 1000,
         coalesce(s.owner_hash = me.h, false),
         s.updated_at,
         (select count(*) from public.spot_comments c
           where c.spot_id = s.id and not c.hidden and (not c.shadow or c.author_hash = me.h)
             and (c.mod_status = 'approved' or c.author_hash = me.h)
             and not exists (select 1 from public.user_blocks b
                              where b.blocker_hash = me.h and b.blocked_hash = c.author_hash))
    from public.public_spots s
   cross join me
   cross join lateral (select case when s.owner_hash = me.h then s.pending_edit end as e) pe
   where not s.hidden
     and (not s.shadow or s.owner_hash = me.h)
     and (s.mod_status = 'approved' or s.owner_hash = me.h)
     and not exists (select 1 from public.user_blocks b
                      where b.blocker_hash = me.h and b.blocked_hash = s.owner_hash)
     and extensions.st_dwithin(s.location, extensions.st_makepoint(lon, lat)::extensions.geography,
                               least(greatest(radius_km, 1), 100) * 1000)
   order by 9
   limit 100
$$;

-- ───────────────────────── trips ─────────────────────────

create or replace function public.create_trip(
  p_title text, p_note text, p_place_name text, p_lat double precision, p_lon double precision,
  p_starts_at timestamptz, p_ends_at timestamptz, p_max_people int, p_contact text,
  p_owner_name text, p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  v_name text := public.clean_name(p_owner_name);
  v_shadow boolean;
  new_id uuid;
begin
  perform public.check_trip_input(p_title, p_starts_at, p_ends_at, p_max_people);
  v_shadow := public.guard('trip', h,
    public.text_fingerprint(coalesce(p_title, '') || ' ' || coalesce(p_note, '')));
  perform public.check_content(p_title, 'title');
  perform public.check_content(p_note, 'text');
  perform public.check_content(p_place_name, 'title');
  perform public.check_content(p_contact, 'contact');
  perform public.check_content(v_name, 'name');
  insert into public.trips (owner_hash, owner_name, title, note, place_name, location,
                            starts_at, ends_at, max_people, contact, shadow, mod_status)
  values (h, v_name, btrim(p_title), left(coalesce(p_note, ''), 500),
          left(btrim(coalesce(p_place_name, '')), 80),
          extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
          p_starts_at, p_ends_at, p_max_people, left(btrim(coalesce(p_contact, '')), 120), v_shadow,
          public.new_status('trip'))
  returning id into new_id;
  -- The owner is the first member.
  insert into public.trip_members (trip_id, member_hash, member_name)
  values (new_id, h, v_name);
  return new_id;
end $$;

-- Time, size and contact (members only) change at once; a new title or
-- note of an approved trip waits for review.
create or replace function public.update_trip(
  p_trip_id uuid, p_title text, p_note text, p_starts_at timestamptz, p_ends_at timestamptz,
  p_max_people int, p_contact text, p_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  members int;
  t public.trips%rowtype;
  v_shadow boolean;
  v_title text := btrim(p_title);
  v_note text := left(coalesce(p_note, ''), 500);
  v_hold boolean;
begin
  perform public.check_trip_input(p_title, p_starts_at, p_ends_at, p_max_people);
  select count(*) into members from public.trip_members m where m.trip_id = p_trip_id;
  if p_max_people < members then
    raise exception 'fewer places than members' using errcode = '22023';
  end if;
  select * into t from public.trips x
   where x.id = p_trip_id and x.owner_hash = h and not x.cancelled for update;
  if not found then return false; end if;
  v_shadow := public.guard('trip_edit', h);
  perform public.check_content(p_title, 'title');
  perform public.check_content(p_note, 'text');
  perform public.check_content(p_contact, 'contact');
  v_hold := t.mod_status = 'approved' and public.held('trip');
  update public.trips x
     set title = case when v_hold then x.title else v_title end,
         note = case when v_hold then x.note else v_note end,
         pending_edit = case when v_hold and (v_title <> x.title or v_note <> x.note)
                             then jsonb_build_object('at', now(), 'title', v_title, 'note', v_note) end,
         edit_rejected_at = case when v_hold then null else x.edit_rejected_at end,
         mod_status = public.resubmit_status('trip', x.mod_status),
         starts_at = p_starts_at, ends_at = p_ends_at, max_people = p_max_people,
         contact = left(btrim(coalesce(p_contact, '')), 120), updated_at = now(),
         shadow = x.shadow or v_shadow
   where x.id = p_trip_id;
  return true;
end $$;

-- 'joined' | 'already' | 'full' | 'closed' (ended, cancelled, hidden, not
-- approved yet, or missing).
create or replace function public.join_trip(p_trip_id uuid, p_name text, p_secret text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  v_name text := public.clean_name(p_name);
  t public.trips%rowtype;
  members int;
begin
  select * into t from public.trips x where x.id = p_trip_id for update;
  if not found or t.cancelled or t.hidden or (t.shadow and t.owner_hash <> h)
     or (t.mod_status <> 'approved' and t.owner_hash <> h)
     or t.ends_at <= now() then
    return 'closed';
  end if;
  if exists (select 1 from public.trip_members m where m.trip_id = p_trip_id and m.member_hash = h) then
    return 'already';
  end if;
  select count(*) into members from public.trip_members m where m.trip_id = p_trip_id;
  if members >= t.max_people then return 'full'; end if;
  perform public.guard('trip_join', h);
  perform public.check_content(v_name, 'name');
  insert into public.trip_members (trip_id, member_hash, member_name)
  values (p_trip_id, h, v_name);
  return 'joined';
end $$;

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
  select t.id,
         coalesce(case when t.owner_hash = me.h then t.pending_edit->>'title' end, t.title),
         coalesce(case when t.owner_hash = me.h then t.pending_edit->>'note' end, t.note),
         t.place_name,
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
     and (t.mod_status = 'approved' or t.owner_hash = me.h)
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
  v_shadow boolean;
begin
  if char_length(btrim(coalesce(p_name, ''))) < 2 then
    raise exception 'invalid name' using errcode = '22023';
  end if;
  perform public.check_photos(p_photos);
  v_shadow := public.guard('pond', h);
  perform public.check_pond_texts(p_name, p_address, p_phone, p_price, p_hours, p_species, p_note);
  -- Same place already listed (and visible to this device): point to it.
  select x.id into near_id from public.ponds x
   where not x.hidden and not x.shadow and (x.mod_status = 'approved' or x.created_by_hash = h)
     and extensions.st_dwithin(x.location, pt, 80) limit 1;
  if near_id is not null then
    raise exception 'pond exists' using errcode = 'P0001', hint = 'duplicate', detail = near_id::text;
  end if;
  insert into public.ponds (name, address, location, phone, price_note, hours_note, species,
                            note, photos, source, created_by_hash, shadow, mod_status)
  values (public.clean_short(p_name, 100), public.clean_short(p_address, 200), pt,
          public.clean_short(p_phone, 30), public.clean_short(p_price, 120),
          public.clean_short(p_hours, 80), public.clean_species(p_species),
          left(coalesce(p_note, ''), 500), coalesce(p_photos, '{}'), 'user', h, v_shadow,
          public.new_status('pond'))
  returning id into new_id;
  -- The person who adds it vouches for it (and their IP cannot confirm again).
  insert into public.pond_confirms (pond_id, device_hash) values (new_id, h);
  perform public.cast_vote('pond_confirm', new_id, h);
  update public.ponds set confirmations = 1 where id = new_id;
  return new_id;
end $$;

-- Writes a proposal (same keys as pond_snapshot) onto the pond.
create or replace function public.apply_pond_edit(p_pond_id uuid, e jsonb)
returns void language plpgsql security definer set search_path = '' as $$
declare
  pt extensions.geography := extensions.st_makepoint((e->>'lon')::float8, (e->>'lat')::float8)::extensions.geography;
begin
  update public.ponds x
     set name = e->>'name', address = e->>'address', location = pt,
         approx_location = x.approx_location and extensions.st_distance(x.location, pt) < 1,
         phone = e->>'phone', price_note = e->>'price', hours_note = e->>'hours',
         species = array(select jsonb_array_elements_text(e->'species')), note = e->>'note',
         photos = array(select jsonb_array_elements_text(e->'photos')), updated_at = now()
   where x.id = p_pond_id;
end $$;

-- The verified owner, or the creator of a pond still waiting for review,
-- edits directly; anyone else's edit of an approved pond becomes a pending
-- proposal in pond_edits (one per device and pond: a newer one replaces it).
-- A shadowed device's edit of someone else's pond is dropped silently.
create or replace function public.update_pond(
  p_pond_id uuid, p_name text, p_address text, p_lat double precision, p_lon double precision,
  p_phone text, p_price text, p_hours text, p_species text[], p_note text, p_photos text[],
  p_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  p public.ponds%rowtype;
  v_shadow boolean;
  v_new jsonb;
  v_mine boolean;
begin
  if char_length(btrim(coalesce(p_name, ''))) < 2 then
    raise exception 'invalid name' using errcode = '22023';
  end if;
  if p_lat is null or p_lon is null or p_lat not between 7.5 and 23.6 or p_lon not between 102 and 118 then
    raise exception 'invalid position' using errcode = '23514';
  end if;
  perform public.check_photos(p_photos);
  select * into p from public.ponds x where x.id = p_pond_id and not x.hidden for update;
  if not found then return false; end if;
  if p.owner_hash is not null and p.owner_hash <> h then return false; end if;
  if p.shadow and coalesce(p.created_by_hash, '') <> h then return false; end if;
  v_mine := coalesce(p.created_by_hash, '') = h or coalesce(p.owner_hash, '') = h;
  if p.mod_status <> 'approved' and not v_mine then return false; end if;
  v_shadow := public.guard('pond_edit', h);
  perform public.check_pond_texts(p_name, p_address, p_phone, p_price, p_hours, p_species, p_note);
  if v_shadow and not v_mine then return true; end if;
  v_new := jsonb_build_object('name', public.clean_short(p_name, 100),
    'address', public.clean_short(p_address, 200), 'phone', public.clean_short(p_phone, 30),
    'price', public.clean_short(p_price, 120), 'hours', public.clean_short(p_hours, 80),
    'species', to_jsonb(public.clean_species(p_species)), 'note', left(coalesce(p_note, ''), 500),
    'lat', p_lat, 'lon', p_lon, 'photos', to_jsonb(coalesce(p_photos, '{}'::text[])));
  if p.mod_status = 'approved' and coalesce(p.owner_hash, '') <> h and public.held('pond') then
    update public.pond_edits e set status = 'superseded', decided_at = now()
     where e.pond_id = p.id and e.editor_hash = h and e.status = 'pending';
    insert into public.pond_edits (pond_id, editor_hash, before, proposed, status)
    values (p.id, h, public.pond_snapshot(p), v_new, 'pending');
    return true;
  end if;
  insert into public.pond_edits (pond_id, editor_hash, before, proposed)
  values (p.id, h, public.pond_snapshot(p), v_new);
  perform public.apply_pond_edit(p.id, v_new);
  update public.ponds x
     set shadow = x.shadow or v_shadow, mod_status = public.resubmit_status('pond', x.mod_status)
   where x.id = p.id;
  return true;
end $$;

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
           where r.pond_id = p.id and not r.hidden and (not r.shadow or r.author_hash = me.h)
             and (r.mod_status = 'approved' or r.author_hash = me.h)),
         (select count(*) from public.pond_reviews r
           where r.pond_id = p.id and not r.hidden and (not r.shadow or r.author_hash = me.h)
             and (r.mod_status = 'approved' or r.author_hash = me.h)),
         nr.starts_at, nr.total_kg, nr.by_owner,
         extensions.st_distance(p.location, here.g) / 1000,
         p.updated_at
    from public.ponds p
   cross join me
   cross join here
    left join lateral (
      select r.starts_at, r.total_kg, r.by_owner from public.pond_releases r
       where r.pond_id = p.id and not r.cancelled and not r.hidden
         and (not r.shadow or r.created_by_hash = me.h)
         and (r.mod_status = 'approved' or r.created_by_hash = me.h)
         and r.starts_at > now() - interval '6 hours'
       order by r.by_owner desc, r.starts_at limit 1
    ) nr on true
   where not p.hidden
     and (not p.shadow or p.created_by_hash = me.h or p.owner_hash = me.h)
     and (p.mod_status = 'approved' or p.created_by_hash = me.h or p.owner_hash = me.h)
     and extensions.st_dwithin(p.location, here.g, least(greatest(p_radius_km, 1), 150) * 1000)
   order by 25
   limit 300
$$;

-- A release by the verified owner is public at once; others' wait.
create or replace function public.post_release(
  p_pond_id uuid, p_starts_at timestamptz, p_fish jsonb, p_note text, p_source_text text,
  p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  v_owner boolean;
  v_shadow boolean;
  fish jsonb;
  total int;
  new_id uuid;
begin
  select coalesce(x.owner_hash = h, false) into v_owner
    from public.ponds x where x.id = p_pond_id and not x.hidden
     and (not x.shadow or x.created_by_hash = h)
     and (x.mod_status = 'approved' or x.created_by_hash = h or x.owner_hash = h);
  if not found then raise exception 'pond not found' using errcode = 'P0002'; end if;
  if p_starts_at is null or p_starts_at < now() - interval '1 day'
     or p_starts_at > now() + interval '60 days' then
    raise exception 'invalid time' using errcode = '22023';
  end if;
  v_shadow := public.guard('release', h);
  perform public.check_content(p_note, 'text');
  perform public.check_content(p_source_text, 'post');
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
  perform public.check_content(
    (select string_agg(f->>'species', ', ') from jsonb_array_elements(fish) f), 'title');
  insert into public.pond_releases (pond_id, starts_at, fish, total_kg, note, source_text,
                                    created_by_hash, by_owner, shadow, mod_status)
  values (p_pond_id, p_starts_at, fish, total, left(coalesce(p_note, ''), 300),
          left(coalesce(p_source_text, ''), 1000), h, v_owner, v_shadow,
          case when v_owner then 'approved' else public.new_status('release') end)
  returning id into new_id;
  return new_id;
end $$;

create or replace function public.releases_for(p_pond_ids uuid[], p_secret text default '')
returns table (
  id uuid, pond_id uuid, starts_at timestamptz, fish jsonb, total_kg int, note text,
  source_text text, by_owner boolean, cancelled boolean, mine boolean, created_at timestamptz
)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  )
  select r.id, r.pond_id, r.starts_at, r.fish, r.total_kg, r.note, r.source_text, r.by_owner,
         r.cancelled,
         coalesce(r.created_by_hash = me.h, false),
         r.created_at
    from public.pond_releases r, me
   where r.pond_id = any (p_pond_ids[1:50])
     and not r.hidden
     and (not r.shadow or r.created_by_hash = me.h)
     and (r.mod_status = 'approved' or r.created_by_hash = me.h)
     and r.starts_at > now() - interval '30 days'
   order by (r.starts_at < now() - interval '6 hours'), r.starts_at
   limit 200
$$;

create or replace function public.review_pond(
  p_pond_id uuid, p_rating int, p_body text, p_name text, p_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  b text := left(btrim(coalesce(p_body, '')), 300);
  v_name text := public.clean_name(p_name);
  v_shadow boolean;
  r public.pond_reviews%rowtype;
begin
  if p_rating is null or p_rating not between 1 and 5 then
    raise exception 'invalid rating' using errcode = '22023';
  end if;
  if not exists (select 1 from public.ponds x where x.id = p_pond_id and not x.hidden
                  and (not x.shadow or x.created_by_hash = h)
                  and (x.mod_status = 'approved' or x.created_by_hash = h or x.owner_hash = h)) then
    return false;
  end if;
  v_shadow := public.guard('review', h, public.text_fingerprint(b));
  perform public.check_content(b, 'text');
  perform public.check_content(v_name, 'name');
  select * into r from public.pond_reviews x where x.pond_id = p_pond_id and x.author_hash = h for update;
  if not found then
    insert into public.pond_reviews (pond_id, author_hash, author_name, rating, body, shadow, mod_status)
    values (p_pond_id, h, v_name, p_rating, b, v_shadow, public.new_status('review'));
  elsif r.mod_status = 'approved' and public.held('review') then
    update public.pond_reviews x
       set pending_edit = jsonb_build_object('at', now(), 'rating', p_rating, 'body', b, 'name', v_name),
           edit_rejected_at = null, shadow = x.shadow or v_shadow
     where x.pond_id = p_pond_id and x.author_hash = h;
  else
    update public.pond_reviews x
       set rating = p_rating, body = b, author_name = v_name, shadow = x.shadow or v_shadow,
           updated_at = now(), pending_edit = null,
           mod_status = public.resubmit_status('review', x.mod_status)
     where x.pond_id = p_pond_id and x.author_hash = h;
  end if;
  return true;
end $$;

create or replace function public.reviews_for(p_pond_id uuid, p_secret text default '')
returns table (author_name text, rating int, body text, created_at timestamptz,
               updated_at timestamptz, mine boolean)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  )
  select coalesce(pe.e->>'name', r.author_name), coalesce((pe.e->>'rating')::int, r.rating),
         coalesce(pe.e->>'body', r.body), r.created_at, r.updated_at,
         coalesce(r.author_hash = me.h, false)
    from public.pond_reviews r
   cross join me
   cross join lateral (select case when r.author_hash = me.h then r.pending_edit end as e) pe
   where r.pond_id = p_pond_id and not r.hidden
     and (not r.shadow or r.author_hash = me.h)
     and (r.mod_status = 'approved' or r.author_hash = me.h)
     and not exists (select 1 from public.user_blocks b
                      where b.blocker_hash = me.h and b.blocked_hash = r.author_hash)
   order by coalesce(r.updated_at, r.created_at) desc
   limit 100
$$;

-- ───────────────────────── the author's view ─────────────────────────

-- The caller's items that are not plainly public: status 'pending' |
-- 'rejected' | 'edit_pending' | 'edit_rejected' (edit refused in the last 7
-- days; the approved version stays). Reviews: item_id = pond id and
-- created_at = the review's created_at. Rejections older than 30 days drop off.
create or replace function public.my_pending(p_secret text)
returns table (kind text, item_id uuid, status text, reason text, created_at timestamptz)
language sql stable security definer set search_path = '' as $$
  with me as (
    select case when public.valid_secret(p_secret) then public.secret_hash(p_secret) end as h
  ),
  items (kind, item_id, mod_status, mod_note, mod_at, pending_edit, edit_rejected_at, created_at) as (
    select 'spot', s.id, s.mod_status, s.mod_note, s.mod_at, s.pending_edit, s.edit_rejected_at, s.created_at
      from public.public_spots s, me where s.owner_hash = me.h and not s.hidden
    union all
    select 'comment', c.id, c.mod_status, c.mod_note, c.mod_at, c.pending_edit, c.edit_rejected_at, c.created_at
      from public.spot_comments c, me where c.author_hash = me.h and not c.hidden
    union all
    select 'trip', t.id, t.mod_status, t.mod_note, t.mod_at, t.pending_edit, t.edit_rejected_at, t.created_at
      from public.trips t, me where t.owner_hash = me.h and not t.hidden and t.ends_at > now()
    union all
    select 'review', r.pond_id, r.mod_status, r.mod_note, r.mod_at, r.pending_edit, r.edit_rejected_at,
           r.created_at
      from public.pond_reviews r, me where r.author_hash = me.h and not r.hidden
    union all
    select 'release', x.id, x.mod_status, x.mod_note, x.mod_at, null::jsonb, null::timestamptz, x.created_at
      from public.pond_releases x, me where x.created_by_hash = me.h and not x.hidden
    union all
    select 'pond', p.id, p.mod_status, p.mod_note, p.mod_at, null::jsonb, null::timestamptz, p.created_at
      from public.ponds p, me
     where p.created_by_hash = me.h and not p.hidden and p.mod_status <> 'approved'
  )
  select i.kind, i.item_id,
         case when i.mod_status <> 'approved' then i.mod_status
              when i.pending_edit is not null then 'edit_pending'
              else 'edit_rejected' end,
         case when i.mod_status = 'pending' or i.pending_edit is not null then '' else i.mod_note end,
         i.created_at
    from items i
   where (i.mod_status = 'pending')
      or (i.mod_status = 'rejected' and coalesce(i.mod_at, i.created_at) > now() - interval '30 days')
      or (i.mod_status = 'approved' and i.pending_edit is not null)
      or (i.mod_status = 'approved' and i.edit_rejected_at > now() - interval '7 days')
  union all
  (select distinct on (e.pond_id) 'pond', e.pond_id,
         case e.status when 'pending' then 'edit_pending' else 'edit_rejected' end,
         case e.status when 'pending' then '' else e.mod_note end,
         e.created_at
    from public.pond_edits e, me
   where e.editor_hash = me.h
     and (e.status = 'pending' or (e.status = 'rejected' and e.decided_at > now() - interval '7 days'))
     -- A pond the caller created and is still pending is reported above.
     and not exists (select 1 from public.ponds p where p.id = e.pond_id and p.mod_status <> 'approved'
                      and p.created_by_hash = me.h)
   order by e.pond_id, e.created_at desc)
  limit 500
$$;

-- ───────────────────────── moderation (owner only) ─────────────────────────

-- Everything waiting for review, oldest first. change: 'new' | 'edit'.
-- Run approve_sql / reject_sql as given (review and pond_edit need the author).
create or replace function public.mod_pending(p_limit int default 100)
returns table (kind text, change text, item_id uuid, author_hash text, preview text,
               created_at timestamptz, device_age interval, strikes int,
               approve_sql text, reject_sql text)
language sql stable security definer set search_path = '' as $$
  with q (kind, change, item_id, author_hash, preview, created_at) as (
    select 'spot', 'new', s.id, s.owner_hash, s.title || ' — ' || s.note || ' [' || s.species || ']'
             || case when cardinality(s.photos) > 0 then ' (' || cardinality(s.photos) || ' ảnh)' else '' end,
           s.created_at
      from public.public_spots s where s.mod_status = 'pending' and not s.hidden and not s.shadow
    union all
    select 'spot', 'edit', s.id, s.owner_hash,
           (s.pending_edit->>'title') || ' — ' || (s.pending_edit->>'note') || ' [' || (s.pending_edit->>'species')
             || '] (' || jsonb_array_length(s.pending_edit->'photos') || ' ảnh) | trước: ' || s.title,
           (s.pending_edit->>'at')::timestamptz
      from public.public_spots s
     where s.mod_status = 'approved' and s.pending_edit is not null and not s.hidden and not s.shadow
    union all
    select 'comment', 'new', c.id, c.author_hash, c.author_name || ': ' || c.body, c.created_at
      from public.spot_comments c where c.mod_status = 'pending' and not c.hidden and not c.shadow
    union all
    select 'comment', 'edit', c.id, c.author_hash,
           c.author_name || ': ' || (c.pending_edit->>'body') || ' | trước: ' || c.body,
           (c.pending_edit->>'at')::timestamptz
      from public.spot_comments c
     where c.mod_status = 'approved' and c.pending_edit is not null and not c.hidden and not c.shadow
    union all
    select 'trip', 'new', t.id, t.owner_hash,
           t.owner_name || ': ' || t.title || ' — ' || t.note || ' @ ' || t.place_name, t.created_at
      from public.trips t
     where t.mod_status = 'pending' and not t.hidden and not t.shadow and not t.cancelled
       and t.ends_at > now()
    union all
    select 'trip', 'edit', t.id, t.owner_hash,
           (t.pending_edit->>'title') || ' — ' || (t.pending_edit->>'note') || ' | trước: ' || t.title,
           (t.pending_edit->>'at')::timestamptz
      from public.trips t
     where t.mod_status = 'approved' and t.pending_edit is not null and not t.hidden and not t.shadow
       and not t.cancelled and t.ends_at > now()
    union all
    select 'pond', 'new', p.id, p.created_by_hash,
           p.name || ' — ' || p.address || ' — ' || p.phone || ' — ' || p.note, p.created_at
      from public.ponds p where p.mod_status = 'pending' and not p.hidden and not p.shadow
    union all
    select 'pond_edit', 'edit', e.pond_id, e.editor_hash,
           coalesce((select string_agg(k || ': ' || coalesce(e.before->>k, '') || ' → ' || (e.proposed->>k), ' | ')
                       from jsonb_object_keys(e.proposed) k
                      where e.proposed->k is distinct from e.before->k), '(không đổi gì)'),
           e.created_at
      from public.pond_edits e
      join public.ponds p on p.id = e.pond_id and not p.hidden
     where e.status = 'pending'
    union all
    select 'release', 'new', r.id, r.created_by_hash,
           to_char(r.starts_at at time zone 'Asia/Ho_Chi_Minh', 'HH24:MI DD/MM') || ' '
             || coalesce((select string_agg((f->>'species') || coalesce(' ' || (f->>'kg') || 'kg', ''), ', ')
                            from jsonb_array_elements(r.fish) f), '')
             || ' — ' || r.note || ' | ' || r.source_text,
           r.created_at
      from public.pond_releases r
     where r.mod_status = 'pending' and not r.hidden and not r.shadow and not r.cancelled
    union all
    select 'review', 'new', v.pond_id, v.author_hash,
           v.rating || '★ ' || v.author_name || ': ' || v.body, v.created_at
      from public.pond_reviews v where v.mod_status = 'pending' and not v.hidden and not v.shadow
    union all
    select 'review', 'edit', v.pond_id, v.author_hash,
           (v.pending_edit->>'rating') || '★ ' || (v.pending_edit->>'name') || ': ' || (v.pending_edit->>'body')
             || ' | trước: ' || v.rating || '★ ' || v.body,
           (v.pending_edit->>'at')::timestamptz
      from public.pond_reviews v
     where v.mod_status = 'approved' and v.pending_edit is not null and not v.hidden and not v.shadow
  )
  select q.kind, q.change, q.item_id, q.author_hash, left(q.preview, 300), q.created_at,
         date_trunc('minute', now() - d.first_seen), coalesce(d.strikes, 0),
         format('select public.mod_approve(%L, %L, %L);', q.kind, q.item_id,
                case when q.kind in ('review', 'pond_edit') then q.author_hash end),
         format('select public.mod_reject(%L, %L, %L, %L);', q.kind, q.item_id, 'lý do',
                case when q.kind in ('review', 'pond_edit') then q.author_hash end)
    from q
    left join public.devices d on d.device_hash = q.author_hash
   order by q.created_at
   limit least(greatest(coalesce(p_limit, 100), 1), 1000)
$$;

-- How much is waiting, per kind, and the oldest item (the 24 h promise).
create or replace function public.mod_pending_summary()
returns table (kind text, change text, items bigint, oldest timestamptz, waiting interval)
language sql stable security definer set search_path = '' as $$
  select m.kind, m.change, count(*), min(m.created_at), date_trunc('minute', now() - min(m.created_at))
    from public.mod_pending(1000) m
   group by m.kind, m.change
   order by 4
$$;

-- Makes an item public (or applies its pending edit). Reviews and pond
-- edits: [p_id] = pond id, [p_author] = author / editor hash. Returns rows changed.
create or replace function public.mod_approve(p_kind text, p_id uuid, p_author text default null)
returns int language plpgsql security definer set search_path = '' as $$
declare
  n int;
  e public.pond_edits%rowtype;
begin
  case p_kind
    when 'spot' then
      update public.public_spots x
         set title = coalesce(x.pending_edit->>'title', x.title),
             note = coalesce(x.pending_edit->>'note', x.note),
             species = coalesce(x.pending_edit->>'species', x.species),
             photos = case when x.pending_edit is null then x.photos
                           else array(select jsonb_array_elements_text(x.pending_edit->'photos')) end,
             updated_at = case when x.pending_edit is null then x.updated_at else now() end,
             pending_edit = null, mod_status = 'approved', mod_note = '', mod_at = now()
       where x.id = p_id and (x.mod_status <> 'approved' or x.pending_edit is not null);
    when 'comment' then
      update public.spot_comments x
         set body = coalesce(x.pending_edit->>'body', x.body),
             updated_at = case when x.pending_edit is null then x.updated_at else now() end,
             pending_edit = null, mod_status = 'approved', mod_note = '', mod_at = now()
       where x.id = p_id and (x.mod_status <> 'approved' or x.pending_edit is not null);
    when 'trip' then
      update public.trips x
         set title = coalesce(x.pending_edit->>'title', x.title),
             note = coalesce(x.pending_edit->>'note', x.note),
             pending_edit = null, mod_status = 'approved', mod_note = '', mod_at = now()
       where x.id = p_id and (x.mod_status <> 'approved' or x.pending_edit is not null);
    when 'review' then
      update public.pond_reviews x
         set rating = coalesce((x.pending_edit->>'rating')::int, x.rating),
             body = coalesce(x.pending_edit->>'body', x.body),
             author_name = coalesce(x.pending_edit->>'name', x.author_name),
             updated_at = case when x.pending_edit is null then x.updated_at else now() end,
             pending_edit = null, mod_status = 'approved', mod_note = '', mod_at = now()
       where x.pond_id = p_id and x.author_hash = p_author
         and (x.mod_status <> 'approved' or x.pending_edit is not null);
    when 'release' then
      update public.pond_releases x set mod_status = 'approved', mod_note = '', mod_at = now()
       where x.id = p_id and x.mod_status <> 'approved';
    when 'pond' then
      update public.ponds x set mod_status = 'approved', mod_note = '', mod_at = now()
       where x.id = p_id and x.mod_status <> 'approved';
    when 'pond_edit' then
      select * into e from public.pond_edits x
       where x.pond_id = p_id and x.editor_hash = p_author and x.status = 'pending'
       order by x.created_at desc limit 1 for update;
      if found then
        update public.pond_edits x
           set status = 'applied', decided_at = now(),
               before = (select public.pond_snapshot(p) from public.ponds p where p.id = p_id)
         where x.id = e.id;
        perform public.apply_pond_edit(p_id, e.proposed);
        return 1;
      end if;
      return 0;
    else
      raise exception 'unknown kind' using errcode = '22023';
  end case;
  get diagnostics n = row_count;
  return n;
end $$;

-- Refuses a pending item (hidden from everyone, the author sees "Không được
-- duyệt") or a pending edit (dropped; the approved version stays).
-- [p_strike] also gives the author a strike (spam, abuse).
create or replace function public.mod_reject(
  p_kind text, p_id uuid, p_reason text default '', p_author text default null,
  p_strike boolean default false
) returns int language plpgsql security definer set search_path = '' as $$
declare
  n int;
  v_reason text := left(coalesce(p_reason, ''), 300);
  v_author text;
begin
  case p_kind
    when 'spot' then
      update public.public_spots x
         set mod_status = case when x.mod_status = 'pending' then 'rejected' else x.mod_status end,
             edit_rejected_at = case when x.mod_status = 'approved' then now() else x.edit_rejected_at end,
             pending_edit = null, mod_note = v_reason, mod_at = now()
       where x.id = p_id and (x.mod_status = 'pending' or x.pending_edit is not null)
      returning x.owner_hash into v_author;
    when 'comment' then
      update public.spot_comments x
         set mod_status = case when x.mod_status = 'pending' then 'rejected' else x.mod_status end,
             edit_rejected_at = case when x.mod_status = 'approved' then now() else x.edit_rejected_at end,
             pending_edit = null, mod_note = v_reason, mod_at = now()
       where x.id = p_id and (x.mod_status = 'pending' or x.pending_edit is not null)
      returning x.author_hash into v_author;
    when 'trip' then
      update public.trips x
         set mod_status = case when x.mod_status = 'pending' then 'rejected' else x.mod_status end,
             edit_rejected_at = case when x.mod_status = 'approved' then now() else x.edit_rejected_at end,
             pending_edit = null, mod_note = v_reason, mod_at = now()
       where x.id = p_id and (x.mod_status = 'pending' or x.pending_edit is not null)
      returning x.owner_hash into v_author;
    when 'review' then
      update public.pond_reviews x
         set mod_status = case when x.mod_status = 'pending' then 'rejected' else x.mod_status end,
             edit_rejected_at = case when x.mod_status = 'approved' then now() else x.edit_rejected_at end,
             pending_edit = null, mod_note = v_reason, mod_at = now()
       where x.pond_id = p_id and x.author_hash = p_author
         and (x.mod_status = 'pending' or x.pending_edit is not null)
      returning x.author_hash into v_author;
    when 'release' then
      update public.pond_releases x set mod_status = 'rejected', mod_note = v_reason, mod_at = now()
       where x.id = p_id and x.mod_status = 'pending'
      returning x.created_by_hash into v_author;
    when 'pond' then
      update public.ponds x set mod_status = 'rejected', mod_note = v_reason, mod_at = now()
       where x.id = p_id and x.mod_status = 'pending'
      returning x.created_by_hash into v_author;
    when 'pond_edit' then
      update public.pond_edits x set status = 'rejected', mod_note = v_reason, decided_at = now()
       where x.pond_id = p_id and x.editor_hash = p_author and x.status = 'pending'
      returning x.editor_hash into v_author;
    else
      raise exception 'unknown kind' using errcode = '22023';
  end case;
  get diagnostics n = row_count;
  if n > 0 and p_strike then perform public.add_strike(v_author); end if;
  return n;
end $$;

-- Approves everything one device has waiting (a regular you trust).
create or replace function public.mod_approve_all_from(p_author text)
returns int language plpgsql security definer set search_path = '' as $$
declare
  r record;
  n int := 0;
begin
  perform public.mod_check_device(p_author);
  for r in select m.kind, m.item_id from public.mod_pending(1000) m where m.author_hash = p_author loop
    n := n + public.mod_approve(r.kind, r.item_id, p_author);
  end loop;
  return n;
end $$;

-- ───────────────────────── grants ─────────────────────────

do $$
declare
  f text;
  api boolean := exists (select 1 from pg_roles where rolname = 'anon');
begin
  -- Internal helpers: only other SECURITY DEFINER functions call them.
  foreach f in array array[
    'public.held(text)', 'public.new_status(text)', 'public.resubmit_status(text, text)',
    'public.apply_pond_edit(uuid, jsonb)'
  ] loop
    execute format('revoke all on function %s from public', f);
    if api then execute format('revoke all on function %s from anon, authenticated', f); end if;
  end loop;
  -- Moderation: SQL editor (postgres) and service_role only.
  foreach f in array array[
    'public.mod_pending(int)', 'public.mod_pending_summary()',
    'public.mod_approve(text, uuid, text)', 'public.mod_reject(text, uuid, text, text, boolean)',
    'public.mod_approve_all_from(text)'
  ] loop
    execute format('revoke all on function %s from public', f);
    if api then
      execute format('revoke all on function %s from anon, authenticated', f);
      execute format('grant execute on function %s to service_role', f);
    end if;
  end loop;
  -- The app reads its own badges.
  revoke all on function public.my_pending(text) from public;
  if api then
    grant execute on function public.my_pending(text) to anon, authenticated;
  end if;
end $$;
