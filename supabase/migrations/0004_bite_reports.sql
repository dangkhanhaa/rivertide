-- P2-37 "Có dính không? 👍/👎": one-tap bite reports after a golden window.
-- Privacy: position snapped to a ~2 km grid before storing, the device is a
-- SHA-256 of its random secret, reads return counts only (never rows).
-- Same pattern as 0002 (RLS on, no policies, SECURITY DEFINER RPCs).

create table if not exists public.bite_reports (
  id bigint generated always as identity primary key,
  owner_hash text not null check (owner_hash ~ '^[0-9a-f]{64}$'),
  cell_lat double precision not null check (cell_lat between 7.5 and 23.6),
  cell_lon double precision not null check (cell_lon between 102 and 118),
  bite boolean not null,
  -- Water at report time, so areas can learn "cá ăn khi nước rút".
  tide_state text check (tide_state in ('rising', 'falling', 'slack')),
  -- Local (Vietnam) hour 0–23 and the fishing score the app showed.
  local_hour smallint check (local_hour between 0 and 23),
  app_score real check (app_score between 0 and 10),
  created_at timestamptz not null default now()
);
create index if not exists bite_reports_cell_time_idx
  on public.bite_reports (cell_lat, cell_lon, created_at desc);
create index if not exists bite_reports_owner_time_idx
  on public.bite_reports (owner_hash, created_at desc);
alter table public.bite_reports enable row level security;

create or replace function public.report_bite(
  p_lat double precision, p_lon double precision, p_bite boolean,
  p_tide_state text, p_local_hour int, p_app_score real, p_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  la double precision := round((p_lat / 0.02)::numeric) * 0.02;
  lo double precision := round((p_lon / 0.02)::numeric) * 0.02;
begin
  if p_lat is null or p_lon is null or p_bite is null
     or la not between 7.5 and 23.6 or lo not between 102 and 118 then
    raise exception 'invalid report' using errcode = '22023';
  end if;
  if p_tide_state is not null and p_tide_state not in ('rising', 'falling', 'slack') then
    raise exception 'invalid tide state' using errcode = '22023';
  end if;
  if p_local_hour is not null and p_local_hour not between 0 and 23 then
    raise exception 'invalid hour' using errcode = '22023';
  end if;
  if p_app_score is not null and p_app_score not between 0 and 10 then
    raise exception 'invalid score' using errcode = '22023';
  end if;
  -- One report per device per 30 minutes, 20 per day.
  if exists (select 1 from public.bite_reports r
              where r.owner_hash = h and r.created_at > now() - interval '30 minutes')
     or (select count(*) from public.bite_reports r
          where r.owner_hash = h and r.created_at > now() - interval '1 day') >= 20 then
    raise exception 'too many reports' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  insert into public.bite_reports (owner_hash, cell_lat, cell_lon, bite, tide_state, local_hour, app_score)
  values (h, la, lo, p_bite, p_tide_state, p_local_hour, p_app_score);
  return true;
end $$;

-- Recent reports around a point: how many biting / not, last p_hours.
create or replace function public.bite_summary(
  p_lat double precision, p_lon double precision,
  p_radius_km double precision default 15, p_hours int default 3
) returns table (bites bigint, misses bigint, latest timestamptz)
language sql stable security definer set search_path = '' as $$
  select count(*) filter (where r.bite), count(*) filter (where not r.bite), max(r.created_at)
    from public.bite_reports r
   where r.created_at > now() - make_interval(hours => least(greatest(p_hours, 1), 24))
     and extensions.st_dwithin(
           extensions.st_makepoint(r.cell_lon, r.cell_lat)::extensions.geography,
           extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
           least(greatest(p_radius_km, 1), 50) * 1000)
$$;

-- What worked in this area over the last 60 days, by water state: the
-- crowd's answer to "nước lên hay nước rút thì cá ăn?".
create or replace function public.bite_patterns(
  p_lat double precision, p_lon double precision, p_radius_km double precision default 30
) returns table (tide_state text, bites bigint, misses bigint)
language sql stable security definer set search_path = '' as $$
  select r.tide_state, count(*) filter (where r.bite), count(*) filter (where not r.bite)
    from public.bite_reports r
   where r.created_at > now() - interval '60 days'
     and r.tide_state is not null
     and extensions.st_dwithin(
           extensions.st_makepoint(r.cell_lon, r.cell_lat)::extensions.geography,
           extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
           least(greatest(p_radius_km, 1), 100) * 1000)
   group by r.tide_state
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'public.report_bite(double precision, double precision, boolean, text, int, real, text)',
    'public.bite_summary(double precision, double precision, double precision, int)',
    'public.bite_patterns(double precision, double precision, double precision)'
  ] loop
    execute format('revoke all on function %s from public', f);
    execute format('grant execute on function %s to anon, authenticated', f);
  end loop;
end $$;
