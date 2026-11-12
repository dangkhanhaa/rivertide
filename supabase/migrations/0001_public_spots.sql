-- Purpose: community fishing spots ("điểm câu cộng đồng"): anyone reads,
-- signed-in (anonymous) users post/edit/delete their own, reports hide abuse.
-- Task: P2-19

create extension if not exists postgis with schema extensions;

create table if not exists public.public_spots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null check (char_length(title) between 2 and 80),
  note text not null default '' check (char_length(note) <= 500),
  species text not null default '' check (char_length(species) <= 100),
  -- Vietnam incl. Hoàng Sa / Trường Sa (same box as the app).
  location extensions.geography(Point, 4326) not null
    check (
      extensions.st_y(location::extensions.geometry) between 7.5 and 23.6
      and extensions.st_x(location::extensions.geometry) between 102 and 118
    ),
  -- Storage paths in bucket spot-photos, "<user_id>/<file>.jpg", at most 3.
  photos text[] not null default '{}' check (cardinality(photos) <= 3),
  report_count int not null default 0 check (report_count >= 0),
  hidden boolean not null default false,
  created_at timestamptz not null default now()
);

comment on table public.public_spots is
  'Fishing spots users chose to make public; hidden after 3 reports (P2-19).';

create index if not exists public_spots_location_gix on public.public_spots using gist (location);
create index if not exists public_spots_user_id_idx on public.public_spots (user_id);
create index if not exists public_spots_created_at_idx on public.public_spots (created_at desc);

alter table public.public_spots enable row level security;

drop policy if exists "read visible spots" on public.public_spots;
create policy "read visible spots" on public.public_spots
  for select using (not hidden or user_id = auth.uid());

drop policy if exists "post own spots" on public.public_spots;
create policy "post own spots" on public.public_spots
  for insert to authenticated with check (user_id = auth.uid() and report_count = 0 and not hidden);

drop policy if exists "edit own spots" on public.public_spots;
create policy "edit own spots" on public.public_spots
  for update to authenticated using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "delete own spots" on public.public_spots;
create policy "delete own spots" on public.public_spots
  for delete to authenticated using (user_id = auth.uid());

-- Users must not lift a hide or reset reports by editing their own row.
create or replace function public.keep_moderation_fields()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.report_count := old.report_count;
  new.hidden := old.hidden;
  new.user_id := old.user_id;
  return new;
end $$;

drop trigger if exists public_spots_keep_moderation on public.public_spots;
create trigger public_spots_keep_moderation before update on public.public_spots
  for each row when (current_user = 'authenticated')
  execute function public.keep_moderation_fields();

-- One report per user per spot.
create table if not exists public.spot_reports (
  spot_id uuid not null references public.public_spots (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  reason text not null default '' check (char_length(reason) <= 200),
  created_at timestamptz not null default now(),
  primary key (spot_id, user_id)
);

comment on table public.spot_reports is 'Abuse reports on public spots (P2-19).';

create index if not exists spot_reports_user_id_idx on public.spot_reports (user_id);

alter table public.spot_reports enable row level security;

drop policy if exists "report as self" on public.spot_reports;
create policy "report as self" on public.spot_reports
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "see own reports" on public.spot_reports;
create policy "see own reports" on public.spot_reports
  for select to authenticated using (user_id = auth.uid());

-- Counting runs as owner so reporters cannot edit spots directly.
create or replace function public.count_spot_report()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  update public.public_spots
     set report_count = report_count + 1,
         hidden = (report_count + 1) >= 3
   where id = new.spot_id;
  return new;
end $$;

drop trigger if exists spot_reports_count on public.spot_reports;
create trigger spot_reports_count after insert on public.spot_reports
  for each row execute function public.count_spot_report();

-- Nearby visible spots, nearest first.
create or replace function public.nearby_spots(lat double precision, lon double precision, radius_km double precision default 30)
returns table (
  id uuid, user_id uuid, title text, note text, species text,
  lat double precision, lon double precision, photos text[],
  created_at timestamptz, distance_km double precision
)
language sql stable set search_path = '' as $$
  select s.id, s.user_id, s.title, s.note, s.species,
         extensions.st_y(s.location::extensions.geometry),
         extensions.st_x(s.location::extensions.geometry),
         s.photos, s.created_at,
         extensions.st_distance(s.location, extensions.st_makepoint(lon, lat)::extensions.geography) / 1000
    from public.public_spots s
   where not s.hidden
     and extensions.st_dwithin(s.location, extensions.st_makepoint(lon, lat)::extensions.geography,
                               least(greatest(radius_km, 1), 100) * 1000)
   order by 10
   limit 100
$$;

grant execute on function public.nearby_spots(double precision, double precision, double precision) to anon, authenticated;

-- Photos: public read, users write only under their own folder, ≤ 1 MB JPEG.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('spot-photos', 'spot-photos', true, 1048576, array['image/jpeg'])
on conflict (id) do update
  set public = true, file_size_limit = 1048576, allowed_mime_types = array['image/jpeg'];

drop policy if exists "upload own spot photos" on storage.objects;
create policy "upload own spot photos" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'spot-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "delete own spot photos" on storage.objects;
create policy "delete own spot photos" on storage.objects
  for delete to authenticated
  using (bucket_id = 'spot-photos' and (storage.foldername(name))[1] = auth.uid()::text);
