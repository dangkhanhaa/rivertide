// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Con Nước';

  @override
  String get common_retry => 'Thử lại';

  @override
  String get common_loading => 'Đang tải…';

  @override
  String get common_empty => 'Chưa có dữ liệu';

  @override
  String get common_reference => 'tham khảo';

  @override
  String get common_estimate => 'ước tính';

  @override
  String common_source(String source) {
    return 'Nguồn: $source';
  }

  @override
  String common_staleBanner(String time) {
    return 'Ngoại tuyến · cập nhật lúc $time';
  }

  @override
  String common_updatedAt(String time) {
    return 'Cập nhật $time';
  }

  @override
  String get common_today => 'Hôm nay';

  @override
  String get common_tomorrow => 'Mai';

  @override
  String get error_network => 'Không kết nối được. Kiểm tra mạng rồi thử lại.';

  @override
  String get error_timeout => 'Nguồn dữ liệu phản hồi chậm. Thử lại sau.';

  @override
  String get error_server => 'Nguồn dữ liệu đang gián đoạn.';

  @override
  String get error_parse => 'Dữ liệu nguồn không hợp lệ.';

  @override
  String get error_notFound => 'Không tìm thấy.';

  @override
  String get error_offlineNoCache => 'Bạn đang ngoại tuyến và chưa có dữ liệu lưu sẵn.';

  @override
  String get error_unknown => 'Đã có lỗi. Thử lại sau.';

  @override
  String get dataKind_observed => 'Thực đo';

  @override
  String get dataKind_forecast => 'Dự báo · tham khảo';

  @override
  String get dataKind_estimate => 'Ước tính';

  @override
  String get tide_rising => 'Đang lên';

  @override
  String get tide_risingFast => 'Lên nhanh';

  @override
  String get tide_slack => 'Nước đứng';

  @override
  String get tide_falling => 'Đang xuống';

  @override
  String get tide_fallingFast => 'Xuống nhanh';

  @override
  String get tide_high => 'Đỉnh triều';

  @override
  String get tide_low => 'Chân triều';

  @override
  String get tide_turning => 'Đang đổi con nước';

  @override
  String get tide_spring => 'Nước rong';

  @override
  String get tide_neap => 'Nước kém';

  @override
  String get tide_normal => 'Nước trung bình';

  @override
  String tide_countdownHigh(String duration) {
    return 'Đỉnh triều sau $duration';
  }

  @override
  String tide_countdownLow(String duration) {
    return 'Chân triều sau $duration';
  }

  @override
  String tide_extremeAt(String time, String level) {
    return '$time · dự kiến $level';
  }

  @override
  String tide_nextOther(String kind, String time, String level) {
    return '$kind kế tiếp: $time · $level';
  }

  @override
  String get tide_noPrediction => 'Chưa có dự báo triều cho trạm này';

  @override
  String tide_correctedBy(String delta) {
    return 'Đã hiệu chỉnh theo thực đo (lệch $delta)';
  }

  @override
  String duration_hm(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String duration_m(int minutes) {
    return '$minutes phút';
  }

  @override
  String confidence_label(String level) {
    return 'Độ tin cậy dự báo: $level';
  }

  @override
  String get confidence_high => 'Cao';

  @override
  String get confidence_medium => 'Trung bình';

  @override
  String get confidence_low => 'Thấp';

  @override
  String skill_backtest(String cm, String min) {
    return 'Kiểm thử ngược: sai số ±$cm cm, giờ đỉnh/chân ±$min phút';
  }

  @override
  String skill_live(int days, String cm, String min) {
    return 'Sai số $days ngày qua: ±$cm cm, ±$min phút';
  }

  @override
  String get skill_unknown => 'Chưa đo được sai số tại điểm này';

  @override
  String get nav_map => 'Bản đồ';

  @override
  String get map_searchHint => 'Tìm xã, phường, cầu, bến, tọa độ…';

  @override
  String get map_searchNone => 'Không tìm thấy trạm phù hợp';

  @override
  String get map_openDetail => 'Xem chi tiết';

  @override
  String map_nextExtreme(String kind, String time, String level, String duration) {
    return '$kind $time ≈ $level · còn $duration';
  }

  @override
  String tide_moreRise(int cm) {
    return 'Nước còn lên thêm khoảng $cm cm';
  }

  @override
  String tide_moreFall(int cm) {
    return 'Nước còn xuống thêm khoảng $cm cm';
  }

  @override
  String get map_locate => 'Vị trí của tôi';

  @override
  String get map_locRationaleTitle => 'Dùng vị trí của bạn?';

  @override
  String get map_locRationaleBody =>
      'App dùng vị trí để đưa bản đồ tới chỗ bạn đang đứng. Vị trí chỉ ở trên máy (nhớ gần đúng ~1 km để lần sau mở nhanh), không gửi đi đâu.';

  @override
  String get map_locAllow => 'Cho phép';

  @override
  String get map_later => 'Để sau';

  @override
  String get map_locServiceOff => 'Định vị đang tắt. Bật định vị trong máy rồi thử lại.';

  @override
  String get map_locDenied => 'Chưa có quyền vị trí.';

  @override
  String get map_locDeniedForeverTitle => 'Quyền vị trí đang bị chặn';

  @override
  String get map_locDeniedForeverBody =>
      'Vào Cài đặt > Ứng dụng > Con Nước > Quyền > Vị trí để bật lại.';

  @override
  String get map_openSettings => 'Mở Cài đặt';

  @override
  String get map_locFailed => 'Không lấy được vị trí. Thử lại sau.';

  @override
  String get map_outsideVn => 'Vị trí nằm ngoài vùng hỗ trợ';

  @override
  String get map_layers => 'Lớp bản đồ';

  @override
  String get map_layerStandard => 'Bản đồ thường';

  @override
  String get map_layerStandardHint => 'Đường, địa danh, sông hồ (OpenFreeMap)';

  @override
  String get map_layerSatellite => 'Ảnh vệ tinh';

  @override
  String get map_layerSatelliteHint =>
      'Sentinel-2 năm 2025, độ phân giải 10 m — thấy rõ sông, bãi bồi, ruộng; không rõ từng nhà';

  @override
  String get map_satelliteCredit =>
      'Ảnh vệ tinh: EOxCloudless (EOX IT Services) · chứa dữ liệu Copernicus Sentinel 2025';

  @override
  String get map_filter => 'Bộ lọc';

  @override
  String get map_filterOnlyTide => 'Chỉ trạm có triều';

  @override
  String get map_filterOnlyAlarm => 'Chỉ trạm đang báo động';

  @override
  String get map_filterHideStale => 'Ẩn trạm mất dữ liệu';

  @override
  String get map_filterNone => 'Không có trạm nào khớp bộ lọc';

  @override
  String get map_legend => 'Chú giải';

  @override
  String get map_legendNormal => 'Bình thường';

  @override
  String get map_legendAlarm1 => 'Báo động I';

  @override
  String get map_legendAlarm2 => 'Báo động II';

  @override
  String get map_legendAlarm3 => 'Báo động III';

  @override
  String get map_legendStale => 'Mất dữ liệu quá 6 giờ (ghim xám, 1 con cá mờ)';

  @override
  String get map_legendSpot => 'Điểm câu cộng đồng';

  @override
  String get map_legendCluster =>
      'Vòng có số: nhóm trạm gần nhau, chạm để phóng to. Màu vòng là mức cá ăn cao nhất trong nhóm; có trạm báo động thì là màu báo động.';

  @override
  String get map_legendNote =>
      'Trạm biển chưa có ngưỡng báo động; màu báo động dùng cho trạm sông ở giai đoạn sau.';

  @override
  String get map_hoangSa => 'Quần đảo Hoàng Sa (Việt Nam)';

  @override
  String get map_truongSa => 'Quần đảo Trường Sa (Việt Nam)';

  @override
  String get map_close => 'Đóng';

  @override
  String get map_stationsError => 'Không tải được danh sách trạm';

  @override
  String get map_baseMapCredit =>
      'Bản đồ nền: OpenFreeMap · © OpenMapTiles · dữ liệu © OpenStreetMap';

  @override
  String get nav_stations => 'Trạm';

  @override
  String get nav_watch => 'Theo dõi';

  @override
  String get nav_fishing => 'Câu cá';

  @override
  String get nav_more => 'Thêm';

  @override
  String get stations_title => 'Trạm mực nước & triều';

  @override
  String get stations_kindGauge => 'Có máy đo';

  @override
  String get stations_kindModel => 'Mô hình';

  @override
  String get stations_coordApprox => 'Tọa độ gần đúng';

  @override
  String get station_tabOverview => 'Tổng quan';

  @override
  String get station_tabHourly => 'Theo giờ';

  @override
  String get station_tabCalendar => 'Lịch triều';

  @override
  String get station_tabInfo => 'Thông tin';

  @override
  String level_lastKnown(String time) {
    return 'Số mới nhất lúc $time · chưa có số cho giờ này';
  }

  @override
  String get calendar_prev => 'Tháng trước';

  @override
  String get calendar_next => 'Tháng sau';

  @override
  String calendar_month(int month, int year) {
    return 'Tháng $month/$year';
  }

  @override
  String get calendar_noTideDay => 'Chưa có dự báo triều cho ngày này';

  @override
  String get calendar_noTideMonth =>
      'Tháng này chưa có dự báo triều, vẫn xem được ngày âm và trăng';

  @override
  String get calendar_rangeLegend => 'Biên độ ngày';

  @override
  String get calendar_lunarLegend => 'Chữ đỏ: mùng 1, rằm';

  @override
  String moon_times(String rise, String set) {
    return 'Trăng mọc $rise · lặn $set';
  }

  @override
  String get moon_alwaysUp => 'Trăng ở trên trời cả ngày';

  @override
  String get moon_alwaysDown => 'Hôm nay trăng không mọc';

  @override
  String get solunar_title => 'Giờ cá ăn theo trăng';

  @override
  String get solunar_titleGood => 'Giờ cá ăn theo trăng · ngày tốt (gần trăng tròn/non)';

  @override
  String solunar_major(String range) {
    return 'Giờ chính $range';
  }

  @override
  String solunar_minor(String range) {
    return 'Giờ phụ $range';
  }

  @override
  String get solunar_now => 'đang diễn ra';

  @override
  String get summary_title => 'Lúc này ở đây';

  @override
  String summary_water(String state, String extreme, String time, String wait) {
    return '$state, $extreme lúc $time (còn $wait)';
  }

  @override
  String summary_fishing(String score, String label) {
    return 'câu $score/10 $label';
  }

  @override
  String summary_wind(int kmh) {
    return 'gió $kmh km/h';
  }

  @override
  String get map_goFishing => 'Đi câu ngay';

  @override
  String get hazard_title => 'Cần chú ý';

  @override
  String get hazard_titleSevere => 'Nguy hiểm — không nên ra sông';

  @override
  String hazard_at(String time) {
    return 'lúc $time';
  }

  @override
  String hazard_between(String from, String to) {
    return '$from–$to';
  }

  @override
  String get hazard_thunderstorm => 'Dông, sét: lên bờ, tránh chỗ trống và cần câu';

  @override
  String get hazard_gust => 'Gió giật trên 50 km/h: không ra thuyền';

  @override
  String get hazard_heavyRain => 'Mưa to trên 20 mm/giờ';

  @override
  String get hazard_possibleStorm => 'Trời không ổn định, có thể có dông';

  @override
  String get hazard_risingFast =>
      'Nước đang lên nhanh bất thường (nhanh hơn hẳn mấy ngày qua): tránh bãi thấp, cồn cát';

  @override
  String get hazard_flood =>
      'Lưu lượng sông ngày mai tăng mạnh (mưa lớn thượng nguồn): nước lên, đục, chảy xiết';

  @override
  String get watch_edit => 'Đặt tên, ghi chú, nhóm';

  @override
  String get watch_editTitle => 'Điểm của bạn';

  @override
  String get watch_label => 'Tên riêng';

  @override
  String get watch_labelHint => 'vd Hố sâu gốc si';

  @override
  String get watch_note => 'Ghi chú';

  @override
  String get watch_noteHint => 'vd Câu mồi giun, chỗ nước xoáy';

  @override
  String get watch_group => 'Nhóm';

  @override
  String get watch_groupHint => 'vd Sông Hồng, Hồ';

  @override
  String get watch_noGroup => 'Chưa xếp nhóm';

  @override
  String get common_save => 'Lưu';

  @override
  String get common_cancel => 'Hủy';

  @override
  String get trip_title => 'Lên kế hoạch chuyến câu';

  @override
  String get trip_open => 'Lên kế hoạch';

  @override
  String get trip_noPlaces =>
      'Lưu vài điểm câu (bấm ⭐ trên bản đồ) để app tìm buổi câu tốt nhất cho bạn.';

  @override
  String trip_intro(int count) {
    return 'Buổi câu tốt nhất 7 ngày tới ở $count điểm đã lưu, tính theo con nước, trăng, thời tiết của từng điểm.';
  }

  @override
  String get trip_none => '7 ngày tới chưa có buổi nào đạt từ 7/10 ở các điểm đã lưu.';

  @override
  String trip_score(String score) {
    return 'Điểm câu cao nhất $score/10';
  }

  @override
  String trip_because(String reasons) {
    return 'Tốt nhờ: $reasons';
  }

  @override
  String get trip_note => 'Ghi chú';

  @override
  String get where_title => 'Hôm nay đi đâu?';

  @override
  String get where_short => 'Đi đâu?';

  @override
  String get more_shortcuts => 'Lối tắt';

  @override
  String get trip_listDetail => 'Xem và tham gia kèo câu quanh đây';

  @override
  String get trip_createDetail => 'Hẹn anh em cùng đi câu, có gợi ý giờ vàng';

  @override
  String get checkin_detail => 'Báo anh em biết bạn đang câu ở đây (ẩn danh, 4 giờ)';

  @override
  String get checkin_peopleDetail => 'Chỗ đang có người câu, ai đang dính cá';

  @override
  String get spot_listDetail => 'Điểm câu anh em đã ghim, có ảnh và bình luận';

  @override
  String get where_entryHint => 'Điểm câu tốt nhất quanh bạn trong 24 giờ tới';

  @override
  String get where_radius => 'Trong vòng';

  @override
  String where_km(int km) {
    return '$km km';
  }

  @override
  String where_around(String place) {
    return 'Quanh $place';
  }

  @override
  String get where_aroundHere => 'Quanh chỗ bạn đứng';

  @override
  String get where_aroundLast => 'Quanh vị trí lần trước của bạn (bấm ◎ để cập nhật)';

  @override
  String get where_needLocation => 'Cho app biết bạn đang ở đâu để tìm điểm câu gần nhất.';

  @override
  String get where_useLocation => 'Dùng vị trí của tôi';

  @override
  String get where_refresh => 'Cập nhật vị trí';

  @override
  String get where_kindHere => 'Chỗ bạn đứng';

  @override
  String get where_kindStation => 'Trạm đo';

  @override
  String get where_kindSaved => 'Điểm đã lưu';

  @override
  String get where_kindCommunity => 'Điểm cộng đồng';

  @override
  String where_distance(String km) {
    return 'cách $km km';
  }

  @override
  String where_golden(String when) {
    return 'Giờ vàng $when';
  }

  @override
  String where_bestHour(String when) {
    return 'Chưa có giờ vàng · giờ khá nhất $when';
  }

  @override
  String get where_unsafe => 'Có cảnh báo thời tiết trong khung giờ này';

  @override
  String get where_loading => 'Đang tính điểm câu…';

  @override
  String get where_failed => 'Không tải được số liệu điểm này';

  @override
  String get where_onMap => 'Xem bản đồ';

  @override
  String get where_fishHere => 'Câu ở đây';

  @override
  String where_rank(int rank) {
    return 'Hạng $rank';
  }

  @override
  String get where_note =>
      'Xếp theo điểm câu ước tính (con nước, giờ trăng, ngày/đêm, thời tiết Open-Meteo) trong 24 giờ tới — chỉ để tham khảo. Điểm cộng đồng do người dùng ghim. Tối đa 8 điểm gần nhất.';

  @override
  String get where_onlyHere =>
      'Trong vòng này chưa có trạm, điểm đã lưu hay điểm cộng đồng nào — chỉ tính được chỗ bạn đứng. Thử vòng lớn hơn.';

  @override
  String get habit_title => 'Thói quen câu của bạn';

  @override
  String habit_needMore(int count) {
    return 'Ghi thêm $count mẻ cá nữa để app tìm ra lúc bạn hay trúng.';
  }

  @override
  String habit_progress(int have, int need) {
    return '$have/$need mẻ';
  }

  @override
  String habit_none(int count) {
    return 'Chưa thấy điều kiện nào nổi bật trong $count mẻ cá. Cứ ghi tiếp nhé.';
  }

  @override
  String habit_hits(int hits, int known) {
    return '$hits/$known mẻ';
  }

  @override
  String get habit_note =>
      'Đếm từ nhật ký trên máy bạn, không phải quy luật chắc chắn. Bạn hay đi câu giờ nào thì giờ đó sẽ nhiều mẻ hơn.';

  @override
  String get habit_match => 'Giống những lần bạn trúng';

  @override
  String get habit_dawn => 'Lúc bình minh';

  @override
  String get habit_morning => 'Buổi sáng';

  @override
  String get habit_midday => 'Buổi trưa';

  @override
  String get habit_afternoon => 'Buổi chiều';

  @override
  String get habit_dusk => 'Lúc hoàng hôn';

  @override
  String get habit_night => 'Ban đêm';

  @override
  String get habit_rising => 'Khi nước đang lên';

  @override
  String get habit_falling => 'Khi nước đang rút';

  @override
  String get habit_slack => 'Lúc nước đứng (đổi con nước)';

  @override
  String get habit_newMoon => 'Quanh ngày không trăng (cuối/đầu tháng âm)';

  @override
  String get habit_fullMoon => 'Quanh ngày trăng tròn (rằm)';

  @override
  String get habit_quarter => 'Ngày trăng nửa vành';

  @override
  String get habit_major => 'Trong giờ trăng chính';

  @override
  String get habit_minor => 'Trong giờ trăng phụ';

  @override
  String get habit_noSolunar => 'Ngoài giờ trăng';

  @override
  String get habit_calm => 'Khi lặng gió (dưới 10 km/h)';

  @override
  String get habit_light => 'Khi gió nhẹ (10–20 km/h)';

  @override
  String get habit_strong => 'Khi gió mạnh (trên 20 km/h)';

  @override
  String get journal_title => 'Nhật ký câu';

  @override
  String get journal_open => 'Nhật ký';

  @override
  String get journal_add => 'Ghi mẻ cá';

  @override
  String get journal_empty =>
      'Chưa có mẻ cá nào. Bấm \"Ghi mẻ cá\" sau mỗi lần câu được: app tự lưu mực nước, con nước, thời tiết và trăng lúc đó.';

  @override
  String journal_place(String name) {
    return 'Tại: $name';
  }

  @override
  String get journal_placeHint => 'Là điểm đang chọn ở tab Câu cá. Đổi điểm ở đó nếu cần.';

  @override
  String get journal_changeTime => 'Đổi giờ';

  @override
  String get journal_species => 'Loại cá';

  @override
  String get journal_weight => 'Cân nặng (kg)';

  @override
  String get journal_length => 'Dài (cm)';

  @override
  String get journal_bait => 'Mồi';

  @override
  String get journal_note => 'Ghi chú';

  @override
  String get journal_camera => 'Chụp ảnh';

  @override
  String get journal_gallery => 'Chọn ảnh';

  @override
  String get journal_removePhoto => 'Bỏ ảnh';

  @override
  String get journal_photoError => 'Không đọc được ảnh này';

  @override
  String get journal_needSpecies => 'Nhập loại cá';

  @override
  String get journal_privacy =>
      'Nhật ký và ảnh chỉ lưu trên máy này. Ảnh được bỏ thông tin vị trí GPS.';

  @override
  String get journal_statsTitle => 'Bạn câu thế nào';

  @override
  String journal_statsCount(int count, String kg) {
    return '$count mẻ · tổng $kg kg';
  }

  @override
  String journal_statsTop(String species, int count) {
    return 'Hay câu được nhất: $species ($count lần)';
  }

  @override
  String journal_statsRising(int pct) {
    return '$pct% số mẻ câu được lúc nước đang lên';
  }

  @override
  String journal_statsFalling(int pct) {
    return '$pct% số mẻ câu được lúc nước đang xuống';
  }

  @override
  String journal_water(String state) {
    return 'nước $state';
  }

  @override
  String get journal_conditions => 'Điều kiện lúc câu';

  @override
  String journal_weightValue(String kg) {
    return 'Nặng $kg kg';
  }

  @override
  String journal_lengthValue(int cm) {
    return 'Dài $cm cm';
  }

  @override
  String journal_baitValue(String bait) {
    return 'Mồi: $bait';
  }

  @override
  String journal_levelValue(String level) {
    return 'Mực nước $level';
  }

  @override
  String journal_scoreValue(String score) {
    return 'điểm câu $score/10';
  }

  @override
  String get journal_delete => 'Xóa';

  @override
  String get journal_deleteTitle => 'Xóa mẻ cá này khỏi nhật ký?';

  @override
  String get place_city => 'Thành phố, thị xã';

  @override
  String get place_ward => 'Khu dân cư, làng';

  @override
  String get place_bridge => 'Cầu';

  @override
  String get place_ferry => 'Bến phà';

  @override
  String get place_wharf => 'Bến';

  @override
  String place_near(String kind, String town) {
    return '$kind · gần $town';
  }

  @override
  String get share_action => 'Chia sẻ';

  @override
  String share_text(String place) {
    return 'Con Nước · $place';
  }

  @override
  String share_level(String level) {
    return 'Mực nước $level';
  }

  @override
  String share_score(String score) {
    return 'Điểm câu $score/10';
  }

  @override
  String get share_copied => 'Đã chép nội dung và đường link, dán vào Zalo/Facebook để gửi';

  @override
  String get share_footer => 'Số liệu tính toán, chỉ để tham khảo · Con Nước';

  @override
  String get more_outdoor => 'Chế độ ngoài trời';

  @override
  String get more_outdoorHint => 'Tương phản cao, chữ to hơn: đọc rõ dưới nắng gắt';

  @override
  String get map_legendFlowRising => 'Đoạn sông nước đang lên';

  @override
  String get map_legendFlowFalling => 'Đoạn sông nước đang rút';

  @override
  String get map_legendFlowSlack => 'Đoạn sông nước đứng';

  @override
  String get map_legendFlowNote =>
      'Màu đoạn sông tính cho từng đoạn (con nước đến mỗi đoạn một giờ khác nhau), cập nhật 10 phút/lần. Vệt chạy chỉ hướng dòng sông ra biển.';

  @override
  String get map_layerWeather => 'Mưa và gió quanh đây';

  @override
  String get map_layerWeatherHint =>
      'Chấm xanh: mưa 1 giờ tới (càng to càng nhiều). Mũi tên: hướng gió thổi tới. Phóng to vùng muốn xem.';

  @override
  String hazard_surge(int cm) {
    return 'Nước biển đang cao hơn thủy triều thường $cm cm (gió mạnh hoặc bão đẩy nước vào): bãi thấp, cửa sông dễ ngập';
  }

  @override
  String get more_install => 'Cài Con Nước lên màn hình chính';

  @override
  String get more_installHow =>
      'Android (Chrome): bấm ⋮ rồi chọn Cài đặt ứng dụng. iPhone (Safari): bấm nút Chia sẻ rồi chọn Thêm vào MH chính. App mở nhanh như app thật, không cần cửa hàng.';

  @override
  String get alert_channel => 'Báo thức con nước';

  @override
  String get alert_channelHint => 'Nhắc trước giờ đỉnh, chân triều và giờ câu đẹp ở điểm đã lưu';

  @override
  String alert_highTitle(String place, String time) {
    return '$place: đỉnh triều $time';
  }

  @override
  String alert_lowTitle(String place, String time) {
    return '$place: chân triều $time';
  }

  @override
  String alert_levelBody(String level, int minutes) {
    return 'Mực nước khoảng $level, còn $minutes phút';
  }

  @override
  String alert_fishTitle(String place, String from, String to) {
    return '$place: giờ câu đẹp $from–$to';
  }

  @override
  String alert_fishBody(String score, int minutes) {
    return 'Điểm câu $score/10, bắt đầu sau $minutes phút';
  }

  @override
  String get alert_toggleOn => 'Bật báo thức con nước';

  @override
  String get alert_toggleOff => 'Tắt báo thức con nước';

  @override
  String get alert_onSnack =>
      'Đã bật báo thức cho điểm này. Chỉnh loại báo và báo trước bao lâu ở nút ⚙ trên cùng.';

  @override
  String alert_fishBodyLike(String score, int minutes) {
    return '✨ Giống những lần bạn trúng · điểm câu $score/10, bắt đầu sau $minutes phút';
  }

  @override
  String get alert_settings => 'Cài đặt báo thức';

  @override
  String get alert_golden => 'Báo trước giờ vàng';

  @override
  String get alert_goldenHint =>
      'Chỉ báo khi khung giờ đó không có cảnh báo dông, gió giật, mưa to';

  @override
  String get alert_tides => 'Báo trước đỉnh triều / chân triều';

  @override
  String get alert_lead => 'Báo trước';

  @override
  String alert_leadMin(int minutes) {
    return '$minutes phút';
  }

  @override
  String get alert_howTo =>
      'Bật chuông ở từng điểm trong danh sách Theo dõi. App tính lại lịch báo mỗi lần mở (7 ngày tới).';

  @override
  String get alert_getApk => 'Tải app Android';

  @override
  String get alert_denied =>
      'Chưa được phép gửi thông báo. Bật trong Cài đặt > Ứng dụng > Con Nước > Thông báo.';

  @override
  String get alert_webOnly =>
      'Báo thức chỉ có trên app Android (trình duyệt không kêu được khi đóng)';

  @override
  String get more_apk => 'Tải app Android (APK)';

  @override
  String get more_apkHint =>
      'Có thêm báo thức con nước và widget màn hình chính. Mở file sau khi tải, cho phép cài từ nguồn này.';

  @override
  String get directions_action => 'Chỉ đường';

  @override
  String get directions_failed => 'Không mở được Google Maps trên máy này';

  @override
  String get search_recent => 'Tìm gần đây';

  @override
  String get place_province => 'Tỉnh, thành phố';

  @override
  String get place_commune => 'Phường, xã';

  @override
  String get search_coordsHint => 'Mở mực nước, giờ câu tại tọa độ này';

  @override
  String place_in(String kind, String area) {
    return '$kind · $area';
  }

  @override
  String search_coords(String coords) {
    return 'Tọa độ $coords';
  }

  @override
  String get spot_edit => 'Sửa';

  @override
  String get spot_editTitle => 'Sửa điểm câu';

  @override
  String get spot_save => 'Lưu thay đổi';

  @override
  String get spot_editSaved => 'Đã lưu thay đổi';

  @override
  String spot_edited(String date) {
    return 'sửa $date';
  }

  @override
  String get spot_tooMany => 'Hôm nay máy này đã đăng đủ 10 điểm. Mai đăng tiếp nhé.';

  @override
  String spot_comments(int count) {
    return '$count bình luận';
  }

  @override
  String get cmt_title => 'Bình luận';

  @override
  String cmt_count(int count) {
    return 'Bình luận ($count)';
  }

  @override
  String get cmt_hint => 'Chia sẻ mồi, giờ cá ăn, đường vào…';

  @override
  String get cmt_send => 'Gửi bình luận';

  @override
  String get cmt_empty => 'Chưa có bình luận nào. Hãy là người đầu tiên!';

  @override
  String get cmt_anon => 'Người câu ẩn danh';

  @override
  String cmt_asName(String name) {
    return 'Bình luận với tên $name · đổi';
  }

  @override
  String get cmt_asAnon => 'Đang ẩn danh · đặt tên hiển thị';

  @override
  String get cmt_edited => 'đã sửa';

  @override
  String get cmt_mine => 'của bạn';

  @override
  String get cmt_more => 'Thêm';

  @override
  String get cmt_edit => 'Sửa bình luận';

  @override
  String get cmt_delete => 'Xóa';

  @override
  String get cmt_report => 'Báo cáo';

  @override
  String get cmt_deleteTitle => 'Xóa bình luận của bạn?';

  @override
  String get cmt_reportTitle => 'Báo cáo bình luận này?';

  @override
  String get cmt_reportHint =>
      'Nói tục, lừa đảo, quảng cáo… Bình luận bị 3 người báo cáo sẽ tự ẩn.';

  @override
  String get cmt_error => 'Chưa gửi được, kiểm tra mạng rồi thử lại';

  @override
  String get cmt_tooFast => 'Bạn gửi hơi nhanh — đợi chút rồi gửi tiếp nhé';

  @override
  String get cmt_loadError => 'Không tải được bình luận';

  @override
  String get name_title => 'Tên hiển thị';

  @override
  String get name_hint => 'vd Khánh Cần Thủ';

  @override
  String get name_note => 'Hiện trên bình luận, kèo câu và tin nhắn. Để trống = ẩn danh.';

  @override
  String get social_save => 'Lưu';

  @override
  String get nav_ponds => 'Hồ câu';

  @override
  String get pond_title => 'Hồ câu';

  @override
  String get pond_tag => 'Hồ câu dịch vụ';

  @override
  String get pond_add => 'Thêm hồ';

  @override
  String get pond_addTitle => 'Thêm hồ câu';

  @override
  String get pond_addHere => 'Thêm hồ câu ở đây';

  @override
  String pond_pill(int count) {
    return '$count hồ câu';
  }

  @override
  String pond_pillSoon(int count) {
    return '$count hồ sắp xả';
  }

  @override
  String get pond_pillDetail => 'Hồ câu dịch vụ quanh đây, lịch xả cá';

  @override
  String get pond_editTitle => 'Sửa thông tin hồ';

  @override
  String get pond_empty =>
      'Chưa có hồ câu nào trong vòng 40 km. Biết hồ nào? Bấm \"Thêm hồ\" để anh em cùng biết.';

  @override
  String get pond_loadError => 'Không tải được danh sách hồ';

  @override
  String get pond_filterRelease => 'Sắp xả cá';

  @override
  String get pond_filterVerified => 'Đã xác minh';

  @override
  String get pond_filterFollowed => 'Đang theo dõi';

  @override
  String get pond_followedSoon => 'Hồ bạn theo dõi sắp xả';

  @override
  String get pond_verified => 'Đã xác minh';

  @override
  String get pond_owner => 'Chủ hồ đã nhận';

  @override
  String get pond_unverified => 'Chưa xác minh';

  @override
  String get pond_fromWeb =>
      'Thông tin gom từ web, có thể đã cũ. Tới nơi thấy đúng thì bấm \"Hồ có thật\" giúp anh em.';

  @override
  String get pond_approx => 'Vị trí gần đúng theo địa chỉ. Ai ở gần bấm \"Sửa\" để chỉnh ghim.';

  @override
  String pond_distance(String km) {
    return 'cách $km';
  }

  @override
  String pond_rating(String rating, int count) {
    return '$rating ★ ($count)';
  }

  @override
  String get pond_noRating => 'Chưa có đánh giá';

  @override
  String pond_releaseChip(String when) {
    return 'Xả $when';
  }

  @override
  String pond_releaseKg(String when, String amount) {
    return '$when · $amount';
  }

  @override
  String pond_kg(String kg) {
    return '$kg kg';
  }

  @override
  String pond_ta(String ta) {
    return '$ta tạ';
  }

  @override
  String pond_ton(String ton) {
    return '$ton tấn';
  }

  @override
  String get pond_releases => 'Lịch xả cá';

  @override
  String get pond_noRelease => 'Chưa có lịch xả sắp tới.';

  @override
  String get pond_official => 'Chủ hồ đăng';

  @override
  String get pond_relayed => 'Người dùng báo · chưa xác nhận';

  @override
  String get pond_releasePast => 'Đã xả';

  @override
  String get pond_releaseCancelled => 'Đã hủy';

  @override
  String get pond_postRelease => 'Báo lịch xả cá';

  @override
  String get pond_showSource => 'Xem bài gốc';

  @override
  String get pond_cancelRelease => 'Hủy lịch này';

  @override
  String get pond_reportRelease => 'Báo sai';

  @override
  String get pond_follow => 'Theo dõi';

  @override
  String get pond_following => 'Đang theo dõi';

  @override
  String get pond_followHint =>
      'Có lịch xả mới ở hồ này sẽ hiện đầu danh sách (app Android có chuông báo).';

  @override
  String get pond_call => 'Gọi';

  @override
  String get pond_price => 'Giá vé';

  @override
  String get pond_hours => 'Giờ mở';

  @override
  String get pond_species => 'Cá trong hồ';

  @override
  String get pond_note => 'Ghi chú';

  @override
  String get pond_sources => 'Nguồn';

  @override
  String get pond_pulseTitle => 'Lúc này ở hồ (6 giờ qua)';

  @override
  String get pond_pulseBusy => 'Đông';

  @override
  String get pond_pulseQuiet => 'Vắng';

  @override
  String get pond_pulseBiting => 'Cá ăn';

  @override
  String get pond_pulseReleased => 'Vừa xả';

  @override
  String pond_pulseCount(String label, int count) {
    return '$label · $count';
  }

  @override
  String get pond_pulseSent => 'Đã gửi. Cảm ơn bạn!';

  @override
  String get pond_pulseWait => 'Mỗi 30 phút báo 1 lần thôi nhé';

  @override
  String get pond_confirm => 'Hồ có thật';

  @override
  String get pond_confirmed => 'Bạn đã xác nhận';

  @override
  String get pond_confirmDone => 'Cảm ơn! Đủ 3 người xác nhận hồ sẽ có dấu ✓';

  @override
  String get pond_edit => 'Sửa';

  @override
  String get pond_claim => 'Tôi là chủ hồ';

  @override
  String get pond_claimTitle => 'Nhận quản lý hồ';

  @override
  String get pond_claimBody =>
      'Để tránh mạo danh, quản trị viên sẽ gọi hoặc nhắn Zalo cho bạn để xác nhận. Duyệt xong, bạn tự đăng lịch xả \"chính thức\", sửa giá vé, giờ mở.';

  @override
  String get pond_claimContact => 'Số điện thoại / Zalo của hồ';

  @override
  String get pond_claimNote => 'Lời nhắn (không bắt buộc)';

  @override
  String get pond_claimSend => 'Gửi yêu cầu';

  @override
  String get pond_claimSent => 'Đã gửi! Quản trị viên sẽ liên hệ bạn sớm.';

  @override
  String get pond_claimPending => 'Yêu cầu của bạn đang chờ duyệt.';

  @override
  String get pond_claimOwned => 'Hồ này đã có chủ quản lý.';

  @override
  String get pond_claimYours => 'Bạn đang là chủ hồ này.';

  @override
  String get pond_report => 'Báo cáo';

  @override
  String get pond_reportTitle => 'Báo cáo hồ này?';

  @override
  String get pond_reportHint =>
      'Hồ không có thật, đã đóng cửa, sai chỗ… 3 người báo cáo thì hồ chưa có chủ sẽ tự ẩn.';

  @override
  String get pond_error => 'Chưa gửi được, kiểm tra mạng rồi thử lại';

  @override
  String get pond_tooMany => 'Bạn thao tác hơi nhiều hôm nay, mai thử lại nhé';

  @override
  String get pond_duplicate => 'Chỗ này đã có hồ trong danh sách. Mở hồ đó?';

  @override
  String get pond_open => 'Mở';

  @override
  String get pond_name => 'Tên hồ';

  @override
  String get pond_nameHint => 'vd Hồ câu Thanh Hà';

  @override
  String get pond_address => 'Địa chỉ';

  @override
  String get pond_phone => 'Số điện thoại / Zalo';

  @override
  String get pond_priceHint => 'vd 200k/ca 4 tiếng, 350k/ngày';

  @override
  String get pond_hoursHint => 'vd 6h–18h, nghỉ thứ 2';

  @override
  String pond_location(String coords) {
    return 'Vị trí ghim: $coords';
  }

  @override
  String get pond_locationHint =>
      'Ghim đặt ở chỗ bạn chọn trên bản đồ. Muốn đổi: chạm đúng hồ trên bản đồ → Thêm hồ.';

  @override
  String get pond_save => 'Lưu';

  @override
  String get pond_added => 'Đã thêm hồ! Cảm ơn bạn.';

  @override
  String get pond_saved => 'Đã lưu';

  @override
  String get pond_needName => 'Nhập tên hồ (từ 2 ký tự)';

  @override
  String get pond_reviews => 'Đánh giá';

  @override
  String get pond_writeReview => 'Viết đánh giá';

  @override
  String get pond_reviewHint => 'Cá có ăn không, giá, dịch vụ, chỗ ngồi…';

  @override
  String get pond_reviewSend => 'Gửi đánh giá';

  @override
  String get pond_reviewEmpty => 'Chưa có đánh giá nào.';

  @override
  String get pond_deleteReview => 'Xóa đánh giá của tôi';

  @override
  String get pond_noStars => 'Chọn số sao';

  @override
  String get release_title => 'Báo lịch xả cá';

  @override
  String get release_paste => 'Dán bài đăng của hồ';

  @override
  String get release_pasteHint =>
      'Copy bài Facebook / chú thích TikTok của hồ rồi dán vào đây. App tự đọc ngày, giờ, loại cá, số lượng.';

  @override
  String get release_pasteButton => 'Dán';

  @override
  String get release_read => 'App đọc được';

  @override
  String get release_notFound => 'Chưa thấy ngày xả trong bài. Chọn ngày bên dưới.';

  @override
  String get release_day => 'Ngày';

  @override
  String get release_time => 'Giờ';

  @override
  String get release_fish => 'Cá xả';

  @override
  String get release_addFish => 'Thêm loại cá';

  @override
  String get release_fishName => 'Loại cá';

  @override
  String get release_fishKg => 'kg';

  @override
  String release_total(String amount) {
    return 'Tổng $amount';
  }

  @override
  String get release_asOwner => 'Bạn là chủ hồ: lịch này hiện là \"Chủ hồ đăng\".';

  @override
  String get release_asUser =>
      'Lịch bạn báo hiện là \"Người dùng báo\" cho tới khi chủ hồ xác nhận. Chỉ báo khi thấy hồ đăng thật nhé.';

  @override
  String get release_post => 'Đăng lịch xả';

  @override
  String get release_posted => 'Đã đăng lịch xả!';

  @override
  String get release_needDay => 'Chọn ngày xả';

  @override
  String get stations_menu => 'Danh sách trạm đo';

  @override
  String get stations_menuHint => 'Mực nước tại các trạm KTTV, IOC';

  @override
  String get trip_tag => 'Kèo câu';

  @override
  String trip_pill(int count) {
    return '$count kèo câu';
  }

  @override
  String get trip_create => 'Rủ đi câu';

  @override
  String get trip_createHere => 'Rủ đi câu ở đây';

  @override
  String get trip_formTitle => 'Tạo kèo câu';

  @override
  String get trip_editTitle => 'Sửa kèo câu';

  @override
  String get trip_name => 'Tên kèo';

  @override
  String get trip_nameHint => 'vd Câu đêm bãi đá cầu Thanh Trì';

  @override
  String get trip_place => 'Địa điểm';

  @override
  String get trip_placeHint => 'vd Bãi đá chân cầu, cổng số 3';

  @override
  String get trip_whereHint =>
      'Ghim kèo đặt ở chỗ này. Muốn hẹn chỗ khác: chạm chỗ đó trên bản đồ → \"Rủ đi câu ở đây\".';

  @override
  String get trip_when => 'Thời gian';

  @override
  String get trip_date => 'Ngày';

  @override
  String get trip_start => 'Bắt đầu';

  @override
  String get trip_duration => 'Câu trong';

  @override
  String trip_hours(int hours) {
    return '$hours giờ';
  }

  @override
  String get trip_golden => 'Giờ vàng ở đây (bấm để chọn)';

  @override
  String trip_goldenChip(String when, String score) {
    return '$when · $score';
  }

  @override
  String get trip_noGolden => '3 ngày tới chưa có giờ vàng ở đây';

  @override
  String get trip_people => 'Số người tối đa (kể cả bạn)';

  @override
  String get trip_contact => 'Liên hệ (không bắt buộc)';

  @override
  String get trip_contactHint => 'Link nhóm Zalo/Facebook hoặc số điện thoại';

  @override
  String get trip_contactNote => 'Chỉ người đã tham gia kèo mới thấy.';

  @override
  String get trip_noteHint => 'Câu gì, mồi gì, đi xe máy hay ô tô ghép, chia tiền xăng…';

  @override
  String get trip_submit => 'Tạo kèo';

  @override
  String get trip_save => 'Lưu thay đổi';

  @override
  String get trip_created => 'Đã tạo kèo! Anh em quanh đây sẽ thấy trên bản đồ.';

  @override
  String get trip_saved => 'Đã lưu kèo';

  @override
  String get trip_needName => 'Đặt tên kèo (từ 2 ký tự)';

  @override
  String get trip_badTime => 'Giờ bắt đầu phải trong 30 ngày tới';

  @override
  String get trip_tooMany => 'Hôm nay máy này đã tạo đủ 5 kèo. Mai tạo tiếp nhé.';

  @override
  String get trip_error => 'Chưa gửi được, kiểm tra mạng rồi thử lại';

  @override
  String get trip_tooFew => 'Kèo đã có nhiều người hơn số này';

  @override
  String get trip_running => 'Đang diễn ra';

  @override
  String get trip_cancelled => 'Đã hủy';

  @override
  String get trip_full => 'Đủ người';

  @override
  String trip_left(int count) {
    return 'Còn $count chỗ';
  }

  @override
  String trip_members(int count, int max) {
    return '$count/$max người';
  }

  @override
  String trip_owner(String name) {
    return 'Chủ kèo: $name';
  }

  @override
  String get trip_yours => 'Kèo của bạn';

  @override
  String get trip_joinedTag => 'Bạn đã tham gia';

  @override
  String get trip_join => 'Tham gia';

  @override
  String get trip_joinedSnack => 'Đã tham gia! Xem liên hệ và nhắn tin với nhóm bên dưới.';

  @override
  String get trip_joinFull => 'Kèo đã đủ người';

  @override
  String get trip_joinClosed => 'Kèo đã kết thúc hoặc bị hủy';

  @override
  String get trip_leave => 'Rời kèo';

  @override
  String get trip_leaveTitle => 'Rời kèo này?';

  @override
  String get trip_cancel => 'Hủy kèo';

  @override
  String get trip_cancelTitle => 'Hủy kèo? Người đã tham gia sẽ thấy \"Đã hủy\".';

  @override
  String get trip_edit => 'Sửa';

  @override
  String get trip_keep => 'Giữ kèo';

  @override
  String get trip_share => 'Rủ thêm bạn';

  @override
  String trip_shareText(String title, String when, String place, String map, String app) {
    return '🎣 Kèo câu: $title\n🕐 $when\n📍 $place\nBản đồ: $map\nXem và tham gia trên app Con Nước: $app';
  }

  @override
  String get trip_report => 'Báo cáo';

  @override
  String get trip_reportTitle => 'Báo cáo kèo này?';

  @override
  String get trip_reportHint =>
      'Lừa đảo, quảng cáo, nội dung xấu… Kèo bị 3 người báo cáo sẽ tự ẩn.';

  @override
  String get trip_membersOnly =>
      'Tham gia để xem liên hệ, danh sách người đi và nhắn tin với nhóm.';

  @override
  String get trip_contactLabel => 'Liên hệ';

  @override
  String get trip_openContact => 'Mở';

  @override
  String get trip_memberList => 'Người đi';

  @override
  String get trip_chat => 'Nhắn tin trong kèo';

  @override
  String get trip_chatEmpty => 'Chưa có tin nhắn. Hẹn giờ gặp, chỗ gửi xe ở đây nhé.';

  @override
  String get trip_chatHint => 'Nhắn cho cả nhóm…';

  @override
  String get trip_send => 'Gửi';

  @override
  String get trip_refresh => 'Tải lại';

  @override
  String get trip_nearbyTitle => 'Kèo câu quanh đây';

  @override
  String get trip_nearbyEmpty => 'Chưa có kèo nào trong vòng 30 km. Tạo kèo đầu tiên để rủ anh em!';

  @override
  String get trip_loadError => 'Không tải được kèo câu';

  @override
  String get trip_notice =>
      'Kèo hiện công khai cho người dùng quanh đây. Không hẹn ở nơi cấm câu; đi theo nhóm, giữ an toàn khi câu đêm.';

  @override
  String get checkin_pill => 'Tôi đang câu';

  @override
  String checkin_pillOn(String time) {
    return 'Đang câu · còn $time';
  }

  @override
  String checkin_count(int count) {
    return '$count người đang câu';
  }

  @override
  String get checkin_title => 'Báo \"đang câu ở đây\"';

  @override
  String get checkin_body =>
      'Anh em quanh đây sẽ thấy có người đang câu ở khu này. Chỉ hiện con số, không hiện tên; vị trí làm tròn khoảng 200 m; tự tắt sau 4 giờ.';

  @override
  String get checkin_biting => 'Đang dính 🐟';

  @override
  String get checkin_noBite => 'Chưa dính';

  @override
  String get checkin_start => 'Bắt đầu';

  @override
  String get checkin_update => 'Cập nhật';

  @override
  String get checkin_stop => 'Về rồi';

  @override
  String get checkin_on => 'Đã báo đang câu. Chúc dính cá to!';

  @override
  String get checkin_off => 'Đã tắt. Về an toàn nhé!';

  @override
  String get checkin_error => 'Chưa gửi được, kiểm tra mạng rồi thử lại';

  @override
  String get checkin_needLocation => 'Cần vị trí của bạn để báo đang câu';

  @override
  String checkin_cellTitle(int count) {
    return '$count người đang câu quanh đây';
  }

  @override
  String checkin_cellBiting(int count) {
    return '$count người báo đang dính cá';
  }

  @override
  String get checkin_cellNoBite => 'Chưa ai báo dính cá';

  @override
  String checkin_cellLatest(String time) {
    return 'Người mới nhất tới lúc $time';
  }

  @override
  String get checkin_cellYou => 'Có cả bạn';

  @override
  String get checkin_listTitle => 'Chỗ đang có người câu';

  @override
  String get checkin_hint => 'Vị trí làm tròn ~200 m, không hiện tên ai.';

  @override
  String get spot_publicTag => 'Điểm câu cộng đồng';

  @override
  String get spot_pinAction => 'Ghim công khai';

  @override
  String spot_nearbyChip(int count) {
    return '$count điểm cộng đồng';
  }

  @override
  String get spot_nearbyTitle => 'Điểm câu gần đây';

  @override
  String get spot_nearbyEmpty =>
      'Chưa có điểm câu nào trong vòng 30 km. Chạm một chỗ trên bản đồ rồi bấm \"Ghim công khai\" để chia sẻ điểm của bạn.';

  @override
  String spot_postedAgo(String date) {
    return 'Đăng $date';
  }

  @override
  String spot_distance(String km) {
    return 'cách $km';
  }

  @override
  String get spot_viewWater => 'Xem nước tại đây';

  @override
  String get spot_report => 'Báo cáo';

  @override
  String get spot_reportTitle => 'Báo cáo điểm câu này?';

  @override
  String get spot_reportHint =>
      'Sai chỗ, ảnh không phù hợp, quảng cáo… Điểm bị nhiều người báo sẽ tự ẩn.';

  @override
  String get spot_reportDone => 'Đã gửi báo cáo. Cảm ơn bạn!';

  @override
  String get spot_reportTwice => 'Bạn đã báo cáo điểm này rồi';

  @override
  String get spot_delete => 'Xóa điểm của tôi';

  @override
  String get spot_deleteTitle => 'Xóa điểm câu này khỏi bản đồ cộng đồng?';

  @override
  String get spot_ownedByYou => 'Điểm của bạn';

  @override
  String get spot_publishTitle => 'Ghim điểm câu công khai';

  @override
  String get spot_name => 'Tên điểm';

  @override
  String get spot_nameHint => 'vd Bãi đá cầu Thanh Trì';

  @override
  String get spot_species => 'Cá hay câu được';

  @override
  String get spot_note => 'Kinh nghiệm';

  @override
  String get spot_noteHint => 'Mồi, giờ đẹp, chỗ để xe, độ sâu…';

  @override
  String get spot_photos => 'Ảnh (tối đa 3)';

  @override
  String get spot_addPhoto => 'Thêm ảnh';

  @override
  String get spot_publicNotice =>
      'Điểm này sẽ hiện công khai cho mọi người dùng Con Nước. Không đăng điểm cấm câu, ảnh có mặt người khác khi chưa được đồng ý.';

  @override
  String get spot_agree => 'Tôi hiểu và đồng ý chia sẻ';

  @override
  String get spot_publish => 'Đăng điểm';

  @override
  String get spot_published => 'Đã ghim! Mọi người quanh đây sẽ thấy điểm của bạn.';

  @override
  String get spot_needName => 'Đặt tên cho điểm (từ 2 ký tự)';

  @override
  String get spot_error => 'Chưa gửi được, kiểm tra mạng rồi thử lại';

  @override
  String get spot_photoError => 'Không đọc được ảnh này';

  @override
  String spot_location(String coords) {
    return 'Vị trí: $coords';
  }

  @override
  String get station_levelNow => 'Mực nước hiện tại';

  @override
  String get station_follow => 'Theo dõi trạm';

  @override
  String get station_unfollow => 'Bỏ theo dõi';

  @override
  String get stations_kindRiver => 'Trạm sông (KTTV)';

  @override
  String get stations_kindRiverDaily => 'Sông có triều (KTTV)';

  @override
  String get station_sourceRiver =>
      'Bản tin thủy văn KTTV (4 mốc đo/ngày + dự báo) · đường từng giờ do app nội suy';

  @override
  String get station_sourceRiverTide =>
      'Bản tin thủy văn KTTV + triều cửa sông (Open-Meteo Marine) · đường từng giờ do app ước tính';

  @override
  String get station_datumNational => 'mốc cao độ của trạm (theo bản tin KTTV)';

  @override
  String station_issued(String time) {
    return 'Bản tin KTTV phát $time';
  }

  @override
  String station_backtestMae(String cm) {
    return 'Kiểm thử ngược: sai số trung bình ±$cm cm';
  }

  @override
  String station_dailyTitle(int hours) {
    return 'Mực nước trong $hours giờ (bản tin KTTV)';
  }

  @override
  String station_dailyObs(String max, String min) {
    return 'Đã đo: cao nhất $max · thấp nhất $min';
  }

  @override
  String station_dailyFc(String max, String min) {
    return 'Dự báo: cao nhất $max · thấp nhất $min';
  }

  @override
  String get station_dailyNoCurve =>
      'Bản tin chỉ cho mức cao nhất và thấp nhất, không ghi giờ. App không vẽ đường để tránh đoán sai giờ nước lên xuống.';

  @override
  String station_dailyRangeNow(String range) {
    return 'Biên độ dự báo $range — nước còn lên/xuống trong khoảng này';
  }

  @override
  String get point_estimateHere => 'Mực nước ước tính tại điểm này';

  @override
  String get point_onWater => 'Điểm nằm trên mặt nước (sông, hồ hoặc biển)';

  @override
  String get point_onLand =>
      'Điểm này không nằm trên sông, hồ hay biển. Số dưới đây là mực nước của nguồn nước gần nhất.';

  @override
  String point_basisRiver(String station, String river, String distance) {
    return 'Dựa theo trạm $station (sông $river) · cách $distance';
  }

  @override
  String point_basisStation(String station, String distance) {
    return 'Dựa theo trạm $station · cách $distance';
  }

  @override
  String point_alongDown(String station, String distance, String river) {
    return 'Cách trạm $station $distance về phía hạ lưu, đo dọc sông $river';
  }

  @override
  String point_alongUp(String station, String distance, String river) {
    return 'Cách trạm $station $distance về phía thượng lưu, đo dọc sông $river';
  }

  @override
  String point_lagEarlier(int minutes) {
    return 'Nước lên/xuống sớm hơn trạm khoảng $minutes phút';
  }

  @override
  String point_lagLater(int minutes) {
    return 'Nước lên/xuống muộn hơn trạm khoảng $minutes phút';
  }

  @override
  String get point_lagSame => 'Nước lên/xuống gần như cùng lúc với trạm';

  @override
  String point_meanLower(int cm) {
    return 'Mặt nước thấp hơn ở trạm khoảng $cm cm';
  }

  @override
  String point_meanHigher(int cm) {
    return 'Mặt nước cao hơn ở trạm khoảng $cm cm';
  }

  @override
  String point_celerity(String speed) {
    return 'Con triều truyền ngược sông khoảng $speed km/giờ';
  }

  @override
  String get point_reachNote =>
      'Ước tính theo vị trí dọc sông, giữa triều ở cửa sông và trạm đo; chưa kiểm chứng bằng trạm thứ hai.';

  @override
  String get flow_unknown =>
      'Chỗ này không nằm trên dòng sông lớn nào nên chưa tính được mực nước và dòng chảy. Giờ câu và thời tiết vẫn tính theo đúng vị trí.';

  @override
  String get flow_headRising => 'Nước sông đang lên';

  @override
  String get flow_headFalling => 'Nước sông đang rút';

  @override
  String get flow_headSteady => 'Nước sông ổn định';

  @override
  String flow_dayValue(String day, String q) {
    return '$day: $q m³/s';
  }

  @override
  String get loc_nearCoast => 'Gần cửa biển';

  @override
  String get point_basisCoast =>
      'Triều ước tính theo vùng biển ven bờ gần nhất; trong sông, giờ nước lên xuống thường muộn hơn và biên độ nhỏ hơn.';

  @override
  String get info_noLevelSources =>
      'Chỗ này chưa có nguồn mực nước. Lưu lượng sông: mô hình GloFAS (qua Open-Meteo Flood), theo ngày. Thời tiết, giờ câu: Open-Meteo và tính toán thiên văn tại đúng tọa độ. Mọi số liệu chỉ mang tính tham khảo.';

  @override
  String get flow_title => 'Dòng chảy sông';

  @override
  String flow_today(String q) {
    return 'Lưu lượng hôm nay ≈ $q m³/s';
  }

  @override
  String flow_tomorrow(String q, String trend) {
    return 'Ngày mai ≈ $q m³/s · $trend';
  }

  @override
  String get flow_rising => 'đang tăng (nước sông lên dần)';

  @override
  String get flow_falling => 'đang giảm (nước sông rút dần)';

  @override
  String get flow_steady => 'ổn định';

  @override
  String get flow_note => 'Ước tính cho dòng chính đoạn sông này, theo ngày.';

  @override
  String chart_band(String cm) {
    return 'Dải mờ quanh đường: sai số khoảng ±$cm cm, đo khi kiểm thử tại trạm';
  }

  @override
  String turn_in(String duration) {
    return 'còn $duration';
  }

  @override
  String day_high(String level, String time) {
    return 'Cao nhất $level · $time';
  }

  @override
  String day_low(String level, String time) {
    return 'Thấp nhất $level · $time';
  }

  @override
  String day_range(int cm) {
    return 'Chênh $cm cm';
  }

  @override
  String get fishAct_title => 'Cá ăn';

  @override
  String get fishAct_low => 'Thấp';

  @override
  String get fishAct_fair => 'Vừa';

  @override
  String get fishAct_high => 'Cao';

  @override
  String get fishAct_peak => 'Rất cao';

  @override
  String fishAct_score(String score) {
    return '$score/10';
  }

  @override
  String fishAct_meter(int count) {
    return '$count trên 5 cá';
  }

  @override
  String fishAct_because(String reasons) {
    return 'Nhờ $reasons';
  }

  @override
  String fishAct_next(String when) {
    return 'Giờ vàng tiếp theo: $when';
  }

  @override
  String fishAct_inWindow(String to) {
    return 'Đang trong giờ vàng đến $to';
  }

  @override
  String get fishAct_noWindow => 'Chưa thấy giờ vàng trong 2 ngày tới';

  @override
  String get fishAct_source =>
      'Ước tính từ con nước, giờ mặt trăng, ngày/đêm và thời tiết (Open-Meteo) — chỉ để tham khảo, không biết chắc chỗ nào có cá.';

  @override
  String get fishAct_quick => 'Chưa có thời tiết: tạm tính theo con nước và giờ mặt trăng.';

  @override
  String get fishTime_now => 'Bây giờ';

  @override
  String fishTime_today(String time) {
    return 'Hôm nay $time';
  }

  @override
  String fishTime_tomorrow(String time) {
    return 'Ngày mai $time';
  }

  @override
  String fishTime_dayAfter(String time) {
    return 'Ngày kia $time';
  }

  @override
  String get fishTime_title => 'Cá ăn lúc';

  @override
  String get fishTime_slider => 'Chọn giờ xem cá ăn';

  @override
  String get fishTime_reset => 'Về bây giờ';

  @override
  String get fishTime_legendNote => 'Màu ghim = mức cá ăn ước tính. Chạm ghim để xem chi tiết.';

  @override
  String get fishTime_collapse => 'Thu gọn';

  @override
  String get fishTime_expand => 'Xem cá ăn theo giờ';

  @override
  String get fish_now_title => 'Câu cá lúc này';

  @override
  String get fish_unsafe => 'Đang có cảnh báo thời tiết — không nên ra nước';

  @override
  String get fish_noWindow => 'Hôm nay không có khung giờ nổi bật';

  @override
  String fish_best(String from, String to) {
    return 'Giờ đẹp hôm nay: $from–$to';
  }

  @override
  String get cond_title => 'Thời tiết & trời';

  @override
  String loc_river(String river) {
    return 'Sông $river';
  }

  @override
  String loc_nearRiver(String river) {
    return 'Gần sông $river';
  }

  @override
  String get loc_sea => 'Vùng biển';

  @override
  String get loc_water => 'Trên mặt nước';

  @override
  String get spot_title => 'Điểm câu';

  @override
  String get spot_mine => 'Vị trí của tôi';

  @override
  String get spot_point => 'Điểm đã chọn';

  @override
  String get spot_useMine => 'Vị trí của tôi';

  @override
  String get spot_pickMap => 'Chọn trên bản đồ';

  @override
  String get spot_pickHint => 'Chạm vào chỗ bạn định câu, rồi bấm \"Câu cá tại đây\"';

  @override
  String get spot_saved => 'Điểm đã lưu';

  @override
  String get fish_here => 'Câu cá tại đây';

  @override
  String get advice_title => 'Gợi ý câu lúc này';

  @override
  String get advice_note => 'Gợi ý theo kinh nghiệm câu phổ biến, tính cho đúng điểm này.';

  @override
  String get advice_unsafe => 'Có dông hoặc gió giật mạnh — không nên câu lúc này';

  @override
  String get advice_rising =>
      'Nước đang lên: cá vào gần bờ, mép cỏ, bãi nông kiếm ăn, nên câu gần bờ';

  @override
  String get advice_falling =>
      'Nước đang rút: cá ra chỗ sâu, mép luồng, cửa lạch, nên câu xa bờ hơn';

  @override
  String get advice_slack => 'Nước đứng: cá ít ăn, chờ nước chảy lại';

  @override
  String advice_slackAt(String time) {
    return 'Nước đứng: cá ít ăn — nước chảy lại khoảng $time';
  }

  @override
  String get advice_windStrong =>
      'Gió mạnh: khó quăng xa — câu sát bờ khuất gió, không nên ra thuyền';

  @override
  String get advice_windDown => 'Có gió: câu phía cuối gió, nơi sóng dồn mồi';

  @override
  String get advice_rain => 'Khả năng mưa cao — mang theo áo mưa';

  @override
  String get advice_flood => 'Nước sông lên nhanh, đục: câu chỗ nước quẩn sau mỏ kè, gốc cây';

  @override
  String get advice_light => 'Sắp bình minh/hoàng hôn — giờ cá ăn mạnh';

  @override
  String get advice_good => 'Điểm câu đang tốt — tranh thủ ra câu';

  @override
  String point_reference(String station, String distance) {
    return 'Ước tính theo trạm $station, cách $distance';
  }

  @override
  String point_referenceRiver(String station, String river, String distance) {
    return 'Ước tính theo trạm $station (sông $river), cách $distance';
  }

  @override
  String get point_title => 'Điểm đã chọn';

  @override
  String point_coords(String coords) {
    return 'Tọa độ: $coords';
  }

  @override
  String get point_copy => 'Sao chép tọa độ';

  @override
  String get point_copied => 'Đã sao chép tọa độ';

  @override
  String get point_noData => 'Chưa tính được số liệu cho điểm này.';

  @override
  String get point_nearby => 'Trạm gần nhất';

  @override
  String point_distance(String distance) {
    return 'cách $distance';
  }

  @override
  String get point_openDetail => 'Xem chi tiết theo giờ';

  @override
  String point_weatherNow(String temp, String wind, int rain) {
    return 'Thời tiết bây giờ: $temp°C · gió $wind km/h · mưa $rain%';
  }

  @override
  String point_sun(String rise, String set) {
    return 'Mặt trời mọc $rise · lặn $set';
  }

  @override
  String get point_seaModel => 'Mô hình biển tính ngay tại điểm này';

  @override
  String get point_tapHint => 'Chạm vào bất kỳ đâu trên bản đồ để xem nước tại đó';

  @override
  String get source_shortGauge => 'IOC + utide';

  @override
  String get source_shortModel => 'Open-Meteo';

  @override
  String get source_shortRiver => 'KTTV';

  @override
  String get source_shortRiverTide => 'KTTV + triều Open-Meteo';

  @override
  String source_compact(String source, String updated) {
    return 'Nguồn: $source · $updated';
  }

  @override
  String get source_details => 'Chi tiết nguồn';

  @override
  String get map_credits => 'Nguồn bản đồ';

  @override
  String get map_creditShort => '© OpenFreeMap · © OpenStreetMap';

  @override
  String get map_creditShortSat => '© EOX · Copernicus · © OpenStreetMap';

  @override
  String station_datumNote(String datum) {
    return 'Độ cao so với $datum';
  }

  @override
  String get station_datumChart => 'số 0 hải đồ (quy đổi theo bản tin KTTV)';

  @override
  String get station_datumMsl => 'mực nước biển trung bình của mô hình';

  @override
  String station_lunarDay(int day, int month) {
    return '$day/$month ÂL';
  }

  @override
  String station_dailyRange(String range) {
    return 'Biên độ $range';
  }

  @override
  String station_coords(String lat, String lon) {
    return 'Tọa độ: $lat, $lon';
  }

  @override
  String station_modelFit(String from, String to) {
    return 'Hằng số triều tính từ số liệu $from đến $to';
  }

  @override
  String get station_sourceGauge => 'IOC Sea Level Monitoring (thực đo) · dự báo tính bằng utide';

  @override
  String get station_sourceModel => 'Open-Meteo Marine (mô hình đại dương, không có thực đo)';

  @override
  String get hourly_now => 'Bây giờ';

  @override
  String hourly_detailTitle(String time) {
    return 'Chi tiết lúc $time';
  }

  @override
  String hourly_obsMinusPred(String delta) {
    return 'Thực đo − dự báo: $delta';
  }

  @override
  String hourly_untilNext(String kind, String duration) {
    return '$kind tiếp theo sau $duration';
  }

  @override
  String hourly_fishScore(String score) {
    return 'Chỉ số câu cá: $score/10';
  }

  @override
  String hourly_weather(String temp, String wind, String rain) {
    return '$temp °C · gió $wind km/h · mưa $rain mm';
  }

  @override
  String get hourly_empty => 'Không có số liệu theo giờ cho khoảng thời gian này.';

  @override
  String get chart_semantics => 'Biểu đồ mực nước, thực đo nét liền, dự báo nét đứt';

  @override
  String get watch_empty => 'Bạn chưa theo dõi trạm nào. Mở một trạm và bấm ⭐ để thêm.';

  @override
  String get fishing_title => 'Chỉ số câu cá';

  @override
  String get fishing_pickStation => 'Chọn trạm';

  @override
  String get fishing_dayScore => 'Điểm hôm nay';

  @override
  String get fishing_reference => 'Chỉ số mang tính tham khảo (công thức fs-1)';

  @override
  String get fishing_golden => 'Giờ vàng';

  @override
  String get fishing_noGolden => 'Hôm nay không có khung giờ đạt ≥ 7 điểm.';

  @override
  String get fishing_next7 => '7 ngày tới';

  @override
  String fishing_level(String score, String label) {
    return '$score/10 · $label';
  }

  @override
  String get fishing_levelGood => 'Tốt';

  @override
  String get fishing_levelFair => 'Khá';

  @override
  String get fishing_levelPoor => 'Kém';

  @override
  String fishing_warnRed(String from, String to) {
    return 'Có dông/sét hoặc gió giật mạnh lúc $from–$to — không nên ra sông/biển trong khung giờ này.';
  }

  @override
  String fishing_warnYellow(String from, String to) {
    return 'Có thể có dông hoặc mưa lớn lúc $from–$to — theo dõi thời tiết.';
  }

  @override
  String fishing_levelOutsideWarning(String score, String label) {
    return '$score/10 · $label ngoài khung giờ cảnh báo';
  }

  @override
  String get fishing_factor_tide => 'con nước';

  @override
  String get fishing_factor_flow => 'dòng chảy';

  @override
  String get fishing_factor_solunar => 'giờ trăng';

  @override
  String get fishing_factor_pressure => 'áp suất';

  @override
  String get fishing_factor_daytime => 'bình minh/hoàng hôn';

  @override
  String get fishing_factor_weather => 'thời tiết';

  @override
  String get fishing_factor_season => 'mùa cá';

  @override
  String fishing_moon(String phase, int pct) {
    return 'Trăng: $phase ($pct%)';
  }

  @override
  String get fishing_weatherSource => 'Open-Meteo (dự báo thời tiết)';

  @override
  String get moon_newMoon => 'Trăng non';

  @override
  String get moon_waxingCrescent => 'Trăng lưỡi liềm đầu tháng';

  @override
  String get moon_firstQuarter => 'Trăng thượng huyền';

  @override
  String get moon_waxingGibbous => 'Trăng khuyết đầu tháng';

  @override
  String get moon_fullMoon => 'Trăng tròn';

  @override
  String get moon_waningGibbous => 'Trăng khuyết cuối tháng';

  @override
  String get moon_lastQuarter => 'Trăng hạ huyền';

  @override
  String get moon_waningCrescent => 'Trăng lưỡi liềm cuối tháng';

  @override
  String get more_info => 'Thông tin ứng dụng';

  @override
  String get more_appName => 'Con Nước';

  @override
  String more_build(String sha) {
    return 'Bản dựng $sha';
  }

  @override
  String get more_update => 'Có phiên bản mới — tải lại trang để cập nhật';

  @override
  String get more_close => 'Đóng';

  @override
  String get more_title => 'Thêm';

  @override
  String get more_theme => 'Giao diện';

  @override
  String get more_themeSystem => 'Theo máy';

  @override
  String get more_themeLight => 'Sáng';

  @override
  String get more_themeDark => 'Tối';

  @override
  String get more_sources => 'Nguồn dữ liệu';

  @override
  String get more_sourcesBody =>
      '• IOC Sea Level Monitoring — thực đo mực nước biển Vũng Tàu, Quy Nhơn (mỗi phút). Dự báo triều tại 2 trạm này tính bằng phân tích điều hòa (utide) từ 12 tháng số liệu; kiểm thử ngược: sai số ±10 cm (Vũng Tàu), ±7 cm (Quy Nhơn).\n• Trung tâm Dự báo KTTV quốc gia — bản tin thủy văn hạn ngắn: mực nước sông 4 mốc/ngày + dự báo. Đường từng giờ do app ước tính (ghép triều cửa sông); kiểm thử ngược: ±12 cm (Hà Nội), ±11 cm (Nam Đàn).\n• Open-Meteo — thời tiết, sóng và mô hình mực nước biển ven bờ.\n• GloFAS (qua Open-Meteo Flood) — lưu lượng dòng chính các sông, theo ngày.\n• Điểm bất kỳ trên bản đồ: mô hình biển tại điểm đó; trên sông Hồng, sông Cả thì tính theo vị trí dọc sông; nơi khác dùng trạm sông KTTV gần nhất (trong 40 km), triều ven bờ (ước tính) hoặc lưu lượng sông.\n• Bản đồ nền: OpenFreeMap · © OpenMapTiles · dữ liệu © OpenStreetMap.\n• Ảnh vệ tinh: EOxCloudless (EOX IT Services GmbH), chứa dữ liệu Copernicus Sentinel 2025.\nMọi số liệu dự báo/ước tính chỉ mang tính tham khảo. Chi tiết nguồn, mốc cao độ và độ tin cậy của từng trạm xem ở tab Thông tin của trạm.';

  @override
  String more_version(String version) {
    return 'Phiên bản $version';
  }
}
