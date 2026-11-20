-- Purpose: anti-spam and anti-abuse for the community features (no login).
-- Device secrets are made on the device, so a spammer can mint new ones at
-- will; per-secret limits alone are not enough. This migration adds:
--   * per-IP limits next to per-device limits (IP kept only as a keyed hash,
--     IPv6 grouped by /64, deleted after 7 days), one generic public.guard()
--     called by every writing RPC, limits tunable in public.rate_limits
--   * device reputation (public.devices): new devices get lower limits,
--     content hidden by reports gives its author a strike, 3 strikes = ban
--     (7 → 30 → 90 days) and the device's last 7 days of content become
--     "shadow": still shown to its author, hidden from everyone else
--   * weighted reports: one vote per IP per item, devices < 1 day old count
--     half, hiding needs weight ≥ 3 from ≥ 3 different IPs
--   * a content filter (links, phone numbers, Zalo/Telegram/inbox ads,
--     gambling spam, offensive words from an editable table, repeated
--     letters, all-caps, the same text again, impersonating names)
--   * moderation functions for the owner (service_role / SQL editor only)
-- Errors stay compatible with older apps: limits keep errcode P0001 + hint
-- 'rate_limit' (detail 'burst' | 'daily' | 'new_device'); new hints are
-- 'content_blocked' (detail = reason) and 'banned' (detail = UTC end time).
-- Every RPC keeps its exact signature and return type.
-- Task: P2-54

-- ───────────────────────── private salt ─────────────────────────

-- Not in an API-exposed schema; only the migration owner reads it.
create schema if not exists private;
revoke all on schema private from public;

create table if not exists private.secrets (
  name text primary key,
  value bytea not null
);
comment on table private.secrets is 'Server-only secrets (IP hash key), never exposed (P2-54).';
alter table private.secrets enable row level security;
revoke all on table private.secrets from public;
insert into private.secrets (name, value)
values ('ip_salt', extensions.gen_random_bytes(32))
on conflict (name) do nothing;

do $$
begin
  -- Supabase API roles: no access to the private schema at all.
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on schema private from anon, authenticated;
    revoke all on table private.secrets from anon, authenticated;
  end if;
end $$;

-- ───────────────────────── tables ─────────────────────────

create table if not exists public.devices (
  device_hash text primary key check (device_hash ~ '^[0-9a-f]{64}$'),
  first_seen timestamptz not null default now(),
  last_seen timestamptz not null default now(),
  strikes int not null default 0 check (strikes >= 0),
  last_strike_at timestamptz,
  bans int not null default 0 check (bans >= 0),
  -- Posting refused until then (error hint 'banned').
  banned_until timestamptz,
  -- Posting accepted but shown only to this device (set by the moderator).
  shadow_until timestamptz,
  note text not null default '' check (char_length(note) <= 300)
);
comment on table public.devices is
  'Device reputation by secret hash: age, strikes, bans, shadow (P2-54).';
alter table public.devices enable row level security;

-- One row per accepted write (failed attempts roll back with the request).
create table if not exists public.rate_events (
  id bigint generated always as identity primary key,
  action text not null check (char_length(action) <= 30),
  device_hash text not null check (device_hash ~ '^[0-9a-f]{64}$'),
  -- HMAC-SHA256 of the client IP (IPv6 /64) with private.secrets.ip_salt.
  ip_hash text check (ip_hash ~ '^[0-9a-f]{64}$'),
  -- Which request header gave the IP, to check the deployment.
  ip_source text not null default 'none' check (ip_source in ('cf', 'xff', 'real', 'none')),
  -- md5 of the folded text, for "same text again" checks (no plain text kept).
  fingerprint text check (fingerprint ~ '^[0-9a-f]{32}$'),
  created_at timestamptz not null default now()
);
comment on table public.rate_events is
  'Accepted community writes for rate limits; kept 7 days (P2-54).';
create index if not exists rate_events_device_idx on public.rate_events (device_hash, action, created_at desc);
create index if not exists rate_events_ip_action_idx on public.rate_events (ip_hash, action, created_at desc);
create index if not exists rate_events_ip_time_idx on public.rate_events (ip_hash, created_at desc);
create index if not exists rate_events_fingerprint_idx
  on public.rate_events (fingerprint, created_at desc) where fingerprint is not null;
create index if not exists rate_events_created_at_idx on public.rate_events (created_at);
alter table public.rate_events enable row level security;

-- Limits per action; null = no limit. Tune with UPDATE, no migration needed.
create table if not exists public.rate_limits (
  action text primary key check (char_length(action) <= 30),
  -- Seconds between two writes of this action from one device.
  min_gap_s int not null default 0 check (min_gap_s >= 0),
  device_day int check (device_day > 0),
  -- Used instead of device_day while the device is < 10 minutes old.
  new_device_day int check (new_device_day > 0),
  ip_minute int check (ip_minute > 0),
  ip_hour int check (ip_hour > 0),
  ip_day int check (ip_day > 0),
  note text not null default ''
);
comment on table public.rate_limits is 'Anti-spam limits per action, editable (P2-54).';
alter table public.rate_limits enable row level security;

-- Per-IP numbers are 4–10× the per-device ones: mobile carriers in Vietnam
-- put many subscribers behind one public IP (CGNAT), so the IP caps only
-- stop scripted floods from many secrets, not a few real neighbours.
insert into public.rate_limits
  (action, min_gap_s, device_day, new_device_day, ip_minute, ip_hour, ip_day, note) values
  ('all',          0, null, null,   40,  600, null, 'all actions together, per IP'),
  ('new_device',   0, null, null, null,   10,   40, 'first write of a new secret, per IP'),
  ('spot',        60,   10,    2, null,   20,   60, 'publish_spot'),
  ('spot_edit',    5,   40,   10, null,   60,  300, 'update_spot'),
  ('comment',     15,   30,    5, null,   60,  400, 'add_comment'),
  ('comment_edit', 5,   50,   10, null,  100,  500, 'edit_comment'),
  ('trip',        60,    5,    1, null,   10,   40, 'create_trip'),
  ('trip_edit',    5,   30,   10, null,   60,  300, 'update_trip'),
  ('trip_join',    3,   30,   10, null,  100,  500, 'join_trip'),
  ('trip_msg',     5,  100,   15, null,  300, 2000, 'post_trip_message (members only)'),
  ('pond',        60,    5,    1, null,   10,   30, 'add_pond'),
  ('pond_edit',   10,   20,    3, null,   40,  150, 'update_pond'),
  ('pond_confirm', 3,   30,    5, null,   60,  300, 'confirm_pond'),
  ('release',     30,   10,    2, null,   20,   80, 'post_release'),
  ('review',      15,   20,    3, null,   40,  200, 'review_pond'),
  ('pulse',        5,   60,   10, null,  120, 1000, 'pulse_pond (+30 min per pond)'),
  ('claim',       60,    3,    1, null,    5,   15, 'claim_pond'),
  ('report',       3,   20,    3, null,   40,  150, 'report_spot/comment/trip/pond/release'),
  ('checkin',      5,   60,   20, null,  300, 3000, 'check_in'),
  ('bite',         5,   30,    5, null,  200, 1500, 'report_bite (+30 min rule)')
on conflict (action) do nothing;

-- Moderator blocks by IP hash: 'block' refuses writes, 'shadow' hides them.
create table if not exists public.ip_blocks (
  ip_hash text primary key check (ip_hash ~ '^[0-9a-f]{64}$'),
  mode text not null default 'block' check (mode in ('block', 'shadow')),
  until timestamptz not null,
  note text not null default '' check (char_length(note) <= 300),
  created_at timestamptz not null default now()
);
comment on table public.ip_blocks is 'Temporary IP-hash blocks set by the moderator, ≤ 7 days (P2-54).';
alter table public.ip_blocks enable row level security;

-- Words refused in public texts. match: 'word' = whole words, accents ignored
-- (only for terms that stay unambiguous without accents); 'accented' = whole
-- words as typed with Vietnamese accents (e.g. "lồn" must not catch "lớn");
-- 'name_part' = anywhere in a display name, accents and spaces ignored.
create table if not exists public.blocked_terms (
  term text primary key check (char_length(btrim(term)) between 2 and 60),
  category text not null check (category in ('offensive', 'spam', 'contact_ad', 'impersonation')),
  match text not null default 'word' check (match in ('word', 'accented', 'name_part')),
  created_at timestamptz not null default now()
);
comment on table public.blocked_terms is 'Editable list of refused words/phrases (P2-54).';
alter table public.blocked_terms enable row level security;

insert into public.blocked_terms (term, category, match) values
  -- Offensive, with accents (without them they collide with common words).
  ('địt', 'offensive', 'accented'), ('đụ', 'offensive', 'accented'),
  ('lồn', 'offensive', 'accented'), ('cặc', 'offensive', 'accented'),
  ('buồi', 'offensive', 'accented'), ('đéo', 'offensive', 'accented'),
  ('đĩ', 'offensive', 'accented'), ('đm', 'offensive', 'accented'),
  ('đmm', 'offensive', 'accented'), ('đcm', 'offensive', 'accented'),
  ('óc chó', 'offensive', 'accented'), ('chó đẻ', 'offensive', 'accented'),
  ('thằng chó', 'offensive', 'accented'), ('đồ chó', 'offensive', 'accented'),
  ('thằng ngu', 'offensive', 'accented'), ('đồ ngu', 'offensive', 'accented'),
  ('súc sinh', 'offensive', 'accented'),
  -- Offensive, unambiguous without accents (chat abbreviations, English).
  ('dcm', 'offensive', 'word'), ('dmm', 'offensive', 'word'), ('dkm', 'offensive', 'word'),
  ('vcl', 'offensive', 'word'), ('vkl', 'offensive', 'word'), ('clgt', 'offensive', 'word'),
  ('loz', 'offensive', 'word'), ('djt', 'offensive', 'word'), ('dit me', 'offensive', 'word'),
  ('fuck', 'offensive', 'word'), ('shit', 'offensive', 'word'), ('bitch', 'offensive', 'word'),
  -- Gambling / scam spam.
  ('nha cai', 'spam', 'word'), ('casino', 'spam', 'word'), ('tai xiu', 'spam', 'word'),
  ('doi thuong', 'spam', 'word'), ('kiem tien online', 'spam', 'word'),
  ('vay tien', 'spam', 'word'), ('baccarat', 'spam', 'word'), ('game bai', 'spam', 'word'),
  ('cá độ', 'spam', 'accented'), ('nổ hũ', 'spam', 'accented'), ('lô đề', 'spam', 'accented'),
  ('gái gọi', 'spam', 'accented'), ('sex', 'spam', 'word'),
  -- "Contact me elsewhere" ads (allowed in contact fields only).
  ('zalo', 'contact_ad', 'word'), ('zl', 'contact_ad', 'word'), ('telegram', 'contact_ad', 'word'),
  ('viber', 'contact_ad', 'word'), ('whatsapp', 'contact_ad', 'word'),
  ('wechat', 'contact_ad', 'word'), ('inbox', 'contact_ad', 'word'), ('ib', 'contact_ad', 'word'),
  ('sdt', 'contact_ad', 'word'), ('hotline', 'contact_ad', 'word'), ('ket ban', 'contact_ad', 'word'),
  -- Display names pretending to be the app or its team.
  ('admin', 'impersonation', 'name_part'), ('quan tri', 'impersonation', 'name_part'),
  ('con nuoc', 'impersonation', 'name_part'), ('moderator', 'impersonation', 'name_part'),
  ('rivertide', 'impersonation', 'name_part'), ('kiem duyet', 'impersonation', 'name_part'),
  ('mod', 'impersonation', 'word'), ('ho tro', 'impersonation', 'word'),
  ('support', 'impersonation', 'word'), ('cskh', 'impersonation', 'word')
on conflict (term) do nothing;

-- One report/confirm per device per item, with the weight it carries.
create table if not exists public.item_votes (
  kind text not null check (kind in ('spot', 'comment', 'trip', 'pond', 'release', 'pond_confirm')),
  item_id uuid not null,
  device_hash text not null check (device_hash ~ '^[0-9a-f]{64}$'),
  -- Nulled after 7 days (the weight already says whether the IP was new).
  ip_hash text check (ip_hash ~ '^[0-9a-f]{64}$'),
  weight real not null check (weight between 0 and 1),
  created_at timestamptz not null default now(),
  primary key (kind, item_id, device_hash)
);
comment on table public.item_votes is 'Weighted reports/confirmations, one per device and IP (P2-54).';
create index if not exists item_votes_ip_idx on public.item_votes (kind, item_id, ip_hash);
create index if not exists item_votes_created_at_idx
  on public.item_votes (created_at) where ip_hash is not null;
alter table public.item_votes enable row level security;

do $$
declare
  t text;
begin
  -- Same pattern as 0001–0004: RLS on, no policies, plus no table grants.
  if exists (select 1 from pg_roles where rolname = 'anon') then
    foreach t in array array['devices', 'rate_events', 'rate_limits', 'ip_blocks',
                             'blocked_terms', 'item_votes'] loop
      execute format('revoke all on table public.%I from anon, authenticated', t);
    end loop;
  end if;
end $$;

-- Shadow = shown only to the author. Releases also get the hidden flag that
-- other content already has (they were hidden by report_count < 3 before).
alter table public.public_spots add column if not exists shadow boolean not null default false;
alter table public.spot_comments add column if not exists shadow boolean not null default false;
alter table public.trips add column if not exists shadow boolean not null default false;
alter table public.trip_messages add column if not exists shadow boolean not null default false;
alter table public.ponds add column if not exists shadow boolean not null default false;
alter table public.pond_releases add column if not exists shadow boolean not null default false;
alter table public.pond_releases add column if not exists hidden boolean not null default false;
alter table public.pond_reviews add column if not exists shadow boolean not null default false;
alter table public.pond_pulses add column if not exists shadow boolean not null default false;
alter table public.checkins add column if not exists shadow boolean not null default false;
alter table public.bite_reports add column if not exists shadow boolean not null default false;

update public.pond_releases set hidden = true where report_count >= 3 and not hidden;

-- Existing devices are not "new": their age starts at their first activity.
insert into public.devices (device_hash, first_seen, last_seen)
select h, min(at), max(at) from (
  select owner_hash, created_at from public.public_spots
  union all select reporter_hash, created_at from public.spot_reports
  union all select author_hash, created_at from public.spot_comments
  union all select reporter_hash, created_at from public.comment_reports
  union all select owner_hash, created_at from public.trips
  union all select member_hash, joined_at from public.trip_members
  union all select author_hash, created_at from public.trip_messages
  union all select reporter_hash, created_at from public.trip_reports
  union all select owner_hash, started_at from public.checkins
  union all select created_by_hash, created_at from public.ponds where created_by_hash is not null
  union all select device_hash, created_at from public.pond_confirms
  union all select device_hash, created_at from public.pond_reports
  union all select editor_hash, created_at from public.pond_edits
  union all select created_by_hash, created_at from public.pond_releases
  union all select author_hash, created_at from public.pond_reviews
  union all select device_hash, created_at from public.pond_pulses
  union all select claimant_hash, created_at from public.pond_claims
  union all select owner_hash, created_at from public.bite_reports
) x (h, at)
group by h
on conflict (device_hash) do nothing;

-- Existing reports keep counting (full weight, IP unknown).
insert into public.item_votes (kind, item_id, device_hash, weight, created_at)
select 'spot', spot_id, reporter_hash, 1, created_at from public.spot_reports
union all select 'comment', comment_id, reporter_hash, 1, created_at from public.comment_reports
union all select 'trip', trip_id, reporter_hash, 1, created_at from public.trip_reports
union all select 'pond', pond_id, device_hash, 1, created_at from public.pond_reports
union all select 'pond_confirm', pond_id, device_hash, 1, created_at from public.pond_confirms
on conflict do nothing;

-- ───────────────────────── IP and errors ─────────────────────────

-- The caller's IP as a keyed hash. Supabase passes request headers to
-- PostgREST as the JSON setting request.headers. cf-connecting-ip is set by
-- Cloudflare (clients cannot forge it); x-forwarded-for's first hop is the
-- fallback the Supabase docs use. No header (local dev, SQL editor) → null:
-- IP limits are skipped and only device limits apply.
create or replace function public.client_ip(out ip_hash text, out ip_source text)
language plpgsql stable security definer set search_path = '' as $$
declare
  hdr jsonb := nullif(current_setting('request.headers', true), '')::jsonb;
  raw text;
  addr inet;
begin
  ip_source := 'none';
  if hdr is null or jsonb_typeof(hdr) <> 'object' then return; end if;
  if coalesce(hdr->>'cf-connecting-ip', '') <> '' then
    raw := hdr->>'cf-connecting-ip'; ip_source := 'cf';
  elsif coalesce(hdr->>'x-forwarded-for', '') <> '' then
    raw := split_part(hdr->>'x-forwarded-for', ',', 1); ip_source := 'xff';
  elsif coalesce(hdr->>'x-real-ip', '') <> '' then
    raw := hdr->>'x-real-ip'; ip_source := 'real';
  end if;
  raw := btrim(left(coalesce(raw, ''), 60));
  if raw !~ '^[0-9a-fA-F:.]{2,45}$' then
    ip_source := 'none';
    return;
  end if;
  begin
    addr := raw::inet;
  exception when invalid_text_representation then
    -- Malformed header value: behave as if there were no IP header.
    ip_source := 'none';
    return;
  end;
  -- One IPv6 subscriber owns a whole /64: count it as one address.
  if family(addr) = 6 then addr := set_masklen(addr, 64); end if;
  select encode(extensions.hmac(convert_to(host(network(addr)), 'UTF8'), s.value, 'sha256'), 'hex')
    into ip_hash
    from private.secrets s where s.name = 'ip_salt';
  if ip_hash is null then ip_source := 'none'; end if;
end $$;

create or replace function public.raise_limit(p_detail text)
returns void language plpgsql volatile set search_path = '' as $$
begin
  raise exception '%', case when p_detail = 'daily' then 'too many today' else 'too fast' end
    using errcode = 'P0001', hint = 'rate_limit', detail = p_detail;
end $$;

create or replace function public.raise_banned(p_until timestamptz)
returns void language plpgsql volatile set search_path = '' as $$
begin
  raise exception 'posting paused' using errcode = 'P0001', hint = 'banned',
    detail = to_char(p_until at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"');
end $$;

-- Deletes IP data older than 7 days. Called now and then by guard() (pg_cron
-- is optional on Supabase); also scheduled below when pg_cron exists.
create or replace function public.purge_abuse_data()
returns void language plpgsql security definer set search_path = '' as $$
begin
  delete from public.rate_events e
   where e.id in (select x.id from public.rate_events x
                   where x.created_at < now() - interval '7 days' limit 5000);
  update public.item_votes v set ip_hash = null
   where (v.kind, v.item_id, v.device_hash) in (
     select x.kind, x.item_id, x.device_hash from public.item_votes x
      where x.ip_hash is not null and x.created_at < now() - interval '7 days' limit 5000);
  delete from public.ip_blocks b where b.until < now();
end $$;

-- ───────────────────────── guard ─────────────────────────

-- Rejects the write when this device or this IP goes over the limits of
-- [p_action] (public.rate_limits) or is banned; logs it otherwise. With a
-- [p_fingerprint] (text_fingerprint of the new text) it also refuses the same
-- text again from this device or IP within 24 h, or from 3+ IPs within 1 h.
-- Returns true when the new content must be stored as shadow.
create or replace function public.guard(p_action text, p_device text, p_fingerprint text default null)
returns boolean language plpgsql volatile security definer set search_path = '' as $$
declare
  lim public.rate_limits%rowtype;
  glob public.rate_limits%rowtype;
  dev public.devices%rowtype;
  blk public.ip_blocks%rowtype;
  v_ip text;
  v_src text;
  v_day bigint;
begin
  if p_device is null or p_device !~ '^[0-9a-f]{64}$' then
    raise exception 'invalid secret' using errcode = '22023';
  end if;
  select * into lim from public.rate_limits r where r.action = p_action;
  if not found then raise exception 'unknown action' using errcode = '22023'; end if;
  select c.ip_hash, c.ip_source into v_ip, v_src from public.client_ip() c;
  -- One write per device at a time, so the counts below are exact.
  perform pg_advisory_xact_lock(hashtextextended('guard:' || p_device, 0));
  if random() < 0.01 then perform public.purge_abuse_data(); end if;

  if v_ip is not null then
    select * into blk from public.ip_blocks b where b.ip_hash = v_ip and b.until > now();
    if found and blk.mode = 'block' then perform public.raise_banned(blk.until); end if;
    select * into glob from public.rate_limits r where r.action = 'all';
    if (select count(*) from public.rate_events e
         where e.ip_hash = v_ip and e.created_at > now() - interval '1 minute') >= glob.ip_minute
       or (select count(*) from public.rate_events e
            where e.ip_hash = v_ip and e.created_at > now() - interval '1 hour') >= glob.ip_hour then
      perform public.raise_limit('burst');
    end if;
  end if;

  select * into dev from public.devices d where d.device_hash = p_device;
  if not found then
    perform public.check_ip_rate(v_ip, 'new_device');
    insert into public.devices (device_hash) values (p_device) on conflict (device_hash) do nothing;
    insert into public.rate_events (action, device_hash, ip_hash, ip_source)
    values ('new_device', p_device, v_ip, v_src);
    select * into dev from public.devices d where d.device_hash = p_device;
  end if;
  if dev.banned_until > now() then perform public.raise_banned(dev.banned_until); end if;

  if lim.min_gap_s > 0 and exists (
    select 1 from public.rate_events e
     where e.device_hash = p_device and e.action = p_action
       and e.created_at > now() - make_interval(secs => lim.min_gap_s)) then
    perform public.raise_limit('burst');
  end if;
  select count(*) into v_day from public.rate_events e
   where e.device_hash = p_device and e.action = p_action
     and e.created_at > now() - interval '1 day';
  if dev.first_seen > now() - interval '10 minutes' and v_day >= lim.new_device_day then
    perform public.raise_limit('new_device');
  end if;
  if v_day >= lim.device_day then perform public.raise_limit('daily'); end if;
  perform public.check_ip_rate(v_ip, p_action);
  perform public.check_repeat(p_fingerprint, p_device, v_ip);

  insert into public.rate_events (action, device_hash, ip_hash, ip_source, fingerprint)
  values (p_action, p_device, v_ip, v_src, p_fingerprint);
  update public.devices d set last_seen = now() where d.device_hash = p_device;
  return coalesce(dev.shadow_until > now(), false) or coalesce(blk.mode = 'shadow', false);
end $$;

-- Hourly and daily cap of one action from one IP hash (none when unknown).
create or replace function public.check_ip_rate(p_ip text, p_action text)
returns void language plpgsql stable security definer set search_path = '' as $$
declare
  lim public.rate_limits%rowtype;
begin
  if p_ip is null then return; end if;
  select * into lim from public.rate_limits r where r.action = p_action;
  if (select count(*) from public.rate_events e where e.ip_hash = p_ip and e.action = p_action
        and e.created_at > now() - interval '1 hour') >= lim.ip_hour then
    perform public.raise_limit('burst');
  end if;
  if (select count(*) from public.rate_events e where e.ip_hash = p_ip and e.action = p_action
        and e.created_at > now() - interval '1 day') >= lim.ip_day then
    perform public.raise_limit('daily');
  end if;
end $$;

create or replace function public.check_repeat(p_fingerprint text, p_device text, p_ip text)
returns void language plpgsql stable security definer set search_path = '' as $$
begin
  if p_fingerprint is null then return; end if;
  if exists (select 1 from public.rate_events e
              where e.fingerprint = p_fingerprint and e.created_at > now() - interval '1 day'
                and (e.device_hash = p_device or e.ip_hash = p_ip))
     or (select count(distinct e.ip_hash) from public.rate_events e
          where e.fingerprint = p_fingerprint and e.created_at > now() - interval '1 hour') >= 3 then
    raise exception 'content blocked: repeat' using errcode = 'P0001',
      hint = 'content_blocked', detail = 'repeat';
  end if;
end $$;

-- ───────────────────────── content filter ─────────────────────────

-- Lower case without Vietnamese accents; NFKD also folds look-alike letters
-- (full-width, math bold) that spammers use to dodge filters.
create or replace function public.fold_text(p text)
returns text language sql immutable set search_path = '' as $$
  select translate(lower(regexp_replace(normalize(coalesce(p, ''), NFKD), '[̀-ͯ]', '', 'g')),
                   'đĐ', 'dd')
$$;

-- " word word " for whole-word matching, with or without accents. Locale
-- independent: after NFKD, Vietnamese letters are ASCII + combining marks + đ.
create or replace function public.word_pad(p text, p_accented boolean)
returns text language sql immutable set search_path = '' as $$
  select ' ' || btrim(case
    when p_accented then regexp_replace(translate(lower(normalize(coalesce(p, ''), NFKD)), 'Đ', 'đ'),
                                        '[^a-z0-9đ̀-ͯ]+', ' ', 'g')
    else regexp_replace(public.fold_text(p), '[^a-z0-9]+', ' ', 'g')
  end) || ' '
$$;

-- md5 of the text without accents, spaces and punctuation; null for short
-- texts ("ok", "cảm ơn") that people legitimately repeat.
create or replace function public.text_fingerprint(p text)
returns text language sql immutable set search_path = '' as $$
  select case when char_length(c) >= 12 then md5(c) end
    from (select regexp_replace(public.fold_text(p), '[^a-z0-9]+', '', 'g') as c) x
$$;

-- Why [p_text] may not be published, or null. Kinds:
--   'text'    free text (comments, chat, notes, reviews): every rule
--   'title'   titles, places, prices: every rule but all-caps
--   'name'    display names: 'title' rules + impersonation
--   'post'    a pond's pasted announcement: no links, no bad words (its
--             phone/Zalo are the pond's own and stay)
--   'contact' phone/Zalo/link fields: only bad words and gambling spam
create or replace function public.content_issue(p_text text, p_kind text)
returns text language plpgsql stable security definer set search_path = '' as $$
declare
  lw text := lower(normalize(coalesce(p_text, ''), NFKC));
  fw text := public.word_pad(p_text, false);
  aw text := public.word_pad(p_text, true);
  fc text := replace(fw, ' ', '');
  nf text := normalize(coalesce(p_text, ''), NFKD);
  v_cat text;
  up int;
  lo int;
begin
  if btrim(fw) = '' then return null; end if;
  if p_kind not in ('contact') and (
       lw ~ 'h\s*t\s*t\s*p\s*s?\s*:\s*/\s*/'
       or lw ~ '(^|[^a-z0-9])www\s*[.,]'
       or lw ~ '[a-z0-9-]{2,}\.(com|net|org|info|biz|xyz|vn|io|site|online|store|club|link|click|live|shop|app|tv|asia|pro|fun|vip|bet|win)([^a-z0-9]|$)'
       or lw ~ '(^|[^a-z0-9])(t|m)\.me/'
       or lw ~ '(bit\.ly|goo\.gl|tinyurl|cutt\.ly|shorturl)'
       or lw ~ '(dot|chấm|cham)\s*(com|net|org|vn)([^a-z0-9]|$)'
       or lw ~ '[(\[]\s*(\.|dot|chấm|cham)\s*[)\]]') then
    return 'link';
  end if;
  if p_kind in ('text', 'title', 'name')
     and public.fold_text(p_text) ~ '(^|[^0-9])(\+\s?84|84|0)[\s.\-]?[1-9]([\s.\-]?[0-9]){8,9}([^0-9]|$)' then
    return 'phone';
  end if;
  select t.category into v_cat from public.blocked_terms t
   where (t.category in ('offensive', 'spam')
          or (t.category = 'contact_ad' and p_kind in ('text', 'title', 'name'))
          or (t.category = 'impersonation' and p_kind = 'name'))
     and (t.match <> 'name_part' or p_kind = 'name')
     and case t.match
           when 'accented' then position(public.word_pad(t.term, true) in aw) > 0
           when 'name_part' then position(replace(public.word_pad(t.term, false), ' ', '') in fc) > 0
           else position(public.word_pad(t.term, false) in fw) > 0
         end
   order by case t.category when 'offensive' then 1 when 'spam' then 2 when 'contact_ad' then 3 else 4 end
   limit 1;
  if v_cat is not null then return v_cat; end if;
  if p_kind in ('text', 'title', 'name') and public.fold_text(p_text) ~ '([a-z])\1{4,}' then
    return 'chars';
  end if;
  if p_kind = 'text' then
    -- ASCII base letters after NFKD: Vietnamese capitals count too.
    up := char_length(regexp_replace(nf, '[^A-Z]', '', 'g'));
    lo := char_length(regexp_replace(nf, '[^a-z]', '', 'g'));
    if up + lo >= 24 and up >= 0.9 * (up + lo) then return 'shouting'; end if;
  end if;
  return null;
end $$;

create or replace function public.check_content(p_text text, p_kind text)
returns void language plpgsql stable security definer set search_path = '' as $$
declare
  v text := public.content_issue(p_text, p_kind);
begin
  if v is not null then
    -- Only the reason code: user text never goes into errors or logs.
    raise exception 'content blocked: %', v using errcode = 'P0001',
      hint = 'content_blocked', detail = v;
  end if;
end $$;

-- ───────────────────────── strikes, shadow, votes ─────────────────────────

-- Shows/hides everything [p_device] posted since [p_since] to other people.
create or replace function public.set_device_shadow(p_device text, p_since timestamptz, p_on boolean)
returns void language plpgsql security definer set search_path = '' as $$
begin
  update public.public_spots x set shadow = p_on where x.owner_hash = p_device and x.created_at >= p_since;
  update public.spot_comments x set shadow = p_on where x.author_hash = p_device and x.created_at >= p_since;
  update public.trips x set shadow = p_on where x.owner_hash = p_device and x.created_at >= p_since;
  update public.trip_messages x set shadow = p_on where x.author_hash = p_device and x.created_at >= p_since;
  -- A pond that has an approved owner since is the owner's, not the creator's.
  update public.ponds x set shadow = p_on
   where x.created_by_hash = p_device and (x.owner_hash is null or x.owner_hash = p_device)
     and x.created_at >= p_since;
  update public.pond_releases x set shadow = p_on where x.created_by_hash = p_device and x.created_at >= p_since;
  update public.pond_reviews x set shadow = p_on where x.author_hash = p_device and x.created_at >= p_since;
  update public.pond_pulses x set shadow = p_on where x.device_hash = p_device and x.created_at >= p_since;
  update public.checkins x set shadow = p_on where x.owner_hash = p_device and x.started_at >= p_since;
  update public.bite_reports x set shadow = p_on where x.owner_hash = p_device and x.created_at >= p_since;
end $$;

-- Content of [p_device] was hidden by reports. Strikes older than 30 days
-- are forgotten; the 3rd strike bans (7, then 30, then 90 days) and shadows
-- the device's last 7 days of content.
create or replace function public.add_strike(p_device text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_strikes int;
begin
  if p_device is null then return; end if;
  insert into public.devices (device_hash) values (p_device) on conflict (device_hash) do nothing;
  update public.devices d
     set strikes = case when d.last_strike_at < now() - interval '30 days' then 1 else d.strikes + 1 end,
         last_strike_at = now()
   where d.device_hash = p_device
  returning d.strikes into v_strikes;
  if v_strikes >= 3 then
    update public.devices d
       set strikes = 0, bans = d.bans + 1,
           banned_until = now() + case d.bans when 0 then interval '7 days'
                                              when 1 then interval '30 days'
                                              else interval '90 days' end
     where d.device_hash = p_device;
    perform public.set_device_shadow(p_device, now() - interval '7 days', true);
  end if;
end $$;

-- Records a report/confirmation; null when this device already voted. Weight:
-- 0 when another device on the same IP already voted on this item or the
-- device is shadowed, 0.5 for a device < 1 day old, else 1.
create or replace function public.cast_vote(p_kind text, p_item uuid, p_device text)
returns real language plpgsql security definer set search_path = '' as $$
declare
  v_ip text := (select c.ip_hash from public.client_ip() c);
  dev public.devices%rowtype;
  w real;
begin
  select * into dev from public.devices d where d.device_hash = p_device;
  w := case
    when v_ip is not null and exists (select 1 from public.item_votes v
          where v.kind = p_kind and v.item_id = p_item and v.ip_hash = v_ip) then 0
    when coalesce(dev.shadow_until > now(), false) then 0
    when dev.first_seen is null or dev.first_seen > now() - interval '1 day' then 0.5
    else 1
  end;
  insert into public.item_votes (kind, item_id, device_hash, ip_hash, weight)
  values (p_kind, p_item, p_device, v_ip, w)
  on conflict do nothing;
  if not found then return null; end if;
  return w;
end $$;

-- Enough reports to hide: total weight ≥ 3 from ≥ 3 different IPs (devices
-- whose IP is unknown count as their own IP).
create or replace function public.votes_hide(p_kind text, p_item uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce(sum(v.weight), 0) >= 3 and count(*) filter (where v.weight > 0) >= 3
    from public.item_votes v where v.kind = p_kind and v.item_id = p_item
$$;

-- ───────────────────────── reports ─────────────────────────

create or replace function public.report_spot(spot_id uuid, reporter_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(reporter_secret);
  s public.public_spots%rowtype;
begin
  perform public.guard('report', h);
  select * into s from public.public_spots x where x.id = report_spot.spot_id for update;
  if not found or s.owner_hash = h then return false; end if;
  insert into public.spot_reports (spot_id, reporter_hash) values (s.id, h) on conflict do nothing;
  if not found then return false; end if;
  perform public.cast_vote('spot', s.id, h);
  update public.public_spots x set report_count = x.report_count + 1 where x.id = s.id;
  if not s.hidden and public.votes_hide('spot', s.id) then
    update public.public_spots x set hidden = true where x.id = s.id;
    perform public.add_strike(s.owner_hash);
  end if;
  return true;
end $$;

create or replace function public.report_comment(p_comment_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  c public.spot_comments%rowtype;
begin
  perform public.guard('report', h);
  select * into c from public.spot_comments x where x.id = p_comment_id for update;
  if not found or c.author_hash = h then return false; end if;
  insert into public.comment_reports (comment_id, reporter_hash) values (c.id, h) on conflict do nothing;
  if not found then return false; end if;
  perform public.cast_vote('comment', c.id, h);
  update public.spot_comments x set report_count = x.report_count + 1 where x.id = c.id;
  if not c.hidden and public.votes_hide('comment', c.id) then
    update public.spot_comments x set hidden = true where x.id = c.id;
    perform public.add_strike(c.author_hash);
  end if;
  return true;
end $$;

create or replace function public.report_trip(p_trip_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  t public.trips%rowtype;
begin
  perform public.guard('report', h);
  select * into t from public.trips x where x.id = p_trip_id for update;
  if not found or t.owner_hash = h then return false; end if;
  insert into public.trip_reports (trip_id, reporter_hash) values (t.id, h) on conflict do nothing;
  if not found then return false; end if;
  perform public.cast_vote('trip', t.id, h);
  update public.trips x set report_count = x.report_count + 1 where x.id = t.id;
  if not t.hidden and public.votes_hide('trip', t.id) then
    update public.trips x set hidden = true where x.id = t.id;
    perform public.add_strike(t.owner_hash);
  end if;
  return true;
end $$;

-- An owned pond is only hidden by the moderator; others like the rest.
create or replace function public.report_pond(p_pond_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  p public.ponds%rowtype;
begin
  perform public.guard('report', h);
  select * into p from public.ponds x where x.id = p_pond_id for update;
  if not found or p.owner_hash = h then return false; end if;
  insert into public.pond_reports (pond_id, device_hash) values (p.id, h) on conflict do nothing;
  if not found then return false; end if;
  perform public.cast_vote('pond', p.id, h);
  update public.ponds x set report_count = x.report_count + 1 where x.id = p.id;
  if not p.hidden and p.owner_hash is null and public.votes_hide('pond', p.id) then
    update public.ponds x set hidden = true where x.id = p.id;
    perform public.add_strike(p.created_by_hash);
  end if;
  return true;
end $$;

-- Before P2-54 every tap counted; now one report per device (false = again).
create or replace function public.report_release(p_release_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  r public.pond_releases%rowtype;
begin
  perform public.guard('report', h);
  select * into r from public.pond_releases x where x.id = p_release_id for update;
  if not found or r.by_owner or r.created_by_hash = h then return false; end if;
  if public.cast_vote('release', r.id, h) is null then return false; end if;
  update public.pond_releases x set report_count = x.report_count + 1 where x.id = r.id;
  if not r.hidden and public.votes_hide('release', r.id) then
    update public.pond_releases x set hidden = true where x.id = r.id;
    perform public.add_strike(r.created_by_hash);
  end if;
  return true;
end $$;

-- ───────────────────────── spots and comments (0001/0002) ─────────────────────────

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
  insert into public.public_spots (owner_hash, title, note, species, location, photos, shadow)
  values (
    h, btrim(title), coalesce(note, ''), coalesce(species, ''),
    extensions.st_makepoint(lon, lat)::extensions.geography, coalesce(photos, '{}'), v_shadow
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
  v_shadow boolean;
begin
  perform public.check_photos(p_photos);
  if not exists (select 1 from public.public_spots s where s.id = p_spot_id and s.owner_hash = h) then
    return false;
  end if;
  v_shadow := public.guard('spot_edit', h);
  perform public.check_content(p_title, 'title');
  perform public.check_content(p_note, 'text');
  perform public.check_content(p_species, 'title');
  update public.public_spots s
     set title = btrim(p_title),
         note = coalesce(p_note, ''),
         species = coalesce(p_species, ''),
         photos = coalesce(p_photos, '{}'),
         shadow = s.shadow or v_shadow,
         updated_at = now()
   where s.id = p_spot_id and s.owner_hash = h;
  return found;
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
                  and (not s.shadow or s.owner_hash = h)) then
    raise exception 'spot not found' using errcode = 'P0002';
  end if;
  v_shadow := public.guard('comment', h, public.text_fingerprint(b));
  perform public.check_content(b, 'text');
  perform public.check_content(v_name, 'name');
  insert into public.spot_comments (spot_id, author_hash, author_name, body, shadow)
  values (p_spot_id, h, v_name, b, v_shadow)
  returning id into new_id;
  return new_id;
end $$;

create or replace function public.edit_comment(p_comment_id uuid, p_body text, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  b text := public.clean_body(p_body);
  v_shadow boolean;
begin
  if not exists (select 1 from public.spot_comments c where c.id = p_comment_id and c.author_hash = h) then
    return false;
  end if;
  v_shadow := public.guard('comment_edit', h);
  perform public.check_content(b, 'text');
  update public.spot_comments c
     set body = b, updated_at = now(), shadow = c.shadow or v_shadow
   where c.id = p_comment_id and c.author_hash = h;
  return found;
end $$;

-- Shadowed spots/comments are listed only for their author.
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
           where c.spot_id = s.id and not c.hidden and (not c.shadow or c.author_hash = me.h))
    from public.public_spots s, me
   where not s.hidden
     and (not s.shadow or s.owner_hash = me.h)
     and extensions.st_dwithin(s.location, extensions.st_makepoint(lon, lat)::extensions.geography,
                               least(greatest(radius_km, 1), 100) * 1000)
   order by 9
   limit 100
$$;

-- ───────────────────────── trips (0002) ─────────────────────────

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
                            starts_at, ends_at, max_people, contact, shadow)
  values (h, v_name, btrim(p_title), left(coalesce(p_note, ''), 500),
          left(btrim(coalesce(p_place_name, '')), 80),
          extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
          p_starts_at, p_ends_at, p_max_people, left(btrim(coalesce(p_contact, '')), 120), v_shadow)
  returning id into new_id;
  -- The owner is the first member.
  insert into public.trip_members (trip_id, member_hash, member_name)
  values (new_id, h, v_name);
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
  v_shadow boolean;
begin
  perform public.check_trip_input(p_title, p_starts_at, p_ends_at, p_max_people);
  select count(*) into members from public.trip_members m where m.trip_id = p_trip_id;
  if p_max_people < members then
    raise exception 'fewer places than members' using errcode = '22023';
  end if;
  if not exists (select 1 from public.trips t
                  where t.id = p_trip_id and t.owner_hash = h and not t.cancelled) then
    return false;
  end if;
  v_shadow := public.guard('trip_edit', h);
  perform public.check_content(p_title, 'title');
  perform public.check_content(p_note, 'text');
  perform public.check_content(p_contact, 'contact');
  update public.trips t
     set title = btrim(p_title), note = left(coalesce(p_note, ''), 500),
         starts_at = p_starts_at, ends_at = p_ends_at, max_people = p_max_people,
         contact = left(btrim(coalesce(p_contact, '')), 120), updated_at = now(),
         shadow = t.shadow or v_shadow
   where t.id = p_trip_id and t.owner_hash = h and not t.cancelled;
  return found;
end $$;

-- 'joined' | 'already' | 'full' | 'closed' (ended, cancelled, hidden or missing).
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
     and t.ends_at > now()
     and (not t.cancelled
          or exists (select 1 from public.trip_members m where m.trip_id = t.id and m.member_hash = me.h))
     and extensions.st_dwithin(t.location, extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
                               least(greatest(p_radius_km, 1), 100) * 1000)
   order by t.starts_at
   limit 100
$$;

create or replace function public.post_trip_message(
  p_trip_id uuid, p_body text, p_name text, p_secret text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  b text := public.clean_body(p_body);
  v_name text := public.clean_name(p_name);
  v_shadow boolean;
  new_id uuid;
begin
  if not exists (select 1 from public.trip_members m where m.trip_id = p_trip_id and m.member_hash = h) then
    raise exception 'not a member' using errcode = '42501';
  end if;
  v_shadow := public.guard('trip_msg', h, public.text_fingerprint(b));
  perform public.check_content(b, 'text');
  perform public.check_content(v_name, 'name');
  insert into public.trip_messages (trip_id, author_hash, author_name, body, shadow)
  values (p_trip_id, h, v_name, b, v_shadow)
  returning id into new_id;
  return new_id;
end $$;

-- Members only; oldest first (a chat). Shadowed messages: author only.
create or replace function public.trip_messages_for(p_trip_id uuid, p_secret text)
returns table (id uuid, author_name text, body text, created_at timestamptz, mine boolean)
language sql stable security definer set search_path = '' as $$
  select x.id, x.author_name, x.body, x.created_at, x.author_hash = public.secret_hash(p_secret)
    from public.trip_messages x
   where x.trip_id = p_trip_id
     and public.valid_secret(p_secret)
     and (not x.shadow or x.author_hash = public.secret_hash(p_secret))
     and exists (select 1 from public.trip_members m
                  where m.trip_id = p_trip_id and m.member_hash = public.secret_hash(p_secret))
   order by x.created_at
   limit 300
$$;

-- ───────────────────────── check-ins and bites (0002/0004) ─────────────────────────

create or replace function public.check_in(
  p_lat double precision, p_lon double precision, p_biting boolean, p_secret text
) returns timestamptz
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  la double precision := round((p_lat / 0.002)::numeric) * 0.002;
  lo double precision := round((p_lon / 0.002)::numeric) * 0.002;
  until_at timestamptz := now() + interval '4 hours';
  v_shadow boolean;
begin
  if p_lat is null or p_lon is null or la not between 7.5 and 23.6 or lo not between 102 and 118 then
    raise exception 'outside Vietnam' using errcode = '22023';
  end if;
  v_shadow := public.guard('checkin', h);
  insert into public.checkins as c (owner_hash, cell_lat, cell_lon, biting, started_at, expires_at, shadow)
  values (h, la, lo, p_biting, now(), until_at, v_shadow)
  on conflict (owner_hash) do update
     set cell_lat = excluded.cell_lat, cell_lon = excluded.cell_lon,
         biting = excluded.biting, expires_at = excluded.expires_at, shadow = excluded.shadow,
         started_at = case when c.expires_at > now() then c.started_at else now() end;
  return until_at;
end $$;

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
     and (not c.shadow or c.owner_hash = me.h)
     and extensions.st_dwithin(
           extensions.st_makepoint(c.cell_lon, c.cell_lat)::extensions.geography,
           extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
           least(greatest(p_radius_km, 1), 100) * 1000)
   group by c.cell_lat, c.cell_lon
   order by 3 desc
   limit 200
$$;

create or replace function public.report_bite(
  p_lat double precision, p_lon double precision, p_bite boolean,
  p_tide_state text, p_local_hour int, p_app_score real, p_secret text
) returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  la double precision := round((p_lat / 0.02)::numeric) * 0.02;
  lo double precision := round((p_lon / 0.02)::numeric) * 0.02;
  v_shadow boolean;
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
  -- One report per device per 30 minutes, 20 per day (P2-37, unchanged).
  if exists (select 1 from public.bite_reports r
              where r.owner_hash = h and r.created_at > now() - interval '30 minutes')
     or (select count(*) from public.bite_reports r
          where r.owner_hash = h and r.created_at > now() - interval '1 day') >= 20 then
    raise exception 'too many reports' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  v_shadow := public.guard('bite', h);
  insert into public.bite_reports (owner_hash, cell_lat, cell_lon, bite, tide_state, local_hour,
                                   app_score, shadow)
  values (h, la, lo, p_bite, p_tide_state, p_local_hour, p_app_score, v_shadow);
  return true;
end $$;

create or replace function public.bite_summary(
  p_lat double precision, p_lon double precision,
  p_radius_km double precision default 15, p_hours int default 3
) returns table (bites bigint, misses bigint, latest timestamptz)
language sql stable security definer set search_path = '' as $$
  select count(*) filter (where r.bite), count(*) filter (where not r.bite), max(r.created_at)
    from public.bite_reports r
   where r.created_at > now() - make_interval(hours => least(greatest(p_hours, 1), 24))
     and not r.shadow
     and extensions.st_dwithin(
           extensions.st_makepoint(r.cell_lon, r.cell_lat)::extensions.geography,
           extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
           least(greatest(p_radius_km, 1), 50) * 1000)
$$;

create or replace function public.bite_patterns(
  p_lat double precision, p_lon double precision, p_radius_km double precision default 30
) returns table (tide_state text, bites bigint, misses bigint)
language sql stable security definer set search_path = '' as $$
  select r.tide_state, count(*) filter (where r.bite), count(*) filter (where not r.bite)
    from public.bite_reports r
   where r.created_at > now() - interval '60 days'
     and r.tide_state is not null
     and not r.shadow
     and extensions.st_dwithin(
           extensions.st_makepoint(r.cell_lon, r.cell_lat)::extensions.geography,
           extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
           least(greatest(p_radius_km, 1), 100) * 1000)
   group by r.tide_state
$$;

-- ───────────────────────── ponds (0003) ─────────────────────────

-- Shared text checks of add_pond/update_pond; the phone field keeps its own
-- rules (it is meant to hold a phone number).
create or replace function public.check_pond_texts(
  p_name text, p_address text, p_phone text, p_price text, p_hours text, p_species text[], p_note text
) returns void language plpgsql stable security definer set search_path = '' as $$
begin
  perform public.check_content(p_name, 'title');
  perform public.check_content(p_address, 'title');
  perform public.check_content(p_phone, 'contact');
  perform public.check_content(p_price, 'title');
  perform public.check_content(p_hours, 'title');
  perform public.check_content(array_to_string(p_species, ', '), 'title');
  perform public.check_content(p_note, 'text');
end $$;

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
  -- Same place already listed: point the user to it instead of a duplicate.
  select x.id into near_id from public.ponds x
   where not x.hidden and not x.shadow and extensions.st_dwithin(x.location, pt, 80) limit 1;
  if near_id is not null then
    raise exception 'pond exists' using errcode = 'P0001', hint = 'duplicate', detail = near_id::text;
  end if;
  insert into public.ponds (name, address, location, phone, price_note, hours_note, species,
                            note, photos, source, created_by_hash, shadow)
  values (public.clean_short(p_name, 100), public.clean_short(p_address, 200), pt,
          public.clean_short(p_phone, 30), public.clean_short(p_price, 120),
          public.clean_short(p_hours, 80), public.clean_species(p_species),
          left(coalesce(p_note, ''), 500), coalesce(p_photos, '{}'), 'user', h, v_shadow)
  returning id into new_id;
  -- The person who adds it vouches for it (and their IP cannot confirm again).
  insert into public.pond_confirms (pond_id, device_hash) values (new_id, h);
  perform public.cast_vote('pond_confirm', new_id, h);
  update public.ponds set confirmations = 1 where id = new_id;
  return new_id;
end $$;

-- A shadowed device's edit of someone else's pond is dropped silently (it
-- would otherwise make a public pond invisible to everyone else).
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
begin
  if char_length(btrim(coalesce(p_name, ''))) < 2 then
    raise exception 'invalid name' using errcode = '22023';
  end if;
  perform public.check_photos(p_photos);
  select * into p from public.ponds x where x.id = p_pond_id and not x.hidden for update;
  if not found then return false; end if;
  if p.owner_hash is not null and p.owner_hash <> h then return false; end if;
  if p.shadow and coalesce(p.created_by_hash, '') <> h then return false; end if;
  v_shadow := public.guard('pond_edit', h);
  perform public.check_pond_texts(p_name, p_address, p_phone, p_price, p_hours, p_species, p_note);
  if v_shadow and coalesce(p.created_by_hash, '') <> h and coalesce(p.owner_hash, '') <> h then
    return true;
  end if;
  insert into public.pond_edits (pond_id, editor_hash, before) values (p.id, h, public.pond_snapshot(p));
  update public.ponds x
     set name = public.clean_short(p_name, 100), address = public.clean_short(p_address, 200),
         location = extensions.st_makepoint(p_lon, p_lat)::extensions.geography,
         approx_location = x.approx_location
           and extensions.st_distance(x.location, extensions.st_makepoint(p_lon, p_lat)::extensions.geography) < 1,
         phone = public.clean_short(p_phone, 30), price_note = public.clean_short(p_price, 120),
         hours_note = public.clean_short(p_hours, 80), species = public.clean_species(p_species),
         note = left(coalesce(p_note, ''), 500), photos = coalesce(p_photos, '{}'),
         shadow = x.shadow or v_shadow, updated_at = now()
   where x.id = p_pond_id;
  return true;
end $$;

-- False when already confirmed from this device. Only the first device per
-- IP (and not shadowed) adds to the count; 3 → verified.
create or replace function public.confirm_pond(p_pond_id uuid, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
begin
  if not exists (select 1 from public.ponds x where x.id = p_pond_id) then return false; end if;
  perform public.guard('pond_confirm', h);
  insert into public.pond_confirms (pond_id, device_hash) values (p_pond_id, h)
  on conflict do nothing;
  if not found then return false; end if;
  if coalesce(public.cast_vote('pond_confirm', p_pond_id, h), 0) > 0 then
    update public.ponds x set confirmations = x.confirmations + 1 where x.id = p_pond_id;
  end if;
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
           where r.pond_id = p.id and not r.hidden and (not r.shadow or r.author_hash = me.h)),
         (select count(*) from public.pond_reviews r
           where r.pond_id = p.id and not r.hidden and (not r.shadow or r.author_hash = me.h)),
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
         and r.starts_at > now() - interval '6 hours'
       order by r.by_owner desc, r.starts_at limit 1
    ) nr on true
   where not p.hidden
     and (not p.shadow or p.created_by_hash = me.h or p.owner_hash = me.h)
     and extensions.st_dwithin(p.location, here.g, least(greatest(p_radius_km, 1), 150) * 1000)
   order by 25
   limit 300
$$;

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
     and (not x.shadow or x.created_by_hash = h);
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
                                    created_by_hash, by_owner, shadow)
  values (p_pond_id, p_starts_at, fish, total, left(coalesce(p_note, ''), 300),
          left(coalesce(p_source_text, ''), 1000), h, v_owner, v_shadow)
  returning id into new_id;
  return new_id;
end $$;

-- Upcoming (and last 30 days of) releases of some ponds, soonest upcoming first.
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
begin
  if p_rating is null or p_rating not between 1 and 5 then
    raise exception 'invalid rating' using errcode = '22023';
  end if;
  if not exists (select 1 from public.ponds x where x.id = p_pond_id and not x.hidden
                  and (not x.shadow or x.created_by_hash = h)) then
    return false;
  end if;
  v_shadow := public.guard('review', h, public.text_fingerprint(b));
  perform public.check_content(b, 'text');
  perform public.check_content(v_name, 'name');
  insert into public.pond_reviews as r (pond_id, author_hash, author_name, rating, body, shadow)
  values (p_pond_id, h, v_name, p_rating, b, v_shadow)
  on conflict (pond_id, author_hash) do update
     set rating = excluded.rating, body = excluded.body, author_name = excluded.author_name,
         shadow = r.shadow or excluded.shadow, updated_at = now();
  return true;
end $$;

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
   order by coalesce(r.updated_at, r.created_at) desc
   limit 100
$$;

-- One quick report per pond per device every 30 minutes (P2-28, unchanged).
create or replace function public.pulse_pond(p_pond_id uuid, p_kind text, p_secret text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  h text := public.require_secret(p_secret);
  v_shadow boolean;
begin
  if p_kind not in ('busy', 'quiet', 'biting', 'released') then
    raise exception 'invalid kind' using errcode = '22023';
  end if;
  if exists (select 1 from public.pond_pulses x where x.pond_id = p_pond_id and x.device_hash = h
              and x.created_at > now() - interval '30 minutes') then
    raise exception 'too fast' using errcode = 'P0001', hint = 'rate_limit';
  end if;
  if not exists (select 1 from public.ponds x where x.id = p_pond_id) then return false; end if;
  v_shadow := public.guard('pulse', h);
  insert into public.pond_pulses (pond_id, device_hash, kind, shadow)
  values (p_pond_id, h, p_kind, v_shadow);
  return true;
end $$;

-- Counts of the last 6 hours (no identities, shadowed reports left out).
create or replace function public.pond_pulse(p_pond_id uuid)
returns table (kind text, people bigint, latest timestamptz)
language sql stable security definer set search_path = '' as $$
  select x.kind, count(distinct x.device_hash), max(x.created_at)
    from public.pond_pulses x
   where x.pond_id = p_pond_id and x.created_at > now() - interval '6 hours' and not x.shadow
   group by x.kind
$$;

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
  perform public.guard('claim', h);
  -- Only the moderator reads claims: contact and note may hold phone/Zalo.
  perform public.check_content(p_contact, 'contact');
  perform public.check_content(p_note, 'contact');
  insert into public.pond_claims (pond_id, claimant_hash, contact, note)
  values (p_pond_id, h, public.clean_short(p_contact, 60), public.clean_short(p_note, 300));
  return 'sent';
end $$;

-- ───────────────────────── moderation (owner only) ─────────────────────────
-- Callable from the Supabase SQL editor (postgres) or with the service_role
-- key; never by anon/authenticated. Usage: docs/moderation.md.

-- Every piece of community content with its author device (internal).
create or replace function public.mod_items()
returns table (kind text, item_id uuid, author_hash text, preview text, reports int,
               hidden boolean, shadow boolean, created_at timestamptz)
language sql stable security definer set search_path = '' as $$
  select 'spot', s.id, s.owner_hash, left(s.title || ' — ' || s.note, 160),
         s.report_count, s.hidden, s.shadow, s.created_at from public.public_spots s
  union all
  select 'comment', c.id, c.author_hash, left(c.author_name || ': ' || c.body, 160),
         c.report_count, c.hidden, c.shadow, c.created_at from public.spot_comments c
  union all
  select 'trip', t.id, t.owner_hash, left(t.owner_name || ': ' || t.title || ' — ' || t.note, 160),
         t.report_count, t.hidden, t.shadow, t.created_at from public.trips t
  union all
  select 'trip_msg', m.id, m.author_hash, left(m.author_name || ': ' || m.body, 160),
         0, false, m.shadow, m.created_at from public.trip_messages m
  union all
  select 'pond', p.id, p.created_by_hash, left(p.name || ' — ' || p.note, 160),
         p.report_count, p.hidden, p.shadow, p.created_at from public.ponds p
  union all
  select 'release', r.id, r.created_by_hash, left(r.note || ' | ' || r.source_text, 160),
         r.report_count, r.hidden, r.shadow, r.created_at from public.pond_releases r
  union all
  -- Reviews are keyed by (pond, author): item_id is the pond.
  select 'review', v.pond_id, v.author_hash, left(v.author_name || ': ' || v.body, 160),
         v.report_count, v.hidden, v.shadow, coalesce(v.updated_at, v.created_at)
    from public.pond_reviews v
$$;

-- Everything posted in the last [p_hours], newest first; [p_device] = one author.
create or replace function public.mod_recent_content(p_hours int default 24, p_device text default null)
returns table (kind text, item_id uuid, author_hash text, preview text, reports int,
               hidden boolean, shadow boolean, created_at timestamptz)
language sql stable security definer set search_path = '' as $$
  select i.* from public.mod_items() i
   where i.created_at > now() - make_interval(hours => least(greatest(p_hours, 1), 24 * 90))
     and (p_device is null or i.author_hash = p_device)
   order by i.created_at desc
   limit 500
$$;

-- Reported items of the last [p_days], most weighty first.
create or replace function public.mod_flagged(p_days int default 7)
returns table (kind text, item_id uuid, author_hash text, preview text, reports bigint,
               weight real, distinct_ips bigint, hidden boolean, shadow boolean,
               last_report timestamptz)
language sql stable security definer set search_path = '' as $$
  select v.kind, v.item_id, i.author_hash, i.preview, count(*), sum(v.weight)::real,
         count(*) filter (where v.weight > 0), i.hidden, i.shadow, max(v.created_at)
    from public.item_votes v
    join public.mod_items() i on i.kind = v.kind and i.item_id = v.item_id
   where v.kind <> 'pond_confirm'
   group by v.kind, v.item_id, i.author_hash, i.preview, i.hidden, i.shadow
  having max(v.created_at) > now() - make_interval(days => least(greatest(p_days, 1), 90))
   order by 6 desc, 10 desc
   limit 200
$$;

-- Busiest IP hashes: many devices or new devices on one IP = scripted spam
-- (or a carrier NAT: look at what they posted before blocking).
create or replace function public.mod_top_ips(p_hours int default 24, p_limit int default 20)
returns table (ip_hash text, events bigint, devices bigint, new_devices bigint, actions text,
               last_at timestamptz, blocked text)
language sql stable security definer set search_path = '' as $$
  select e.ip_hash, count(*), count(distinct e.device_hash),
         count(*) filter (where e.action = 'new_device'),
         string_agg(distinct e.action, ', '), max(e.created_at),
         (select b.mode || ' → ' || b.until::text from public.ip_blocks b
           where b.ip_hash = e.ip_hash and b.until > now())
    from public.rate_events e
   where e.ip_hash is not null
     and e.created_at > now() - make_interval(hours => least(greatest(p_hours, 1), 24 * 7))
   group by e.ip_hash
   order by 2 desc
   limit least(greatest(p_limit, 1), 200)
$$;

create or replace function public.mod_top_devices(p_hours int default 24, p_limit int default 20)
returns table (device_hash text, events bigint, ips bigint, actions text, first_seen timestamptz,
               strikes int, bans int, banned_until timestamptz, shadow_until timestamptz)
language sql stable security definer set search_path = '' as $$
  select e.device_hash, count(*), count(distinct e.ip_hash), string_agg(distinct e.action, ', '),
         d.first_seen, d.strikes, d.bans, d.banned_until, d.shadow_until
    from public.rate_events e
    left join public.devices d on d.device_hash = e.device_hash
   where e.created_at > now() - make_interval(hours => least(greatest(p_hours, 1), 24 * 7))
   group by e.device_hash, d.first_seen, d.strikes, d.bans, d.banned_until, d.shadow_until
   order by 2 desc
   limit least(greatest(p_limit, 1), 200)
$$;

-- Which header gave the IP ('none' everywhere = IP limits are not working).
create or replace function public.mod_ip_sources(p_hours int default 24)
returns table (ip_source text, events bigint)
language sql stable security definer set search_path = '' as $$
  select e.ip_source, count(*) from public.rate_events e
   where e.created_at > now() - make_interval(hours => least(greatest(p_hours, 1), 24 * 7))
   group by e.ip_source order by 2 desc
$$;

create or replace function public.mod_check_device(p_device text)
returns void language plpgsql immutable set search_path = '' as $$
begin
  if p_device is null or p_device !~ '^[0-9a-f]{64}$' then
    raise exception 'device hash must be 64 hex chars' using errcode = '22023';
  end if;
end $$;

-- Bans posting for [p_days]; by default also shadows its last 7 days.
create or replace function public.mod_ban_device(
  p_device text, p_days int default 7, p_note text default '', p_shadow_recent boolean default true
) returns timestamptz language plpgsql security definer set search_path = '' as $$
declare
  v_until timestamptz := now() + make_interval(days => least(greatest(p_days, 1), 3650));
begin
  perform public.mod_check_device(p_device);
  insert into public.devices (device_hash) values (p_device) on conflict (device_hash) do nothing;
  update public.devices d
     set banned_until = v_until, bans = d.bans + 1, note = left(coalesce(p_note, ''), 300)
   where d.device_hash = p_device;
  if p_shadow_recent then
    perform public.set_device_shadow(p_device, now() - interval '7 days', true);
  end if;
  return v_until;
end $$;

-- Lifts ban and shadow, forgets strikes; [p_restore] shows its content again.
create or replace function public.mod_unban_device(p_device text, p_restore boolean default true)
returns void language plpgsql security definer set search_path = '' as $$
begin
  perform public.mod_check_device(p_device);
  update public.devices d
     set banned_until = null, shadow_until = null, strikes = 0, last_strike_at = null
   where d.device_hash = p_device;
  if p_restore then
    perform public.set_device_shadow(p_device, '-infinity'::timestamptz, false);
  end if;
end $$;

-- Lets the device keep posting, but nobody else sees it (for ban evaders).
create or replace function public.mod_shadow_device(p_device text, p_days int default 30)
returns timestamptz language plpgsql security definer set search_path = '' as $$
declare
  v_until timestamptz := now() + make_interval(days => least(greatest(p_days, 1), 3650));
begin
  perform public.mod_check_device(p_device);
  insert into public.devices (device_hash) values (p_device) on conflict (device_hash) do nothing;
  update public.devices d set shadow_until = v_until where d.device_hash = p_device;
  perform public.set_device_shadow(p_device, now() - interval '7 days', true);
  return v_until;
end $$;

-- At most 7 days (IP data retention); 'block' refuses, 'shadow' hides.
create or replace function public.mod_block_ip(
  p_ip_hash text, p_hours int default 24, p_mode text default 'block', p_note text default ''
) returns timestamptz language plpgsql security definer set search_path = '' as $$
declare
  v_until timestamptz := now() + make_interval(hours => least(greatest(p_hours, 1), 168));
begin
  perform public.mod_check_device(p_ip_hash);
  if p_mode not in ('block', 'shadow') then
    raise exception 'mode must be block or shadow' using errcode = '22023';
  end if;
  insert into public.ip_blocks (ip_hash, mode, until, note)
  values (p_ip_hash, p_mode, v_until, left(coalesce(p_note, ''), 300))
  on conflict (ip_hash) do update
     set mode = excluded.mode, until = excluded.until, note = excluded.note;
  return v_until;
end $$;

create or replace function public.mod_unblock_ip(p_ip_hash text)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  delete from public.ip_blocks b where b.ip_hash = p_ip_hash;
  return found;
end $$;

-- Hides/shows one item. Reviews: [p_id] = pond id and [p_author] = author
-- hash. [p_strike] also gives the author a strike when hiding.
create or replace function public.mod_set_hidden(
  p_kind text, p_id uuid, p_hidden boolean, p_author text default null, p_strike boolean default false
) returns int language plpgsql security definer set search_path = '' as $$
declare
  n int;
  v_author text;
begin
  case p_kind
    when 'spot' then
      update public.public_spots x set hidden = p_hidden where x.id = p_id returning x.owner_hash into v_author;
    when 'comment' then
      update public.spot_comments x set hidden = p_hidden where x.id = p_id returning x.author_hash into v_author;
    when 'trip' then
      update public.trips x set hidden = p_hidden where x.id = p_id returning x.owner_hash into v_author;
    when 'trip_msg' then
      -- Chat messages have no hidden flag: hiding = shadow (author still sees it).
      update public.trip_messages x set shadow = p_hidden where x.id = p_id returning x.author_hash into v_author;
    when 'pond' then
      update public.ponds x set hidden = p_hidden where x.id = p_id returning x.created_by_hash into v_author;
    when 'release' then
      update public.pond_releases x set hidden = p_hidden where x.id = p_id returning x.created_by_hash into v_author;
    when 'review' then
      update public.pond_reviews x set hidden = p_hidden
       where x.pond_id = p_id and x.author_hash = p_author returning x.author_hash into v_author;
    else
      raise exception 'unknown kind' using errcode = '22023';
  end case;
  get diagnostics n = row_count;
  if n > 0 and p_hidden and p_strike then perform public.add_strike(v_author); end if;
  return n;
end $$;

-- ───────────────────────── grants and cleanup schedule ─────────────────────────

do $$
declare
  f text;
  api boolean := exists (select 1 from pg_roles where rolname = 'anon');
begin
  -- Internal helpers: only other SECURITY DEFINER functions call them.
  foreach f in array array[
    'public.client_ip()', 'public.raise_limit(text)', 'public.raise_banned(timestamptz)',
    'public.purge_abuse_data()', 'public.guard(text, text, text)',
    'public.check_ip_rate(text, text)', 'public.check_repeat(text, text, text)',
    'public.fold_text(text)', 'public.word_pad(text, boolean)', 'public.text_fingerprint(text)',
    'public.content_issue(text, text)', 'public.check_content(text, text)',
    'public.set_device_shadow(text, timestamptz, boolean)', 'public.add_strike(text)',
    'public.cast_vote(text, uuid, text)', 'public.votes_hide(text, uuid)',
    'public.check_pond_texts(text, text, text, text, text, text[], text)',
    'public.mod_items()', 'public.mod_check_device(text)'
  ] loop
    execute format('revoke all on function %s from public', f);
    if api then execute format('revoke all on function %s from anon, authenticated', f); end if;
  end loop;
  -- Moderation: SQL editor (postgres) and service_role only.
  foreach f in array array[
    'public.mod_recent_content(int, text)', 'public.mod_flagged(int)',
    'public.mod_top_ips(int, int)', 'public.mod_top_devices(int, int)',
    'public.mod_ip_sources(int)', 'public.mod_ban_device(text, int, text, boolean)',
    'public.mod_unban_device(text, boolean)', 'public.mod_shadow_device(text, int)',
    'public.mod_block_ip(text, int, text, text)', 'public.mod_unblock_ip(text)',
    'public.mod_set_hidden(text, uuid, boolean, text, boolean)'
  ] loop
    execute format('revoke all on function %s from public', f);
    if api then
      execute format('revoke all on function %s from anon, authenticated', f);
      execute format('grant execute on function %s to service_role', f);
    end if;
  end loop;
  -- Daily cleanup when pg_cron is enabled (guard() also cleans up now and then).
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule('purge-abuse-data', '17 3 * * *', 'select public.purge_abuse_data()');
  end if;
end $$;
