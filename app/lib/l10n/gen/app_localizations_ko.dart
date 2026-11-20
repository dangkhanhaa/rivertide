// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Con Nước';

  @override
  String get common_retry => '다시 시도';

  @override
  String get common_loading => '불러오는 중…';

  @override
  String get common_empty => '아직 데이터가 없어요';

  @override
  String get common_reference => '참고용';

  @override
  String get common_estimate => '추정';

  @override
  String common_source(String source) {
    return '출처: $source';
  }

  @override
  String common_staleBanner(String time) {
    return '오프라인 · $time 업데이트';
  }

  @override
  String common_updatedAt(String time) {
    return '$time 업데이트';
  }

  @override
  String get common_today => '오늘';

  @override
  String get common_tomorrow => '내일';

  @override
  String get error_network => '연결할 수 없어요. 네트워크를 확인하고 다시 시도하세요.';

  @override
  String get error_timeout => '데이터 출처의 응답이 느려요. 나중에 다시 시도하세요.';

  @override
  String get error_server => '데이터 출처가 일시적으로 중단되었어요.';

  @override
  String get error_parse => '원본 데이터가 올바르지 않아요.';

  @override
  String get error_notFound => '찾을 수 없어요.';

  @override
  String get error_offlineNoCache => '오프라인 상태이고 저장된 데이터가 아직 없어요.';

  @override
  String get error_unknown => '오류가 발생했어요. 나중에 다시 시도하세요.';

  @override
  String get dataKind_observed => '실측';

  @override
  String get dataKind_forecast => '예보 · 참고용';

  @override
  String get dataKind_estimate => '추정';

  @override
  String get tide_rising => '들물';

  @override
  String get tide_risingFast => '빠르게 상승';

  @override
  String get tide_slack => '정조';

  @override
  String get tide_falling => '날물';

  @override
  String get tide_fallingFast => '빠르게 하강';

  @override
  String get tide_high => '만조';

  @override
  String get tide_low => '간조';

  @override
  String get tide_turning => '물때 바뀌는 중';

  @override
  String get tide_spring => '사리';

  @override
  String get tide_neap => '조금';

  @override
  String get tide_normal => '중간 물때';

  @override
  String tide_countdownHigh(String duration) {
    return '$duration 후 만조';
  }

  @override
  String tide_countdownLow(String duration) {
    return '$duration 후 간조';
  }

  @override
  String tide_extremeAt(String time, String level) {
    return '$time · 예상 $level';
  }

  @override
  String tide_nextOther(String kind, String time, String level) {
    return '다음 $kind: $time · $level';
  }

  @override
  String get tide_noPrediction => '이 관측소의 조석 예보가 아직 없어요';

  @override
  String tide_correctedBy(String delta) {
    return '실측값으로 보정됨 (차이 $delta)';
  }

  @override
  String duration_hm(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String duration_m(int minutes) {
    return '$minutes분';
  }

  @override
  String confidence_label(String level) {
    return '예보 신뢰도: $level';
  }

  @override
  String get confidence_high => '높음';

  @override
  String get confidence_medium => '보통';

  @override
  String get confidence_low => '낮음';

  @override
  String skill_backtest(String cm, String min) {
    return '백테스트: 오차 ±$cm cm, 만조/간조 시각 ±$min분';
  }

  @override
  String skill_live(int days, String cm, String min) {
    return '최근 $days일 오차: ±$cm cm, ±$min분';
  }

  @override
  String get skill_unknown => '이 지점의 오차는 아직 측정되지 않았어요';

  @override
  String get nav_map => '지도';

  @override
  String get map_searchHint => '읍·면, 동, 다리, 선착장, 좌표 검색…';

  @override
  String get map_searchNone => '일치하는 관측소가 없어요';

  @override
  String get map_openDetail => '자세히 보기';

  @override
  String map_nextExtreme(String kind, String time, String level, String duration) {
    return '$kind $time ≈ $level · $duration 남음';
  }

  @override
  String tide_moreRise(int cm) {
    return '물이 약 $cm cm 더 오를 거예요';
  }

  @override
  String tide_moreFall(int cm) {
    return '물이 약 $cm cm 더 빠질 거예요';
  }

  @override
  String get map_locate => '내 위치';

  @override
  String get map_locRationaleTitle => '내 위치를 사용할까요?';

  @override
  String get map_locRationaleBody =>
      '앱은 위치를 사용해 지도를 내 위치로 옮기고, 가까운 관측소와 낚시터를 찾고, 현재 위치의 물때와 날씨를 가져와요. 위치는 신원과 연결되지 않고 공개되지 않아요.';

  @override
  String get map_locAllow => '허용';

  @override
  String get map_later => '나중에';

  @override
  String get map_locServiceOff => '위치 서비스가 꺼져 있어요. 기기에서 위치를 켜고 다시 시도하세요.';

  @override
  String get map_locDenied => '위치 권한이 없어요.';

  @override
  String get map_locDeniedForeverTitle => '위치 권한이 차단되었어요';

  @override
  String get map_locDeniedForeverBody => '설정 > 앱 > Con Nước > 권한 > 위치에서 다시 켜세요.';

  @override
  String get map_openSettings => '설정 열기';

  @override
  String get map_locFailed => '위치를 가져올 수 없어요. 나중에 다시 시도하세요.';

  @override
  String get map_outsideVn => '지원 지역 밖의 위치예요';

  @override
  String get map_layers => '지도 레이어';

  @override
  String get map_layerStandard => '일반 지도';

  @override
  String get map_layerStandardHint => '도로, 지명, 강과 호수 (OpenFreeMap)';

  @override
  String get map_layerSatellite => '위성 사진';

  @override
  String get map_layerSatelliteHint =>
      'Sentinel-2 2025년, 해상도 10 m — 강, 모래톱, 논밭은 잘 보이지만 개별 집은 잘 안 보여요';

  @override
  String get map_satelliteCredit =>
      '위성 사진: EOxCloudless (EOX IT Services) · Copernicus Sentinel 2025 데이터 포함';

  @override
  String get map_filter => '필터';

  @override
  String get map_filterOnlyTide => '조석 관측소만';

  @override
  String get map_filterOnlyAlarm => '경보 중인 관측소만';

  @override
  String get map_filterHideStale => '데이터 없는 관측소 숨기기';

  @override
  String get map_filterNone => '필터에 맞는 관측소가 없어요';

  @override
  String get map_legend => '범례';

  @override
  String get map_legendNormal => '정상';

  @override
  String get map_legendAlarm1 => '경보 I단계';

  @override
  String get map_legendAlarm2 => '경보 II단계';

  @override
  String get map_legendAlarm3 => '경보 III단계';

  @override
  String get map_legendStale => '6시간 넘게 데이터 없음 (회색 핀, 흐린 물고기)';

  @override
  String get map_legendSpot => '커뮤니티 낚시 포인트';

  @override
  String get map_legendCluster =>
      '숫자가 있는 원: 가까운 관측소 묶음이에요. 탭하면 확대돼요. 원 색은 묶음 안에서 가장 높은 입질 활동이며, 경보 중인 관측소가 있으면 경보 색으로 표시돼요.';

  @override
  String get map_legendNote => '바다 관측소는 아직 경보 기준이 없어요. 경보 색은 이후 단계에서 강 관측소에 사용돼요.';

  @override
  String get map_hoangSa => 'Hoàng Sa 군도 (베트남)';

  @override
  String get map_truongSa => 'Trường Sa 군도 (베트남)';

  @override
  String get map_close => '닫기';

  @override
  String get map_stationsError => '관측소 목록을 불러올 수 없어요';

  @override
  String get map_baseMapCredit => '배경 지도: OpenFreeMap · © OpenMapTiles · 데이터 © OpenStreetMap';

  @override
  String get nav_stations => '관측소';

  @override
  String get nav_watch => '관심 목록';

  @override
  String get nav_fishing => '낚시';

  @override
  String get nav_more => '더보기';

  @override
  String get stations_title => '수위 및 조석 관측소';

  @override
  String get stations_kindGauge => '측정기 있음';

  @override
  String get stations_kindModel => '모델';

  @override
  String get stations_coordApprox => '대략적인 좌표';

  @override
  String get station_tabOverview => '개요';

  @override
  String get station_tabHourly => '시간별';

  @override
  String get station_tabCalendar => '물때표';

  @override
  String get station_tabInfo => '정보';

  @override
  String level_lastKnown(String time) {
    return '최신 측정값 $time · 이 시간 측정값은 아직 없어요';
  }

  @override
  String get calendar_prev => '이전 달';

  @override
  String get calendar_next => '다음 달';

  @override
  String calendar_month(int month, int year) {
    return '$year년 $month월';
  }

  @override
  String get calendar_noTideDay => '이 날의 조석 예보가 아직 없어요';

  @override
  String get calendar_noTideMonth => '이번 달 조석 예보는 아직 없지만 음력 날짜와 달은 볼 수 있어요';

  @override
  String get calendar_rangeLegend => '일 조차';

  @override
  String get calendar_lunarLegend => '빨간 글씨: 음력 1일, 15일';

  @override
  String moon_times(String rise, String set) {
    return '월출 $rise · 월몰 $set';
  }

  @override
  String get moon_alwaysUp => '달이 하루 종일 떠 있어요';

  @override
  String get moon_alwaysDown => '오늘은 달이 뜨지 않아요';

  @override
  String get solunar_title => '달 기준 입질 시간';

  @override
  String get solunar_titleGood => '달 기준 입질 시간 · 좋은 날 (보름/그믐 근처)';

  @override
  String solunar_major(String range) {
    return '주요 시간 $range';
  }

  @override
  String solunar_minor(String range) {
    return '보조 시간 $range';
  }

  @override
  String get solunar_now => '진행 중';

  @override
  String get summary_title => '지금 여기는';

  @override
  String summary_water(String state, String extreme, String time, String wait) {
    return '$state, $time에 $extreme ($wait 남음)';
  }

  @override
  String summary_fishing(String score, String label) {
    return '낚시 $score/10 $label';
  }

  @override
  String summary_wind(int kmh) {
    return '바람 $kmh km/h';
  }

  @override
  String get map_goFishing => '바로 낚시 가기';

  @override
  String get hazard_title => '주의';

  @override
  String get hazard_titleSevere => '위험 — 강에 나가지 마세요';

  @override
  String hazard_at(String time) {
    return '$time';
  }

  @override
  String hazard_between(String from, String to) {
    return '$from–$to';
  }

  @override
  String get hazard_thunderstorm => '뇌우, 낙뢰: 물가에서 벗어나 트인 곳과 낚싯대를 피하세요';

  @override
  String get hazard_gust => '돌풍 50 km/h 이상: 배를 띄우지 마세요';

  @override
  String get hazard_heavyRain => '시간당 20 mm 이상 폭우';

  @override
  String get hazard_possibleStorm => '날씨가 불안정해 뇌우가 있을 수 있어요';

  @override
  String get hazard_risingFast => '물이 비정상적으로 빠르게 오르고 있어요 (최근 며칠보다 훨씬 빠름): 낮은 둔치와 모래톱을 피하세요';

  @override
  String get hazard_flood => '내일 강 유량 급증 (상류 폭우): 물이 불고 탁하며 유속이 빨라요';

  @override
  String get watch_edit => '이름, 메모, 그룹';

  @override
  String get watch_editTitle => '내 포인트';

  @override
  String get watch_label => '별칭';

  @override
  String get watch_labelHint => '예: 반얀나무 아래 깊은 웅덩이';

  @override
  String get watch_note => '메모';

  @override
  String get watch_noteHint => '예: 지렁이 미끼, 와류 지점';

  @override
  String get watch_group => '그룹';

  @override
  String get watch_groupHint => '예: 홍강, 호수';

  @override
  String get watch_noGroup => '그룹 없음';

  @override
  String get common_save => '저장';

  @override
  String get common_cancel => '취소';

  @override
  String get trip_title => '낚시 계획 세우기';

  @override
  String get trip_open => '계획하기';

  @override
  String get trip_noPlaces => '낚시 포인트를 몇 곳 저장하면(지도에서 ⭐ 탭) 앱이 가장 좋은 낚시 시간을 찾아드려요.';

  @override
  String trip_intro(int count) {
    return '저장한 포인트 $count곳의 향후 7일 최적 낚시 시간이에요. 포인트별 물때, 달, 날씨로 계산했어요.';
  }

  @override
  String get trip_none => '향후 7일 동안 저장한 포인트에서 7/10 이상인 시간이 없어요.';

  @override
  String trip_score(String score) {
    return '최고 낚시 점수 $score/10';
  }

  @override
  String trip_because(String reasons) {
    return '좋은 이유: $reasons';
  }

  @override
  String get trip_note => '메모';

  @override
  String get where_title => '오늘 어디로 갈까?';

  @override
  String get where_short => '어디로?';

  @override
  String get more_shortcuts => '바로가기';

  @override
  String get trip_listDetail => '근처 낚시 모임 보고 참여하기';

  @override
  String get trip_createDetail => '친구들과 낚시 약속 잡기, 골든 타임 추천 포함';

  @override
  String get checkin_detail => '여기서 낚시 중이라고 알리기 (익명, 4시간)';

  @override
  String get checkin_peopleDetail => '지금 낚시 중인 곳, 누가 입질 받는지';

  @override
  String get spot_listDetail => '낚시인들이 핀한 포인트, 사진과 댓글 포함';

  @override
  String get where_entryHint => '향후 24시간 내 주변 최고의 낚시 포인트';

  @override
  String get where_radius => '반경';

  @override
  String where_km(int km) {
    return '${km}km';
  }

  @override
  String where_around(String place) {
    return '$place 주변';
  }

  @override
  String get where_aroundHere => '지금 계신 곳 주변';

  @override
  String get where_aroundLast => '마지막 위치 주변 (◎ 탭하여 업데이트)';

  @override
  String get where_needLocation => '가장 가까운 낚시 포인트를 찾으려면 현재 위치를 알려주세요.';

  @override
  String get where_useLocation => '내 위치 사용';

  @override
  String get where_refresh => '위치 업데이트';

  @override
  String get where_kindHere => '현재 위치';

  @override
  String get where_kindStation => '관측소';

  @override
  String get where_kindSaved => '저장한 포인트';

  @override
  String get where_kindCommunity => '커뮤니티 포인트';

  @override
  String where_distance(String km) {
    return '$km km 거리';
  }

  @override
  String where_golden(String when) {
    return '골든 타임 $when';
  }

  @override
  String where_bestHour(String when) {
    return '골든 타임 없음 · 가장 좋은 시간 $when';
  }

  @override
  String get where_unsafe => '이 시간대에 기상 경보가 있어요';

  @override
  String get where_loading => '낚시 점수 계산 중…';

  @override
  String get where_failed => '이 포인트의 데이터를 불러올 수 없어요';

  @override
  String get where_onMap => '지도 보기';

  @override
  String get where_fishHere => '여기서 낚시';

  @override
  String where_rank(int rank) {
    return '$rank위';
  }

  @override
  String get where_note =>
      '향후 24시간의 추정 낚시 점수(물때, 달 시간, 낮/밤, Open-Meteo 날씨) 순으로 정렬했어요 — 참고용이에요. 커뮤니티 포인트는 사용자가 핀한 곳이에요. 가장 가까운 포인트 최대 8곳.';

  @override
  String get where_onlyHere => '이 반경 안에 관측소, 저장한 포인트, 커뮤니티 포인트가 없어 현재 위치만 계산할 수 있어요. 반경을 넓혀 보세요.';

  @override
  String get habit_title => '내 낚시 습관';

  @override
  String habit_needMore(int count) {
    return '조과를 $count번 더 기록하면 앱이 자주 잡히는 때를 찾아드려요.';
  }

  @override
  String habit_progress(int have, int need) {
    return '$have/$need회';
  }

  @override
  String habit_none(int count) {
    return '조과 $count회에서 아직 두드러진 조건이 없어요. 계속 기록해 보세요.';
  }

  @override
  String habit_hits(int hits, int known) {
    return '$hits/$known회';
  }

  @override
  String get habit_note => '기기의 일지로 집계한 것이며 확실한 법칙은 아니에요. 자주 낚시하는 시간대일수록 조과가 많을 수밖에 없어요.';

  @override
  String get habit_match => '잘 잡혔던 때와 비슷해요';

  @override
  String get habit_dawn => '새벽';

  @override
  String get habit_morning => '오전';

  @override
  String get habit_midday => '한낮';

  @override
  String get habit_afternoon => '오후';

  @override
  String get habit_dusk => '해질녘';

  @override
  String get habit_night => '밤';

  @override
  String get habit_rising => '들물일 때';

  @override
  String get habit_falling => '날물일 때';

  @override
  String get habit_slack => '정조일 때 (물때 바뀔 때)';

  @override
  String get habit_newMoon => '그믐 무렵 (음력 월말/월초)';

  @override
  String get habit_fullMoon => '보름 무렵 (음력 15일)';

  @override
  String get habit_quarter => '반달인 날';

  @override
  String get habit_major => '달 주요 시간대';

  @override
  String get habit_minor => '달 보조 시간대';

  @override
  String get habit_noSolunar => '달 시간대 외';

  @override
  String get habit_calm => '바람이 잔잔할 때 (10 km/h 미만)';

  @override
  String get habit_light => '약한 바람 (10–20 km/h)';

  @override
  String get habit_strong => '강한 바람 (20 km/h 이상)';

  @override
  String get journal_title => '낚시 일지';

  @override
  String get journal_open => '일지';

  @override
  String get journal_add => '조과 기록';

  @override
  String get journal_empty => '아직 조과가 없어요. 고기를 잡을 때마다 \'조과 기록\'을 누르세요. 그때의 수위, 물때, 날씨, 달이 자동 저장돼요.';

  @override
  String journal_place(String name) {
    return '장소: $name';
  }

  @override
  String get journal_placeHint => '낚시 탭에서 선택된 포인트예요. 필요하면 거기서 바꾸세요.';

  @override
  String get journal_changeTime => '시간 변경';

  @override
  String get journal_species => '어종';

  @override
  String get journal_weight => '무게 (kg)';

  @override
  String get journal_length => '길이 (cm)';

  @override
  String get journal_bait => '미끼';

  @override
  String get journal_note => '메모';

  @override
  String get journal_camera => '사진 찍기';

  @override
  String get journal_gallery => '사진 선택';

  @override
  String get journal_removePhoto => '사진 삭제';

  @override
  String get journal_photoError => '이 사진을 읽을 수 없어요';

  @override
  String get journal_needSpecies => '어종을 입력하세요';

  @override
  String get journal_privacy => '일지와 사진은 이 기기에만 저장돼요. 사진의 GPS 위치 정보는 삭제돼요.';

  @override
  String get journal_statsTitle => '나의 낚시';

  @override
  String journal_statsCount(int count, String kg) {
    return '$count회 · 총 $kg kg';
  }

  @override
  String journal_statsTop(String species, int count) {
    return '가장 많이 잡은 어종: $species ($count회)';
  }

  @override
  String journal_statsRising(int pct) {
    return '조과의 $pct%가 들물일 때';
  }

  @override
  String journal_statsFalling(int pct) {
    return '조과의 $pct%가 날물일 때';
  }

  @override
  String journal_water(String state) {
    return '물 $state';
  }

  @override
  String get journal_conditions => '낚시할 때의 조건';

  @override
  String journal_weightValue(String kg) {
    return '무게 $kg kg';
  }

  @override
  String journal_lengthValue(int cm) {
    return '길이 $cm cm';
  }

  @override
  String journal_baitValue(String bait) {
    return '미끼: $bait';
  }

  @override
  String journal_levelValue(String level) {
    return '수위 $level';
  }

  @override
  String journal_scoreValue(String score) {
    return '낚시 점수 $score/10';
  }

  @override
  String get journal_delete => '삭제';

  @override
  String get journal_deleteTitle => '일지에서 이 조과를 삭제할까요?';

  @override
  String get place_city => '시, 읍';

  @override
  String get place_ward => '동네, 마을';

  @override
  String get place_bridge => '다리';

  @override
  String get place_ferry => '나루터';

  @override
  String get place_wharf => '선착장';

  @override
  String place_near(String kind, String town) {
    return '$kind · $town 근처';
  }

  @override
  String get share_action => '공유';

  @override
  String share_text(String place) {
    return 'Con Nước · $place';
  }

  @override
  String share_level(String level) {
    return '수위 $level';
  }

  @override
  String share_score(String score) {
    return '낚시 점수 $score/10';
  }

  @override
  String get share_copied => '내용과 링크를 복사했어요. Zalo/Facebook에 붙여넣어 보내세요';

  @override
  String get share_footer => '계산된 데이터, 참고용 · Con Nước';

  @override
  String get more_outdoor => '야외 모드';

  @override
  String get more_outdoorHint => '높은 대비, 더 큰 글씨: 강한 햇빛 아래서도 잘 보여요';

  @override
  String get map_legendFlowRising => '물이 오르는 강 구간';

  @override
  String get map_legendFlowFalling => '물이 빠지는 강 구간';

  @override
  String get map_legendFlowSlack => '정조인 강 구간';

  @override
  String get map_legendFlowNote =>
      '강 구간마다 따로 색을 입혀요 (물때가 구간마다 다른 시간에 도달). 10분마다 업데이트돼요. 움직이는 줄무늬는 강물이 바다로 흐르는 방향이에요.';

  @override
  String get map_layerWeather => '주변 비와 바람';

  @override
  String get map_layerWeatherHint => '파란 점: 1시간 내 비 (클수록 많이 옴). 화살표: 바람이 부는 방향. 보고 싶은 지역을 확대하세요.';

  @override
  String hazard_surge(int cm) {
    return '해수면이 평소 조위보다 $cm cm 높아요 (강풍이나 태풍이 물을 밀어 올림): 낮은 해변과 강 하구가 잠기기 쉬워요';
  }

  @override
  String get more_install => 'Con Nước를 홈 화면에 추가';

  @override
  String get more_installHow =>
      'Android (Chrome): ⋮ 을 누르고 \'앱 설치\'를 선택하세요. iPhone (Safari): 공유 버튼을 누르고 \'홈 화면에 추가\'를 선택하세요. 스토어 없이 진짜 앱처럼 빠르게 열려요.';

  @override
  String get alert_channel => '물때 알람';

  @override
  String get alert_channelHint => '저장한 포인트의 만조, 간조, 좋은 낚시 시간 전에 알려드려요';

  @override
  String alert_highTitle(String place, String time) {
    return '$place: 만조 $time';
  }

  @override
  String alert_lowTitle(String place, String time) {
    return '$place: 간조 $time';
  }

  @override
  String alert_levelBody(String level, int minutes) {
    return '수위 약 $level, $minutes분 남음';
  }

  @override
  String alert_fishTitle(String place, String from, String to) {
    return '$place: 좋은 낚시 시간 $from–$to';
  }

  @override
  String alert_fishBody(String score, int minutes) {
    return '낚시 점수 $score/10, $minutes분 후 시작';
  }

  @override
  String get alert_toggleOn => '물때 알람 켜기';

  @override
  String get alert_toggleOff => '물때 알람 끄기';

  @override
  String get alert_onSnack => '이 포인트의 알람을 켰어요. 알람 종류와 미리 알림 시간은 상단 ⚙ 버튼에서 설정하세요.';

  @override
  String alert_fishBodyLike(String score, int minutes) {
    return '✨ 잘 잡혔던 때와 비슷해요 · 낚시 점수 $score/10, $minutes분 후 시작';
  }

  @override
  String get alert_settings => '알람 설정';

  @override
  String get alert_golden => '골든 타임 전에 알림';

  @override
  String get alert_goldenHint => '해당 시간대에 뇌우, 돌풍, 폭우 경보가 없을 때만 알려요';

  @override
  String get alert_tides => '만조 / 간조 전에 알림';

  @override
  String get alert_lead => '미리 알림';

  @override
  String alert_leadMin(int minutes) {
    return '$minutes분';
  }

  @override
  String get alert_howTo => '관심 목록에서 포인트마다 종 아이콘을 켜세요. 앱을 열 때마다 알람 일정을 다시 계산해요 (향후 7일).';

  @override
  String get alert_getApk => 'Android 앱 받기';

  @override
  String get alert_denied => '알림이 허용되지 않았어요. 설정 > 앱 > Con Nước > 알림에서 켜세요.';

  @override
  String get alert_webOnly => '알람은 Android 앱에서만 가능해요 (브라우저는 닫혀 있으면 울릴 수 없어요)';

  @override
  String get more_apk => 'Android 앱 다운로드 (APK)';

  @override
  String get more_apkHint => '물때 알람과 홈 화면 위젯이 추가돼요. 다운로드 후 파일을 열고 이 출처의 설치를 허용하세요.';

  @override
  String get directions_action => '길찾기';

  @override
  String get directions_failed => '이 기기에서 Google Maps를 열 수 없어요';

  @override
  String get search_recent => '최근 검색';

  @override
  String get place_province => '성, 시';

  @override
  String get place_commune => '동, 사';

  @override
  String get search_coordsHint => '이 좌표의 수위와 낚시 시간 열기';

  @override
  String place_in(String kind, String area) {
    return '$kind · $area';
  }

  @override
  String search_coords(String coords) {
    return '좌표 $coords';
  }

  @override
  String get spot_edit => '수정';

  @override
  String get spot_editTitle => '낚시 포인트 수정';

  @override
  String get spot_save => '변경 사항 저장';

  @override
  String get spot_editSaved => '변경 사항을 저장했어요';

  @override
  String spot_edited(String date) {
    return '$date 수정됨';
  }

  @override
  String get spot_tooMany => '이 기기는 오늘 포인트 10곳을 모두 올렸어요. 내일 또 올려 주세요.';

  @override
  String spot_comments(int count) {
    return '댓글 $count개';
  }

  @override
  String get cmt_title => '댓글';

  @override
  String cmt_count(int count) {
    return '댓글 ($count)';
  }

  @override
  String get cmt_hint => '미끼, 입질 시간, 가는 길 등을 공유해 주세요…';

  @override
  String get cmt_send => '댓글 등록';

  @override
  String get cmt_empty => '아직 댓글이 없어요. 첫 댓글을 남겨 보세요!';

  @override
  String get cmt_anon => '익명 낚시인';

  @override
  String cmt_asName(String name) {
    return '$name(으)로 댓글 작성 · 변경';
  }

  @override
  String get cmt_asAnon => '익명 · 표시 이름 설정';

  @override
  String get cmt_edited => '수정됨';

  @override
  String get cmt_mine => '내 댓글';

  @override
  String get cmt_more => '더보기';

  @override
  String get cmt_edit => '댓글 수정';

  @override
  String get cmt_delete => '삭제';

  @override
  String get cmt_report => '신고';

  @override
  String get cmt_deleteTitle => '내 댓글을 삭제할까요?';

  @override
  String get cmt_reportTitle => '이 댓글을 신고할까요?';

  @override
  String get cmt_reportHint => '욕설, 사기, 광고 등… 3명이 신고한 댓글은 자동으로 숨겨져요.';

  @override
  String get cmt_error => '보내지 못했어요. 네트워크를 확인하고 다시 시도하세요';

  @override
  String get cmt_tooFast => '너무 빨리 보내고 있어요 — 잠시 후 다시 보내 주세요';

  @override
  String get cmt_loadError => '댓글을 불러올 수 없어요';

  @override
  String get name_title => '표시 이름';

  @override
  String get name_hint => '예: 낚시꾼 칸';

  @override
  String get name_note => '댓글, 낚시 모임, 메시지에 표시돼요. 비워 두면 익명이에요.';

  @override
  String get social_save => '저장';

  @override
  String get nav_ponds => '낚시터';

  @override
  String get pond_title => '낚시터';

  @override
  String get pond_tag => '유료 낚시터';

  @override
  String get pond_add => '낚시터 추가';

  @override
  String get pond_addTitle => '낚시터 추가';

  @override
  String get pond_addHere => '여기에 낚시터 추가';

  @override
  String pond_pill(int count) {
    return '낚시터 $count곳';
  }

  @override
  String pond_pillSoon(int count) {
    return '곧 방류하는 낚시터 $count곳';
  }

  @override
  String get pond_pillDetail => '주변 유료 낚시터, 방류 일정';

  @override
  String get pond_editTitle => '낚시터 정보 수정';

  @override
  String get pond_empty => '40 km 이내에 아직 낚시터가 없어요. 아는 곳이 있나요? \"낚시터 추가\"를 눌러 모두와 공유하세요.';

  @override
  String get pond_loadError => '낚시터 목록을 불러오지 못했어요';

  @override
  String get pond_filterRelease => '곧 방류';

  @override
  String get pond_filterVerified => '인증됨';

  @override
  String get pond_filterFollowed => '팔로우 중';

  @override
  String get pond_followedSoon => '팔로우한 낚시터가 곧 방류해요';

  @override
  String get pond_verified => '인증됨';

  @override
  String get pond_owner => '주인 인증 완료';

  @override
  String get pond_unverified => '미인증';

  @override
  String get pond_fromWeb => '웹에서 모은 정보라 오래됐을 수 있어요. 현장에서 맞다면 \"실제 있는 낚시터\"를 눌러 주세요.';

  @override
  String get pond_approx => '주소 기준 대략적인 위치예요. 근처에 있다면 \"수정\"을 눌러 핀을 옮겨 주세요.';

  @override
  String pond_distance(String km) {
    return '$km 거리';
  }

  @override
  String pond_rating(String rating, int count) {
    return '$rating ★ ($count)';
  }

  @override
  String get pond_noRating => '아직 평가 없음';

  @override
  String pond_releaseChip(String when) {
    return '$when 방류';
  }

  @override
  String pond_releaseKg(String when, String amount) {
    return '$when · $amount';
  }

  @override
  String pond_kg(String kg) {
    return '${kg}kg';
  }

  @override
  String pond_ta(String ta) {
    return '$ta퀸탈';
  }

  @override
  String pond_ton(String ton) {
    return '$ton톤';
  }

  @override
  String get pond_releases => '방류 일정';

  @override
  String get pond_noRelease => '예정된 방류가 없어요.';

  @override
  String get pond_official => '주인 등록';

  @override
  String get pond_relayed => '사용자 제보 · 미확인';

  @override
  String get pond_releasePast => '방류 완료';

  @override
  String get pond_releaseCancelled => '취소됨';

  @override
  String get pond_postRelease => '방류 일정 제보';

  @override
  String get pond_showSource => '원본 게시물 보기';

  @override
  String get pond_cancelRelease => '이 일정 취소';

  @override
  String get pond_reportRelease => '잘못된 정보 신고';

  @override
  String get pond_follow => '팔로우';

  @override
  String get pond_following => '팔로우 중';

  @override
  String get pond_followHint => '이 낚시터에 새 방류 일정이 생기면 목록 맨 위에 표시돼요(Android 앱은 알림이 울려요).';

  @override
  String get pond_call => '전화';

  @override
  String get pond_price => '요금';

  @override
  String get pond_hours => '영업시간';

  @override
  String get pond_species => '낚시터 어종';

  @override
  String get pond_note => '메모';

  @override
  String get pond_sources => '출처';

  @override
  String get pond_pulseTitle => '지금 낚시터 상황 (최근 6시간)';

  @override
  String get pond_pulseBusy => '붐빔';

  @override
  String get pond_pulseQuiet => '한산';

  @override
  String get pond_pulseBiting => '입질 중';

  @override
  String get pond_pulseReleased => '방금 방류';

  @override
  String pond_pulseCount(String label, int count) {
    return '$label · $count';
  }

  @override
  String get pond_pulseSent => '보냈어요. 감사합니다!';

  @override
  String get pond_pulseWait => '30분에 한 번만 제보할 수 있어요';

  @override
  String get pond_confirm => '실제 있는 낚시터';

  @override
  String get pond_confirmed => '확인했어요';

  @override
  String get pond_confirmDone => '감사합니다! 3명이 확인하면 낚시터에 ✓ 표시가 붙어요';

  @override
  String get pond_edit => '수정';

  @override
  String get pond_claim => '제가 주인이에요';

  @override
  String get pond_claimTitle => '낚시터 관리 신청';

  @override
  String get pond_claimBody =>
      '사칭을 막기 위해 관리자가 전화나 Zalo로 연락해 확인해요. 승인되면 \"공식\" 방류 일정을 올리고 요금과 영업시간을 직접 수정할 수 있어요.';

  @override
  String get pond_claimContact => '낚시터 전화번호 / Zalo';

  @override
  String get pond_claimNote => '메시지(선택)';

  @override
  String get pond_claimSend => '신청 보내기';

  @override
  String get pond_claimSent => '보냈어요! 관리자가 곧 연락드릴게요.';

  @override
  String get pond_claimPending => '신청이 승인 대기 중이에요.';

  @override
  String get pond_claimOwned => '이 낚시터는 이미 주인이 관리하고 있어요.';

  @override
  String get pond_claimYours => '이 낚시터의 주인이에요.';

  @override
  String get pond_report => '신고';

  @override
  String get pond_reportTitle => '이 낚시터를 신고할까요?';

  @override
  String get pond_reportHint => '없는 곳, 폐업, 위치 오류 등… 주인이 없는 낚시터는 3명이 신고하면 자동으로 숨겨져요.';

  @override
  String get pond_error => '보내지 못했어요. 네트워크를 확인하고 다시 시도하세요';

  @override
  String get pond_tooMany => '오늘은 작업이 너무 많았어요. 내일 다시 시도해 주세요';

  @override
  String get pond_duplicate => '이곳에 이미 등록된 낚시터가 있어요. 열어 볼까요?';

  @override
  String get pond_open => '열기';

  @override
  String get pond_name => '낚시터 이름';

  @override
  String get pond_nameHint => '예: Thanh Hà 낚시터';

  @override
  String get pond_address => '주소';

  @override
  String get pond_phone => '전화번호 / Zalo';

  @override
  String get pond_priceHint => '예: 200k/4시간, 350k/일';

  @override
  String get pond_hoursHint => '예: 6시–18시, 월요일 휴무';

  @override
  String pond_location(String coords) {
    return '핀 위치: $coords';
  }

  @override
  String get pond_locationHint => '핀은 지도에서 고른 곳에 놓여요. 바꾸려면: 지도에서 낚시터를 정확히 누르고 → 낚시터 추가.';

  @override
  String get pond_save => '저장';

  @override
  String get pond_added => '낚시터를 추가했어요! 감사합니다.';

  @override
  String get pond_saved => '저장됨';

  @override
  String get pond_needName => '낚시터 이름을 입력하세요(2자 이상)';

  @override
  String get pond_reviews => '리뷰';

  @override
  String get pond_writeReview => '리뷰 쓰기';

  @override
  String get pond_reviewHint => '입질, 요금, 서비스, 자리…';

  @override
  String get pond_reviewSend => '리뷰 등록';

  @override
  String get pond_reviewEmpty => '아직 리뷰가 없어요.';

  @override
  String get pond_deleteReview => '내 리뷰 삭제';

  @override
  String get pond_noStars => '별점을 선택하세요';

  @override
  String get release_title => '방류 일정 제보';

  @override
  String get release_paste => '낚시터 게시물 붙여넣기';

  @override
  String get release_pasteHint =>
      '낚시터의 Facebook 게시물 / TikTok 설명을 복사해 여기에 붙여넣으세요. 앱이 날짜, 시간, 어종, 양을 자동으로 읽어요.';

  @override
  String get release_pasteButton => '붙여넣기';

  @override
  String get release_read => '앱이 읽은 내용';

  @override
  String get release_notFound => '게시물에서 방류 날짜를 찾지 못했어요. 아래에서 날짜를 고르세요.';

  @override
  String get release_day => '날짜';

  @override
  String get release_time => '시간';

  @override
  String get release_fish => '방류 어종';

  @override
  String get release_addFish => '어종 추가';

  @override
  String get release_fishName => '어종';

  @override
  String get release_fishKg => 'kg';

  @override
  String release_total(String amount) {
    return '총 $amount';
  }

  @override
  String get release_asOwner => '주인이시군요: 이 일정은 \"주인 등록\"으로 표시돼요.';

  @override
  String get release_asUser => '제보한 일정은 주인이 확인할 때까지 \"사용자 제보\"로 표시돼요. 낚시터의 실제 게시물을 봤을 때만 제보해 주세요.';

  @override
  String get release_post => '방류 일정 등록';

  @override
  String get release_posted => '방류 일정을 등록했어요!';

  @override
  String get release_needDay => '방류 날짜를 고르세요';

  @override
  String get stations_menu => '관측소 목록';

  @override
  String get stations_menuHint => 'KTTV·IOC 관측소의 수위';

  @override
  String get trip_tag => '낚시 모임';

  @override
  String trip_pill(int count) {
    return '낚시 모임 $count개';
  }

  @override
  String get trip_create => '낚시 모임 만들기';

  @override
  String get trip_createHere => '여기서 낚시 모임 만들기';

  @override
  String get trip_formTitle => '낚시 모임 만들기';

  @override
  String get trip_editTitle => '낚시 모임 수정';

  @override
  String get trip_name => '모임 이름';

  @override
  String get trip_nameHint => '예: Thanh Trì 다리 갯바위 밤낚시';

  @override
  String get trip_place => '모이는 곳';

  @override
  String get trip_placeHint => '예: 다리 아래 갯바위, 3번 게이트';

  @override
  String get trip_whereHint => '모임 핀이 여기에 놓여요. 다른 곳에서 만나려면: 지도에서 그곳을 누르고 → \"여기서 낚시 모임 만들기\".';

  @override
  String get trip_when => '시간';

  @override
  String get trip_date => '날짜';

  @override
  String get trip_start => '시작';

  @override
  String get trip_duration => '낚시 시간';

  @override
  String trip_hours(int hours) {
    return '$hours시간';
  }

  @override
  String get trip_golden => '이곳의 골든 타임 (눌러서 선택)';

  @override
  String trip_goldenChip(String when, String score) {
    return '$when · $score';
  }

  @override
  String get trip_noGolden => '앞으로 3일간 이곳에 골든 타임이 없어요';

  @override
  String get trip_people => '최대 인원(본인 포함)';

  @override
  String get trip_contact => '연락처(선택)';

  @override
  String get trip_contactHint => 'Zalo/Facebook 그룹 링크 또는 전화번호';

  @override
  String get trip_contactNote => '모임에 참여한 사람만 볼 수 있어요.';

  @override
  String get trip_noteHint => '대상어, 미끼, 오토바이 또는 카풀, 기름값 나누기…';

  @override
  String get trip_submit => '모임 만들기';

  @override
  String get trip_save => '변경 사항 저장';

  @override
  String get trip_created => '모임을 만들었어요! 주변 낚시꾼들이 지도에서 볼 수 있어요.';

  @override
  String get trip_saved => '모임을 저장했어요';

  @override
  String get trip_needName => '모임 이름을 정해 주세요(2자 이상)';

  @override
  String get trip_badTime => '시작 시간은 앞으로 30일 이내여야 해요';

  @override
  String get trip_tooMany => '이 기기는 오늘 모임을 5개 만들었어요. 내일 또 만들어 주세요.';

  @override
  String get trip_error => '보내지 못했어요. 네트워크를 확인하고 다시 시도하세요';

  @override
  String get trip_tooFew => '이미 참여한 인원이 이 숫자보다 많아요';

  @override
  String get trip_running => '진행 중';

  @override
  String get trip_cancelled => '취소됨';

  @override
  String get trip_full => '마감';

  @override
  String trip_left(int count) {
    return '$count자리 남음';
  }

  @override
  String trip_members(int count, int max) {
    return '$count/$max명';
  }

  @override
  String trip_owner(String name) {
    return '모임장: $name';
  }

  @override
  String get trip_yours => '내 모임';

  @override
  String get trip_joinedTag => '참여함';

  @override
  String get trip_join => '참여';

  @override
  String get trip_joinedSnack => '참여했어요! 아래에서 연락처를 보고 그룹과 대화하세요.';

  @override
  String get trip_joinFull => '모임 인원이 다 찼어요';

  @override
  String get trip_joinClosed => '모임이 끝났거나 취소됐어요';

  @override
  String get trip_leave => '모임 나가기';

  @override
  String get trip_leaveTitle => '이 모임에서 나갈까요?';

  @override
  String get trip_cancel => '모임 취소';

  @override
  String get trip_cancelTitle => '모임을 취소할까요? 참여자에게 \"취소됨\"으로 표시돼요.';

  @override
  String get trip_edit => '수정';

  @override
  String get trip_keep => '모임 유지';

  @override
  String get trip_share => '친구 더 초대';

  @override
  String trip_shareText(String title, String when, String place, String map, String app) {
    return '🎣 낚시 모임: $title\n🕐 $when\n📍 $place\n지도: $map\nCon Nước 앱에서 보고 참여하기: $app';
  }

  @override
  String get trip_report => '신고';

  @override
  String get trip_reportTitle => '이 모임을 신고할까요?';

  @override
  String get trip_reportHint => '사기, 광고, 부적절한 내용 등… 3명이 신고한 모임은 자동으로 숨겨져요.';

  @override
  String get trip_membersOnly => '참여하면 연락처와 참여자 목록을 보고 그룹과 대화할 수 있어요.';

  @override
  String get trip_contactLabel => '연락처';

  @override
  String get trip_openContact => '열기';

  @override
  String get trip_memberList => '참여자';

  @override
  String get trip_chat => '모임 채팅';

  @override
  String get trip_chatEmpty => '아직 메시지가 없어요. 여기서 만날 시간과 주차 장소를 정해 보세요.';

  @override
  String get trip_chatHint => '그룹에 메시지 보내기…';

  @override
  String get trip_send => '보내기';

  @override
  String get trip_refresh => '새로고침';

  @override
  String get trip_nearbyTitle => '주변 낚시 모임';

  @override
  String get trip_nearbyEmpty => '30 km 이내에 아직 모임이 없어요. 첫 모임을 만들어 낚시 친구를 모아 보세요!';

  @override
  String get trip_loadError => '낚시 모임을 불러오지 못했어요';

  @override
  String get trip_notice => '모임은 주변 사용자에게 공개돼요. 낚시 금지 구역에서 만나지 말고, 여럿이 함께 가며 밤낚시 때는 안전에 유의하세요.';

  @override
  String get checkin_pill => '낚시 중이에요';

  @override
  String checkin_pillOn(String time) {
    return '낚시 중 · $time 남음';
  }

  @override
  String checkin_count(int count) {
    return '$count명 낚시 중';
  }

  @override
  String get checkin_title => '\"여기서 낚시 중\" 알리기';

  @override
  String get checkin_body =>
      '주변 낚시꾼들이 이 구역에 누군가 낚시 중인 걸 볼 수 있어요. 이름 없이 인원수만 보이고, 위치는 약 200 m 단위로 반올림되며, 4시간 후 자동으로 꺼져요.';

  @override
  String get checkin_biting => '입질 중 🐟';

  @override
  String get checkin_noBite => '아직 입질 없음';

  @override
  String get checkin_start => '시작';

  @override
  String get checkin_update => '업데이트';

  @override
  String get checkin_stop => '철수';

  @override
  String get checkin_on => '낚시 중으로 알렸어요. 대물 기원해요!';

  @override
  String get checkin_off => '껐어요. 안전하게 귀가하세요!';

  @override
  String get checkin_error => '보내지 못했어요. 네트워크를 확인하고 다시 시도하세요';

  @override
  String get checkin_needLocation => '낚시 중을 알리려면 위치가 필요해요';

  @override
  String checkin_cellTitle(int count) {
    return '주변에서 $count명 낚시 중';
  }

  @override
  String checkin_cellBiting(int count) {
    return '$count명이 입질 중이라고 알렸어요';
  }

  @override
  String get checkin_cellNoBite => '아직 입질 소식이 없어요';

  @override
  String checkin_cellLatest(String time) {
    return '가장 최근 도착 $time';
  }

  @override
  String get checkin_cellYou => '나도 포함';

  @override
  String get checkin_listTitle => '낚시 중인 곳';

  @override
  String get checkin_hint => '위치는 약 200 m 단위로 반올림되고 이름은 표시되지 않아요.';

  @override
  String get spot_publicTag => '커뮤니티 포인트';

  @override
  String get spot_pinAction => '공개 핀 꽂기';

  @override
  String spot_nearbyChip(int count) {
    return '커뮤니티 포인트 $count곳';
  }

  @override
  String get spot_nearbyTitle => '주변 낚시 포인트';

  @override
  String get spot_nearbyEmpty =>
      '30 km 이내에 아직 낚시 포인트가 없어요. 지도에서 한 곳을 누른 뒤 \"공개 핀 꽂기\"로 내 포인트를 공유하세요.';

  @override
  String spot_postedAgo(String date) {
    return '$date 등록';
  }

  @override
  String spot_distance(String km) {
    return '$km 거리';
  }

  @override
  String get spot_viewWater => '이곳 물때 보기';

  @override
  String get spot_report => '신고';

  @override
  String get spot_reportTitle => '이 포인트를 신고할까요?';

  @override
  String get spot_reportHint => '위치 오류, 부적절한 사진, 광고 등… 여러 명이 신고한 포인트는 자동으로 숨겨져요.';

  @override
  String get spot_reportDone => '신고를 보냈어요. 감사합니다!';

  @override
  String get spot_reportTwice => '이미 이 포인트를 신고했어요';

  @override
  String get spot_delete => '내 포인트 삭제';

  @override
  String get spot_deleteTitle => '커뮤니티 지도에서 이 포인트를 삭제할까요?';

  @override
  String get spot_ownedByYou => '내 포인트';

  @override
  String get spot_publishTitle => '낚시 포인트 공개 핀 꽂기';

  @override
  String get spot_name => '포인트 이름';

  @override
  String get spot_nameHint => '예: Thanh Trì 다리 갯바위';

  @override
  String get spot_species => '자주 잡히는 어종';

  @override
  String get spot_note => '팁';

  @override
  String get spot_noteHint => '미끼, 좋은 시간대, 주차, 수심…';

  @override
  String get spot_photos => '사진(최대 3장)';

  @override
  String get spot_addPhoto => '사진 추가';

  @override
  String get spot_publicNotice =>
      '이 포인트는 모든 Con Nước 사용자에게 공개돼요. 낚시 금지 구역이나 동의 없이 다른 사람이 나온 사진은 올리지 마세요.';

  @override
  String get spot_agree => '이해했으며 공유에 동의해요';

  @override
  String get spot_publish => '포인트 등록';

  @override
  String get spot_published => '핀을 꽂았어요! 주변 사람들이 내 포인트를 볼 수 있어요.';

  @override
  String get spot_needName => '포인트 이름을 정해 주세요(2자 이상)';

  @override
  String get spot_error => '보내지 못했어요. 네트워크를 확인하고 다시 시도하세요';

  @override
  String get spot_photoError => '이 사진을 읽을 수 없어요';

  @override
  String spot_location(String coords) {
    return '위치: $coords';
  }

  @override
  String get station_levelNow => '현재 수위';

  @override
  String get station_follow => '관측소 팔로우';

  @override
  String get station_unfollow => '팔로우 취소';

  @override
  String get stations_kindRiver => '하천 관측소(KTTV)';

  @override
  String get stations_kindRiverDaily => '조석 영향 하천(KTTV)';

  @override
  String get station_sourceRiver => 'KTTV 수문 속보(하루 4회 관측 + 예보) · 시간별 선은 앱이 보간';

  @override
  String get station_sourceRiverTide => 'KTTV 수문 속보 + 하구 조석(Open-Meteo Marine) · 시간별 선은 앱이 추정';

  @override
  String get station_datumNational => '관측소 기준면(KTTV 속보 기준)';

  @override
  String station_issued(String time) {
    return 'KTTV 속보 발표 $time';
  }

  @override
  String station_backtestMae(String cm) {
    return '백테스트: 평균 오차 ±$cm cm';
  }

  @override
  String station_dailyTitle(int hours) {
    return '$hours시간 수위(KTTV 속보)';
  }

  @override
  String station_dailyObs(String max, String min) {
    return '관측: 최고 $max · 최저 $min';
  }

  @override
  String station_dailyFc(String max, String min) {
    return '예보: 최고 $max · 최저 $min';
  }

  @override
  String get station_dailyNoCurve =>
      '속보에는 최고·최저 수위만 있고 시간이 없어요. 물이 오르내리는 시간을 잘못 짐작하지 않도록 앱은 선을 그리지 않아요.';

  @override
  String station_dailyRangeNow(String range) {
    return '예보 변동폭 $range — 이 범위 안에서 수위가 오르내려요';
  }

  @override
  String get point_estimateHere => '이 지점의 추정 수위';

  @override
  String get point_onWater => '이 지점은 물 위에 있어요(강, 호수 또는 바다)';

  @override
  String get point_onLand => '이 지점은 강, 호수, 바다 위가 아니에요. 아래 수치는 가장 가까운 수역의 수위예요.';

  @override
  String point_basisRiver(String station, String river, String distance) {
    return '$station 관측소($river강) 기준 · $distance 거리';
  }

  @override
  String point_basisStation(String station, String distance) {
    return '$station 관측소 기준 · $distance 거리';
  }

  @override
  String point_alongDown(String station, String distance, String river) {
    return '$station 관측소에서 하류로 $distance, $river강을 따라 측정';
  }

  @override
  String point_alongUp(String station, String distance, String river) {
    return '$station 관측소에서 상류로 $distance, $river강을 따라 측정';
  }

  @override
  String point_lagEarlier(int minutes) {
    return '물이 관측소보다 약 $minutes분 일찍 오르내려요';
  }

  @override
  String point_lagLater(int minutes) {
    return '물이 관측소보다 약 $minutes분 늦게 오르내려요';
  }

  @override
  String get point_lagSame => '물이 관측소와 거의 동시에 오르내려요';

  @override
  String point_meanLower(int cm) {
    return '수면이 관측소보다 약 $cm cm 낮아요';
  }

  @override
  String point_meanHigher(int cm) {
    return '수면이 관측소보다 약 $cm cm 높아요';
  }

  @override
  String point_celerity(String speed) {
    return '조석파가 강을 거슬러 약 $speed km/h로 전해져요';
  }

  @override
  String get point_reachNote => '강을 따라 하구 조석과 관측소 사이의 위치로 추정했어요. 아직 두 번째 관측소로 검증하지 않았어요.';

  @override
  String get flow_unknown => '이곳은 큰 강 위가 아니라서 수위와 유량을 계산할 수 없어요. 낚시 시간과 날씨는 정확한 위치 기준으로 계산돼요.';

  @override
  String get flow_headRising => '강물이 불어나고 있어요';

  @override
  String get flow_headFalling => '강물이 빠지고 있어요';

  @override
  String get flow_headSteady => '강물이 안정적이에요';

  @override
  String flow_dayValue(String day, String q) {
    return '$day: $q m³/s';
  }

  @override
  String get loc_nearCoast => '하구 근처';

  @override
  String get point_basisCoast => '가장 가까운 연안 해역 기준으로 조석을 추정했어요. 강 안쪽은 보통 만조·간조가 더 늦고 조차가 작아요.';

  @override
  String get info_noLevelSources =>
      '이곳은 아직 수위 데이터가 없어요. 강 유량: GloFAS 모델(Open-Meteo Flood 경유), 일 단위. 날씨·낚시 시간: Open-Meteo와 정확한 좌표의 천문 계산. 모든 수치는 참고용이에요.';

  @override
  String get flow_title => '강 유량';

  @override
  String flow_today(String q) {
    return '오늘 유량 ≈ $q m³/s';
  }

  @override
  String flow_tomorrow(String q, String trend) {
    return '내일 ≈ $q m³/s · $trend';
  }

  @override
  String get flow_rising => '증가 중(강물이 점점 불어남)';

  @override
  String get flow_falling => '감소 중(강물이 점점 빠짐)';

  @override
  String get flow_steady => '안정';

  @override
  String get flow_note => '이 구간 본류의 일 단위 추정치예요.';

  @override
  String chart_band(String cm) {
    return '선 주위의 흐린 띠: 관측소 백테스트로 측정한 오차 약 ±$cm cm';
  }

  @override
  String turn_in(String duration) {
    return '$duration 후';
  }

  @override
  String day_high(String level, String time) {
    return '최고 $level · $time';
  }

  @override
  String day_low(String level, String time) {
    return '최저 $level · $time';
  }

  @override
  String day_range(int cm) {
    return '차이 $cm cm';
  }

  @override
  String get fishAct_title => '입질 활동';

  @override
  String get fishAct_low => '낮음';

  @override
  String get fishAct_fair => '보통';

  @override
  String get fishAct_high => '높음';

  @override
  String get fishAct_peak => '매우 높음';

  @override
  String fishAct_score(String score) {
    return '$score/10';
  }

  @override
  String fishAct_meter(int count) {
    return '5마리 중 $count마리';
  }

  @override
  String fishAct_because(String reasons) {
    return '$reasons 덕분';
  }

  @override
  String fishAct_next(String when) {
    return '다음 골든 타임: $when';
  }

  @override
  String fishAct_inWindow(String to) {
    return '$to까지 골든 타임';
  }

  @override
  String get fishAct_noWindow => '앞으로 2일간 골든 타임이 없어요';

  @override
  String get fishAct_source => '물때, 달 시간, 낮/밤, 날씨(Open-Meteo)로 추정 — 참고용이며, 어디에 물고기가 있는지는 알 수 없어요.';

  @override
  String get fishAct_quick => '날씨 정보 없음: 우선 물때와 달 시간으로 계산했어요.';

  @override
  String get fishTime_now => '지금';

  @override
  String fishTime_today(String time) {
    return '오늘 $time';
  }

  @override
  String fishTime_tomorrow(String time) {
    return '내일 $time';
  }

  @override
  String fishTime_dayAfter(String time) {
    return '모레 $time';
  }

  @override
  String get fishTime_title => '입질 시간';

  @override
  String get fishTime_slider => '시간을 골라 입질 활동 보기';

  @override
  String get fishTime_reset => '지금으로';

  @override
  String get fishTime_legendNote => '핀 색상 = 추정 입질 활동. 핀을 누르면 자세히 볼 수 있어요.';

  @override
  String get fishTime_collapse => '접기';

  @override
  String get fishTime_expand => '시간별 입질 활동 보기';

  @override
  String get fishing_changeSpot => '변경';

  @override
  String get fishing_plan => '계획';

  @override
  String get pond_search => '이름으로 낚시터 검색…';

  @override
  String pond_header(int count) {
    return '내 주변 낚시터 $count곳';
  }

  @override
  String pond_headerSoon(int count) {
    return '3일 안에 방류하는 낚시터 $count곳';
  }

  @override
  String get pond_headerNone => '예정된 방류가 없어요';

  @override
  String fishing_nextGolden(String range) {
    return '골든 타임 $range';
  }

  @override
  String get fishing_hourly => '오늘 시간별';

  @override
  String get fish_now_title => '지금 낚시';

  @override
  String get fish_unsafe => '기상 경보 발령 중 — 물에 나가지 마세요';

  @override
  String get fish_noWindow => '오늘은 눈에 띄는 시간대가 없어요';

  @override
  String fish_best(String from, String to) {
    return '오늘 좋은 시간: $from–$to';
  }

  @override
  String get cond_title => '해와 달';

  @override
  String loc_river(String river) {
    return '$river강';
  }

  @override
  String loc_nearRiver(String river) {
    return '$river강 근처';
  }

  @override
  String get loc_sea => '바다';

  @override
  String get loc_water => '물 위';

  @override
  String get spot_title => '낚시 포인트';

  @override
  String get spot_mine => '내 위치';

  @override
  String get spot_point => '선택한 지점';

  @override
  String get spot_useMine => '내 위치';

  @override
  String get spot_pickMap => '지도에서 선택';

  @override
  String get spot_pickHint => '낚시할 곳을 탭한 다음 \'여기서 낚시\'를 누르세요';

  @override
  String get spot_saved => '저장한 포인트';

  @override
  String get fish_here => '여기서 낚시';

  @override
  String get advice_title => '지금 낚시 팁';

  @override
  String get advice_note => '일반적인 낚시 경험을 바탕으로 이 포인트에 맞춰 계산했어요.';

  @override
  String get advice_unsafe => '뇌우 또는 강한 돌풍 — 지금은 낚시하지 마세요';

  @override
  String get advice_rising => '물이 들어오는 중: 고기가 물가, 수초 가장자리, 얕은 곳으로 먹이를 찾아와요 — 가까이 노리세요';

  @override
  String get advice_falling => '물이 빠지는 중: 고기가 깊은 곳, 물골 가장자리, 샛강 입구로 빠져요 — 더 멀리 노리세요';

  @override
  String get advice_slack => '정조: 입질이 적어요, 물이 다시 흐를 때까지 기다리세요';

  @override
  String advice_slackAt(String time) {
    return '정조: 입질이 적어요 — $time쯤 물이 다시 흘러요';
  }

  @override
  String get advice_windStrong => '강풍: 멀리 던지기 어려워요 — 바람을 피한 물가에서 낚시하고 배는 타지 마세요';

  @override
  String get advice_windDown => '바람 있음: 바람이 불어 가는 쪽, 파도가 미끼를 모으는 곳을 노리세요';

  @override
  String get advice_rain => '비 올 확률 높음 — 우비를 챙기세요';

  @override
  String get advice_flood => '강물이 빠르게 불고 탁해요: 수제 뒤, 나무 뿌리 주변 와류를 노리세요';

  @override
  String get advice_light => '곧 일출/일몰 — 입질이 활발한 시간';

  @override
  String get advice_good => '포인트 상태 좋음 — 지금 출조하세요';

  @override
  String point_reference(String station, String distance) {
    return '$station 관측소 기준 추정, $distance 거리';
  }

  @override
  String point_referenceRiver(String station, String river, String distance) {
    return '$station 관측소($river강) 기준 추정, $distance 거리';
  }

  @override
  String get point_title => '선택한 지점';

  @override
  String point_coords(String coords) {
    return '좌표: $coords';
  }

  @override
  String get point_copy => '좌표 복사';

  @override
  String get point_copied => '좌표를 복사했어요';

  @override
  String get point_noData => '아직 이 지점의 데이터를 계산하지 못했어요.';

  @override
  String get point_nearby => '가장 가까운 관측소';

  @override
  String point_distance(String distance) {
    return '$distance 거리';
  }

  @override
  String get point_openDetail => '시간별 상세 보기';

  @override
  String point_weatherNow(String temp, String wind, int rain) {
    return '현재 날씨: $temp°C · 바람 $wind km/h · 비 $rain%';
  }

  @override
  String point_sun(String rise, String set) {
    return '일출 $rise · 일몰 $set';
  }

  @override
  String get point_seaModel => '이 지점에서 바로 계산한 해양 모델';

  @override
  String get point_tapHint => '지도 아무 곳이나 탭해서 그곳의 물때를 확인하세요';

  @override
  String get source_shortGauge => 'IOC + utide';

  @override
  String get source_shortModel => 'Open-Meteo';

  @override
  String get source_shortRiver => 'KTTV';

  @override
  String get source_shortRiverTide => 'KTTV + Open-Meteo 조석';

  @override
  String source_compact(String source, String updated) {
    return '출처: $source · $updated';
  }

  @override
  String get source_details => '출처 상세';

  @override
  String get map_credits => '지도 출처';

  @override
  String get map_creditShort => '© OpenStreetMap';

  @override
  String get map_creditShortSat => '© EOX · © OpenStreetMap';

  @override
  String station_datumNote(String datum) {
    return '$datum 기준 높이';
  }

  @override
  String get station_datumChart => '해도 기준면(KTTV 예보문 기준으로 환산)';

  @override
  String get station_datumMsl => '모델 평균 해수면';

  @override
  String station_lunarDay(int day, int month) {
    return '음력 $month/$day';
  }

  @override
  String station_dailyRange(String range) {
    return '조차 $range';
  }

  @override
  String station_coords(String lat, String lon) {
    return '좌표: $lat, $lon';
  }

  @override
  String station_modelFit(String from, String to) {
    return '$from부터 $to까지의 데이터로 계산한 조석 상수';
  }

  @override
  String get station_sourceGauge => 'IOC Sea Level Monitoring(실측) · 예보는 utide로 계산';

  @override
  String get station_sourceModel => 'Open-Meteo Marine(해양 모델, 실측 없음)';

  @override
  String get hourly_now => '지금';

  @override
  String hourly_detailTitle(String time) {
    return '$time 상세';
  }

  @override
  String hourly_obsMinusPred(String delta) {
    return '실측 − 예보: $delta';
  }

  @override
  String hourly_untilNext(String kind, String duration) {
    return '다음 $kind까지 $duration';
  }

  @override
  String hourly_fishScore(String score) {
    return '낚시 지수: $score/10';
  }

  @override
  String hourly_weather(String temp, String wind, String rain) {
    return '$temp °C · 바람 $wind km/h · 비 $rain mm';
  }

  @override
  String get hourly_empty => '이 시간대에는 시간별 데이터가 없어요.';

  @override
  String get chart_semantics => '수위 그래프, 실측은 실선, 예보는 점선';

  @override
  String get watch_empty =>
      '지도에서 지점(또는 관측소)을 탭한 다음 ⭐를 눌러 저장하세요. 저장한 포인트는 여기서 빠르게 확인하고, 알림을 받고, 오프라인에서도 쓸 수 있어요.';

  @override
  String get watch_emptyTitle => '아직 포인트가 없어요';

  @override
  String get watch_openMap => '지도 열기';

  @override
  String get fishing_title => '낚시';

  @override
  String get fishing_pickStation => '관측소 선택';

  @override
  String get fishing_dayScore => '오늘 점수';

  @override
  String fishing_reference(String version) {
    return '추정 지수, 참고용(공식 $version: 물때, 달 시간, 일출/일몰, 24시간 기압, 기온, 바람·비)';
  }

  @override
  String get fishing_golden => '다가오는 골든 타임';

  @override
  String get fishing_noGolden => '오늘은 7점 이상인 시간대가 없어요.';

  @override
  String get fishing_next7 => '향후 7일';

  @override
  String get fishing_nowMark => '지금';

  @override
  String fishing_hourShort(int hour) {
    return '$hour시';
  }

  @override
  String fishing_level(String score, String label) {
    return '$score/10 · $label';
  }

  @override
  String get fishing_levelGood => '좋음';

  @override
  String get fishing_levelFair => '보통';

  @override
  String get fishing_levelPoor => '나쁨';

  @override
  String fishing_warnRed(String from, String to) {
    return '$from–$to 뇌우/낙뢰 또는 강한 돌풍 — 이 시간에는 강/바다에 나가지 마세요.';
  }

  @override
  String fishing_warnYellow(String from, String to) {
    return '$from–$to 뇌우 또는 폭우 가능 — 날씨를 주시하세요.';
  }

  @override
  String fishing_levelOutsideWarning(String score, String label) {
    return '$score/10 · $label (경보 시간 외)';
  }

  @override
  String get fishing_factor_tide => '물때';

  @override
  String get fishing_factor_flow => '물흐름';

  @override
  String get fishing_factor_solunar => '달 시간';

  @override
  String get fishing_factor_pressure => '기압';

  @override
  String get fishing_factor_daytime => '일출/일몰';

  @override
  String get fishing_factor_weather => '날씨';

  @override
  String get fishing_factor_temperature => '쾌적한 기온';

  @override
  String get fishing_factor_season => '어종 시즌';

  @override
  String fishing_moon(String phase, int pct) {
    return '$phase · 밝기 $pct%';
  }

  @override
  String get fishing_weatherSource => 'Open-Meteo(일기 예보)';

  @override
  String get moon_newMoon => '삭';

  @override
  String get moon_waxingCrescent => '초승달';

  @override
  String get moon_firstQuarter => '상현달';

  @override
  String get moon_waxingGibbous => '차가는 달';

  @override
  String get moon_fullMoon => '보름달';

  @override
  String get moon_waningGibbous => '기우는 달';

  @override
  String get moon_lastQuarter => '하현달';

  @override
  String get moon_waningCrescent => '그믐달';

  @override
  String get more_info => '앱 정보';

  @override
  String get more_appName => 'Con Nước';

  @override
  String more_build(String sha) {
    return '빌드 $sha';
  }

  @override
  String get more_update => '새 버전이 있어요 — 페이지를 새로고침해 업데이트하세요';

  @override
  String get more_close => '닫기';

  @override
  String get more_title => '더보기';

  @override
  String get more_explore => '둘러보기';

  @override
  String get more_app => '앱';

  @override
  String get more_journalHint => '내 조과와 낚시 습관';

  @override
  String get more_profileHint => '댓글, 낚시 모임, 리뷰에 표시되는 이름';

  @override
  String get more_editName => '이름 변경';

  @override
  String get more_theme => '테마';

  @override
  String get more_themeSystem => '시스템 설정';

  @override
  String get more_themeLight => '라이트';

  @override
  String get more_themeDark => '다크';

  @override
  String get more_sources => '데이터 출처';

  @override
  String get more_sourcesBody =>
      '• IOC Sea Level Monitoring — Vũng Tàu, Quy Nhơn 해수면 실측(1분마다). 이 2개 관측소의 조석 예보는 12개월 데이터를 조화 분석(utide)해 계산; 역검증 오차: ±10 cm(Vũng Tàu), ±7 cm(Quy Nhơn).\n• 베트남 국가수문기상예보센터(KTTV) — 단기 수문 예보문: 하천 수위 하루 4회 + 예보. 시간별 곡선은 앱이 추정(하구 조석과 결합); 역검증: ±12 cm(하노이), ±11 cm(Nam Đàn).\n• Open-Meteo — 날씨, 파도, 연안 해수면 모델.\n• GloFAS(Open-Meteo Flood 경유) — 하천 본류 일별 유량.\n• 지도의 임의 지점: 그 지점의 해양 모델; 홍강, Cả강에서는 강을 따라 위치로 계산; 그 외에는 가장 가까운 KTTV 하천 관측소(40 km 이내), 연안 조석(추정) 또는 하천 유량 사용.\n• 배경 지도: OpenFreeMap · © OpenMapTiles · 데이터 © OpenStreetMap.\n• 위성 영상: EOxCloudless(EOX IT Services GmbH), Copernicus Sentinel 2025 데이터 포함.\n모든 예보/추정 수치는 참고용이에요. 출처, 기준면, 신뢰도는 각 관측소의 정보 탭에서 확인하세요.';

  @override
  String more_version(String version) {
    return '버전 $version';
  }

  @override
  String get set_title => '설정';

  @override
  String get set_entry => '화면 및 설정';

  @override
  String get set_entryHint => '색상, 배경, 글꼴, 글자 크기, 언어, 알림';

  @override
  String get set_previewTitle => '입질 활동: 높음 · 8.2';

  @override
  String get set_previewBody => '골든 타임 17:00–18:30 · 물 들어오는 중';

  @override
  String get set_look => '화면';

  @override
  String get set_mode => '라이트 또는 다크';

  @override
  String get set_accent => '강조 색상';

  @override
  String get set_backdrop => '배경';

  @override
  String get set_font => '글꼴';

  @override
  String get set_textSize => '글자 크기';

  @override
  String get accent_ocean => '바다';

  @override
  String get accent_jade => '비취';

  @override
  String get accent_leaf => '잎사귀';

  @override
  String get accent_sunset => '노을';

  @override
  String get accent_coral => '산호';

  @override
  String get accent_violet => '보라';

  @override
  String get accent_slate => '흑연';

  @override
  String get accent_gold => '청동';

  @override
  String get backdrop_mist => '안개';

  @override
  String get backdrop_warm => '따뜻한 종이';

  @override
  String get backdrop_pure => '흰색 / AMOLED';

  @override
  String get backdrop_tinted => '강조 색상 따라가기';

  @override
  String get font_beVietnam => 'Be Vietnam';

  @override
  String get font_nunito => 'Nunito 둥근체';

  @override
  String get font_system => '기기 글꼴';

  @override
  String get size_small => '작게';

  @override
  String get size_normal => '보통';

  @override
  String get size_large => '크게';

  @override
  String get size_huge => '아주 크게';

  @override
  String get set_general => '일반';

  @override
  String get set_language => '언어';

  @override
  String get lang_system => '휴대폰 설정';

  @override
  String get lang_vi => 'Tiếng Việt';

  @override
  String get lang_en => 'English';

  @override
  String get set_start => '앱 시작 화면';

  @override
  String get set_notifications => '알림';

  @override
  String get set_notificationsHint => '골든 타임, 만조/간조, 얼마나 미리 알릴지';

  @override
  String get set_motion => '동작 줄이기';

  @override
  String get set_motionHint => '헤엄치는 물고기, 흐르는 물, 애니메이션 끄기 — 오래된 휴대폰에서 더 부드럽고 배터리 절약';

  @override
  String get set_data => '데이터 및 저장공간';

  @override
  String set_cache(String mb) {
    return '캐시 데이터: $mb MB';
  }

  @override
  String get set_cacheHint => '예보, 날씨, 배경 지도 — 필요할 때 다시 받아요. 일지, 저장한 포인트, 설정은 지워지지 않아요.';

  @override
  String get set_cacheClear => '삭제';

  @override
  String get set_cacheCleared => '캐시 데이터를 삭제했어요';

  @override
  String get set_reset => '기본 화면으로 복원';

  @override
  String get set_resetDone => '기본 화면으로 복원했어요';

  @override
  String get sp_title => '오늘은 뭘 낚을까요?';

  @override
  String get sp_seeAll => '모두 보기';

  @override
  String get sp_guideTitle => '어종 도감';

  @override
  String get sp_today => '오늘';

  @override
  String sp_bestTime(String range) {
    return '좋은 시간: $range';
  }

  @override
  String get sp_noTime => '오늘은 좋은 시간이 없어요';

  @override
  String get sp_inSeason => '제철';

  @override
  String get sp_offSeason => '비시즌';

  @override
  String get sp_season => '주 시즌';

  @override
  String get sp_where => '포인트';

  @override
  String get sp_bait => '미끼';

  @override
  String get sp_chum => '밑밥';

  @override
  String get sp_how => '낚는 법';

  @override
  String get sp_todayTips => '오늘 참고';

  @override
  String get sp_note => '일반적인 낚시 경험을 이곳의 실제 물때와 날씨에 맞춰 조정했어요. 참고용이에요.';

  @override
  String get sp_noTips => '오늘은 평소 조건이에요. 하던 대로 낚시하세요.';

  @override
  String get habitat_pond => '연못·호수';

  @override
  String get habitat_river => '강';

  @override
  String get habitat_estuary => '하구';

  @override
  String get habitat_sea => '바다';

  @override
  String get depth_surface => '표층';

  @override
  String get depth_middle => '중층';

  @override
  String get depth_bottom => '바닥';

  @override
  String get spTip_outOfSeason => '아직 주 시즌이 아니에요: 낚을 수는 있지만 적어요.';

  @override
  String get spTip_waitForCurrent => '물이 흐를 때 먹는 어종이에요: 지금은 정조, 물이 다시 흐를 때까지 기다리세요.';

  @override
  String get spTip_murkyStrongBait => '비 온 뒤 흙탕물: 냄새 강한(비린) 미끼로, 물이 맑은 물가 쪽을 노리세요.';

  @override
  String get spTip_coldSmallBaitDeep => '날이 추워짐: 입질이 느려요. 작은 미끼로 깊게, 인내심 있게.';

  @override
  String get spTip_hotGoDeepShade => '무더위: 이른 아침, 해 질 녘에 하거나 깊은 곳과 나무 그늘을 노리세요.';

  @override
  String get spTip_pressureFallingBite => '기압 하강 중: 날씨가 바뀌기 전에 고기가 활발히 먹는 경우가 많아요. 서두르세요.';

  @override
  String get spTip_pressureRisingFinesse => '바람 뒤 기압 급상승: 입질이 약해요. 가는 줄, 작은 바늘을 쓰세요.';

  @override
  String get spTip_windDownwind => '강풍: 바람을 받는 쪽 물가로 가세요. 미끼와 먹이가 그쪽으로 몰려요.';

  @override
  String get spTip_risingNearBank => '물이 들어오는 중: 고기가 물가로 먹이를 찾아와요, 가까이 노리세요.';

  @override
  String get spTip_fallingDeeper => '물이 빠지는 중: 고기가 깊은 물골, 수로 입구로 빠져요, 더 멀리 노리세요.';

  @override
  String get nb_button => '입질이 없나요?';

  @override
  String get nb_title => '입질이 없나요? 이렇게 해 보세요';

  @override
  String get nb_now => '지금 상황에 맞춰';

  @override
  String get nb_always => '확인해 볼 것들';

  @override
  String nb_waitCurrent(String time) {
    return '지금은 정조: $time쯤 물이 다시 흐르면 입질이 좋아져요. 그동안 미끼를 갈고 밑밥을 뿌리세요.';
  }

  @override
  String get nb_goDeepShade => '강한 햇볕: 고기가 깊이 내려가요. 더 깊게 하거나 그늘, 나무 뿌리 쪽으로 옮기세요.';

  @override
  String get nb_coldSlow => '추운 날: 미끼를 작게, 천천히 감고, 깊은 곳 바닥을 노리세요.';

  @override
  String get nb_murkySmell => '흙탕물: 냄새 강한(비린) 미끼로 바꾸고, 물가 쪽 맑은 물을 찾으세요.';

  @override
  String get nb_finesse => '바람 뒤 기압 상승: 고기가 예민해요. 가는 줄, 작은 바늘, 미끼는 적게.';

  @override
  String get nb_downwind => '강풍: 바람을 받는 쪽 물가로 가세요. 먹이가 그쪽으로 밀려와요.';

  @override
  String nb_nextGolden(String time) {
    return '다음 골든 타임은 $time: 잠시 쉬었다가 제시간에 돌아오세요.';
  }

  @override
  String get nb_changeDepth => '수심 바꾸기: 바닥부터 시작해 20–30 cm씩 올려 보세요.';

  @override
  String get nb_moveSpot => '20–30분 동안 기포나 입질이 없으면: 자리를 옮겨 수초, 나무 뿌리, 와류를 찾으세요.';

  @override
  String get nb_freshBait => '새 미끼로 갈고 바늘 끝을 살짝 드러내세요. 오래된 미끼와 밑밥은 냄새가 빠져요.';

  @override
  String get nb_stayQuiet => '조용히 하고, 그림자가 수면에 드리우지 않게 하세요.';

  @override
  String get nb_finerLine => '고기가 예민하면 더 가는 줄, 더 작은 바늘로 바꾸세요.';

  @override
  String get fishing_species => '어종';

  @override
  String get sp_carp => '잉어';

  @override
  String get sp_carp_where => '연못, 호수, 느린 강; 수초 군락, 물에 잠긴 나무 뿌리, 진흙 바닥 주변.';

  @override
  String get sp_carp_bait => '볶은 쌀겨, 옥수수 가루, 불린 옥수수, 붉은 지렁이.';

  @override
  String get sp_carp_chum => '신맛 밑밥(쌀겨 + 옥수수 가루 발효) 또는 우유, 파인애플 향. 15–20분 전에 밑밥을 뿌리세요.';

  @override
  String get sp_carp_how => '대낚시 또는 바닥 원투로 바닥에 붙이고 예민한 찌 사용; 잉어는 찌를 올린 뒤 끌고 가는 경우가 많아요.';

  @override
  String get sp_tilapia => '틸라피아';

  @override
  String get sp_tilapia_where => '연못, 호수, 수로, 느린 강; 따뜻하고 햇볕 드는 물가.';

  @override
  String get sp_tilapia_bait => '펠릿, 밀가루 반죽, 지렁이, 작은 새우.';

  @override
  String get sp_tilapia_chum => '달콤한 향(우유, 바닐라) 또는 약간 비린 밑밥을 조금씩 자주.';

  @override
  String get sp_tilapia_how => '작은 바늘, 중층에서 바닥 근처; 찌가 잠기면 바로 가볍게 챔질.';

  @override
  String get sp_grassCarp => '초어';

  @override
  String get sp_grassCarp_where => '호수, 큰 강, 유료 낚시터; 풀과 부평초가 있는 물가.';

  @override
  String get sp_grassCarp_bait => '어린 풀, 카사바 잎, 삶은 옥수수, 쌀겨 반죽.';

  @override
  String get sp_grassCarp_chum => '발효 옥수수, 쌀겨에 옥수수 가루를 섞은 것.';

  @override
  String get sp_grassCarp_how => '튼튼한 줄과 낚싯대, 드랙은 적당히; 힘차게 달리니 차분히 끌어내세요.';

  @override
  String get sp_snakehead => '가물치';

  @override
  String get sp_snakehead_where => '논, 수로, 수초와 부레옥잠 많은 연못; 물가 가까이, 부유물 주변.';

  @override
  String get sp_snakehead_bait => '개구리, 작은 산 물고기, 루어(프로그, 스푼).';

  @override
  String get sp_snakehead_chum => '밑밥 필요 없음.';

  @override
  String get sp_snakehead_how => '수초 가장자리를 따라 끌거나 액션을 주고, 조용히 이동; 강하게 물고 수초 속으로 파고들어요.';

  @override
  String get sp_walkingCatfish => '워킹 메기';

  @override
  String get sp_walkingCatfish_where => '연못, 논, 진흙 바닥 수로; 물가의 구멍.';

  @override
  String get sp_walkingCatfish_bait => '지렁이, 닭 내장, 새우, 비린 미끼.';

  @override
  String get sp_walkingCatfish_chum => '비린 밑밥(상한 생선, 어분).';

  @override
  String get sp_walkingCatfish_how => '밤이나 비 온 뒤 바닥 낚시; 채비는 튼튼하게, 바늘은 중간 크기.';

  @override
  String get sp_pangasius => '판가시우스(tra, basa)';

  @override
  String get sp_pangasius_where => '메콩 유역 큰 강, 유료 낚시터; 깊은 물골.';

  @override
  String get sp_pangasius_bait => '펠릿, 닭 내장, 상한 생선, 반죽.';

  @override
  String get sp_pangasius_chum => '비린 또는 신맛 밑밥.';

  @override
  String get sp_pangasius_how => '중층에서 바닥까지, 튼튼한 줄; 힘이 아주 세요.';

  @override
  String get sp_mystus => '미스투스 메기';

  @override
  String get sp_mystus_where => '흐르는 강과 계류, 자갈 여울; 구간마다 먹는 시간이 달라요.';

  @override
  String get sp_mystus_bait => '지렁이, 새우, 애벌레.';

  @override
  String get sp_mystus_chum => '약간 비리게, 조금만.';

  @override
  String get sp_mystus_how => '물이 흐르기 시작할 때 물살 경계를 따라 바닥 낚시; 언제 들어오는지 현지 낚시꾼에게 물어보세요.';

  @override
  String get sp_mullet => '숭어';

  @override
  String get sp_mullet_where => '하구, 석호, 항구; 들물에 수로 입구로 들어오고 날물에 빠져나가요.';

  @override
  String get sp_mullet_bait => '이끼, 밀가루와 쌀겨 반죽, 빵 속살.';

  @override
  String get sp_mullet_chum => '신맛에 약간 비린 밑밥을 물살 따라 고르게.';

  @override
  String get sp_mullet_how => '작고 예민한 찌와 작은 바늘로, 물이 흐를 때 흐름을 따라 낚으세요.';

  @override
  String get sp_seabass => '바라문디(농어)';

  @override
  String get sp_seabass_where => '하구, 석호, 갯바위; 교각, 수문, 와류 주변.';

  @override
  String get sp_seabass_bait => '산 새우, 작은 물고기, 루어.';

  @override
  String get sp_seabass_chum => '밑밥 필요 없음.';

  @override
  String get sp_seabass_how => '루어를 던지거나 산 새우를 물살에 흘리세요; 물살이 셀 때와 새벽, 해 질 녘이 가장 좋아요.';

  @override
  String get sp_snapper => '도미(스내퍼)';

  @override
  String get sp_snapper_where => '바다, 갯바위, 암초; 깊은 암초 바닥.';

  @override
  String get sp_snapper_bait => '오징어, 새우, 신선한 미끼 고기.';

  @override
  String get sp_snapper_chum => '필요 없음, 또는 잘게 썬 미끼를 바닥에.';

  @override
  String get sp_snapper_how => '바닥 낚시, 바닥을 잡을 만큼만 봉돌, 내마모 목줄; 사리 때가 가장 좋아요.';

  @override
  String get sp_grouper => '능성어(그루퍼)';

  @override
  String get sp_grouper_where => '암초, 해안 갯바위; 바위 바닥의 구멍.';

  @override
  String get sp_grouper_bait => '작은 산 물고기, 오징어, 새우.';

  @override
  String get sp_grouper_chum => '밑밥 필요 없음.';

  @override
  String get sp_grouper_how => '물자마자 바로 제압해 구멍으로 못 들어가게; 튼튼한 줄.';

  @override
  String get sp_goby => '망둑어';

  @override
  String get sp_goby_where => '수로, 기수역 강; 모래·진흙 바닥.';

  @override
  String get sp_goby_bait => '작은 새우, 지렁이.';

  @override
  String get sp_goby_chum => '밑밥 필요 없음.';

  @override
  String get sp_goby_how => '가벼운 바닥 채비, 작은 바늘; 입질이 약하니 찌가 확실히 움직일 때까지 기다리세요.';

  @override
  String get sp_climbingPerch => '등목어';

  @override
  String get sp_climbingPerch_where => '논, 도랑, 연못; 풀 가장자리; 첫 비가 온 뒤가 가장 좋아요.';

  @override
  String get sp_climbingPerch_bait => '지렁이, 메뚜기, 밥 반죽.';

  @override
  String get sp_climbingPerch_chum => '볶은 쌀겨를 물가에 조금.';

  @override
  String get sp_climbingPerch_how => '풀 물가 가까이 손줄 낚시, 작은 바늘, 빠른 챔질.';

  @override
  String get sp_crucian => '붕어';

  @override
  String get sp_crucian_where => '연못, 호수; 바닥과 중층, 시원한 물을 좋아해요.';

  @override
  String get sp_crucian_bait => '붉은 지렁이, 밀가루 반죽.';

  @override
  String get sp_crucian_chum => '곱고 달콤한 밑밥을 조금.';

  @override
  String get sp_crucian_how => '작은 바늘, 예민한 찌, 대낚시; 서늘한 계절에 많아요.';

  @override
  String get sp_bighead => '대두어·백련어';

  @override
  String get sp_bighead_where => '큰 호수, 유료 낚시터; 맑고 따뜻한 날 표층과 중층.';

  @override
  String get sp_bighead_bait => '집어 떡밥: 쌀겨와 콩가루를 느슨하게 뭉쳐 물속에서 풀리게.';

  @override
  String get sp_bighead_chum => '물에 뜨는 밑밥, 물속에서 구름처럼 퍼져요.';

  @override
  String get sp_bighead_how => '표층–중층에 찌를 띄우고 풀리는 떡밥 뭉치 사용; 찌가 천천히 잠길 때 챔질.';

  @override
  String get nav_backAgain => '한 번 더 뒤로 스와이프하면 종료돼요';

  @override
  String get map_hereNow => '지금 내 주변';

  @override
  String map_nextGolden(String time) {
    return '골든 타임 $time';
  }

  @override
  String get fishing_noGoldenShort => '아직 골든 타임 없음';

  @override
  String get flood_entry => '몇 시에 돌아갈 길이 잠길까?';

  @override
  String get flood_title => '몇 시에 돌아갈 길이 잠길까?';

  @override
  String get flood_ask => '지금 수면이 서 있는 곳(또는 돌아갈 길)보다 대략 얼마나 낮나요?';

  @override
  String flood_margin(int cm) {
    return '${cm}cm';
  }

  @override
  String get flood_noTide => '이곳은 아직 조석 예보가 없어 계산할 수 없어요.';

  @override
  String get flood_safe => '앞으로 24시간 동안 물이 거기까지 오지 않아요';

  @override
  String flood_at(String time) {
    return '물이 $time에 도달해요';
  }

  @override
  String get flood_already => '물이 이미 이 높이예요. 바로 떠나세요.';

  @override
  String flood_leave(String time) {
    return '$time 전에 떠나세요.';
  }

  @override
  String flood_in(String duration) {
    return '약 $duration 남았어요.';
  }

  @override
  String flood_recede(String time) {
    return '$time쯤 물이 다시 빠져요.';
  }

  @override
  String flood_peak(String time, String level) {
    return '만조 $time, 관측소 기준면 대비 약 $level.';
  }

  @override
  String get flood_windy => '강풍: 물이 예보보다 높아질 수 있어 앱이 20 cm 앞당겨 계산했어요. 더 일찍 떠나세요.';

  @override
  String get flood_note => '이곳 조석 예보로 추정한 값으로 참고용이에요. 파도, 바람, 홍수로 물이 더 빨리 오를 수 있어요: 항상 퇴로를 확보하세요.';

  @override
  String flood_minutes(int m) {
    return '$m분';
  }

  @override
  String flood_hoursMinutes(int h, int m) {
    return '$h시간 $m분';
  }

  @override
  String flood_alarmButton(String time) {
    return '$time에 알람';
  }

  @override
  String flood_alarmSet(String time) {
    return '$time 알람 설정됨 · 탭해서 취소';
  }

  @override
  String get flood_alarmApk => '알람은 Android 앱에서 쓸 수 있어요(더보기 탭에서 APK 다운로드).';

  @override
  String flood_alarmTitle(String place) {
    return '곧 잠겨요: $place';
  }

  @override
  String flood_alarmBody(String time) {
    return '물이 $time쯤 도달해요. 낚싯대를 거두고 바로 자리를 떠나세요.';
  }

  @override
  String get flood_channel => '돌아갈 길 침수 알림';

  @override
  String get shift_title => '곧 날씨가 바뀌어요';

  @override
  String get shift_dayAfter => '모레';

  @override
  String shift_coldFront(String when) {
    return '$when 추워져요(계절풍): 그 직전에 입질이 활발한 경우가 많으니 가 볼 만해요. 그 후 1–2일은 입질이 약해요.';
  }

  @override
  String shift_heavyRain(String when) {
    return '$when 큰비: 비 온 뒤 물이 탁해요. 바닥을 노리고 비린 미끼로, 물가 쪽 맑은 곳을 찾으세요.';
  }

  @override
  String shift_pressureDrop(String when) {
    return '$when부터 기압 급하강: 날씨가 나빠져요. 뇌우, 저기압 경보를 주시하세요.';
  }

  @override
  String shift_heatWave(String when) {
    return '$when 36°C 넘는 무더위: 이른 아침, 해 질 녘에, 깊은 곳과 그늘을 노리세요.';
  }

  @override
  String get shift_note => 'Open-Meteo 일기 예보 기준, 참고용이에요.';

  @override
  String get alert_evening => '전날 저녁 알림(20:00)';

  @override
  String get alert_eveningHint => '\'내일 낚시 갈까요?\': 내 포인트의 내일 최고 골든 타임';

  @override
  String digest_title(String place) {
    return '내일 낚시 갈까요? · $place';
  }

  @override
  String digest_body(String range, String band, String score) {
    return '골든 타임 $range: 입질 활동 $band($score). 오늘 밤 장비를 챙겨 두세요!';
  }

  @override
  String get digest_none => '내일은 이곳에 골든 타임이 없어요. 앱에서 \'어디로 갈까?\'를 열어 더 좋은 곳을 찾아보세요.';

  @override
  String get brag_open => '조과 사진 자랑하기';

  @override
  String get brag_title => '조과 자랑';

  @override
  String get brag_share => '사진 공유';

  @override
  String get brag_showPlace => '낚시 장소 이름 표시';

  @override
  String get brag_showPlaceHint => '명당을 비밀로 지키도록 기본은 꺼져 있어요';

  @override
  String brag_score(String score) {
    return '입질 활동 $score';
  }

  @override
  String brag_text(String species, String link) {
    return '방금 $species 낚았어요! Con Nước에서 입질 시간과 물때 보기: $link';
  }

  @override
  String get bite_question => '여기서 낚시 중이세요? 입질 있나요?';

  @override
  String get bite_yes => '입질 있음';

  @override
  String get bite_no => '입질 없음';

  @override
  String get bite_thanks => '감사합니다! 알려 주신 덕분에 근처 낚시꾼들이 입질 여부를 알 수 있어요.';

  @override
  String get bite_tooSoon => '방금 알려 주셨어요. 30분 뒤에 다시 알려 주세요.';

  @override
  String get bite_failed => '보내지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String bite_summary(int bites, int misses) {
    return '근처 최근 3시간: 입질 있음 $bites명, 입질 없음 $misses명.';
  }

  @override
  String get bite_first => '아직 근처에서 알려 준 사람이 없어요. 첫 번째가 되어 주세요!';

  @override
  String bite_pattern(String state, int rate) {
    return '이곳은 $state 때 입질이 가장 좋아요 (입질 $rate%, 최근 60일).';
  }

  @override
  String get bite_rising => '들물';

  @override
  String get bite_falling => '날물';

  @override
  String get bite_slack => '정조';

  @override
  String get bite_note => '낚시꾼들의 응답을 모은 것으로, 약 2km 범위의 지역만 저장하며 신원은 저장하지 않아요.';

  @override
  String get gear_title => '장비 & 매듭';

  @override
  String get gear_entry => '장비 & 매듭';

  @override
  String get gear_entryHint => '챙길 장비 목록, 자주 쓰는 매듭 6가지 묶는 법';

  @override
  String get gear_tabPack => '챙길 것';

  @override
  String get gear_tabKnots => '매듭';

  @override
  String gear_progress(int done, int total) {
    return '$done/$total개';
  }

  @override
  String get gear_clear => '다음 출조를 위해 모두 체크 해제';

  @override
  String get trip_night => '밤낚시';

  @override
  String get trip_sea => '바다, 갯바위';

  @override
  String get trip_pond => '유료 낚시터';

  @override
  String get trip_river => '강, 수로';

  @override
  String get gear_rodReel => '낚싯대, 릴 (릴 회전·드랙 점검)';

  @override
  String get gear_spareLine => '여분 낚싯줄';

  @override
  String get gear_hooksWeights => '여분 바늘, 봉돌, 찌, 스냅';

  @override
  String get gear_baitChum => '미끼와 밑밥';

  @override
  String get gear_netTowel => '뜰채와 손수건';

  @override
  String get gear_waterFood => '마실 물, 먹을 것';

  @override
  String get gear_sunHat => '모자, 선크림, 선글라스';

  @override
  String get gear_raincoat => '우비';

  @override
  String get gear_phonePower => '완충한 휴대폰, 보조배터리';

  @override
  String get gear_trashBag => '쓰레기 되가져갈 봉투';

  @override
  String get gear_headlamp => '헤드랜턴, 여분 배터리';

  @override
  String get gear_glowSticks => '케미라이트, 전자찌 불빛';

  @override
  String get gear_mosquito => '모기 기피제';

  @override
  String get gear_jacket => '겉옷 (바람 불고 추운 밤)';

  @override
  String get gear_nonSlipShoes => '미끄럼 방지 신발';

  @override
  String get gear_lifeJacket => '구명조끼';

  @override
  String get gear_tideCheck => '앱에서 물때와 \"돌아갈 길 침수\" 확인';

  @override
  String get gear_leader => '내마모 쇼크리더';

  @override
  String get gear_pliers => '바늘 빼기 플라이어';

  @override
  String get gear_pondCall => '낚시터에 전화: 요금, 영업시간, 방류 일정';

  @override
  String get gear_chairUmbrella => '의자, 파라솔';

  @override
  String get gear_keepNet => '살림망 또는 물칸';

  @override
  String get gear_boots => '장화 또는 웨이딩 슈즈';

  @override
  String get gear_rodRest => '받침틀, 뒷꽂이';

  @override
  String knot_strength(int pct) {
    return '줄 강도의 약 $pct% 유지';
  }

  @override
  String get knot_note => '공통 팁: 조이기 전에 침으로 적시고, 열이 나지 않게 천천히 조이고, 끝은 2–3mm 남기고 자르세요. 그림은 개략도입니다.';

  @override
  String get knot_improvedClinch => '개량 클린치 매듭';

  @override
  String get knot_improvedClinch_use => '모노줄에 바늘, 스냅 연결. 가장 쉬워서 누구나 알아 두면 좋아요.';

  @override
  String get knot_improvedClinch_steps =>
      '줄을 바늘 귀에 통과시키고 약 15cm 남깁니다.\n줄 끝을 원줄에 5–7번 감습니다.\n줄 끝을 바늘 귀 쪽 작은 고리에 넣고, 방금 생긴 큰 고리로 다시 통과시킵니다.\n적신 뒤 원줄을 당겨 조이고 끝을 자릅니다.';

  @override
  String get knot_palomar => '팔로마 매듭';

  @override
  String get knot_palomar_use => '합사(PE)에 바늘, 루어 연결. 매우 튼튼하고 빨라요.';

  @override
  String get knot_palomar_steps =>
      '줄을 약 15cm 두 겹으로 접어 접힌 부분을 바늘 귀에 넣습니다.\n두 겹 줄로 느슨한 옭매듭을 맵니다.\n바늘 전체를 접힌 고리 안으로 통과시킵니다.\n적신 뒤 양쪽을 당겨 조이고 끝을 자릅니다.';

  @override
  String get knot_uni => '유니 매듭';

  @override
  String get knot_uni_use => '바늘, 스냅, 루어 연결; 모노줄과 합사 모두 사용 가능.';

  @override
  String get knot_uni_steps =>
      '줄을 바늘 귀에 통과시키고 줄 끝을 원줄과 나란히 접어 고리를 만듭니다.\n줄 끝으로 고리 안의 두 줄을 5–6번 감습니다.\n줄 끝을 당겨 감은 부분을 가지런히 정리합니다.\n적신 뒤 원줄을 당겨 매듭을 바늘 귀까지 밀고 끝을 자릅니다.';

  @override
  String get knot_doubleUni => '더블 유니 매듭';

  @override
  String get knot_doubleUni_use => '두 줄 연결 (합사와 모노 쇼크리더, 또는 끊어진 줄).';

  @override
  String get knot_doubleUni_steps =>
      '두 줄 끝을 약 20cm 겹칩니다.\n첫 번째 줄 끝으로 두 번째 줄에 유니 매듭을 맵니다 (3–4회; 합사는 6–8회).\n두 번째 줄 끝도 똑같이 합니다.\n적신 뒤 두 원줄을 당겨 두 매듭이 맞붙게 하고 끝을 자릅니다.';

  @override
  String get knot_perfectionLoop => '퍼펙션 루프';

  @override
  String get knot_perfectionLoop_use => '줄 끝에 고리를 만들어 채비, 쇼크리더를 빠르게 연결.';

  @override
  String get knot_perfectionLoop_steps =>
      '줄 끝에 작은 고리를 만들고 줄 끝은 뒤쪽에 둡니다.\n줄 끝을 감아 앞쪽에 두 번째 고리를 만듭니다.\n줄 끝을 두 고리 사이로 넣습니다.\n두 번째 고리를 첫 번째 고리로 빼내 조이고 끝을 자릅니다.';

  @override
  String get knot_snell => '스넬 매듭';

  @override
  String get knot_snell_use => '대낚시·외바늘 묶기. 줄이 바늘 축을 따라 곧게 뻗어 걸림률이 높아져요.';

  @override
  String get knot_snell_steps =>
      '줄을 바늘 귀에 통과시키고 바늘 축을 따라 놓아 고리를 만듭니다.\n고리로 바늘 축과 줄을 귀에서 아래로 7–8번 감습니다.\n감은 부분을 잡고 원줄을 당겨 조입니다.\n적신 뒤 한 번 더 조이고 끝을 자릅니다.';

  @override
  String get font_quicksand => 'Quicksand';

  @override
  String get set_navStyle => '탭 바 스타일';

  @override
  String get nav_styleDot => '점';

  @override
  String get lang_zh => '中文';

  @override
  String get lang_ko => '한국어';

  @override
  String get lang_ja => '日本語';

  @override
  String get pond_zalo => 'Zalo 채팅';

  @override
  String get pond_filterWeekend => '주말 방류';

  @override
  String get release_alarmPond => '팔로우한 낚시터';

  @override
  String release_alarmTitle(String pond) {
    return '곧 방류: $pond';
  }

  @override
  String release_alarmBody(String when) {
    return '$when 방류. 일찍 가서 좋은 자리 잡으세요!';
  }

  @override
  String release_alarmBodyKg(String when, int kg) {
    return '$when 약 ${kg}kg 방류. 일찍 가서 좋은 자리 잡으세요!';
  }

  @override
  String get nav_styleArc => '아치';

  @override
  String get nav_styleNotch => '노치';

  @override
  String get nav_styleGlass => '글래스';

  @override
  String get map_layerPonds => '낚시터';

  @override
  String get map_layerSpots => '커뮤니티 포인트';

  @override
  String get map_layerTrips => '낚시 모임';

  @override
  String get map_layerCheckins => '지금 낚시 중';

  @override
  String get onb_skip => '건너뛰기';

  @override
  String get onb_back => '뒤로';

  @override
  String get onb_next => '계속';

  @override
  String get onb_start => '시작하기';

  @override
  String get onb_finish => '완료';

  @override
  String onb_progress(int step, int total) {
    return '$step/$total단계';
  }

  @override
  String get onb_welcomeTitle => 'Con Nước에 오신 것을 환영합니다';

  @override
  String get onb_welcomeBody => '물때, 골든타임, 주변 낚시터를 한눈에 — 오프라인에서도 사용할 수 있어요.';

  @override
  String get onb_welcomeTide => '지역별 물때와 날씨';

  @override
  String get onb_welcomeGolden => '매일의 골든타임과 낚시 지수';

  @override
  String get onb_welcomeCommunity => '커뮤니티의 낚시터, 포인트, 출조 모임';

  @override
  String get onb_welcomeTime => '1분이면 끝나요 · 약관 외 모든 단계는 건너뛸 수 있어요';

  @override
  String get onb_langTitle => '언어 선택';

  @override
  String get onb_langBody => '선택하면 바로 바뀌며, 설정에서 다시 바꿀 수 있어요.';

  @override
  String get onb_nameTitle => '이름을 알려 주세요';

  @override
  String get onb_nameBody => '댓글, 출조 모임, 낚시터 리뷰에 표시돼요. 선택 사항: 비워 두면 익명이에요.';

  @override
  String get onb_nameShownAs => '다른 사람에게 보이는 이름';

  @override
  String get onb_nameErrShort => '2자 이상 입력하세요.';

  @override
  String get onb_nameErrLong => '최대 30자까지 입력할 수 있어요.';

  @override
  String get onb_nameErrChars => '숨겨진 문자가 포함되어 있어요.';

  @override
  String get onb_nameErrLink => '이름에 링크를 넣을 수 없어요.';

  @override
  String get onb_nameErrPhone => '이름에 전화번호를 넣을 수 없어요.';

  @override
  String get onb_nameErrReserved => '관리자나 앱으로 오해될 수 있는 이름이에요. 다른 이름을 골라 주세요.';

  @override
  String get onb_kindTitle => '어떤 분이신가요?';

  @override
  String get onb_kindBody => '하나 이상 고르세요. 맞는 탭과 지도 레이어로 열어 드려요.';

  @override
  String get onb_kindWeekend => '주말 취미 낚시';

  @override
  String get onb_kindWeekendHint => '오늘 낚시 가기 좋은지 빠르게 확인';

  @override
  String get onb_kindPro => '전문 낚시 (강, 바다)';

  @override
  String get onb_kindProHint => '물때, 골든타임, 바람과 파도';

  @override
  String get onb_kindPond => '유료 낚시터 이용';

  @override
  String get onb_kindPondHint => '낚시터 찾기, 방류 일정과 리뷰';

  @override
  String get onb_kindOwner => '낚시터 운영자';

  @override
  String get onb_kindOwnerHint => '낚시터 등록, 방류 소식 알리기';

  @override
  String get onb_kindBoater => '바다·배 이용자';

  @override
  String get onb_kindBoaterHint => '출항 전 물때와 풍랑 확인';

  @override
  String get onb_kindTide => '물때만 보기';

  @override
  String get onb_kindTideHint => '깔끔한 지도: 관측소와 수위만';

  @override
  String get onb_prefsTitle => '조금만 더 설정해요';

  @override
  String get onb_prefsBody => '모두 선택 사항이며 나중에 바꿀 수 있어요.';

  @override
  String get onb_waterTitle => '주로 어디서 낚시하나요?';

  @override
  String get onb_waterRiver => '강, 수로';

  @override
  String get onb_waterSea => '바다';

  @override
  String get onb_waterLake => '호수, 저수지';

  @override
  String get onb_notifyTitle => '알림';

  @override
  String get onb_notifyAlarms => '골든타임 & 물때 알람';

  @override
  String get onb_notifyAlarmsHint => '관심 탭에서 장소별로 켜세요';

  @override
  String get onb_notifyDenied => '알림 권한이 없어요. 휴대폰 설정에서 다시 켤 수 있어요.';

  @override
  String get onb_locTitle => '내 위치';

  @override
  String get onb_locAllow => '위치 허용';

  @override
  String get onb_locOn => '위치가 켜져 있어요';

  @override
  String get onb_lookTitle => '모양 선택';

  @override
  String get onb_lookBody => '강조 색상, 라이트/다크, 탭 바 스타일. 아래에서 미리 보세요.';

  @override
  String get social_tooFast => '조금 빨라요 — 잠시 후 다시 시도해 주세요';

  @override
  String get social_daily => '오늘 보낼 수 있는 횟수를 다 썼어요. 내일 다시 시도해 주세요.';

  @override
  String get social_newDevice => '새 기기는 처음에 제한이 있어요 — 약 10분 후 다시 보내 주세요';

  @override
  String get social_banned => '이 기기의 내용이 여러 번 신고되어 게시가 일시 중지되었어요';

  @override
  String social_bannedUntil(String time) {
    return '이 기기의 내용이 여러 번 신고되어 $time까지 게시가 중지되었어요';
  }

  @override
  String get blocked_link => '공개 내용에는 링크를 올리지 말아 주세요';

  @override
  String get blocked_phone => '공개 내용에는 전화번호를 쓰지 말아 주세요 (광고·사기 방지)';

  @override
  String get blocked_contactAd => '공개 내용에서 Zalo, Telegram, DM 초대는 하지 말아 주세요';

  @override
  String get blocked_spam => '도박·대출 광고 같은 내용은 게시할 수 없어요';

  @override
  String get blocked_offensive => '비속어가 있어요. 수정해 주세요';

  @override
  String get blocked_chars => '글자를 반복하지 말아 주세요 (예: \"gooood\")';

  @override
  String get blocked_shouting => 'Caps Lock을 꺼 주세요';

  @override
  String get blocked_impersonation => '운영팀으로 오해할 수 있는 이름이에요. 다른 이름을 골라 주세요';

  @override
  String get blocked_repeat => '방금 똑같은 내용을 보냈어요';

  @override
  String get blocked_other => '게시하기에 적합하지 않은 내용이에요. 수정해 주세요';

  @override
  String get wx_title => '날씨';

  @override
  String wx_source(String time) {
    return '예보 · Open-Meteo · $time 업데이트';
  }

  @override
  String wx_staleSource(String time) {
    return '오프라인 · $time에 저장된 예보 · Open-Meteo';
  }

  @override
  String get wx_now => '지금';

  @override
  String get wx_forecastTag => '예보';

  @override
  String wx_feels(String temp) {
    return '체감 $temp°';
  }

  @override
  String get wx_humidity => '습도';

  @override
  String get wx_wind => '바람';

  @override
  String get wx_gust => '돌풍';

  @override
  String get wx_uv => '자외선 지수';

  @override
  String get wx_pressure => '기압';

  @override
  String get wx_rainSoon => '3시간 내 비';

  @override
  String get wx_visibility => '가시거리';

  @override
  String wx_windValue(String dir, int kmh) {
    return '$dir $kmh km/h';
  }

  @override
  String wx_force(int force) {
    return '$force등급';
  }

  @override
  String wx_kmh(int kmh) {
    return '$kmh km/h';
  }

  @override
  String wx_percent(int pct) {
    return '$pct%';
  }

  @override
  String wx_hpa(int hpa) {
    return '$hpa hPa';
  }

  @override
  String wx_km(String km) {
    return '$km km';
  }

  @override
  String wx_mm(String mm) {
    return '$mm mm';
  }

  @override
  String get wx_uvLow => '낮음';

  @override
  String get wx_uvModerate => '보통';

  @override
  String get wx_uvHigh => '높음';

  @override
  String get wx_uvVeryHigh => '매우 높음';

  @override
  String get wx_uvExtreme => '위험';

  @override
  String get wx_trendFallingFast => '빠르게 하강';

  @override
  String get wx_trendFalling => '하강';

  @override
  String get wx_trendSteady => '안정';

  @override
  String get wx_trendRising => '상승';

  @override
  String get wx_trendRisingFast => '빠르게 상승';

  @override
  String wx_trend24h(String trend) {
    return '24시간 전보다 $trend';
  }

  @override
  String get wx_skyClear => '맑음';

  @override
  String get wx_skyClearNight => '맑음';

  @override
  String get wx_skyMainlyClear => '대체로 맑음';

  @override
  String get wx_skyPartlyCloudy => '구름 조금';

  @override
  String get wx_skyOvercast => '흐림';

  @override
  String get wx_skyFog => '안개';

  @override
  String get wx_skyDrizzle => '이슬비';

  @override
  String get wx_skyRainLight => '약한 비';

  @override
  String get wx_skyRainModerate => '비';

  @override
  String get wx_skyRainHeavy => '강한 비';

  @override
  String get wx_skyShowersLight => '약한 소나기';

  @override
  String get wx_skyShowers => '소나기';

  @override
  String get wx_skyShowersHeavy => '강한 소나기';

  @override
  String get wx_skySnow => '눈';

  @override
  String get wx_skyThunderstorm => '뇌우';

  @override
  String get wx_skyThunderstormHail => '뇌우, 우박';

  @override
  String get wx_dirN => '북풍';

  @override
  String get wx_dirNe => '북동풍';

  @override
  String get wx_dirE => '동풍';

  @override
  String get wx_dirSe => '남동풍';

  @override
  String get wx_dirS => '남풍';

  @override
  String get wx_dirSw => '남서풍';

  @override
  String get wx_dirW => '서풍';

  @override
  String get wx_dirNw => '북서풍';

  @override
  String get wx_hourlyTitle => '시간별';

  @override
  String wx_dailyTitle(int days) {
    return '앞으로 $days일';
  }

  @override
  String get wx_wdMon => '월';

  @override
  String get wx_wdTue => '화';

  @override
  String get wx_wdWed => '수';

  @override
  String get wx_wdThu => '목';

  @override
  String get wx_wdFri => '금';

  @override
  String get wx_wdSat => '토';

  @override
  String get wx_wdSun => '일';

  @override
  String get wx_partMorning => '아침';

  @override
  String get wx_partNoon => '낮';

  @override
  String get wx_partAfternoon => '오후';

  @override
  String get wx_partEvening => '저녁';

  @override
  String get wx_partNight => '밤';

  @override
  String wx_when(String part, String day) {
    return '$day $part';
  }

  @override
  String get wx_dayToday => '오늘';

  @override
  String get wx_dayTomorrow => '내일';

  @override
  String wx_dayWind(int kmh) {
    return '최대 풍속 $kmh km/h';
  }

  @override
  String wx_dayGust(int kmh) {
    return '돌풍 $kmh km/h';
  }

  @override
  String get wx_farNote => '4일째부터는 장기 예보라 정확도가 낮습니다.';

  @override
  String get wx_adviceTitle => '낚시 팁';

  @override
  String wx_adv_storm(String when) {
    return '$when 뇌우 — 물가와 개활지를 피하세요';
  }

  @override
  String wx_adv_wind(String when, int force) {
    return '$when부터 강풍, 최대 $force등급 — 배를 띄우지 마세요';
  }

  @override
  String wx_adv_gust(String when, int force) {
    return '$when 돌풍 $force등급 — 배 위에서 조심하세요';
  }

  @override
  String wx_adv_heavyRain(String when, int mm) {
    return '$when 폭우, 하루 약 ${mm}mm — 물이 탁해지고 강물이 빠르게 불어날 수 있어요';
  }

  @override
  String wx_adv_rainSoon(String time, int pct) {
    return '$time부터 비 가능성 ($pct%) — 우비를 챙기세요';
  }

  @override
  String wx_adv_fog(String when) {
    return '$when 안개 — 천천히 운항하고 불을 켜세요';
  }

  @override
  String wx_adv_cold(String when, int temp) {
    return '추움, $when $temp°까지 — 따뜻하게 입으세요';
  }

  @override
  String wx_adv_heat(String when, int temp) {
    return '무더위, $when 체감 $temp° — 물을 충분히 마시고 땡볕을 피하세요';
  }

  @override
  String wx_adv_uv(String when, int uv) {
    return '$when 자외선 $uv — 모자, 긴소매, 선크림';
  }

  @override
  String get wx_adv_pressure => '잔잔하고 기압이 조금씩 내려가요 — 입질이 좋다고들 해요';

  @override
  String get wx_adv_calm => '6시간 동안 바람 약하고 비 가능성 낮음 — 낚시하기 좋아요';

  @override
  String get wx_adviceNote => '예보 기반, 참고용';

  @override
  String get wx_empty => '이곳의 날씨 예보가 아직 없어요';

  @override
  String get wx_error => '날씨 예보를 불러오지 못했어요';

  @override
  String wx_hourSemantics(String time, String sky, String temp, String pct) {
    return '$time: $sky, $temp도, 강수 확률 $pct';
  }

  @override
  String wx_daySemantics(String day, String sky, String min, String max, String pct) {
    return '$day: $sky, 최저 $min도, 최고 $max도, 강수 확률 $pct';
  }

  @override
  String wx_dayRain(String mm) {
    return '비 ${mm}mm';
  }

  @override
  String wx_dayWindDir(String dir, int kmh) {
    return '$dir 최대 $kmh km/h';
  }

  @override
  String get wx_hourlyLegend => '파란색: 강수 확률(%)과 강수량(mm). 마지막 줄: 풍속 km/h, 화살표는 바람이 부는 방향.';

  @override
  String get water_kind_sea => '바다';

  @override
  String get water_kind_river => '강';

  @override
  String get water_kind_canal => '운하';

  @override
  String get water_kind_creek => '갯골';

  @override
  String get water_kind_stream => '개울';

  @override
  String get water_kind_ditch => '수로';

  @override
  String get water_kind_lake => '호수';

  @override
  String get water_kind_pond => '연못';

  @override
  String get water_kind_reservoir => '저수지';

  @override
  String get water_kind_lagoon => '석호';

  @override
  String get water_kind_dock => '항만';

  @override
  String get water_kind_land => '육지';

  @override
  String get water_kind_unknown => '물의 종류를 알 수 없음';

  @override
  String get water_tide_tidal => '조석 있음';

  @override
  String get water_tide_weak => '약한 조석(추정)';

  @override
  String get water_tide_none => '조석 없음';

  @override
  String get water_tide_unknown => '조석 여부 알 수 없음';

  @override
  String get water_reason_sea => '바닷물은 조석에 따라 오르내려요.';

  @override
  String get water_reason_lagoon => '석호는 좁은 입구로 바다와 이어져 조석이 작고 늦어요.';

  @override
  String get water_reason_still => '고인 물(호수, 연못): 조석이 없어요.';

  @override
  String get water_reason_land => '이 지점은 육지예요.';

  @override
  String water_reason_highGround(int meters) {
    return '지면 높이 약 ${meters}m: 조석이 닿지 않아요.';
  }

  @override
  String get water_reason_riverData => '이 구간의 관측소에서 조석 변동이 기록돼요.';

  @override
  String get water_reason_southNetwork => '남부 삼각주 수로망: 조석이 운하와 갯골까지 들어와요.';

  @override
  String get water_reason_southSmall => '남부의 작은 물길이나 높은 지대: 수문에 막혀 조석이 약해요.';

  @override
  String get water_reason_northRiver => '북부 삼각주 강: 조석이 있고 바다에서 멀수록 약해요.';

  @override
  String get water_reason_gated => '관개 수로는 보통 수문이 있어 조석을 따르지 않아요.';

  @override
  String water_reason_nearSea(String distance) {
    return '바다에서 약 $distance: 조석이 약하게 닿을 수 있어요.';
  }

  @override
  String water_reason_farFromSea(String distance) {
    return '바다에서 약 $distance: 조석이 닿지 않아요.';
  }

  @override
  String get water_reason_unknownKind =>
      '강, 호수, 육지 중 무엇인지 아직 몰라요. 지도에서 물 위를 정확히 눌러 주세요. 아래 수치는 참고용이에요.';

  @override
  String get water_reason_noSeaDistance => '바다까지의 거리를 계산하지 못했어요.';

  @override
  String get water_checking => 'OpenStreetMap 확인 중…';

  @override
  String get water_source => '물 종류는 © OpenStreetMap 기준이며, 조석 여부는 지역·바다까지 거리·고도로 추정해요.';

  @override
  String get water_noTideNote => '이곳은 물때가 없어요. 달 시간과 날씨로 입질을 봐요.';

  @override
  String water_structure(String what, String name, String distance) {
    return '$what$name 근처(거리 $distance): 여닫을 때 물살이 세고 소용돌이가 생겨요. 거리를 두세요.';
  }

  @override
  String get water_structure_dam => '댐';

  @override
  String get water_structure_weir => '보';

  @override
  String get water_structure_lock => '갑문';

  @override
  String get water_structure_sluice => '수문';

  @override
  String get water_structure_culvert => '암거';

  @override
  String get land_title => '육지 지점';

  @override
  String get land_hint => '가까운 강이나 호수를 눌러 물 정보를 보세요.';

  @override
  String get land_nearby => '가까운 물';

  @override
  String land_nearbyItem(String name, String distance) {
    return '$name · 거리 $distance';
  }

  @override
  String get fishAct_sourceNoTide => '달 시간, 낮/밤, 날씨(Open-Meteo)로 추정 — 참고용이며 물고기 위치는 알 수 없어요.';

  @override
  String get fishAct_quickNoTide => '날씨가 아직 없어요: 달 시간과 낮/밤으로 임시 계산해요.';

  @override
  String get fishing_factor_runoff => '24시간 강수';

  @override
  String get water_reason_coastalLake =>
      '해안 바로 옆 호수: 바다와 이어진 석호(조석 작음)일 수도, 민물 호수일 수도 있어요. 지도로는 구분할 수 없어요.';

  @override
  String get onb_termsTitle => '약관 및 개인정보';

  @override
  String get onb_termsBody => '시작 전에 간단히 읽어 주세요. 전문은 아래 링크에 있어요.';

  @override
  String get onb_termsDevice => '기기에 저장: 낚시 일지, 관심 장소, 설정. 전송하지 않아요.';

  @override
  String get onb_termsServer => '서버에 저장: 공개로 올린 내용과 스팸 방지에 필요한 데이터.';

  @override
  String get onb_termsLocation => '위치는 주변 물때, 날씨, 낚시터를 보여 주는 데만 쓰이고 공개되지 않아요.';

  @override
  String get onb_termsCommunity =>
      '커뮤니티: 광고, 도박, 사기, 괴롭힘, 불법 어로(전기, 폭발물, 독극물)는 금지예요. 위반 시 숨김 또는 차단돼요. 다른 사람을 신고하고 차단할 수 있어요.';

  @override
  String get onb_termsSafety => '모든 수치, 예보, 경고는 참고용이에요. 물가에서의 안전은 본인 책임이에요.';

  @override
  String get onb_termsAgree => '이용약관과 개인정보 처리방침을 읽었으며 동의합니다';

  @override
  String get onb_termsUpdatedBody => '앱을 계속 사용하려면 읽고 동의해 주세요.';

  @override
  String get onb_termsContinue => '동의하고 계속';

  @override
  String get legal_section => '법적 고지';

  @override
  String get legal_terms => '이용약관';

  @override
  String get legal_privacy => '개인정보 처리방침';

  @override
  String get legal_disclaimer => '면책 조항';

  @override
  String get legal_disclaimerText =>
      '앱의 수위, 조석 예보, 낚시 지수, 안전 경고는 과학적 모델과 공공 데이터에 기반한 참고 정보일 뿐이며, 관계 당국의 공식 재난 경보나 수상 안전·구조 수칙을 대신하지 않습니다. 야외 활동에서의 결정과 안전은 본인이 책임집니다.';

  @override
  String get legal_disclaimerShort => '수치는 참고용이며 공식 경보를 대신하지 않아요. 안전은 본인 책임이에요.';

  @override
  String get legal_contact => '문의 / 위반 신고';

  @override
  String get legal_contactHint => 'GitHub Issues로 · 신고는 24시간 이내 처리';

  @override
  String get block_action => '이 사람 차단';

  @override
  String get block_title => '이 사람을 차단할까요?';

  @override
  String get block_body => '이 사람의 포인트, 댓글, 출조, 메시지, 리뷰가 더 이상 보이지 않아요. 상대방에게 알리지 않아요.';

  @override
  String get block_done => '차단했어요. 이 사람의 콘텐츠를 숨겼어요.';

  @override
  String get block_failed => '이 콘텐츠를 차단할 수 없어요.';

  @override
  String get block_unblockAll => '모두 차단 해제';

  @override
  String get block_unblockHint => '차단한 사람들의 콘텐츠를 다시 표시';

  @override
  String block_unblockDone(int count) {
    return '$count명 차단 해제됨';
  }

  @override
  String get onb_termsRequired =>
      '이용약관과 개인정보 처리방침에 동의해야 앱을 사용할 수 있어요. 동의 전에는 데이터를 불러오거나 위치를 요청하거나 아무것도 보내지 않아요.';

  @override
  String get onb_exitApp => '앱 종료';

  @override
  String get erase_action => '내 데이터 삭제';

  @override
  String get erase_hint => '올린 모든 내용과 이 기기에 저장된 앱 데이터를 모두 삭제합니다';

  @override
  String get erase_title => '데이터를 삭제할까요?';

  @override
  String get erase_body =>
      '다음 항목이 영구 삭제됩니다:\n• 서버: 내가 올린 낚시 포인트, 댓글, 출조 모임, 메시지, \"낚시 중\" 체크인, 입질 보고, 리뷰, 신고 및 차단 기록. 다른 사람이 확인한 낚시터는 커뮤니티를 위해 남지만 더 이상 나와 연결되지 않습니다.\n• 이 기기: 저장한 장소, 조행 일지, 알림, 설정, 표시 이름, 기기 코드.\n\n삭제 후 앱은 새로 설치한 것처럼 시작 화면으로 돌아갑니다. 되돌릴 수 없습니다.';

  @override
  String get erase_bodyLocal =>
      '이 기기에 저장된 앱 데이터가 모두 영구 삭제됩니다: 저장한 장소, 조행 일지, 알림, 설정, 표시 이름.\n\n삭제 후 앱은 새로 설치한 것처럼 시작 화면으로 돌아갑니다. 되돌릴 수 없습니다.';

  @override
  String get erase_continue => '계속';

  @override
  String get erase_title2 => '정말 모두 삭제할까요?';

  @override
  String get erase_word => '삭제';

  @override
  String erase_typeHint(String word) {
    return '확인하려면 아래에 $word를 입력하세요.';
  }

  @override
  String get erase_confirm => '영구 삭제';

  @override
  String get erase_working => '데이터 삭제 중…';

  @override
  String get erase_doneTitle => '삭제 완료';

  @override
  String get erase_doneBody => '서버와 이 기기의 데이터가 삭제되었습니다. 앱이 시작 화면부터 다시 시작됩니다.';

  @override
  String get erase_failedTitle => '아직 삭제되지 않음';

  @override
  String get erase_failedServer => '서버에 연결할 수 없어 이 기기를 포함해 아무것도 삭제하지 않았습니다. 네트워크를 확인한 뒤 다시 시도하세요.';

  @override
  String get erase_failedDevice =>
      '서버의 데이터는 삭제되었지만 이 기기의 일부 데이터를 삭제하지 못했습니다. 다시 시도하세요. 계속 실패하면 앱을 삭제하면 나머지도 지워집니다.';

  @override
  String get alert_unsupported => '이 기기에서는 아직 물때 알람을 사용할 수 없어요.';

  @override
  String get pond_followHintPlain => '이 낚시터에 새 방류 일정이 생기면 목록 맨 위에 표시돼요.';
}
