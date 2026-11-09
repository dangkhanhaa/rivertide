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
  String get map_searchHint => 'Tìm trạm (gõ không dấu cũng được)';

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
      'App dùng vị trí để đưa bản đồ tới chỗ bạn đang đứng. Vị trí chỉ dùng trên máy, không lưu và không gửi đi.';

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
      'Vào Cài đặt → Ứng dụng → Con Nước → Quyền → Vị trí để bật lại.';

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
      'Ảnh vệ tinh: EOxCloudless (EOX IT Services) · chứa dữ liệu Copernicus Sentinel 2025 · chỉ dùng phi thương mại';

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
  String get map_legendStale => 'Mất dữ liệu quá 6 giờ';

  @override
  String get map_legendCluster =>
      'Vòng có số: nhóm trạm gần nhau, chạm để phóng to. Màu vòng là màu của trạm nghiêm trọng nhất.';

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
  String get point_noData =>
      'Chưa có dữ liệu mực nước cho điểm này: không có biển gần và không có trạm sông KTTV nào trong vòng 40 km.';

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
    return 'Hằng số triều tính từ số liệu $from → $to';
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
  String get fishing_factor_solunar => 'solunar';

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
      '• IOC Sea Level Monitoring — thực đo mực nước biển Vũng Tàu, Quy Nhơn (mỗi phút). Dự báo triều tại 2 trạm này tính bằng phân tích điều hòa (utide) từ 12 tháng số liệu; kiểm thử ngược: sai số ±10 cm (Vũng Tàu), ±7 cm (Quy Nhơn).\n• Trung tâm Dự báo KTTV quốc gia — bản tin thủy văn hạn ngắn: mực nước sông 4 mốc/ngày + dự báo. Đường từng giờ do app ước tính (ghép triều cửa sông); kiểm thử ngược: ±12 cm (Hà Nội), ±11 cm (Nam Đàn).\n• Open-Meteo — thời tiết, sóng và mô hình mực nước biển tại điểm ven biển (gói miễn phí, phi thương mại).\n• Điểm bất kỳ trên bản đồ: mô hình biển tại điểm đó, hoặc trạm sông KTTV gần nhất (trong 40 km).\n• Bản đồ nền: OpenFreeMap · © OpenMapTiles · dữ liệu © OpenStreetMap.\n• Ảnh vệ tinh: EOxCloudless (EOX IT Services GmbH), chứa dữ liệu Copernicus Sentinel 2025, giấy phép CC BY-NC-SA 4.0.\nMọi số liệu dự báo/ước tính chỉ mang tính tham khảo. Chi tiết nguồn, mốc cao độ và độ tin cậy của từng trạm xem ở tab Thông tin của trạm.';

  @override
  String get more_about => 'Giới thiệu';

  @override
  String get more_aboutBody =>
      'Con Nước — bản dùng thử V0. Không có máy chủ: app lấy dữ liệu trực tiếp từ nguồn miễn phí và tính toán trên máy.';

  @override
  String more_version(String version) {
    return 'Phiên bản $version';
  }
}
