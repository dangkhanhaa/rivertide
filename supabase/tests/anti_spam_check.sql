-- P2-54 anti-spam check. Run after 0005_anti_spam.sql, e.g. in the Supabase
-- SQL editor or: psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/anti_spam_check.sql
-- Everything runs inside BEGIN … ROLLBACK: it leaves no data behind. Client
-- IPs are simulated with set_config('request.headers', …) like PostgREST does.
-- Success = the last line prints "ALL ANTI-SPAM CHECKS PASSED"; any failure
-- stops with an error that starts with "FAIL".

begin;

-- ── helpers (temporary, gone after the transaction) ──
create function pg_temp.ok(p_cond boolean, p_label text) returns void
language plpgsql as $$
begin
  if p_cond is distinct from true then raise exception 'FAIL: %', p_label; end if;
  raise notice 'PASS %', p_label;
end $$;

-- A test device secret (64 hex) from a name.
create function pg_temp.sec(p_name text) returns text
language sql immutable as $$ select md5(p_name) || md5(p_name || '#') $$;

create function pg_temp.hash(p_name text) returns text
language sql immutable as $$ select public.secret_hash(pg_temp.sec(p_name)) $$;

-- Simulates the caller's IP (null = no header, like local dev).
create function pg_temp.ip(p_ip text) returns void
language sql as $$
  select set_config('request.headers',
    case when p_ip is null then '' else json_build_object('x-forwarded-for', p_ip || ', 172.16.0.1')::text end,
    true)
$$;

-- A device that has existed for 2 days (no "new device" limits, full report weight).
create function pg_temp.mature(p_name text) returns void
language sql as $$
  insert into public.devices (device_hash, first_seen)
  values (pg_temp.hash(p_name), now() - interval '2 days')
  on conflict (device_hash) do update set first_seen = now() - interval '2 days'
$$;

-- now() is fixed inside a transaction: move past activity back instead.
create function pg_temp.later(p interval) returns void
language sql as $$
  update public.rate_events set created_at = created_at - p;
  update public.devices set first_seen = first_seen - p;
$$;

-- Runs [p_sql]; it must fail with this hint (and detail when given).
create function pg_temp.expect_err(p_sql text, p_hint text, p_detail text default null)
returns void language plpgsql as $$
declare
  v_hint text;
  v_detail text;
begin
  begin
    execute p_sql;
  exception when others then
    get stacked diagnostics v_hint = pg_exception_hint, v_detail = pg_exception_detail;
    if v_hint is distinct from p_hint or (p_detail is not null and v_detail is distinct from p_detail) then
      raise exception 'FAIL: % → hint=% detail=% (expected %/%): %',
        left(p_sql, 90), v_hint, v_detail, p_hint, p_detail, sqlerrm;
    end if;
    raise notice 'PASS refused %/%: %', v_hint, v_detail, left(p_sql, 90);
    return;
  end;
  raise exception 'FAIL: expected % but it succeeded: %', p_hint, left(p_sql, 90);
end $$;

-- ── 1. content filter: blocks and false positives ──
select pg_temp.ok(public.content_issue(t, k) is not distinct from want,
                  format('filter %s [%s] → %s', t, k, coalesce(want, 'ok')))
  from (values
    ('xem thêm tại cauca.com nhé', 'text', 'link'),
    ('vào https://abc.xyz', 'text', 'link'),
    ('web: www . cauca . vn', 'text', 'link'),
    ('abc chấm com', 'text', 'link'),
    ('liên hệ t.me/cauca', 'text', 'link'),
    ('gọi 0912 345 678 nha', 'text', 'phone'),
    ('đt 0912.345.678', 'text', 'phone'),
    ('+84 912 345 678', 'text', 'phone'),
    ('máy bàn 028 3823 4567', 'text', 'phone'),
    ('ib mình nhé', 'text', 'contact_ad'),
    ('kết bạn Zalo để biết thêm', 'text', 'contact_ad'),
    ('tài xỉu uy tín', 'text', 'spam'),
    ('cá độ bóng đá', 'text', 'spam'),
    ('đm thằng này', 'text', 'offensive'),
    ('ĐỊT MẸ', 'text', 'offensive'),
    ('ngonnnnnn quá', 'text', 'chars'),
    ('CÁ ĂN MẠNH LẮM MỌI NGƯỜI ƠI RA NGAY ĐI', 'text', 'shouting'),
    ('Admin Con Nước', 'name', 'impersonation'),
    ('Quản trị viên', 'name', 'impersonation'),
    ('ad min', 'name', 'impersonation'),
    -- must stay allowed
    ('Cá lớn quá, các bạn ra buổi sáng nhé', 'text', null),
    ('Câu mồi cơm, cám gạo', 'text', null),
    ('Giải thưởng 100.000.000đ, vé 500.000', 'text', null),
    ('đẹp quá.Có ai đi không', 'text', null),
    ('Xả lúc 05.30 - 07.30 ngày 05-11-2026', 'text', null),
    ('cá đỏ đuôi', 'text', null),
    ('HỒ CÂU THANH TÂM', 'title', null),
    ('Khánh Cần Thủ', 'name', null),
    ('0912345678', 'contact', null),
    ('https://zalo.me/0912345678', 'contact', null),
    ('Hồ có Zalo 0912 345 678, xả 500kg chép', 'post', null),
    ('Hồ ở abc.com', 'post', 'link')
  ) v (t, k, want);

-- ── 2. setup: a spot to comment on ──
select pg_temp.ip('10.0.0.9');
select pg_temp.mature('spotter');
do $$
begin
  perform public.publish_spot('Bến đò cũ', 'Nước rút câu được', 'Cá tra', 10.03, 105.78,
                              '{}', pg_temp.sec('spotter'));
end $$;

-- ── 3. rate limits ──
select pg_temp.ip('10.0.0.1');
select pg_temp.ok(public.add_comment(s.id, 'Chỗ này câu đêm được không anh', '', pg_temp.sec('c1')) is not null,
                  'first comment of a new device accepted')
  from public.public_spots s where s.owner_hash = pg_temp.hash('spotter');
select pg_temp.expect_err(format(
  'select public.add_comment(%L, %L, %L, %L)',
  (select id from public.public_spots where owner_hash = pg_temp.hash('spotter')),
  'Thêm câu nữa', '', pg_temp.sec('c1')), 'rate_limit', 'burst');

-- New device (< 10 min): 5 comments, then 'new_device'.
select pg_temp.ip('10.0.0.2');
do $$
declare
  sid uuid := (select id from public.public_spots where owner_hash = pg_temp.hash('spotter'));
begin
  for i in 1..5 loop
    perform public.add_comment(sid, 'Bình luận số ' || i, '', pg_temp.sec('c2'));
    update public.rate_events set created_at = created_at - interval '20 seconds';
  end loop;
end $$;
select pg_temp.expect_err(format('select public.add_comment(%L, %L, %L, %L)',
  (select id from public.public_spots where owner_hash = pg_temp.hash('spotter')),
  'Bình luận số 6', '', pg_temp.sec('c2')), 'rate_limit', 'new_device');

-- Same text again (same device, then another device on the same IP).
select pg_temp.ip('10.0.0.3');
select pg_temp.mature('c3');
select pg_temp.mature('c3b');
select public.add_comment(id, 'Hôm nay cá ăn mạnh lắm mọi người', '', pg_temp.sec('c3'))
  from public.public_spots where owner_hash = pg_temp.hash('spotter');
select pg_temp.later('1 minute');
select pg_temp.expect_err(format('select public.add_comment(%L, %L, %L, %L)',
  (select id from public.public_spots where owner_hash = pg_temp.hash('spotter')),
  'hôm nay  cá ăn mạnh lắm, mọi người!', '', pg_temp.sec('c3')), 'content_blocked', 'repeat');
select pg_temp.expect_err(format('select public.add_comment(%L, %L, %L, %L)',
  (select id from public.public_spots where owner_hash = pg_temp.hash('spotter')),
  'Hôm nay cá ăn mạnh lắm mọi người', '', pg_temp.sec('c3b')), 'content_blocked', 'repeat');

-- Content filter through the RPCs.
select pg_temp.ip('10.0.0.4');
select pg_temp.expect_err(format('select public.add_comment(%L, %L, %L, %L)',
  (select id from public.public_spots where owner_hash = pg_temp.hash('spotter')),
  'Mua cần câu giá rẻ tại cancau.vn', '', pg_temp.sec('c4')), 'content_blocked', 'link');
select pg_temp.expect_err(format('select public.add_comment(%L, %L, %L, %L)',
  (select id from public.public_spots where owner_hash = pg_temp.hash('spotter')),
  'Bán mồi, gọi 0987 654 321', '', pg_temp.sec('c4')), 'content_blocked', 'phone');
select pg_temp.expect_err(format('select public.add_comment(%L, %L, %L, %L)',
  (select id from public.public_spots where owner_hash = pg_temp.hash('spotter')),
  'Chào cả nhà', 'Admin', pg_temp.sec('c4')), 'content_blocked', 'impersonation');

-- No IP header (local dev): device limits only, still works.
select pg_temp.ip(null);
select pg_temp.ok(public.add_comment(id, 'Không có header IP', '', pg_temp.sec('c5')) is not null,
                  'works without IP header')
  from public.public_spots where owner_hash = pg_temp.hash('spotter');
select pg_temp.ok((select ip_hash is null and ip_source = 'none' from public.rate_events
                    where device_hash = pg_temp.hash('c5') and action = 'comment'),
                  'no header → no IP stored');
select pg_temp.ok((select count(*) = 0 from public.rate_events where ip_hash = '10.0.0.1'),
                  'raw IP never stored');

-- cf-connecting-ip wins over a forged x-forwarded-for.
select set_config('request.headers',
  '{"cf-connecting-ip":"203.0.113.7","x-forwarded-for":"1.1.1.1, 203.0.113.7"}', true);
select pg_temp.ok((select ip_source = 'cf' from public.client_ip()), 'cf-connecting-ip preferred');
-- IPv6 grouped by /64.
select set_config('request.headers', '{"x-forwarded-for":"2001:db8:1:2:aaaa::1"}', true);
create temp table v6 as select ip_hash from public.client_ip();
select set_config('request.headers', '{"x-forwarded-for":"2001:db8:1:2:bbbb::9"}', true);
select pg_temp.ok((select ip_hash from public.client_ip()) = (select ip_hash from v6), 'IPv6 same /64 = same IP');

-- New secrets per IP: 10 per hour, then refused.
select pg_temp.ip('10.0.0.50');
do $$
begin
  for i in 1..10 loop
    perform public.check_in(10.03, 105.78, null, pg_temp.sec('flood' || i));
  end loop;
end $$;
select pg_temp.expect_err(format('select public.check_in(10.03, 105.78, null, %L)',
  pg_temp.sec('flood11')), 'rate_limit', 'burst');

-- Global per-IP burst (lowered for the test).
update public.rate_limits set ip_minute = 3 where action = 'all';
select pg_temp.ip('10.0.0.60');
select pg_temp.mature('g' || i) from generate_series(1, 4) i;
select public.check_in(10.03, 105.78, null, pg_temp.sec('g' || i)) from generate_series(1, 3) i;
select pg_temp.expect_err(format('select public.check_in(10.03, 105.78, null, %L)', pg_temp.sec('g4')),
  'rate_limit', 'burst');
update public.rate_limits set ip_minute = 40 where action = 'all';

-- ── 4. report brigading ──
select pg_temp.ip('10.1.0.1');
select pg_temp.mature('author');
select public.publish_spot('Điểm của tác giả ' || i, '', '', 10.03 + i * 0.01, 105.78, '{}', pg_temp.sec('author'))
  from generate_series(1, 1) i;
select pg_temp.later('2 minutes');
-- 5 mature devices, one IP: only the first counts.
select pg_temp.mature('r' || i) from generate_series(1, 9) i;
select pg_temp.ip('10.2.0.1');
select public.report_spot(s.id, pg_temp.sec('r' || i))
  from public.public_spots s, generate_series(1, 5) i
 where s.owner_hash = pg_temp.hash('author');
select pg_temp.ok((select not hidden and report_count = 5 from public.public_spots
                    where owner_hash = pg_temp.hash('author')),
                  '5 reports from one IP do not hide');
select pg_temp.ip('10.3.0.1');
select public.report_spot(id, pg_temp.sec('r6')) from public.public_spots where owner_hash = pg_temp.hash('author');
select pg_temp.ok((select not hidden from public.public_spots where owner_hash = pg_temp.hash('author')),
                  '2 IPs do not hide');
select pg_temp.ip('10.4.0.1');
select public.report_spot(id, pg_temp.sec('r7')) from public.public_spots where owner_hash = pg_temp.hash('author');
select pg_temp.ok((select hidden from public.public_spots where owner_hash = pg_temp.hash('author')),
                  '3 mature devices on 3 IPs hide');
select pg_temp.ok((select strikes = 1 from public.devices where device_hash = pg_temp.hash('author')),
                  'author got a strike');

-- Young reporters count half: 3 new devices on 3 IPs do not hide.
select pg_temp.ip('10.1.0.2');
select pg_temp.mature('author2');
select public.publish_spot('Điểm khác', '', '', 10.5, 105.9, '{}', pg_temp.sec('author2'));
do $$
declare
  sid uuid := (select id from public.public_spots where owner_hash = pg_temp.hash('author2'));
begin
  for i in 1..3 loop
    perform pg_temp.ip('10.5.0.' || i);
    perform public.report_spot(sid, pg_temp.sec('young' || i));
  end loop;
end $$;
select pg_temp.ok((select not hidden from public.public_spots where owner_hash = pg_temp.hash('author2')),
                  '3 new devices (< 1 day) do not hide');

-- Reporter limit: a new device may report 3 times, then 'new_device'.
select pg_temp.ip('10.6.0.1');
do $$
begin
  for i in 1..3 loop
    perform public.report_comment(gen_random_uuid(), pg_temp.sec('reporter'));
    update public.rate_events set created_at = created_at - interval '5 seconds';
  end loop;
end $$;
select pg_temp.expect_err(format('select public.report_comment(%L, %L)', gen_random_uuid(),
  pg_temp.sec('reporter')), 'rate_limit', 'new_device');

-- ── 5. strikes → ban → shadow ──
select pg_temp.ip('10.1.0.1');
do $$
begin
  -- Two more spots, then a comment that stays unreported.
  perform public.publish_spot('Điểm thứ hai', '', '', 11.0, 106.0, '{}', pg_temp.sec('author'));
  perform pg_temp.later('2 minutes');
  perform public.publish_spot('Điểm thứ ba', '', '', 11.1, 106.1, '{}', pg_temp.sec('author'));
  perform pg_temp.later('2 minutes');
  perform public.publish_spot('Điểm không ai báo', '', '', 11.2, 106.2, '{}', pg_temp.sec('author'));
  perform pg_temp.later('2 minutes');
end $$;
do $$
declare
  s record;
begin
  for s in select id from public.public_spots
            where owner_hash = pg_temp.hash('author') and title in ('Điểm thứ hai', 'Điểm thứ ba') loop
    for i in 7..9 loop
      perform pg_temp.ip('10.7.' || i || '.1');
      perform public.report_spot(s.id, pg_temp.sec('r' || i));
      perform pg_temp.later('10 seconds');
    end loop;
  end loop;
end $$;
select pg_temp.ok((select banned_until > now() + interval '6 days' from public.devices
                    where device_hash = pg_temp.hash('author')), '3 strikes → banned ~7 days');
select pg_temp.ok((select shadow and not hidden from public.public_spots
                    where owner_hash = pg_temp.hash('author') and title = 'Điểm không ai báo'),
                  'banned author''s other content is shadow');
select pg_temp.ip('10.1.0.1');
select pg_temp.expect_err(format(
  'select public.publish_spot(%L, %L, %L, 11.3, 106.3, %L, %L)', 'Điểm mới', '', '', '{}',
  pg_temp.sec('author')), 'banned');
select pg_temp.ok(exists (select 1 from public.nearby_spots(11.2, 106.2, 5, pg_temp.sec('author'))
                           where title = 'Điểm không ai báo' and mine),
                  'shadow spot visible to its author');
select pg_temp.ok(not exists (select 1 from public.nearby_spots(11.2, 106.2, 5, pg_temp.sec('someone'))
                               where title = 'Điểm không ai báo'),
                  'shadow spot hidden from others');
select pg_temp.ok(not exists (select 1 from public.nearby_spots(11.2, 106.2, 5, '')
                               where title = 'Điểm không ai báo'),
                  'shadow spot hidden from anonymous readers');

-- ── 6. ponds: confirmations need different IPs; phone field keeps phones ──
select pg_temp.ip('10.8.0.1');
select pg_temp.mature('pondman');
select pg_temp.ok(public.add_pond('Hồ câu Thanh Tâm', 'Ấp 3, xã Tân Phú', 10.9, 106.7, '0912 345 678',
                                  '50k/giờ', '6h–18h', array['Chép', 'Trắm'], 'Có mái che',
                                  '{}', pg_temp.sec('pondman')) is not null,
                  'pond with phone in the phone field accepted');
select pg_temp.later('2 minutes');
select pg_temp.expect_err(format(
  'select public.add_pond(%L, %L, 12.0, 107.0, %L, %L, %L, %L, %L, %L, %L)',
  'Hồ mới', '', '', '', '', '{}', 'Liên hệ zalo chủ hồ', '{}', pg_temp.sec('pondman')),
  'content_blocked', 'contact_ad');
select pg_temp.mature('confirmer1');
select public.confirm_pond(id, pg_temp.sec('confirmer1')) from public.ponds where name = 'Hồ câu Thanh Tâm';
select pg_temp.ok((select confirmations = 1 from public.ponds where name = 'Hồ câu Thanh Tâm'),
                  'confirm from the creator''s IP does not count');
select pg_temp.ip('10.8.0.2');
select pg_temp.mature('confirmer2');
select public.confirm_pond(id, pg_temp.sec('confirmer2')) from public.ponds where name = 'Hồ câu Thanh Tâm';
select pg_temp.ok((select confirmations = 2 from public.ponds where name = 'Hồ câu Thanh Tâm'),
                  'confirm from another IP counts');

-- Release reports: one per device now.
select pg_temp.ip('10.8.0.3');
select pg_temp.mature('relayer');
select public.post_release(id, now() + interval '1 day', '[{"species":"Chép","kg":300}]', '', '',
                           pg_temp.sec('relayer'))
  from public.ponds where name = 'Hồ câu Thanh Tâm';
select pg_temp.ip('10.8.0.4');
select pg_temp.mature('flagger');
select pg_temp.ok(public.report_release(id, pg_temp.sec('flagger')), 'first release report counts')
  from public.pond_releases where created_by_hash = pg_temp.hash('relayer');
select pg_temp.later('10 seconds');
select pg_temp.ok(not public.report_release(id, pg_temp.sec('flagger')), 'second release report ignored')
  from public.pond_releases where created_by_hash = pg_temp.hash('relayer');

-- ── 7. every other changed RPC still runs (same signatures as the app uses) ──
select pg_temp.ip('10.9.0.1');
select pg_temp.mature('smoke');
select pg_temp.mature('smoke2');
do $$
declare
  me text := pg_temp.sec('smoke');
  other text := pg_temp.sec('smoke2');
  sid uuid;
  cid uuid;
  tid uuid;
  pid uuid;
begin
  sid := public.publish_spot('Điểm thử', 'Ghi chú', 'Cá lóc', 9.5, 105.5, '{}', me);
  perform pg_temp.later('2 minutes');
  perform pg_temp.ok(public.update_spot(sid, 'Điểm thử sửa', 'Ghi chú mới', '', '{}', me), 'update_spot');
  cid := public.add_comment(sid, 'Bình luận để sửa', 'Người thử', me);
  perform pg_temp.later('1 minute');
  perform pg_temp.ok(public.edit_comment(cid, 'Bình luận đã sửa', me), 'edit_comment');
  perform pg_temp.ok((select count(*) = 1 from public.list_comments(sid, other)), 'list_comments');
  perform pg_temp.ok((select comment_count = 1 from public.nearby_spots(9.5, 105.5, 5, other) where id = sid),
                     'nearby_spots comment_count');
  tid := public.create_trip('Đi câu sáng mai', 'Mang mồi trùn', 'Bến Ninh Kiều', 10.03, 105.78,
                            now() + interval '1 day', now() + interval '1 day 4 hours', 5,
                            'zalo.me/0912345678', 'Người thử', me);
  perform pg_temp.later('2 minutes');
  perform pg_temp.ok(public.update_trip(tid, 'Đi câu sáng mai sửa', '', now() + interval '1 day',
                                        now() + interval '1 day 3 hours', 6, '0912345678', me), 'update_trip');
  perform pg_temp.ok(public.join_trip(tid, 'Bạn câu', other) = 'joined', 'join_trip');
  perform public.post_trip_message(tid, 'Mấy giờ đi anh', 'Bạn câu', other);
  perform pg_temp.ok((select count(*) = 1 from public.trip_messages_for(tid, me)), 'trip_messages_for');
  perform pg_temp.ok(exists (select 1 from public.nearby_trips(10.03, 105.78, 5, other) where id = tid and joined),
                     'nearby_trips');
  perform pg_temp.later('10 seconds');
  perform pg_temp.ok(public.report_trip(tid, other), 'report_trip');
  perform pg_temp.later('10 seconds');
  perform pg_temp.ok(public.report_comment(cid, other), 'report_comment');
  perform public.check_in(21.03, 105.85, true, me);
  perform pg_temp.ok((select bool_or(mine) from public.nearby_checkins(21.03, 105.85, 5, me)), 'nearby_checkins');
  perform public.report_bite(10.03, 105.78, true, 'rising', 6, 7.5, me);
  perform pg_temp.ok((select bites >= 1 from public.bite_summary(10.03, 105.78, 15, 3)), 'bite_summary');
  perform pg_temp.ok((select count(*) >= 1 from public.bite_patterns(10.03, 105.78, 30)), 'bite_patterns');
  pid := public.add_pond('Hồ thử nghiệm', '', 9.9, 105.9, '', '', '', '{}', '', '{}', me);
  perform pg_temp.later('2 minutes');
  perform pg_temp.ok(public.update_pond(pid, 'Hồ thử nghiệm 2', 'Ấp 1', 9.9, 105.9, '0912345678',
                                        '', '', array['Rô phi'], 'Ghi chú', '{}', other), 'update_pond');
  perform pg_temp.ok(public.review_pond(pid, 4, 'Hồ sạch, cá ăn đều', 'Bạn câu', other), 'review_pond');
  perform pg_temp.ok((select count(*) = 1 from public.reviews_for(pid, me)), 'reviews_for');
  perform pg_temp.ok(public.pulse_pond(pid, 'busy', other), 'pulse_pond');
  perform pg_temp.ok((select count(*) = 1 from public.pond_pulse(pid)), 'pond_pulse');
  perform public.post_release(pid, now() + interval '2 days', '[{"species":"Chép","kg":200}]', 'Xả chiều',
                              'Hồ xả 200kg chép, liên hệ 0912 345 678', other);
  perform pg_temp.ok((select count(*) = 1 from public.releases_for(array[pid], me)), 'releases_for');
  perform pg_temp.ok(exists (select 1 from public.nearby_ponds(9.9, 105.9, 5, me)
                              where id = pid and review_count = 1 and next_release_kg = 200), 'nearby_ponds');
  perform pg_temp.ok(public.claim_pond(pid, 'Zalo 0912345678', 'Tôi là chủ hồ', other) = 'sent', 'claim_pond');
  perform pg_temp.later('10 seconds');
  perform pg_temp.ok(public.report_pond(pid, other), 'report_pond');
  -- Moderation helpers run for the owner.
  perform pg_temp.ok((select count(*) > 0 from public.mod_recent_content(24, null)), 'mod_recent_content');
  perform pg_temp.ok((select count(*) > 0 from public.mod_top_devices(24, 20)), 'mod_top_devices');
  perform pg_temp.ok((select count(*) > 0 from public.mod_ip_sources(24)), 'mod_ip_sources');
  perform pg_temp.ok(public.mod_set_hidden('comment', cid, true) = 1, 'mod_set_hidden');
  perform pg_temp.ok(public.mod_set_hidden('review', pid, true, public.secret_hash(other)) = 1,
                     'mod_set_hidden review');
  perform pg_temp.ok(public.mod_shadow_device(public.secret_hash(other), 30) > now(), 'mod_shadow_device');
  perform pg_temp.ok((select count(*) = 0 from public.trip_messages_for(tid, me)),
                     'shadowed chat hidden from others');
  perform pg_temp.ok((select count(*) = 1 from public.trip_messages_for(tid, other)),
                     'shadowed chat visible to its author');
  perform pg_temp.ok(public.mod_block_ip(
    (select ip_hash from public.client_ip()), 24, 'block', 'test') > now(), 'mod_block_ip');
end $$;
select pg_temp.expect_err(format('select public.check_in(10.03, 105.78, null, %L)', pg_temp.sec('smoke')),
  'banned');
select pg_temp.ok(public.mod_unblock_ip((select ip_hash from public.client_ip())), 'mod_unblock_ip');
select pg_temp.ok(public.mod_ban_device(pg_temp.hash('smoke'), 7, 'test') > now(), 'mod_ban_device');

-- ── 8. moderation: privileges and unban ──
select pg_temp.ok(not has_function_privilege(r, f, 'execute'), format('%s cannot run %s', r, f))
  from unnest(array['anon', 'authenticated']) r,
       unnest(array['public.mod_ban_device(text, int, text, boolean)',
                    'public.mod_unban_device(text, boolean)', 'public.mod_flagged(int)',
                    'public.mod_recent_content(int, text)', 'public.mod_top_ips(int, int)',
                    'public.mod_set_hidden(text, uuid, boolean, text, boolean)',
                    'public.guard(text, text, text)', 'public.content_issue(text, text)',
                    'public.client_ip()', 'public.add_strike(text)']) f
 where exists (select 1 from pg_roles where rolname = 'anon');
-- Every function added by 0005 is internal or moderation-only.
select pg_temp.ok(not has_function_privilege(r, p.oid, 'execute'), format('%s cannot run %s', r, p.proname))
  from pg_proc p, unnest(array['anon', 'authenticated']) r
 where p.pronamespace = 'public'::regnamespace
   and (p.proname like 'mod\_%' or p.proname in (
     'client_ip', 'raise_limit', 'raise_banned', 'purge_abuse_data', 'guard', 'check_ip_rate',
     'check_repeat', 'fold_text', 'word_pad', 'text_fingerprint', 'content_issue', 'check_content',
     'set_device_shadow', 'add_strike', 'cast_vote', 'votes_hide', 'check_pond_texts'))
   and exists (select 1 from pg_roles where rolname = 'anon');
select pg_temp.ok(has_function_privilege('anon', 'public.add_comment(uuid, text, text, text)', 'execute'),
                  'anon can still call add_comment')
 where exists (select 1 from pg_roles where rolname = 'anon');
select pg_temp.ok(not has_table_privilege(r, 'public.' || t, 'select'), format('%s cannot read %s', r, t))
  from unnest(array['anon', 'authenticated']) r,
       unnest(array['devices', 'rate_events', 'item_votes', 'ip_blocks', 'blocked_terms', 'rate_limits']) t
 where exists (select 1 from pg_roles where rolname = 'anon');
select pg_temp.ok(not has_schema_privilege(r, 'private', 'usage'), format('%s cannot use schema private', r))
  from unnest(array['anon', 'authenticated']) r
 where exists (select 1 from pg_roles where rolname = 'anon');

select pg_temp.ok((select count(*) > 0 from public.mod_flagged(7)), 'mod_flagged lists reports');
select pg_temp.ok((select count(*) > 0 from public.mod_top_ips(24, 20)), 'mod_top_ips lists IPs');
select public.mod_unban_device(pg_temp.hash('author'));
select pg_temp.ok((select banned_until is null from public.devices where device_hash = pg_temp.hash('author')),
                  'unban clears the ban');
select pg_temp.ok((select not shadow from public.public_spots
                    where owner_hash = pg_temp.hash('author') and title = 'Điểm không ai báo'),
                  'unban restores shadowed content');

select 'ALL ANTI-SPAM CHECKS PASSED' as result;

rollback;
