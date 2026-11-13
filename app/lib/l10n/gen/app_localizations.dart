import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Con Nước'**
  String get appTitle;

  /// No description provided for @common_retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải…'**
  String get common_loading;

  /// No description provided for @common_empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get common_empty;

  /// No description provided for @common_reference.
  ///
  /// In vi, this message translates to:
  /// **'tham khảo'**
  String get common_reference;

  /// No description provided for @common_estimate.
  ///
  /// In vi, this message translates to:
  /// **'ước tính'**
  String get common_estimate;

  /// No description provided for @common_source.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn: {source}'**
  String common_source(String source);

  /// No description provided for @common_staleBanner.
  ///
  /// In vi, this message translates to:
  /// **'Ngoại tuyến · cập nhật lúc {time}'**
  String common_staleBanner(String time);

  /// No description provided for @common_updatedAt.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật {time}'**
  String common_updatedAt(String time);

  /// No description provided for @common_today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get common_today;

  /// No description provided for @common_tomorrow.
  ///
  /// In vi, this message translates to:
  /// **'Mai'**
  String get common_tomorrow;

  /// No description provided for @error_network.
  ///
  /// In vi, this message translates to:
  /// **'Không kết nối được. Kiểm tra mạng rồi thử lại.'**
  String get error_network;

  /// No description provided for @error_timeout.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn dữ liệu phản hồi chậm. Thử lại sau.'**
  String get error_timeout;

  /// No description provided for @error_server.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn dữ liệu đang gián đoạn.'**
  String get error_server;

  /// No description provided for @error_parse.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu nguồn không hợp lệ.'**
  String get error_parse;

  /// No description provided for @error_notFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy.'**
  String get error_notFound;

  /// No description provided for @error_offlineNoCache.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang ngoại tuyến và chưa có dữ liệu lưu sẵn.'**
  String get error_offlineNoCache;

  /// No description provided for @error_unknown.
  ///
  /// In vi, this message translates to:
  /// **'Đã có lỗi. Thử lại sau.'**
  String get error_unknown;

  /// No description provided for @dataKind_observed.
  ///
  /// In vi, this message translates to:
  /// **'Thực đo'**
  String get dataKind_observed;

  /// No description provided for @dataKind_forecast.
  ///
  /// In vi, this message translates to:
  /// **'Dự báo · tham khảo'**
  String get dataKind_forecast;

  /// No description provided for @dataKind_estimate.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính'**
  String get dataKind_estimate;

  /// No description provided for @tide_rising.
  ///
  /// In vi, this message translates to:
  /// **'Đang lên'**
  String get tide_rising;

  /// No description provided for @tide_risingFast.
  ///
  /// In vi, this message translates to:
  /// **'Lên nhanh'**
  String get tide_risingFast;

  /// No description provided for @tide_slack.
  ///
  /// In vi, this message translates to:
  /// **'Nước đứng'**
  String get tide_slack;

  /// No description provided for @tide_falling.
  ///
  /// In vi, this message translates to:
  /// **'Đang xuống'**
  String get tide_falling;

  /// No description provided for @tide_fallingFast.
  ///
  /// In vi, this message translates to:
  /// **'Xuống nhanh'**
  String get tide_fallingFast;

  /// No description provided for @tide_high.
  ///
  /// In vi, this message translates to:
  /// **'Đỉnh triều'**
  String get tide_high;

  /// No description provided for @tide_low.
  ///
  /// In vi, this message translates to:
  /// **'Chân triều'**
  String get tide_low;

  /// No description provided for @tide_turning.
  ///
  /// In vi, this message translates to:
  /// **'Đang đổi con nước'**
  String get tide_turning;

  /// No description provided for @tide_spring.
  ///
  /// In vi, this message translates to:
  /// **'Nước rong'**
  String get tide_spring;

  /// No description provided for @tide_neap.
  ///
  /// In vi, this message translates to:
  /// **'Nước kém'**
  String get tide_neap;

  /// No description provided for @tide_normal.
  ///
  /// In vi, this message translates to:
  /// **'Nước trung bình'**
  String get tide_normal;

  /// No description provided for @tide_countdownHigh.
  ///
  /// In vi, this message translates to:
  /// **'Đỉnh triều sau {duration}'**
  String tide_countdownHigh(String duration);

  /// No description provided for @tide_countdownLow.
  ///
  /// In vi, this message translates to:
  /// **'Chân triều sau {duration}'**
  String tide_countdownLow(String duration);

  /// No description provided for @tide_extremeAt.
  ///
  /// In vi, this message translates to:
  /// **'{time} · dự kiến {level}'**
  String tide_extremeAt(String time, String level);

  /// No description provided for @tide_nextOther.
  ///
  /// In vi, this message translates to:
  /// **'{kind} kế tiếp: {time} · {level}'**
  String tide_nextOther(String kind, String time, String level);

  /// No description provided for @tide_noPrediction.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dự báo triều cho trạm này'**
  String get tide_noPrediction;

  /// No description provided for @tide_correctedBy.
  ///
  /// In vi, this message translates to:
  /// **'Đã hiệu chỉnh theo thực đo (lệch {delta})'**
  String tide_correctedBy(String delta);

  /// No description provided for @duration_hm.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ {minutes} phút'**
  String duration_hm(int hours, int minutes);

  /// No description provided for @duration_m.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String duration_m(int minutes);

  /// No description provided for @confidence_label.
  ///
  /// In vi, this message translates to:
  /// **'Độ tin cậy dự báo: {level}'**
  String confidence_label(String level);

  /// No description provided for @confidence_high.
  ///
  /// In vi, this message translates to:
  /// **'Cao'**
  String get confidence_high;

  /// No description provided for @confidence_medium.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình'**
  String get confidence_medium;

  /// No description provided for @confidence_low.
  ///
  /// In vi, this message translates to:
  /// **'Thấp'**
  String get confidence_low;

  /// No description provided for @skill_backtest.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm thử ngược: sai số ±{cm} cm, giờ đỉnh/chân ±{min} phút'**
  String skill_backtest(String cm, String min);

  /// No description provided for @skill_live.
  ///
  /// In vi, this message translates to:
  /// **'Sai số {days} ngày qua: ±{cm} cm, ±{min} phút'**
  String skill_live(int days, String cm, String min);

  /// No description provided for @skill_unknown.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đo được sai số tại điểm này'**
  String get skill_unknown;

  /// No description provided for @nav_map.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ'**
  String get nav_map;

  /// No description provided for @map_searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm xã, phường, cầu, bến, tọa độ…'**
  String get map_searchHint;

  /// No description provided for @map_searchNone.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy trạm phù hợp'**
  String get map_searchNone;

  /// No description provided for @map_openDetail.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết'**
  String get map_openDetail;

  /// No description provided for @map_nextExtreme.
  ///
  /// In vi, this message translates to:
  /// **'{kind} {time} ≈ {level} · còn {duration}'**
  String map_nextExtreme(String kind, String time, String level, String duration);

  /// No description provided for @tide_moreRise.
  ///
  /// In vi, this message translates to:
  /// **'Nước còn lên thêm khoảng {cm} cm'**
  String tide_moreRise(int cm);

  /// No description provided for @tide_moreFall.
  ///
  /// In vi, this message translates to:
  /// **'Nước còn xuống thêm khoảng {cm} cm'**
  String tide_moreFall(int cm);

  /// No description provided for @map_locate.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí của tôi'**
  String get map_locate;

  /// No description provided for @map_locRationaleTitle.
  ///
  /// In vi, this message translates to:
  /// **'Dùng vị trí của bạn?'**
  String get map_locRationaleTitle;

  /// No description provided for @map_locRationaleBody.
  ///
  /// In vi, this message translates to:
  /// **'App dùng vị trí để đưa bản đồ tới chỗ bạn đang đứng. Vị trí chỉ ở trên máy (nhớ gần đúng ~1 km để lần sau mở nhanh), không gửi đi đâu.'**
  String get map_locRationaleBody;

  /// No description provided for @map_locAllow.
  ///
  /// In vi, this message translates to:
  /// **'Cho phép'**
  String get map_locAllow;

  /// No description provided for @map_later.
  ///
  /// In vi, this message translates to:
  /// **'Để sau'**
  String get map_later;

  /// No description provided for @map_locServiceOff.
  ///
  /// In vi, this message translates to:
  /// **'Định vị đang tắt. Bật định vị trong máy rồi thử lại.'**
  String get map_locServiceOff;

  /// No description provided for @map_locDenied.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có quyền vị trí.'**
  String get map_locDenied;

  /// No description provided for @map_locDeniedForeverTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quyền vị trí đang bị chặn'**
  String get map_locDeniedForeverTitle;

  /// No description provided for @map_locDeniedForeverBody.
  ///
  /// In vi, this message translates to:
  /// **'Vào Cài đặt > Ứng dụng > Con Nước > Quyền > Vị trí để bật lại.'**
  String get map_locDeniedForeverBody;

  /// No description provided for @map_openSettings.
  ///
  /// In vi, this message translates to:
  /// **'Mở Cài đặt'**
  String get map_openSettings;

  /// No description provided for @map_locFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không lấy được vị trí. Thử lại sau.'**
  String get map_locFailed;

  /// No description provided for @map_outsideVn.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí nằm ngoài vùng hỗ trợ'**
  String get map_outsideVn;

  /// No description provided for @map_layers.
  ///
  /// In vi, this message translates to:
  /// **'Lớp bản đồ'**
  String get map_layers;

  /// No description provided for @map_layerStandard.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ thường'**
  String get map_layerStandard;

  /// No description provided for @map_layerStandardHint.
  ///
  /// In vi, this message translates to:
  /// **'Đường, địa danh, sông hồ (OpenFreeMap)'**
  String get map_layerStandardHint;

  /// No description provided for @map_layerSatellite.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh vệ tinh'**
  String get map_layerSatellite;

  /// No description provided for @map_layerSatelliteHint.
  ///
  /// In vi, this message translates to:
  /// **'Sentinel-2 năm 2025, độ phân giải 10 m — thấy rõ sông, bãi bồi, ruộng; không rõ từng nhà'**
  String get map_layerSatelliteHint;

  /// No description provided for @map_satelliteCredit.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh vệ tinh: EOxCloudless (EOX IT Services) · chứa dữ liệu Copernicus Sentinel 2025'**
  String get map_satelliteCredit;

  /// No description provided for @map_filter.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get map_filter;

  /// No description provided for @map_filterOnlyTide.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ trạm có triều'**
  String get map_filterOnlyTide;

  /// No description provided for @map_filterOnlyAlarm.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ trạm đang báo động'**
  String get map_filterOnlyAlarm;

  /// No description provided for @map_filterHideStale.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn trạm mất dữ liệu'**
  String get map_filterHideStale;

  /// No description provided for @map_filterNone.
  ///
  /// In vi, this message translates to:
  /// **'Không có trạm nào khớp bộ lọc'**
  String get map_filterNone;

  /// No description provided for @map_legend.
  ///
  /// In vi, this message translates to:
  /// **'Chú giải'**
  String get map_legend;

  /// No description provided for @map_legendNormal.
  ///
  /// In vi, this message translates to:
  /// **'Bình thường'**
  String get map_legendNormal;

  /// No description provided for @map_legendAlarm1.
  ///
  /// In vi, this message translates to:
  /// **'Báo động I'**
  String get map_legendAlarm1;

  /// No description provided for @map_legendAlarm2.
  ///
  /// In vi, this message translates to:
  /// **'Báo động II'**
  String get map_legendAlarm2;

  /// No description provided for @map_legendAlarm3.
  ///
  /// In vi, this message translates to:
  /// **'Báo động III'**
  String get map_legendAlarm3;

  /// No description provided for @map_legendStale.
  ///
  /// In vi, this message translates to:
  /// **'Mất dữ liệu quá 6 giờ (ghim xám, 1 con cá mờ)'**
  String get map_legendStale;

  /// No description provided for @map_legendSpot.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu cộng đồng'**
  String get map_legendSpot;

  /// No description provided for @map_legendCluster.
  ///
  /// In vi, this message translates to:
  /// **'Vòng có số: nhóm trạm gần nhau, chạm để phóng to. Màu vòng là mức cá ăn cao nhất trong nhóm; có trạm báo động thì là màu báo động.'**
  String get map_legendCluster;

  /// No description provided for @map_legendNote.
  ///
  /// In vi, this message translates to:
  /// **'Trạm biển chưa có ngưỡng báo động; màu báo động dùng cho trạm sông ở giai đoạn sau.'**
  String get map_legendNote;

  /// No description provided for @map_hoangSa.
  ///
  /// In vi, this message translates to:
  /// **'Quần đảo Hoàng Sa (Việt Nam)'**
  String get map_hoangSa;

  /// No description provided for @map_truongSa.
  ///
  /// In vi, this message translates to:
  /// **'Quần đảo Trường Sa (Việt Nam)'**
  String get map_truongSa;

  /// No description provided for @map_close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get map_close;

  /// No description provided for @map_stationsError.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được danh sách trạm'**
  String get map_stationsError;

  /// No description provided for @map_baseMapCredit.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ nền: OpenFreeMap · © OpenMapTiles · dữ liệu © OpenStreetMap'**
  String get map_baseMapCredit;

  /// No description provided for @nav_stations.
  ///
  /// In vi, this message translates to:
  /// **'Trạm'**
  String get nav_stations;

  /// No description provided for @nav_watch.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi'**
  String get nav_watch;

  /// No description provided for @nav_fishing.
  ///
  /// In vi, this message translates to:
  /// **'Câu cá'**
  String get nav_fishing;

  /// No description provided for @nav_more.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get nav_more;

  /// No description provided for @stations_title.
  ///
  /// In vi, this message translates to:
  /// **'Trạm mực nước & triều'**
  String get stations_title;

  /// No description provided for @stations_kindGauge.
  ///
  /// In vi, this message translates to:
  /// **'Có máy đo'**
  String get stations_kindGauge;

  /// No description provided for @stations_kindModel.
  ///
  /// In vi, this message translates to:
  /// **'Mô hình'**
  String get stations_kindModel;

  /// No description provided for @stations_coordApprox.
  ///
  /// In vi, this message translates to:
  /// **'Tọa độ gần đúng'**
  String get stations_coordApprox;

  /// No description provided for @station_tabOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get station_tabOverview;

  /// No description provided for @station_tabHourly.
  ///
  /// In vi, this message translates to:
  /// **'Theo giờ'**
  String get station_tabHourly;

  /// No description provided for @station_tabCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Lịch triều'**
  String get station_tabCalendar;

  /// No description provided for @station_tabInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get station_tabInfo;

  /// No description provided for @level_lastKnown.
  ///
  /// In vi, this message translates to:
  /// **'Số mới nhất lúc {time} · chưa có số cho giờ này'**
  String level_lastKnown(String time);

  /// No description provided for @calendar_prev.
  ///
  /// In vi, this message translates to:
  /// **'Tháng trước'**
  String get calendar_prev;

  /// No description provided for @calendar_next.
  ///
  /// In vi, this message translates to:
  /// **'Tháng sau'**
  String get calendar_next;

  /// No description provided for @calendar_month.
  ///
  /// In vi, this message translates to:
  /// **'Tháng {month}/{year}'**
  String calendar_month(int month, int year);

  /// No description provided for @calendar_noTideDay.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dự báo triều cho ngày này'**
  String get calendar_noTideDay;

  /// No description provided for @calendar_noTideMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này chưa có dự báo triều, vẫn xem được ngày âm và trăng'**
  String get calendar_noTideMonth;

  /// No description provided for @calendar_rangeLegend.
  ///
  /// In vi, this message translates to:
  /// **'Biên độ ngày'**
  String get calendar_rangeLegend;

  /// No description provided for @calendar_lunarLegend.
  ///
  /// In vi, this message translates to:
  /// **'Chữ đỏ: mùng 1, rằm'**
  String get calendar_lunarLegend;

  /// No description provided for @moon_times.
  ///
  /// In vi, this message translates to:
  /// **'Trăng mọc {rise} · lặn {set}'**
  String moon_times(String rise, String set);

  /// No description provided for @moon_alwaysUp.
  ///
  /// In vi, this message translates to:
  /// **'Trăng ở trên trời cả ngày'**
  String get moon_alwaysUp;

  /// No description provided for @moon_alwaysDown.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay trăng không mọc'**
  String get moon_alwaysDown;

  /// No description provided for @solunar_title.
  ///
  /// In vi, this message translates to:
  /// **'Giờ cá ăn theo trăng'**
  String get solunar_title;

  /// No description provided for @solunar_titleGood.
  ///
  /// In vi, this message translates to:
  /// **'Giờ cá ăn theo trăng · ngày tốt (gần trăng tròn/non)'**
  String get solunar_titleGood;

  /// No description provided for @solunar_major.
  ///
  /// In vi, this message translates to:
  /// **'Giờ chính {range}'**
  String solunar_major(String range);

  /// No description provided for @solunar_minor.
  ///
  /// In vi, this message translates to:
  /// **'Giờ phụ {range}'**
  String solunar_minor(String range);

  /// No description provided for @solunar_now.
  ///
  /// In vi, this message translates to:
  /// **'đang diễn ra'**
  String get solunar_now;

  /// No description provided for @summary_title.
  ///
  /// In vi, this message translates to:
  /// **'Lúc này ở đây'**
  String get summary_title;

  /// No description provided for @summary_water.
  ///
  /// In vi, this message translates to:
  /// **'{state}, {extreme} lúc {time} (còn {wait})'**
  String summary_water(String state, String extreme, String time, String wait);

  /// No description provided for @summary_fishing.
  ///
  /// In vi, this message translates to:
  /// **'câu {score}/10 {label}'**
  String summary_fishing(String score, String label);

  /// No description provided for @summary_wind.
  ///
  /// In vi, this message translates to:
  /// **'gió {kmh} km/h'**
  String summary_wind(int kmh);

  /// No description provided for @map_goFishing.
  ///
  /// In vi, this message translates to:
  /// **'Đi câu ngay'**
  String get map_goFishing;

  /// No description provided for @hazard_title.
  ///
  /// In vi, this message translates to:
  /// **'Cần chú ý'**
  String get hazard_title;

  /// No description provided for @hazard_titleSevere.
  ///
  /// In vi, this message translates to:
  /// **'Nguy hiểm — không nên ra sông'**
  String get hazard_titleSevere;

  /// No description provided for @hazard_at.
  ///
  /// In vi, this message translates to:
  /// **'lúc {time}'**
  String hazard_at(String time);

  /// No description provided for @hazard_between.
  ///
  /// In vi, this message translates to:
  /// **'{from}–{to}'**
  String hazard_between(String from, String to);

  /// No description provided for @hazard_thunderstorm.
  ///
  /// In vi, this message translates to:
  /// **'Dông, sét: lên bờ, tránh chỗ trống và cần câu'**
  String get hazard_thunderstorm;

  /// No description provided for @hazard_gust.
  ///
  /// In vi, this message translates to:
  /// **'Gió giật trên 50 km/h: không ra thuyền'**
  String get hazard_gust;

  /// No description provided for @hazard_heavyRain.
  ///
  /// In vi, this message translates to:
  /// **'Mưa to trên 20 mm/giờ'**
  String get hazard_heavyRain;

  /// No description provided for @hazard_possibleStorm.
  ///
  /// In vi, this message translates to:
  /// **'Trời không ổn định, có thể có dông'**
  String get hazard_possibleStorm;

  /// No description provided for @hazard_risingFast.
  ///
  /// In vi, this message translates to:
  /// **'Nước đang lên nhanh bất thường (nhanh hơn hẳn mấy ngày qua): tránh bãi thấp, cồn cát'**
  String get hazard_risingFast;

  /// No description provided for @hazard_flood.
  ///
  /// In vi, this message translates to:
  /// **'Lưu lượng sông ngày mai tăng mạnh (mưa lớn thượng nguồn): nước lên, đục, chảy xiết'**
  String get hazard_flood;

  /// No description provided for @watch_edit.
  ///
  /// In vi, this message translates to:
  /// **'Đặt tên, ghi chú, nhóm'**
  String get watch_edit;

  /// No description provided for @watch_editTitle.
  ///
  /// In vi, this message translates to:
  /// **'Điểm của bạn'**
  String get watch_editTitle;

  /// No description provided for @watch_label.
  ///
  /// In vi, this message translates to:
  /// **'Tên riêng'**
  String get watch_label;

  /// No description provided for @watch_labelHint.
  ///
  /// In vi, this message translates to:
  /// **'vd Hố sâu gốc si'**
  String get watch_labelHint;

  /// No description provided for @watch_note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get watch_note;

  /// No description provided for @watch_noteHint.
  ///
  /// In vi, this message translates to:
  /// **'vd Câu mồi giun, chỗ nước xoáy'**
  String get watch_noteHint;

  /// No description provided for @watch_group.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm'**
  String get watch_group;

  /// No description provided for @watch_groupHint.
  ///
  /// In vi, this message translates to:
  /// **'vd Sông Hồng, Hồ'**
  String get watch_groupHint;

  /// No description provided for @watch_noGroup.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xếp nhóm'**
  String get watch_noGroup;

  /// No description provided for @common_save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get common_cancel;

  /// No description provided for @trip_title.
  ///
  /// In vi, this message translates to:
  /// **'Lên kế hoạch chuyến câu'**
  String get trip_title;

  /// No description provided for @trip_open.
  ///
  /// In vi, this message translates to:
  /// **'Lên kế hoạch'**
  String get trip_open;

  /// No description provided for @trip_noPlaces.
  ///
  /// In vi, this message translates to:
  /// **'Lưu vài điểm câu (bấm ⭐ trên bản đồ) để app tìm buổi câu tốt nhất cho bạn.'**
  String get trip_noPlaces;

  /// No description provided for @trip_intro.
  ///
  /// In vi, this message translates to:
  /// **'Buổi câu tốt nhất 7 ngày tới ở {count} điểm đã lưu, tính theo con nước, trăng, thời tiết của từng điểm.'**
  String trip_intro(int count);

  /// No description provided for @trip_none.
  ///
  /// In vi, this message translates to:
  /// **'7 ngày tới chưa có buổi nào đạt từ 7/10 ở các điểm đã lưu.'**
  String get trip_none;

  /// No description provided for @trip_score.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu cao nhất {score}/10'**
  String trip_score(String score);

  /// No description provided for @trip_because.
  ///
  /// In vi, this message translates to:
  /// **'Tốt nhờ: {reasons}'**
  String trip_because(String reasons);

  /// No description provided for @trip_note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get trip_note;

  /// No description provided for @where_title.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay đi đâu?'**
  String get where_title;

  /// No description provided for @where_short.
  ///
  /// In vi, this message translates to:
  /// **'Đi đâu?'**
  String get where_short;

  /// No description provided for @more_shortcuts.
  ///
  /// In vi, this message translates to:
  /// **'Lối tắt'**
  String get more_shortcuts;

  /// No description provided for @trip_listDetail.
  ///
  /// In vi, this message translates to:
  /// **'Xem và tham gia kèo câu quanh đây'**
  String get trip_listDetail;

  /// No description provided for @trip_createDetail.
  ///
  /// In vi, this message translates to:
  /// **'Hẹn anh em cùng đi câu, có gợi ý giờ vàng'**
  String get trip_createDetail;

  /// No description provided for @checkin_detail.
  ///
  /// In vi, this message translates to:
  /// **'Báo anh em biết bạn đang câu ở đây (ẩn danh, 4 giờ)'**
  String get checkin_detail;

  /// No description provided for @checkin_peopleDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chỗ đang có người câu, ai đang dính cá'**
  String get checkin_peopleDetail;

  /// No description provided for @spot_listDetail.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu anh em đã ghim, có ảnh và bình luận'**
  String get spot_listDetail;

  /// No description provided for @where_entryHint.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu tốt nhất quanh bạn trong 24 giờ tới'**
  String get where_entryHint;

  /// No description provided for @where_radius.
  ///
  /// In vi, this message translates to:
  /// **'Trong vòng'**
  String get where_radius;

  /// No description provided for @where_km.
  ///
  /// In vi, this message translates to:
  /// **'{km} km'**
  String where_km(int km);

  /// No description provided for @where_around.
  ///
  /// In vi, this message translates to:
  /// **'Quanh {place}'**
  String where_around(String place);

  /// No description provided for @where_aroundHere.
  ///
  /// In vi, this message translates to:
  /// **'Quanh chỗ bạn đứng'**
  String get where_aroundHere;

  /// No description provided for @where_aroundLast.
  ///
  /// In vi, this message translates to:
  /// **'Quanh vị trí lần trước của bạn (bấm ◎ để cập nhật)'**
  String get where_aroundLast;

  /// No description provided for @where_needLocation.
  ///
  /// In vi, this message translates to:
  /// **'Cho app biết bạn đang ở đâu để tìm điểm câu gần nhất.'**
  String get where_needLocation;

  /// No description provided for @where_useLocation.
  ///
  /// In vi, this message translates to:
  /// **'Dùng vị trí của tôi'**
  String get where_useLocation;

  /// No description provided for @where_refresh.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật vị trí'**
  String get where_refresh;

  /// No description provided for @where_kindHere.
  ///
  /// In vi, this message translates to:
  /// **'Chỗ bạn đứng'**
  String get where_kindHere;

  /// No description provided for @where_kindStation.
  ///
  /// In vi, this message translates to:
  /// **'Trạm đo'**
  String get where_kindStation;

  /// No description provided for @where_kindSaved.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đã lưu'**
  String get where_kindSaved;

  /// No description provided for @where_kindCommunity.
  ///
  /// In vi, this message translates to:
  /// **'Điểm cộng đồng'**
  String get where_kindCommunity;

  /// No description provided for @where_distance.
  ///
  /// In vi, this message translates to:
  /// **'cách {km} km'**
  String where_distance(String km);

  /// No description provided for @where_golden.
  ///
  /// In vi, this message translates to:
  /// **'Giờ vàng {when}'**
  String where_golden(String when);

  /// No description provided for @where_bestHour.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giờ vàng · giờ khá nhất {when}'**
  String where_bestHour(String when);

  /// No description provided for @where_unsafe.
  ///
  /// In vi, this message translates to:
  /// **'Có cảnh báo thời tiết trong khung giờ này'**
  String get where_unsafe;

  /// No description provided for @where_loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tính điểm câu…'**
  String get where_loading;

  /// No description provided for @where_failed.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được số liệu điểm này'**
  String get where_failed;

  /// No description provided for @where_onMap.
  ///
  /// In vi, this message translates to:
  /// **'Xem bản đồ'**
  String get where_onMap;

  /// No description provided for @where_fishHere.
  ///
  /// In vi, this message translates to:
  /// **'Câu ở đây'**
  String get where_fishHere;

  /// No description provided for @where_rank.
  ///
  /// In vi, this message translates to:
  /// **'Hạng {rank}'**
  String where_rank(int rank);

  /// No description provided for @where_note.
  ///
  /// In vi, this message translates to:
  /// **'Xếp theo điểm câu ước tính (con nước, giờ trăng, ngày/đêm, thời tiết Open-Meteo) trong 24 giờ tới — chỉ để tham khảo. Điểm cộng đồng do người dùng ghim. Tối đa 8 điểm gần nhất.'**
  String get where_note;

  /// No description provided for @where_onlyHere.
  ///
  /// In vi, this message translates to:
  /// **'Trong vòng này chưa có trạm, điểm đã lưu hay điểm cộng đồng nào — chỉ tính được chỗ bạn đứng. Thử vòng lớn hơn.'**
  String get where_onlyHere;

  /// No description provided for @habit_title.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen câu của bạn'**
  String get habit_title;

  /// No description provided for @habit_needMore.
  ///
  /// In vi, this message translates to:
  /// **'Ghi thêm {count} mẻ cá nữa để app tìm ra lúc bạn hay trúng.'**
  String habit_needMore(int count);

  /// No description provided for @habit_progress.
  ///
  /// In vi, this message translates to:
  /// **'{have}/{need} mẻ'**
  String habit_progress(int have, int need);

  /// No description provided for @habit_none.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thấy điều kiện nào nổi bật trong {count} mẻ cá. Cứ ghi tiếp nhé.'**
  String habit_none(int count);

  /// No description provided for @habit_hits.
  ///
  /// In vi, this message translates to:
  /// **'{hits}/{known} mẻ'**
  String habit_hits(int hits, int known);

  /// No description provided for @habit_note.
  ///
  /// In vi, this message translates to:
  /// **'Đếm từ nhật ký trên máy bạn, không phải quy luật chắc chắn. Bạn hay đi câu giờ nào thì giờ đó sẽ nhiều mẻ hơn.'**
  String get habit_note;

  /// No description provided for @habit_match.
  ///
  /// In vi, this message translates to:
  /// **'Giống những lần bạn trúng'**
  String get habit_match;

  /// No description provided for @habit_dawn.
  ///
  /// In vi, this message translates to:
  /// **'Lúc bình minh'**
  String get habit_dawn;

  /// No description provided for @habit_morning.
  ///
  /// In vi, this message translates to:
  /// **'Buổi sáng'**
  String get habit_morning;

  /// No description provided for @habit_midday.
  ///
  /// In vi, this message translates to:
  /// **'Buổi trưa'**
  String get habit_midday;

  /// No description provided for @habit_afternoon.
  ///
  /// In vi, this message translates to:
  /// **'Buổi chiều'**
  String get habit_afternoon;

  /// No description provided for @habit_dusk.
  ///
  /// In vi, this message translates to:
  /// **'Lúc hoàng hôn'**
  String get habit_dusk;

  /// No description provided for @habit_night.
  ///
  /// In vi, this message translates to:
  /// **'Ban đêm'**
  String get habit_night;

  /// No description provided for @habit_rising.
  ///
  /// In vi, this message translates to:
  /// **'Khi nước đang lên'**
  String get habit_rising;

  /// No description provided for @habit_falling.
  ///
  /// In vi, this message translates to:
  /// **'Khi nước đang rút'**
  String get habit_falling;

  /// No description provided for @habit_slack.
  ///
  /// In vi, this message translates to:
  /// **'Lúc nước đứng (đổi con nước)'**
  String get habit_slack;

  /// No description provided for @habit_newMoon.
  ///
  /// In vi, this message translates to:
  /// **'Quanh ngày không trăng (cuối/đầu tháng âm)'**
  String get habit_newMoon;

  /// No description provided for @habit_fullMoon.
  ///
  /// In vi, this message translates to:
  /// **'Quanh ngày trăng tròn (rằm)'**
  String get habit_fullMoon;

  /// No description provided for @habit_quarter.
  ///
  /// In vi, this message translates to:
  /// **'Ngày trăng nửa vành'**
  String get habit_quarter;

  /// No description provided for @habit_major.
  ///
  /// In vi, this message translates to:
  /// **'Trong giờ trăng chính'**
  String get habit_major;

  /// No description provided for @habit_minor.
  ///
  /// In vi, this message translates to:
  /// **'Trong giờ trăng phụ'**
  String get habit_minor;

  /// No description provided for @habit_noSolunar.
  ///
  /// In vi, this message translates to:
  /// **'Ngoài giờ trăng'**
  String get habit_noSolunar;

  /// No description provided for @habit_calm.
  ///
  /// In vi, this message translates to:
  /// **'Khi lặng gió (dưới 10 km/h)'**
  String get habit_calm;

  /// No description provided for @habit_light.
  ///
  /// In vi, this message translates to:
  /// **'Khi gió nhẹ (10–20 km/h)'**
  String get habit_light;

  /// No description provided for @habit_strong.
  ///
  /// In vi, this message translates to:
  /// **'Khi gió mạnh (trên 20 km/h)'**
  String get habit_strong;

  /// No description provided for @journal_title.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký câu'**
  String get journal_title;

  /// No description provided for @journal_open.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký'**
  String get journal_open;

  /// No description provided for @journal_add.
  ///
  /// In vi, this message translates to:
  /// **'Ghi mẻ cá'**
  String get journal_add;

  /// No description provided for @journal_empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mẻ cá nào. Bấm \"Ghi mẻ cá\" sau mỗi lần câu được: app tự lưu mực nước, con nước, thời tiết và trăng lúc đó.'**
  String get journal_empty;

  /// No description provided for @journal_place.
  ///
  /// In vi, this message translates to:
  /// **'Tại: {name}'**
  String journal_place(String name);

  /// No description provided for @journal_placeHint.
  ///
  /// In vi, this message translates to:
  /// **'Là điểm đang chọn ở tab Câu cá. Đổi điểm ở đó nếu cần.'**
  String get journal_placeHint;

  /// No description provided for @journal_changeTime.
  ///
  /// In vi, this message translates to:
  /// **'Đổi giờ'**
  String get journal_changeTime;

  /// No description provided for @journal_species.
  ///
  /// In vi, this message translates to:
  /// **'Loại cá'**
  String get journal_species;

  /// No description provided for @journal_weight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng (kg)'**
  String get journal_weight;

  /// No description provided for @journal_length.
  ///
  /// In vi, this message translates to:
  /// **'Dài (cm)'**
  String get journal_length;

  /// No description provided for @journal_bait.
  ///
  /// In vi, this message translates to:
  /// **'Mồi'**
  String get journal_bait;

  /// No description provided for @journal_note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get journal_note;

  /// No description provided for @journal_camera.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get journal_camera;

  /// No description provided for @journal_gallery.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh'**
  String get journal_gallery;

  /// No description provided for @journal_removePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ ảnh'**
  String get journal_removePhoto;

  /// No description provided for @journal_photoError.
  ///
  /// In vi, this message translates to:
  /// **'Không đọc được ảnh này'**
  String get journal_photoError;

  /// No description provided for @journal_needSpecies.
  ///
  /// In vi, this message translates to:
  /// **'Nhập loại cá'**
  String get journal_needSpecies;

  /// No description provided for @journal_privacy.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký và ảnh chỉ lưu trên máy này. Ảnh được bỏ thông tin vị trí GPS.'**
  String get journal_privacy;

  /// No description provided for @journal_statsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn câu thế nào'**
  String get journal_statsTitle;

  /// No description provided for @journal_statsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} mẻ · tổng {kg} kg'**
  String journal_statsCount(int count, String kg);

  /// No description provided for @journal_statsTop.
  ///
  /// In vi, this message translates to:
  /// **'Hay câu được nhất: {species} ({count} lần)'**
  String journal_statsTop(String species, int count);

  /// No description provided for @journal_statsRising.
  ///
  /// In vi, this message translates to:
  /// **'{pct}% số mẻ câu được lúc nước đang lên'**
  String journal_statsRising(int pct);

  /// No description provided for @journal_statsFalling.
  ///
  /// In vi, this message translates to:
  /// **'{pct}% số mẻ câu được lúc nước đang xuống'**
  String journal_statsFalling(int pct);

  /// No description provided for @journal_water.
  ///
  /// In vi, this message translates to:
  /// **'nước {state}'**
  String journal_water(String state);

  /// No description provided for @journal_conditions.
  ///
  /// In vi, this message translates to:
  /// **'Điều kiện lúc câu'**
  String get journal_conditions;

  /// No description provided for @journal_weightValue.
  ///
  /// In vi, this message translates to:
  /// **'Nặng {kg} kg'**
  String journal_weightValue(String kg);

  /// No description provided for @journal_lengthValue.
  ///
  /// In vi, this message translates to:
  /// **'Dài {cm} cm'**
  String journal_lengthValue(int cm);

  /// No description provided for @journal_baitValue.
  ///
  /// In vi, this message translates to:
  /// **'Mồi: {bait}'**
  String journal_baitValue(String bait);

  /// No description provided for @journal_levelValue.
  ///
  /// In vi, this message translates to:
  /// **'Mực nước {level}'**
  String journal_levelValue(String level);

  /// No description provided for @journal_scoreValue.
  ///
  /// In vi, this message translates to:
  /// **'điểm câu {score}/10'**
  String journal_scoreValue(String score);

  /// No description provided for @journal_delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get journal_delete;

  /// No description provided for @journal_deleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa mẻ cá này khỏi nhật ký?'**
  String get journal_deleteTitle;

  /// No description provided for @place_city.
  ///
  /// In vi, this message translates to:
  /// **'Thành phố, thị xã'**
  String get place_city;

  /// No description provided for @place_ward.
  ///
  /// In vi, this message translates to:
  /// **'Khu dân cư, làng'**
  String get place_ward;

  /// No description provided for @place_bridge.
  ///
  /// In vi, this message translates to:
  /// **'Cầu'**
  String get place_bridge;

  /// No description provided for @place_ferry.
  ///
  /// In vi, this message translates to:
  /// **'Bến phà'**
  String get place_ferry;

  /// No description provided for @place_wharf.
  ///
  /// In vi, this message translates to:
  /// **'Bến'**
  String get place_wharf;

  /// No description provided for @place_near.
  ///
  /// In vi, this message translates to:
  /// **'{kind} · gần {town}'**
  String place_near(String kind, String town);

  /// No description provided for @share_action.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get share_action;

  /// No description provided for @share_text.
  ///
  /// In vi, this message translates to:
  /// **'Con Nước · {place}'**
  String share_text(String place);

  /// No description provided for @share_level.
  ///
  /// In vi, this message translates to:
  /// **'Mực nước {level}'**
  String share_level(String level);

  /// No description provided for @share_score.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu {score}/10'**
  String share_score(String score);

  /// No description provided for @share_copied.
  ///
  /// In vi, this message translates to:
  /// **'Đã chép nội dung và đường link, dán vào Zalo/Facebook để gửi'**
  String get share_copied;

  /// No description provided for @share_footer.
  ///
  /// In vi, this message translates to:
  /// **'Số liệu tính toán, chỉ để tham khảo · Con Nước'**
  String get share_footer;

  /// No description provided for @more_outdoor.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ ngoài trời'**
  String get more_outdoor;

  /// No description provided for @more_outdoorHint.
  ///
  /// In vi, this message translates to:
  /// **'Tương phản cao, chữ to hơn: đọc rõ dưới nắng gắt'**
  String get more_outdoorHint;

  /// No description provided for @map_legendFlowRising.
  ///
  /// In vi, this message translates to:
  /// **'Đoạn sông nước đang lên'**
  String get map_legendFlowRising;

  /// No description provided for @map_legendFlowFalling.
  ///
  /// In vi, this message translates to:
  /// **'Đoạn sông nước đang rút'**
  String get map_legendFlowFalling;

  /// No description provided for @map_legendFlowSlack.
  ///
  /// In vi, this message translates to:
  /// **'Đoạn sông nước đứng'**
  String get map_legendFlowSlack;

  /// No description provided for @map_legendFlowNote.
  ///
  /// In vi, this message translates to:
  /// **'Màu đoạn sông tính cho từng đoạn (con nước đến mỗi đoạn một giờ khác nhau), cập nhật 10 phút/lần. Vệt chạy chỉ hướng dòng sông ra biển.'**
  String get map_legendFlowNote;

  /// No description provided for @map_layerWeather.
  ///
  /// In vi, this message translates to:
  /// **'Mưa và gió quanh đây'**
  String get map_layerWeather;

  /// No description provided for @map_layerWeatherHint.
  ///
  /// In vi, this message translates to:
  /// **'Chấm xanh: mưa 1 giờ tới (càng to càng nhiều). Mũi tên: hướng gió thổi tới. Phóng to vùng muốn xem.'**
  String get map_layerWeatherHint;

  /// No description provided for @hazard_surge.
  ///
  /// In vi, this message translates to:
  /// **'Nước biển đang cao hơn thủy triều thường {cm} cm (gió mạnh hoặc bão đẩy nước vào): bãi thấp, cửa sông dễ ngập'**
  String hazard_surge(int cm);

  /// No description provided for @more_install.
  ///
  /// In vi, this message translates to:
  /// **'Cài Con Nước lên màn hình chính'**
  String get more_install;

  /// No description provided for @more_installHow.
  ///
  /// In vi, this message translates to:
  /// **'Android (Chrome): bấm ⋮ rồi chọn Cài đặt ứng dụng. iPhone (Safari): bấm nút Chia sẻ rồi chọn Thêm vào MH chính. App mở nhanh như app thật, không cần cửa hàng.'**
  String get more_installHow;

  /// No description provided for @alert_channel.
  ///
  /// In vi, this message translates to:
  /// **'Báo thức con nước'**
  String get alert_channel;

  /// No description provided for @alert_channelHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc trước giờ đỉnh, chân triều và giờ câu đẹp ở điểm đã lưu'**
  String get alert_channelHint;

  /// No description provided for @alert_highTitle.
  ///
  /// In vi, this message translates to:
  /// **'{place}: đỉnh triều {time}'**
  String alert_highTitle(String place, String time);

  /// No description provided for @alert_lowTitle.
  ///
  /// In vi, this message translates to:
  /// **'{place}: chân triều {time}'**
  String alert_lowTitle(String place, String time);

  /// No description provided for @alert_levelBody.
  ///
  /// In vi, this message translates to:
  /// **'Mực nước khoảng {level}, còn {minutes} phút'**
  String alert_levelBody(String level, int minutes);

  /// No description provided for @alert_fishTitle.
  ///
  /// In vi, this message translates to:
  /// **'{place}: giờ câu đẹp {from}–{to}'**
  String alert_fishTitle(String place, String from, String to);

  /// No description provided for @alert_fishBody.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu {score}/10, bắt đầu sau {minutes} phút'**
  String alert_fishBody(String score, int minutes);

  /// No description provided for @alert_toggleOn.
  ///
  /// In vi, this message translates to:
  /// **'Bật báo thức con nước'**
  String get alert_toggleOn;

  /// No description provided for @alert_toggleOff.
  ///
  /// In vi, this message translates to:
  /// **'Tắt báo thức con nước'**
  String get alert_toggleOff;

  /// No description provided for @alert_onSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã bật báo thức cho điểm này. Chỉnh loại báo và báo trước bao lâu ở nút ⚙ trên cùng.'**
  String get alert_onSnack;

  /// No description provided for @alert_fishBodyLike.
  ///
  /// In vi, this message translates to:
  /// **'✨ Giống những lần bạn trúng · điểm câu {score}/10, bắt đầu sau {minutes} phút'**
  String alert_fishBodyLike(String score, int minutes);

  /// No description provided for @alert_settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt báo thức'**
  String get alert_settings;

  /// No description provided for @alert_golden.
  ///
  /// In vi, this message translates to:
  /// **'Báo trước giờ vàng'**
  String get alert_golden;

  /// No description provided for @alert_goldenHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ báo khi khung giờ đó không có cảnh báo dông, gió giật, mưa to'**
  String get alert_goldenHint;

  /// No description provided for @alert_tides.
  ///
  /// In vi, this message translates to:
  /// **'Báo trước đỉnh triều / chân triều'**
  String get alert_tides;

  /// No description provided for @alert_lead.
  ///
  /// In vi, this message translates to:
  /// **'Báo trước'**
  String get alert_lead;

  /// No description provided for @alert_leadMin.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String alert_leadMin(int minutes);

  /// No description provided for @alert_howTo.
  ///
  /// In vi, this message translates to:
  /// **'Bật chuông ở từng điểm trong danh sách Theo dõi. App tính lại lịch báo mỗi lần mở (7 ngày tới).'**
  String get alert_howTo;

  /// No description provided for @alert_getApk.
  ///
  /// In vi, this message translates to:
  /// **'Tải app Android'**
  String get alert_getApk;

  /// No description provided for @alert_denied.
  ///
  /// In vi, this message translates to:
  /// **'Chưa được phép gửi thông báo. Bật trong Cài đặt > Ứng dụng > Con Nước > Thông báo.'**
  String get alert_denied;

  /// No description provided for @alert_webOnly.
  ///
  /// In vi, this message translates to:
  /// **'Báo thức chỉ có trên app Android (trình duyệt không kêu được khi đóng)'**
  String get alert_webOnly;

  /// No description provided for @more_apk.
  ///
  /// In vi, this message translates to:
  /// **'Tải app Android (APK)'**
  String get more_apk;

  /// No description provided for @more_apkHint.
  ///
  /// In vi, this message translates to:
  /// **'Có thêm báo thức con nước và widget màn hình chính. Mở file sau khi tải, cho phép cài từ nguồn này.'**
  String get more_apkHint;

  /// No description provided for @directions_action.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ đường'**
  String get directions_action;

  /// No description provided for @directions_failed.
  ///
  /// In vi, this message translates to:
  /// **'Không mở được Google Maps trên máy này'**
  String get directions_failed;

  /// No description provided for @search_recent.
  ///
  /// In vi, this message translates to:
  /// **'Tìm gần đây'**
  String get search_recent;

  /// No description provided for @place_province.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh, thành phố'**
  String get place_province;

  /// No description provided for @place_commune.
  ///
  /// In vi, this message translates to:
  /// **'Phường, xã'**
  String get place_commune;

  /// No description provided for @search_coordsHint.
  ///
  /// In vi, this message translates to:
  /// **'Mở mực nước, giờ câu tại tọa độ này'**
  String get search_coordsHint;

  /// No description provided for @place_in.
  ///
  /// In vi, this message translates to:
  /// **'{kind} · {area}'**
  String place_in(String kind, String area);

  /// No description provided for @search_coords.
  ///
  /// In vi, this message translates to:
  /// **'Tọa độ {coords}'**
  String search_coords(String coords);

  /// No description provided for @spot_edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get spot_edit;

  /// No description provided for @spot_editTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sửa điểm câu'**
  String get spot_editTitle;

  /// No description provided for @spot_save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get spot_save;

  /// No description provided for @spot_editSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu thay đổi'**
  String get spot_editSaved;

  /// No description provided for @spot_edited.
  ///
  /// In vi, this message translates to:
  /// **'sửa {date}'**
  String spot_edited(String date);

  /// No description provided for @spot_tooMany.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay máy này đã đăng đủ 10 điểm. Mai đăng tiếp nhé.'**
  String get spot_tooMany;

  /// No description provided for @spot_comments.
  ///
  /// In vi, this message translates to:
  /// **'{count} bình luận'**
  String spot_comments(int count);

  /// No description provided for @cmt_title.
  ///
  /// In vi, this message translates to:
  /// **'Bình luận'**
  String get cmt_title;

  /// No description provided for @cmt_count.
  ///
  /// In vi, this message translates to:
  /// **'Bình luận ({count})'**
  String cmt_count(int count);

  /// No description provided for @cmt_hint.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ mồi, giờ cá ăn, đường vào…'**
  String get cmt_hint;

  /// No description provided for @cmt_send.
  ///
  /// In vi, this message translates to:
  /// **'Gửi bình luận'**
  String get cmt_send;

  /// No description provided for @cmt_empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bình luận nào. Hãy là người đầu tiên!'**
  String get cmt_empty;

  /// No description provided for @cmt_anon.
  ///
  /// In vi, this message translates to:
  /// **'Người câu ẩn danh'**
  String get cmt_anon;

  /// No description provided for @cmt_asName.
  ///
  /// In vi, this message translates to:
  /// **'Bình luận với tên {name} · đổi'**
  String cmt_asName(String name);

  /// No description provided for @cmt_asAnon.
  ///
  /// In vi, this message translates to:
  /// **'Đang ẩn danh · đặt tên hiển thị'**
  String get cmt_asAnon;

  /// No description provided for @cmt_edited.
  ///
  /// In vi, this message translates to:
  /// **'đã sửa'**
  String get cmt_edited;

  /// No description provided for @cmt_mine.
  ///
  /// In vi, this message translates to:
  /// **'của bạn'**
  String get cmt_mine;

  /// No description provided for @cmt_more.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get cmt_more;

  /// No description provided for @cmt_edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa bình luận'**
  String get cmt_edit;

  /// No description provided for @cmt_delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get cmt_delete;

  /// No description provided for @cmt_report.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get cmt_report;

  /// No description provided for @cmt_deleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bình luận của bạn?'**
  String get cmt_deleteTitle;

  /// No description provided for @cmt_reportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo bình luận này?'**
  String get cmt_reportTitle;

  /// No description provided for @cmt_reportHint.
  ///
  /// In vi, this message translates to:
  /// **'Nói tục, lừa đảo, quảng cáo… Bình luận bị 3 người báo cáo sẽ tự ẩn.'**
  String get cmt_reportHint;

  /// No description provided for @cmt_error.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được, kiểm tra mạng rồi thử lại'**
  String get cmt_error;

  /// No description provided for @cmt_tooFast.
  ///
  /// In vi, this message translates to:
  /// **'Bạn gửi hơi nhanh — đợi chút rồi gửi tiếp nhé'**
  String get cmt_tooFast;

  /// No description provided for @cmt_loadError.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được bình luận'**
  String get cmt_loadError;

  /// No description provided for @name_title.
  ///
  /// In vi, this message translates to:
  /// **'Tên hiển thị'**
  String get name_title;

  /// No description provided for @name_hint.
  ///
  /// In vi, this message translates to:
  /// **'vd Khánh Cần Thủ'**
  String get name_hint;

  /// No description provided for @name_note.
  ///
  /// In vi, this message translates to:
  /// **'Hiện trên bình luận, kèo câu và tin nhắn. Để trống = ẩn danh.'**
  String get name_note;

  /// No description provided for @social_save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get social_save;

  /// No description provided for @nav_ponds.
  ///
  /// In vi, this message translates to:
  /// **'Hồ câu'**
  String get nav_ponds;

  /// No description provided for @pond_title.
  ///
  /// In vi, this message translates to:
  /// **'Hồ câu'**
  String get pond_title;

  /// No description provided for @pond_tag.
  ///
  /// In vi, this message translates to:
  /// **'Hồ câu dịch vụ'**
  String get pond_tag;

  /// No description provided for @pond_add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hồ'**
  String get pond_add;

  /// No description provided for @pond_addTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hồ câu'**
  String get pond_addTitle;

  /// No description provided for @pond_addHere.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hồ câu ở đây'**
  String get pond_addHere;

  /// No description provided for @pond_pill.
  ///
  /// In vi, this message translates to:
  /// **'{count} hồ câu'**
  String pond_pill(int count);

  /// No description provided for @pond_pillSoon.
  ///
  /// In vi, this message translates to:
  /// **'{count} hồ sắp xả'**
  String pond_pillSoon(int count);

  /// No description provided for @pond_pillDetail.
  ///
  /// In vi, this message translates to:
  /// **'Hồ câu dịch vụ quanh đây, lịch xả cá'**
  String get pond_pillDetail;

  /// No description provided for @pond_editTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sửa thông tin hồ'**
  String get pond_editTitle;

  /// No description provided for @pond_empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có hồ câu nào trong vòng 40 km. Biết hồ nào? Bấm \"Thêm hồ\" để anh em cùng biết.'**
  String get pond_empty;

  /// No description provided for @pond_loadError.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được danh sách hồ'**
  String get pond_loadError;

  /// No description provided for @pond_filterRelease.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xả cá'**
  String get pond_filterRelease;

  /// No description provided for @pond_filterVerified.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác minh'**
  String get pond_filterVerified;

  /// No description provided for @pond_filterFollowed.
  ///
  /// In vi, this message translates to:
  /// **'Đang theo dõi'**
  String get pond_filterFollowed;

  /// No description provided for @pond_followedSoon.
  ///
  /// In vi, this message translates to:
  /// **'Hồ bạn theo dõi sắp xả'**
  String get pond_followedSoon;

  /// No description provided for @pond_verified.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác minh'**
  String get pond_verified;

  /// No description provided for @pond_owner.
  ///
  /// In vi, this message translates to:
  /// **'Chủ hồ đã nhận'**
  String get pond_owner;

  /// No description provided for @pond_unverified.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác minh'**
  String get pond_unverified;

  /// No description provided for @pond_fromWeb.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin gom từ web, có thể đã cũ. Tới nơi thấy đúng thì bấm \"Hồ có thật\" giúp anh em.'**
  String get pond_fromWeb;

  /// No description provided for @pond_approx.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí gần đúng theo địa chỉ. Ai ở gần bấm \"Sửa\" để chỉnh ghim.'**
  String get pond_approx;

  /// No description provided for @pond_distance.
  ///
  /// In vi, this message translates to:
  /// **'cách {km}'**
  String pond_distance(String km);

  /// No description provided for @pond_rating.
  ///
  /// In vi, this message translates to:
  /// **'{rating} ★ ({count})'**
  String pond_rating(String rating, int count);

  /// No description provided for @pond_noRating.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá'**
  String get pond_noRating;

  /// No description provided for @pond_releaseChip.
  ///
  /// In vi, this message translates to:
  /// **'Xả {when}'**
  String pond_releaseChip(String when);

  /// No description provided for @pond_releaseKg.
  ///
  /// In vi, this message translates to:
  /// **'{when} · {amount}'**
  String pond_releaseKg(String when, String amount);

  /// No description provided for @pond_kg.
  ///
  /// In vi, this message translates to:
  /// **'{kg} kg'**
  String pond_kg(String kg);

  /// No description provided for @pond_ta.
  ///
  /// In vi, this message translates to:
  /// **'{ta} tạ'**
  String pond_ta(String ta);

  /// No description provided for @pond_ton.
  ///
  /// In vi, this message translates to:
  /// **'{ton} tấn'**
  String pond_ton(String ton);

  /// No description provided for @pond_releases.
  ///
  /// In vi, this message translates to:
  /// **'Lịch xả cá'**
  String get pond_releases;

  /// No description provided for @pond_noRelease.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lịch xả sắp tới.'**
  String get pond_noRelease;

  /// No description provided for @pond_official.
  ///
  /// In vi, this message translates to:
  /// **'Chủ hồ đăng'**
  String get pond_official;

  /// No description provided for @pond_relayed.
  ///
  /// In vi, this message translates to:
  /// **'Người dùng báo · chưa xác nhận'**
  String get pond_relayed;

  /// No description provided for @pond_releasePast.
  ///
  /// In vi, this message translates to:
  /// **'Đã xả'**
  String get pond_releasePast;

  /// No description provided for @pond_releaseCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get pond_releaseCancelled;

  /// No description provided for @pond_postRelease.
  ///
  /// In vi, this message translates to:
  /// **'Báo lịch xả cá'**
  String get pond_postRelease;

  /// No description provided for @pond_showSource.
  ///
  /// In vi, this message translates to:
  /// **'Xem bài gốc'**
  String get pond_showSource;

  /// No description provided for @pond_cancelRelease.
  ///
  /// In vi, this message translates to:
  /// **'Hủy lịch này'**
  String get pond_cancelRelease;

  /// No description provided for @pond_reportRelease.
  ///
  /// In vi, this message translates to:
  /// **'Báo sai'**
  String get pond_reportRelease;

  /// No description provided for @pond_follow.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi'**
  String get pond_follow;

  /// No description provided for @pond_following.
  ///
  /// In vi, this message translates to:
  /// **'Đang theo dõi'**
  String get pond_following;

  /// No description provided for @pond_followHint.
  ///
  /// In vi, this message translates to:
  /// **'Có lịch xả mới ở hồ này sẽ hiện đầu danh sách (app Android có chuông báo).'**
  String get pond_followHint;

  /// No description provided for @pond_call.
  ///
  /// In vi, this message translates to:
  /// **'Gọi'**
  String get pond_call;

  /// No description provided for @pond_price.
  ///
  /// In vi, this message translates to:
  /// **'Giá vé'**
  String get pond_price;

  /// No description provided for @pond_hours.
  ///
  /// In vi, this message translates to:
  /// **'Giờ mở'**
  String get pond_hours;

  /// No description provided for @pond_species.
  ///
  /// In vi, this message translates to:
  /// **'Cá trong hồ'**
  String get pond_species;

  /// No description provided for @pond_note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get pond_note;

  /// No description provided for @pond_sources.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn'**
  String get pond_sources;

  /// No description provided for @pond_pulseTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lúc này ở hồ (6 giờ qua)'**
  String get pond_pulseTitle;

  /// No description provided for @pond_pulseBusy.
  ///
  /// In vi, this message translates to:
  /// **'Đông'**
  String get pond_pulseBusy;

  /// No description provided for @pond_pulseQuiet.
  ///
  /// In vi, this message translates to:
  /// **'Vắng'**
  String get pond_pulseQuiet;

  /// No description provided for @pond_pulseBiting.
  ///
  /// In vi, this message translates to:
  /// **'Cá ăn'**
  String get pond_pulseBiting;

  /// No description provided for @pond_pulseReleased.
  ///
  /// In vi, this message translates to:
  /// **'Vừa xả'**
  String get pond_pulseReleased;

  /// No description provided for @pond_pulseCount.
  ///
  /// In vi, this message translates to:
  /// **'{label} · {count}'**
  String pond_pulseCount(String label, int count);

  /// No description provided for @pond_pulseSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi. Cảm ơn bạn!'**
  String get pond_pulseSent;

  /// No description provided for @pond_pulseWait.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi 30 phút báo 1 lần thôi nhé'**
  String get pond_pulseWait;

  /// No description provided for @pond_confirm.
  ///
  /// In vi, this message translates to:
  /// **'Hồ có thật'**
  String get pond_confirm;

  /// No description provided for @pond_confirmed.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã xác nhận'**
  String get pond_confirmed;

  /// No description provided for @pond_confirmDone.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn! Đủ 3 người xác nhận hồ sẽ có dấu ✓'**
  String get pond_confirmDone;

  /// No description provided for @pond_edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get pond_edit;

  /// No description provided for @pond_claim.
  ///
  /// In vi, this message translates to:
  /// **'Tôi là chủ hồ'**
  String get pond_claim;

  /// No description provided for @pond_claimTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhận quản lý hồ'**
  String get pond_claimTitle;

  /// No description provided for @pond_claimBody.
  ///
  /// In vi, this message translates to:
  /// **'Để tránh mạo danh, quản trị viên sẽ gọi hoặc nhắn Zalo cho bạn để xác nhận. Duyệt xong, bạn tự đăng lịch xả \"chính thức\", sửa giá vé, giờ mở.'**
  String get pond_claimBody;

  /// No description provided for @pond_claimContact.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại / Zalo của hồ'**
  String get pond_claimContact;

  /// No description provided for @pond_claimNote.
  ///
  /// In vi, this message translates to:
  /// **'Lời nhắn (không bắt buộc)'**
  String get pond_claimNote;

  /// No description provided for @pond_claimSend.
  ///
  /// In vi, this message translates to:
  /// **'Gửi yêu cầu'**
  String get pond_claimSend;

  /// No description provided for @pond_claimSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi! Quản trị viên sẽ liên hệ bạn sớm.'**
  String get pond_claimSent;

  /// No description provided for @pond_claimPending.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu của bạn đang chờ duyệt.'**
  String get pond_claimPending;

  /// No description provided for @pond_claimOwned.
  ///
  /// In vi, this message translates to:
  /// **'Hồ này đã có chủ quản lý.'**
  String get pond_claimOwned;

  /// No description provided for @pond_claimYours.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang là chủ hồ này.'**
  String get pond_claimYours;

  /// No description provided for @pond_report.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get pond_report;

  /// No description provided for @pond_reportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo hồ này?'**
  String get pond_reportTitle;

  /// No description provided for @pond_reportHint.
  ///
  /// In vi, this message translates to:
  /// **'Hồ không có thật, đã đóng cửa, sai chỗ… 3 người báo cáo thì hồ chưa có chủ sẽ tự ẩn.'**
  String get pond_reportHint;

  /// No description provided for @pond_error.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được, kiểm tra mạng rồi thử lại'**
  String get pond_error;

  /// No description provided for @pond_tooMany.
  ///
  /// In vi, this message translates to:
  /// **'Bạn thao tác hơi nhiều hôm nay, mai thử lại nhé'**
  String get pond_tooMany;

  /// No description provided for @pond_duplicate.
  ///
  /// In vi, this message translates to:
  /// **'Chỗ này đã có hồ trong danh sách. Mở hồ đó?'**
  String get pond_duplicate;

  /// No description provided for @pond_open.
  ///
  /// In vi, this message translates to:
  /// **'Mở'**
  String get pond_open;

  /// No description provided for @pond_name.
  ///
  /// In vi, this message translates to:
  /// **'Tên hồ'**
  String get pond_name;

  /// No description provided for @pond_nameHint.
  ///
  /// In vi, this message translates to:
  /// **'vd Hồ câu Thanh Hà'**
  String get pond_nameHint;

  /// No description provided for @pond_address.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ'**
  String get pond_address;

  /// No description provided for @pond_phone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại / Zalo'**
  String get pond_phone;

  /// No description provided for @pond_priceHint.
  ///
  /// In vi, this message translates to:
  /// **'vd 200k/ca 4 tiếng, 350k/ngày'**
  String get pond_priceHint;

  /// No description provided for @pond_hoursHint.
  ///
  /// In vi, this message translates to:
  /// **'vd 6h–18h, nghỉ thứ 2'**
  String get pond_hoursHint;

  /// No description provided for @pond_location.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí ghim: {coords}'**
  String pond_location(String coords);

  /// No description provided for @pond_locationHint.
  ///
  /// In vi, this message translates to:
  /// **'Ghim đặt ở chỗ bạn chọn trên bản đồ. Muốn đổi: chạm đúng hồ trên bản đồ → Thêm hồ.'**
  String get pond_locationHint;

  /// No description provided for @pond_save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get pond_save;

  /// No description provided for @pond_added.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm hồ! Cảm ơn bạn.'**
  String get pond_added;

  /// No description provided for @pond_saved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu'**
  String get pond_saved;

  /// No description provided for @pond_needName.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên hồ (từ 2 ký tự)'**
  String get pond_needName;

  /// No description provided for @pond_reviews.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá'**
  String get pond_reviews;

  /// No description provided for @pond_writeReview.
  ///
  /// In vi, this message translates to:
  /// **'Viết đánh giá'**
  String get pond_writeReview;

  /// No description provided for @pond_reviewHint.
  ///
  /// In vi, this message translates to:
  /// **'Cá có ăn không, giá, dịch vụ, chỗ ngồi…'**
  String get pond_reviewHint;

  /// No description provided for @pond_reviewSend.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đánh giá'**
  String get pond_reviewSend;

  /// No description provided for @pond_reviewEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá nào.'**
  String get pond_reviewEmpty;

  /// No description provided for @pond_deleteReview.
  ///
  /// In vi, this message translates to:
  /// **'Xóa đánh giá của tôi'**
  String get pond_deleteReview;

  /// No description provided for @pond_noStars.
  ///
  /// In vi, this message translates to:
  /// **'Chọn số sao'**
  String get pond_noStars;

  /// No description provided for @release_title.
  ///
  /// In vi, this message translates to:
  /// **'Báo lịch xả cá'**
  String get release_title;

  /// No description provided for @release_paste.
  ///
  /// In vi, this message translates to:
  /// **'Dán bài đăng của hồ'**
  String get release_paste;

  /// No description provided for @release_pasteHint.
  ///
  /// In vi, this message translates to:
  /// **'Copy bài Facebook / chú thích TikTok của hồ rồi dán vào đây. App tự đọc ngày, giờ, loại cá, số lượng.'**
  String get release_pasteHint;

  /// No description provided for @release_pasteButton.
  ///
  /// In vi, this message translates to:
  /// **'Dán'**
  String get release_pasteButton;

  /// No description provided for @release_read.
  ///
  /// In vi, this message translates to:
  /// **'App đọc được'**
  String get release_read;

  /// No description provided for @release_notFound.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thấy ngày xả trong bài. Chọn ngày bên dưới.'**
  String get release_notFound;

  /// No description provided for @release_day.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get release_day;

  /// No description provided for @release_time.
  ///
  /// In vi, this message translates to:
  /// **'Giờ'**
  String get release_time;

  /// No description provided for @release_fish.
  ///
  /// In vi, this message translates to:
  /// **'Cá xả'**
  String get release_fish;

  /// No description provided for @release_addFish.
  ///
  /// In vi, this message translates to:
  /// **'Thêm loại cá'**
  String get release_addFish;

  /// No description provided for @release_fishName.
  ///
  /// In vi, this message translates to:
  /// **'Loại cá'**
  String get release_fishName;

  /// No description provided for @release_fishKg.
  ///
  /// In vi, this message translates to:
  /// **'kg'**
  String get release_fishKg;

  /// No description provided for @release_total.
  ///
  /// In vi, this message translates to:
  /// **'Tổng {amount}'**
  String release_total(String amount);

  /// No description provided for @release_asOwner.
  ///
  /// In vi, this message translates to:
  /// **'Bạn là chủ hồ: lịch này hiện là \"Chủ hồ đăng\".'**
  String get release_asOwner;

  /// No description provided for @release_asUser.
  ///
  /// In vi, this message translates to:
  /// **'Lịch bạn báo hiện là \"Người dùng báo\" cho tới khi chủ hồ xác nhận. Chỉ báo khi thấy hồ đăng thật nhé.'**
  String get release_asUser;

  /// No description provided for @release_post.
  ///
  /// In vi, this message translates to:
  /// **'Đăng lịch xả'**
  String get release_post;

  /// No description provided for @release_posted.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng lịch xả!'**
  String get release_posted;

  /// No description provided for @release_needDay.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày xả'**
  String get release_needDay;

  /// No description provided for @stations_menu.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách trạm đo'**
  String get stations_menu;

  /// No description provided for @stations_menuHint.
  ///
  /// In vi, this message translates to:
  /// **'Mực nước tại các trạm KTTV, IOC'**
  String get stations_menuHint;

  /// No description provided for @trip_tag.
  ///
  /// In vi, this message translates to:
  /// **'Kèo câu'**
  String get trip_tag;

  /// No description provided for @trip_pill.
  ///
  /// In vi, this message translates to:
  /// **'{count} kèo câu'**
  String trip_pill(int count);

  /// No description provided for @trip_create.
  ///
  /// In vi, this message translates to:
  /// **'Rủ đi câu'**
  String get trip_create;

  /// No description provided for @trip_createHere.
  ///
  /// In vi, this message translates to:
  /// **'Rủ đi câu ở đây'**
  String get trip_createHere;

  /// No description provided for @trip_formTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo kèo câu'**
  String get trip_formTitle;

  /// No description provided for @trip_editTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sửa kèo câu'**
  String get trip_editTitle;

  /// No description provided for @trip_name.
  ///
  /// In vi, this message translates to:
  /// **'Tên kèo'**
  String get trip_name;

  /// No description provided for @trip_nameHint.
  ///
  /// In vi, this message translates to:
  /// **'vd Câu đêm bãi đá cầu Thanh Trì'**
  String get trip_nameHint;

  /// No description provided for @trip_place.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm'**
  String get trip_place;

  /// No description provided for @trip_placeHint.
  ///
  /// In vi, this message translates to:
  /// **'vd Bãi đá chân cầu, cổng số 3'**
  String get trip_placeHint;

  /// No description provided for @trip_whereHint.
  ///
  /// In vi, this message translates to:
  /// **'Ghim kèo đặt ở chỗ này. Muốn hẹn chỗ khác: chạm chỗ đó trên bản đồ → \"Rủ đi câu ở đây\".'**
  String get trip_whereHint;

  /// No description provided for @trip_when.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get trip_when;

  /// No description provided for @trip_date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get trip_date;

  /// No description provided for @trip_start.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get trip_start;

  /// No description provided for @trip_duration.
  ///
  /// In vi, this message translates to:
  /// **'Câu trong'**
  String get trip_duration;

  /// No description provided for @trip_hours.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ'**
  String trip_hours(int hours);

  /// No description provided for @trip_golden.
  ///
  /// In vi, this message translates to:
  /// **'Giờ vàng ở đây (bấm để chọn)'**
  String get trip_golden;

  /// No description provided for @trip_goldenChip.
  ///
  /// In vi, this message translates to:
  /// **'{when} · {score}'**
  String trip_goldenChip(String when, String score);

  /// No description provided for @trip_noGolden.
  ///
  /// In vi, this message translates to:
  /// **'3 ngày tới chưa có giờ vàng ở đây'**
  String get trip_noGolden;

  /// No description provided for @trip_people.
  ///
  /// In vi, this message translates to:
  /// **'Số người tối đa (kể cả bạn)'**
  String get trip_people;

  /// No description provided for @trip_contact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ (không bắt buộc)'**
  String get trip_contact;

  /// No description provided for @trip_contactHint.
  ///
  /// In vi, this message translates to:
  /// **'Link nhóm Zalo/Facebook hoặc số điện thoại'**
  String get trip_contactHint;

  /// No description provided for @trip_contactNote.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ người đã tham gia kèo mới thấy.'**
  String get trip_contactNote;

  /// No description provided for @trip_noteHint.
  ///
  /// In vi, this message translates to:
  /// **'Câu gì, mồi gì, đi xe máy hay ô tô ghép, chia tiền xăng…'**
  String get trip_noteHint;

  /// No description provided for @trip_submit.
  ///
  /// In vi, this message translates to:
  /// **'Tạo kèo'**
  String get trip_submit;

  /// No description provided for @trip_save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get trip_save;

  /// No description provided for @trip_created.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo kèo! Anh em quanh đây sẽ thấy trên bản đồ.'**
  String get trip_created;

  /// No description provided for @trip_saved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu kèo'**
  String get trip_saved;

  /// No description provided for @trip_needName.
  ///
  /// In vi, this message translates to:
  /// **'Đặt tên kèo (từ 2 ký tự)'**
  String get trip_needName;

  /// No description provided for @trip_badTime.
  ///
  /// In vi, this message translates to:
  /// **'Giờ bắt đầu phải trong 30 ngày tới'**
  String get trip_badTime;

  /// No description provided for @trip_tooMany.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay máy này đã tạo đủ 5 kèo. Mai tạo tiếp nhé.'**
  String get trip_tooMany;

  /// No description provided for @trip_error.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được, kiểm tra mạng rồi thử lại'**
  String get trip_error;

  /// No description provided for @trip_tooFew.
  ///
  /// In vi, this message translates to:
  /// **'Kèo đã có nhiều người hơn số này'**
  String get trip_tooFew;

  /// No description provided for @trip_running.
  ///
  /// In vi, this message translates to:
  /// **'Đang diễn ra'**
  String get trip_running;

  /// No description provided for @trip_cancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get trip_cancelled;

  /// No description provided for @trip_full.
  ///
  /// In vi, this message translates to:
  /// **'Đủ người'**
  String get trip_full;

  /// No description provided for @trip_left.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} chỗ'**
  String trip_left(int count);

  /// No description provided for @trip_members.
  ///
  /// In vi, this message translates to:
  /// **'{count}/{max} người'**
  String trip_members(int count, int max);

  /// No description provided for @trip_owner.
  ///
  /// In vi, this message translates to:
  /// **'Chủ kèo: {name}'**
  String trip_owner(String name);

  /// No description provided for @trip_yours.
  ///
  /// In vi, this message translates to:
  /// **'Kèo của bạn'**
  String get trip_yours;

  /// No description provided for @trip_joinedTag.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã tham gia'**
  String get trip_joinedTag;

  /// No description provided for @trip_join.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia'**
  String get trip_join;

  /// No description provided for @trip_joinedSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã tham gia! Xem liên hệ và nhắn tin với nhóm bên dưới.'**
  String get trip_joinedSnack;

  /// No description provided for @trip_joinFull.
  ///
  /// In vi, this message translates to:
  /// **'Kèo đã đủ người'**
  String get trip_joinFull;

  /// No description provided for @trip_joinClosed.
  ///
  /// In vi, this message translates to:
  /// **'Kèo đã kết thúc hoặc bị hủy'**
  String get trip_joinClosed;

  /// No description provided for @trip_leave.
  ///
  /// In vi, this message translates to:
  /// **'Rời kèo'**
  String get trip_leave;

  /// No description provided for @trip_leaveTitle.
  ///
  /// In vi, this message translates to:
  /// **'Rời kèo này?'**
  String get trip_leaveTitle;

  /// No description provided for @trip_cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy kèo'**
  String get trip_cancel;

  /// No description provided for @trip_cancelTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hủy kèo? Người đã tham gia sẽ thấy \"Đã hủy\".'**
  String get trip_cancelTitle;

  /// No description provided for @trip_edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get trip_edit;

  /// No description provided for @trip_keep.
  ///
  /// In vi, this message translates to:
  /// **'Giữ kèo'**
  String get trip_keep;

  /// No description provided for @trip_share.
  ///
  /// In vi, this message translates to:
  /// **'Rủ thêm bạn'**
  String get trip_share;

  /// No description provided for @trip_shareText.
  ///
  /// In vi, this message translates to:
  /// **'🎣 Kèo câu: {title}\n🕐 {when}\n📍 {place}\nBản đồ: {map}\nXem và tham gia trên app Con Nước: {app}'**
  String trip_shareText(String title, String when, String place, String map, String app);

  /// No description provided for @trip_report.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get trip_report;

  /// No description provided for @trip_reportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo kèo này?'**
  String get trip_reportTitle;

  /// No description provided for @trip_reportHint.
  ///
  /// In vi, this message translates to:
  /// **'Lừa đảo, quảng cáo, nội dung xấu… Kèo bị 3 người báo cáo sẽ tự ẩn.'**
  String get trip_reportHint;

  /// No description provided for @trip_membersOnly.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia để xem liên hệ, danh sách người đi và nhắn tin với nhóm.'**
  String get trip_membersOnly;

  /// No description provided for @trip_contactLabel.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get trip_contactLabel;

  /// No description provided for @trip_openContact.
  ///
  /// In vi, this message translates to:
  /// **'Mở'**
  String get trip_openContact;

  /// No description provided for @trip_memberList.
  ///
  /// In vi, this message translates to:
  /// **'Người đi'**
  String get trip_memberList;

  /// No description provided for @trip_chat.
  ///
  /// In vi, this message translates to:
  /// **'Nhắn tin trong kèo'**
  String get trip_chat;

  /// No description provided for @trip_chatEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin nhắn. Hẹn giờ gặp, chỗ gửi xe ở đây nhé.'**
  String get trip_chatEmpty;

  /// No description provided for @trip_chatHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhắn cho cả nhóm…'**
  String get trip_chatHint;

  /// No description provided for @trip_send.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get trip_send;

  /// No description provided for @trip_refresh.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại'**
  String get trip_refresh;

  /// No description provided for @trip_nearbyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kèo câu quanh đây'**
  String get trip_nearbyTitle;

  /// No description provided for @trip_nearbyEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có kèo nào trong vòng 30 km. Tạo kèo đầu tiên để rủ anh em!'**
  String get trip_nearbyEmpty;

  /// No description provided for @trip_loadError.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được kèo câu'**
  String get trip_loadError;

  /// No description provided for @trip_notice.
  ///
  /// In vi, this message translates to:
  /// **'Kèo hiện công khai cho người dùng quanh đây. Không hẹn ở nơi cấm câu; đi theo nhóm, giữ an toàn khi câu đêm.'**
  String get trip_notice;

  /// No description provided for @checkin_pill.
  ///
  /// In vi, this message translates to:
  /// **'Tôi đang câu'**
  String get checkin_pill;

  /// No description provided for @checkin_pillOn.
  ///
  /// In vi, this message translates to:
  /// **'Đang câu · còn {time}'**
  String checkin_pillOn(String time);

  /// No description provided for @checkin_count.
  ///
  /// In vi, this message translates to:
  /// **'{count} người đang câu'**
  String checkin_count(int count);

  /// No description provided for @checkin_title.
  ///
  /// In vi, this message translates to:
  /// **'Báo \"đang câu ở đây\"'**
  String get checkin_title;

  /// No description provided for @checkin_body.
  ///
  /// In vi, this message translates to:
  /// **'Anh em quanh đây sẽ thấy có người đang câu ở khu này. Chỉ hiện con số, không hiện tên; vị trí làm tròn khoảng 200 m; tự tắt sau 4 giờ.'**
  String get checkin_body;

  /// No description provided for @checkin_biting.
  ///
  /// In vi, this message translates to:
  /// **'Đang dính 🐟'**
  String get checkin_biting;

  /// No description provided for @checkin_noBite.
  ///
  /// In vi, this message translates to:
  /// **'Chưa dính'**
  String get checkin_noBite;

  /// No description provided for @checkin_start.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get checkin_start;

  /// No description provided for @checkin_update.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get checkin_update;

  /// No description provided for @checkin_stop.
  ///
  /// In vi, this message translates to:
  /// **'Về rồi'**
  String get checkin_stop;

  /// No description provided for @checkin_on.
  ///
  /// In vi, this message translates to:
  /// **'Đã báo đang câu. Chúc dính cá to!'**
  String get checkin_on;

  /// No description provided for @checkin_off.
  ///
  /// In vi, this message translates to:
  /// **'Đã tắt. Về an toàn nhé!'**
  String get checkin_off;

  /// No description provided for @checkin_error.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được, kiểm tra mạng rồi thử lại'**
  String get checkin_error;

  /// No description provided for @checkin_needLocation.
  ///
  /// In vi, this message translates to:
  /// **'Cần vị trí của bạn để báo đang câu'**
  String get checkin_needLocation;

  /// No description provided for @checkin_cellTitle.
  ///
  /// In vi, this message translates to:
  /// **'{count} người đang câu quanh đây'**
  String checkin_cellTitle(int count);

  /// No description provided for @checkin_cellBiting.
  ///
  /// In vi, this message translates to:
  /// **'{count} người báo đang dính cá'**
  String checkin_cellBiting(int count);

  /// No description provided for @checkin_cellNoBite.
  ///
  /// In vi, this message translates to:
  /// **'Chưa ai báo dính cá'**
  String get checkin_cellNoBite;

  /// No description provided for @checkin_cellLatest.
  ///
  /// In vi, this message translates to:
  /// **'Người mới nhất tới lúc {time}'**
  String checkin_cellLatest(String time);

  /// No description provided for @checkin_cellYou.
  ///
  /// In vi, this message translates to:
  /// **'Có cả bạn'**
  String get checkin_cellYou;

  /// No description provided for @checkin_listTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỗ đang có người câu'**
  String get checkin_listTitle;

  /// No description provided for @checkin_hint.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí làm tròn ~200 m, không hiện tên ai.'**
  String get checkin_hint;

  /// No description provided for @spot_publicTag.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu cộng đồng'**
  String get spot_publicTag;

  /// No description provided for @spot_pinAction.
  ///
  /// In vi, this message translates to:
  /// **'Ghim công khai'**
  String get spot_pinAction;

  /// No description provided for @spot_nearbyChip.
  ///
  /// In vi, this message translates to:
  /// **'{count} điểm cộng đồng'**
  String spot_nearbyChip(int count);

  /// No description provided for @spot_nearbyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu gần đây'**
  String get spot_nearbyTitle;

  /// No description provided for @spot_nearbyEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có điểm câu nào trong vòng 30 km. Chạm một chỗ trên bản đồ rồi bấm \"Ghim công khai\" để chia sẻ điểm của bạn.'**
  String get spot_nearbyEmpty;

  /// No description provided for @spot_postedAgo.
  ///
  /// In vi, this message translates to:
  /// **'Đăng {date}'**
  String spot_postedAgo(String date);

  /// No description provided for @spot_distance.
  ///
  /// In vi, this message translates to:
  /// **'cách {km}'**
  String spot_distance(String km);

  /// No description provided for @spot_viewWater.
  ///
  /// In vi, this message translates to:
  /// **'Xem nước tại đây'**
  String get spot_viewWater;

  /// No description provided for @spot_report.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get spot_report;

  /// No description provided for @spot_reportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo điểm câu này?'**
  String get spot_reportTitle;

  /// No description provided for @spot_reportHint.
  ///
  /// In vi, this message translates to:
  /// **'Sai chỗ, ảnh không phù hợp, quảng cáo… Điểm bị nhiều người báo sẽ tự ẩn.'**
  String get spot_reportHint;

  /// No description provided for @spot_reportDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi báo cáo. Cảm ơn bạn!'**
  String get spot_reportDone;

  /// No description provided for @spot_reportTwice.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã báo cáo điểm này rồi'**
  String get spot_reportTwice;

  /// No description provided for @spot_delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa điểm của tôi'**
  String get spot_delete;

  /// No description provided for @spot_deleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa điểm câu này khỏi bản đồ cộng đồng?'**
  String get spot_deleteTitle;

  /// No description provided for @spot_ownedByYou.
  ///
  /// In vi, this message translates to:
  /// **'Điểm của bạn'**
  String get spot_ownedByYou;

  /// No description provided for @spot_publishTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ghim điểm câu công khai'**
  String get spot_publishTitle;

  /// No description provided for @spot_name.
  ///
  /// In vi, this message translates to:
  /// **'Tên điểm'**
  String get spot_name;

  /// No description provided for @spot_nameHint.
  ///
  /// In vi, this message translates to:
  /// **'vd Bãi đá cầu Thanh Trì'**
  String get spot_nameHint;

  /// No description provided for @spot_species.
  ///
  /// In vi, this message translates to:
  /// **'Cá hay câu được'**
  String get spot_species;

  /// No description provided for @spot_note.
  ///
  /// In vi, this message translates to:
  /// **'Kinh nghiệm'**
  String get spot_note;

  /// No description provided for @spot_noteHint.
  ///
  /// In vi, this message translates to:
  /// **'Mồi, giờ đẹp, chỗ để xe, độ sâu…'**
  String get spot_noteHint;

  /// No description provided for @spot_photos.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh (tối đa 3)'**
  String get spot_photos;

  /// No description provided for @spot_addPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh'**
  String get spot_addPhoto;

  /// No description provided for @spot_publicNotice.
  ///
  /// In vi, this message translates to:
  /// **'Điểm này sẽ hiện công khai cho mọi người dùng Con Nước. Không đăng điểm cấm câu, ảnh có mặt người khác khi chưa được đồng ý.'**
  String get spot_publicNotice;

  /// No description provided for @spot_agree.
  ///
  /// In vi, this message translates to:
  /// **'Tôi hiểu và đồng ý chia sẻ'**
  String get spot_agree;

  /// No description provided for @spot_publish.
  ///
  /// In vi, this message translates to:
  /// **'Đăng điểm'**
  String get spot_publish;

  /// No description provided for @spot_published.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghim! Mọi người quanh đây sẽ thấy điểm của bạn.'**
  String get spot_published;

  /// No description provided for @spot_needName.
  ///
  /// In vi, this message translates to:
  /// **'Đặt tên cho điểm (từ 2 ký tự)'**
  String get spot_needName;

  /// No description provided for @spot_error.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được, kiểm tra mạng rồi thử lại'**
  String get spot_error;

  /// No description provided for @spot_photoError.
  ///
  /// In vi, this message translates to:
  /// **'Không đọc được ảnh này'**
  String get spot_photoError;

  /// No description provided for @spot_location.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí: {coords}'**
  String spot_location(String coords);

  /// No description provided for @station_levelNow.
  ///
  /// In vi, this message translates to:
  /// **'Mực nước hiện tại'**
  String get station_levelNow;

  /// No description provided for @station_follow.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi trạm'**
  String get station_follow;

  /// No description provided for @station_unfollow.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ theo dõi'**
  String get station_unfollow;

  /// No description provided for @stations_kindRiver.
  ///
  /// In vi, this message translates to:
  /// **'Trạm sông (KTTV)'**
  String get stations_kindRiver;

  /// No description provided for @stations_kindRiverDaily.
  ///
  /// In vi, this message translates to:
  /// **'Sông có triều (KTTV)'**
  String get stations_kindRiverDaily;

  /// No description provided for @station_sourceRiver.
  ///
  /// In vi, this message translates to:
  /// **'Bản tin thủy văn KTTV (4 mốc đo/ngày + dự báo) · đường từng giờ do app nội suy'**
  String get station_sourceRiver;

  /// No description provided for @station_sourceRiverTide.
  ///
  /// In vi, this message translates to:
  /// **'Bản tin thủy văn KTTV + triều cửa sông (Open-Meteo Marine) · đường từng giờ do app ước tính'**
  String get station_sourceRiverTide;

  /// No description provided for @station_datumNational.
  ///
  /// In vi, this message translates to:
  /// **'mốc cao độ của trạm (theo bản tin KTTV)'**
  String get station_datumNational;

  /// No description provided for @station_issued.
  ///
  /// In vi, this message translates to:
  /// **'Bản tin KTTV phát {time}'**
  String station_issued(String time);

  /// No description provided for @station_backtestMae.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm thử ngược: sai số trung bình ±{cm} cm'**
  String station_backtestMae(String cm);

  /// No description provided for @station_dailyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mực nước trong {hours} giờ (bản tin KTTV)'**
  String station_dailyTitle(int hours);

  /// No description provided for @station_dailyObs.
  ///
  /// In vi, this message translates to:
  /// **'Đã đo: cao nhất {max} · thấp nhất {min}'**
  String station_dailyObs(String max, String min);

  /// No description provided for @station_dailyFc.
  ///
  /// In vi, this message translates to:
  /// **'Dự báo: cao nhất {max} · thấp nhất {min}'**
  String station_dailyFc(String max, String min);

  /// No description provided for @station_dailyNoCurve.
  ///
  /// In vi, this message translates to:
  /// **'Bản tin chỉ cho mức cao nhất và thấp nhất, không ghi giờ. App không vẽ đường để tránh đoán sai giờ nước lên xuống.'**
  String get station_dailyNoCurve;

  /// No description provided for @station_dailyRangeNow.
  ///
  /// In vi, this message translates to:
  /// **'Biên độ dự báo {range} — nước còn lên/xuống trong khoảng này'**
  String station_dailyRangeNow(String range);

  /// No description provided for @point_estimateHere.
  ///
  /// In vi, this message translates to:
  /// **'Mực nước ước tính tại điểm này'**
  String get point_estimateHere;

  /// No description provided for @point_onWater.
  ///
  /// In vi, this message translates to:
  /// **'Điểm nằm trên mặt nước (sông, hồ hoặc biển)'**
  String get point_onWater;

  /// No description provided for @point_onLand.
  ///
  /// In vi, this message translates to:
  /// **'Điểm này không nằm trên sông, hồ hay biển. Số dưới đây là mực nước của nguồn nước gần nhất.'**
  String get point_onLand;

  /// No description provided for @point_basisRiver.
  ///
  /// In vi, this message translates to:
  /// **'Dựa theo trạm {station} (sông {river}) · cách {distance}'**
  String point_basisRiver(String station, String river, String distance);

  /// No description provided for @point_basisStation.
  ///
  /// In vi, this message translates to:
  /// **'Dựa theo trạm {station} · cách {distance}'**
  String point_basisStation(String station, String distance);

  /// No description provided for @point_alongDown.
  ///
  /// In vi, this message translates to:
  /// **'Cách trạm {station} {distance} về phía hạ lưu, đo dọc sông {river}'**
  String point_alongDown(String station, String distance, String river);

  /// No description provided for @point_alongUp.
  ///
  /// In vi, this message translates to:
  /// **'Cách trạm {station} {distance} về phía thượng lưu, đo dọc sông {river}'**
  String point_alongUp(String station, String distance, String river);

  /// No description provided for @point_lagEarlier.
  ///
  /// In vi, this message translates to:
  /// **'Nước lên/xuống sớm hơn trạm khoảng {minutes} phút'**
  String point_lagEarlier(int minutes);

  /// No description provided for @point_lagLater.
  ///
  /// In vi, this message translates to:
  /// **'Nước lên/xuống muộn hơn trạm khoảng {minutes} phút'**
  String point_lagLater(int minutes);

  /// No description provided for @point_lagSame.
  ///
  /// In vi, this message translates to:
  /// **'Nước lên/xuống gần như cùng lúc với trạm'**
  String get point_lagSame;

  /// No description provided for @point_meanLower.
  ///
  /// In vi, this message translates to:
  /// **'Mặt nước thấp hơn ở trạm khoảng {cm} cm'**
  String point_meanLower(int cm);

  /// No description provided for @point_meanHigher.
  ///
  /// In vi, this message translates to:
  /// **'Mặt nước cao hơn ở trạm khoảng {cm} cm'**
  String point_meanHigher(int cm);

  /// No description provided for @point_celerity.
  ///
  /// In vi, this message translates to:
  /// **'Con triều truyền ngược sông khoảng {speed} km/giờ'**
  String point_celerity(String speed);

  /// No description provided for @point_reachNote.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính theo vị trí dọc sông, giữa triều ở cửa sông và trạm đo; chưa kiểm chứng bằng trạm thứ hai.'**
  String get point_reachNote;

  /// No description provided for @flow_unknown.
  ///
  /// In vi, this message translates to:
  /// **'Chỗ này không nằm trên dòng sông lớn nào nên chưa tính được mực nước và dòng chảy. Giờ câu và thời tiết vẫn tính theo đúng vị trí.'**
  String get flow_unknown;

  /// No description provided for @flow_headRising.
  ///
  /// In vi, this message translates to:
  /// **'Nước sông đang lên'**
  String get flow_headRising;

  /// No description provided for @flow_headFalling.
  ///
  /// In vi, this message translates to:
  /// **'Nước sông đang rút'**
  String get flow_headFalling;

  /// No description provided for @flow_headSteady.
  ///
  /// In vi, this message translates to:
  /// **'Nước sông ổn định'**
  String get flow_headSteady;

  /// No description provided for @flow_dayValue.
  ///
  /// In vi, this message translates to:
  /// **'{day}: {q} m³/s'**
  String flow_dayValue(String day, String q);

  /// No description provided for @loc_nearCoast.
  ///
  /// In vi, this message translates to:
  /// **'Gần cửa biển'**
  String get loc_nearCoast;

  /// No description provided for @point_basisCoast.
  ///
  /// In vi, this message translates to:
  /// **'Triều ước tính theo vùng biển ven bờ gần nhất; trong sông, giờ nước lên xuống thường muộn hơn và biên độ nhỏ hơn.'**
  String get point_basisCoast;

  /// No description provided for @info_noLevelSources.
  ///
  /// In vi, this message translates to:
  /// **'Chỗ này chưa có nguồn mực nước. Lưu lượng sông: mô hình GloFAS (qua Open-Meteo Flood), theo ngày. Thời tiết, giờ câu: Open-Meteo và tính toán thiên văn tại đúng tọa độ. Mọi số liệu chỉ mang tính tham khảo.'**
  String get info_noLevelSources;

  /// No description provided for @flow_title.
  ///
  /// In vi, this message translates to:
  /// **'Dòng chảy sông'**
  String get flow_title;

  /// No description provided for @flow_today.
  ///
  /// In vi, this message translates to:
  /// **'Lưu lượng hôm nay ≈ {q} m³/s'**
  String flow_today(String q);

  /// No description provided for @flow_tomorrow.
  ///
  /// In vi, this message translates to:
  /// **'Ngày mai ≈ {q} m³/s · {trend}'**
  String flow_tomorrow(String q, String trend);

  /// No description provided for @flow_rising.
  ///
  /// In vi, this message translates to:
  /// **'đang tăng (nước sông lên dần)'**
  String get flow_rising;

  /// No description provided for @flow_falling.
  ///
  /// In vi, this message translates to:
  /// **'đang giảm (nước sông rút dần)'**
  String get flow_falling;

  /// No description provided for @flow_steady.
  ///
  /// In vi, this message translates to:
  /// **'ổn định'**
  String get flow_steady;

  /// No description provided for @flow_note.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính cho dòng chính đoạn sông này, theo ngày.'**
  String get flow_note;

  /// No description provided for @chart_band.
  ///
  /// In vi, this message translates to:
  /// **'Dải mờ quanh đường: sai số khoảng ±{cm} cm, đo khi kiểm thử tại trạm'**
  String chart_band(String cm);

  /// No description provided for @turn_in.
  ///
  /// In vi, this message translates to:
  /// **'còn {duration}'**
  String turn_in(String duration);

  /// No description provided for @day_high.
  ///
  /// In vi, this message translates to:
  /// **'Cao nhất {level} · {time}'**
  String day_high(String level, String time);

  /// No description provided for @day_low.
  ///
  /// In vi, this message translates to:
  /// **'Thấp nhất {level} · {time}'**
  String day_low(String level, String time);

  /// No description provided for @day_range.
  ///
  /// In vi, this message translates to:
  /// **'Chênh {cm} cm'**
  String day_range(int cm);

  /// No description provided for @fishAct_title.
  ///
  /// In vi, this message translates to:
  /// **'Cá ăn'**
  String get fishAct_title;

  /// No description provided for @fishAct_low.
  ///
  /// In vi, this message translates to:
  /// **'Thấp'**
  String get fishAct_low;

  /// No description provided for @fishAct_fair.
  ///
  /// In vi, this message translates to:
  /// **'Vừa'**
  String get fishAct_fair;

  /// No description provided for @fishAct_high.
  ///
  /// In vi, this message translates to:
  /// **'Cao'**
  String get fishAct_high;

  /// No description provided for @fishAct_peak.
  ///
  /// In vi, this message translates to:
  /// **'Rất cao'**
  String get fishAct_peak;

  /// No description provided for @fishAct_score.
  ///
  /// In vi, this message translates to:
  /// **'{score}/10'**
  String fishAct_score(String score);

  /// No description provided for @fishAct_meter.
  ///
  /// In vi, this message translates to:
  /// **'{count} trên 5 cá'**
  String fishAct_meter(int count);

  /// No description provided for @fishAct_because.
  ///
  /// In vi, this message translates to:
  /// **'Nhờ {reasons}'**
  String fishAct_because(String reasons);

  /// No description provided for @fishAct_next.
  ///
  /// In vi, this message translates to:
  /// **'Giờ vàng tiếp theo: {when}'**
  String fishAct_next(String when);

  /// No description provided for @fishAct_inWindow.
  ///
  /// In vi, this message translates to:
  /// **'Đang trong giờ vàng đến {to}'**
  String fishAct_inWindow(String to);

  /// No description provided for @fishAct_noWindow.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thấy giờ vàng trong 2 ngày tới'**
  String get fishAct_noWindow;

  /// No description provided for @fishAct_source.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính từ con nước, giờ mặt trăng, ngày/đêm và thời tiết (Open-Meteo) — chỉ để tham khảo, không biết chắc chỗ nào có cá.'**
  String get fishAct_source;

  /// No description provided for @fishAct_quick.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thời tiết: tạm tính theo con nước và giờ mặt trăng.'**
  String get fishAct_quick;

  /// No description provided for @fishTime_now.
  ///
  /// In vi, this message translates to:
  /// **'Bây giờ'**
  String get fishTime_now;

  /// No description provided for @fishTime_today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay {time}'**
  String fishTime_today(String time);

  /// No description provided for @fishTime_tomorrow.
  ///
  /// In vi, this message translates to:
  /// **'Ngày mai {time}'**
  String fishTime_tomorrow(String time);

  /// No description provided for @fishTime_dayAfter.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kia {time}'**
  String fishTime_dayAfter(String time);

  /// No description provided for @fishTime_title.
  ///
  /// In vi, this message translates to:
  /// **'Cá ăn lúc'**
  String get fishTime_title;

  /// No description provided for @fishTime_slider.
  ///
  /// In vi, this message translates to:
  /// **'Chọn giờ xem cá ăn'**
  String get fishTime_slider;

  /// No description provided for @fishTime_reset.
  ///
  /// In vi, this message translates to:
  /// **'Về bây giờ'**
  String get fishTime_reset;

  /// No description provided for @fishTime_legendNote.
  ///
  /// In vi, this message translates to:
  /// **'Màu ghim = mức cá ăn ước tính. Chạm ghim để xem chi tiết.'**
  String get fishTime_legendNote;

  /// No description provided for @fishTime_collapse.
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn'**
  String get fishTime_collapse;

  /// No description provided for @fishTime_expand.
  ///
  /// In vi, this message translates to:
  /// **'Xem cá ăn theo giờ'**
  String get fishTime_expand;

  /// No description provided for @fishing_changeSpot.
  ///
  /// In vi, this message translates to:
  /// **'Đổi'**
  String get fishing_changeSpot;

  /// No description provided for @fishing_plan.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch'**
  String get fishing_plan;

  /// No description provided for @pond_search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm hồ theo tên…'**
  String get pond_search;

  /// No description provided for @pond_header.
  ///
  /// In vi, this message translates to:
  /// **'{count} hồ quanh bạn'**
  String pond_header(int count);

  /// No description provided for @pond_headerSoon.
  ///
  /// In vi, this message translates to:
  /// **'{count} hồ sắp xả cá trong 3 ngày'**
  String pond_headerSoon(int count);

  /// No description provided for @pond_headerNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lịch xả cá nào sắp tới'**
  String get pond_headerNone;

  /// No description provided for @fishing_nextGolden.
  ///
  /// In vi, this message translates to:
  /// **'Giờ vàng {range}'**
  String fishing_nextGolden(String range);

  /// No description provided for @fishing_hourly.
  ///
  /// In vi, this message translates to:
  /// **'Từng giờ hôm nay'**
  String get fishing_hourly;

  /// No description provided for @fish_now_title.
  ///
  /// In vi, this message translates to:
  /// **'Câu cá lúc này'**
  String get fish_now_title;

  /// No description provided for @fish_unsafe.
  ///
  /// In vi, this message translates to:
  /// **'Đang có cảnh báo thời tiết — không nên ra nước'**
  String get fish_unsafe;

  /// No description provided for @fish_noWindow.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay không có khung giờ nổi bật'**
  String get fish_noWindow;

  /// No description provided for @fish_best.
  ///
  /// In vi, this message translates to:
  /// **'Giờ đẹp hôm nay: {from}–{to}'**
  String fish_best(String from, String to);

  /// No description provided for @cond_title.
  ///
  /// In vi, this message translates to:
  /// **'Thời tiết & trời'**
  String get cond_title;

  /// No description provided for @loc_river.
  ///
  /// In vi, this message translates to:
  /// **'Sông {river}'**
  String loc_river(String river);

  /// No description provided for @loc_nearRiver.
  ///
  /// In vi, this message translates to:
  /// **'Gần sông {river}'**
  String loc_nearRiver(String river);

  /// No description provided for @loc_sea.
  ///
  /// In vi, this message translates to:
  /// **'Vùng biển'**
  String get loc_sea;

  /// No description provided for @loc_water.
  ///
  /// In vi, this message translates to:
  /// **'Trên mặt nước'**
  String get loc_water;

  /// No description provided for @spot_title.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu'**
  String get spot_title;

  /// No description provided for @spot_mine.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí của tôi'**
  String get spot_mine;

  /// No description provided for @spot_point.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đã chọn'**
  String get spot_point;

  /// No description provided for @spot_useMine.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí của tôi'**
  String get spot_useMine;

  /// No description provided for @spot_pickMap.
  ///
  /// In vi, this message translates to:
  /// **'Chọn trên bản đồ'**
  String get spot_pickMap;

  /// No description provided for @spot_pickHint.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào chỗ bạn định câu, rồi bấm \"Câu cá tại đây\"'**
  String get spot_pickHint;

  /// No description provided for @spot_saved.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đã lưu'**
  String get spot_saved;

  /// No description provided for @fish_here.
  ///
  /// In vi, this message translates to:
  /// **'Câu cá tại đây'**
  String get fish_here;

  /// No description provided for @advice_title.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý câu lúc này'**
  String get advice_title;

  /// No description provided for @advice_note.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý theo kinh nghiệm câu phổ biến, tính cho đúng điểm này.'**
  String get advice_note;

  /// No description provided for @advice_unsafe.
  ///
  /// In vi, this message translates to:
  /// **'Có dông hoặc gió giật mạnh — không nên câu lúc này'**
  String get advice_unsafe;

  /// No description provided for @advice_rising.
  ///
  /// In vi, this message translates to:
  /// **'Nước đang lên: cá vào gần bờ, mép cỏ, bãi nông kiếm ăn, nên câu gần bờ'**
  String get advice_rising;

  /// No description provided for @advice_falling.
  ///
  /// In vi, this message translates to:
  /// **'Nước đang rút: cá ra chỗ sâu, mép luồng, cửa lạch, nên câu xa bờ hơn'**
  String get advice_falling;

  /// No description provided for @advice_slack.
  ///
  /// In vi, this message translates to:
  /// **'Nước đứng: cá ít ăn, chờ nước chảy lại'**
  String get advice_slack;

  /// No description provided for @advice_slackAt.
  ///
  /// In vi, this message translates to:
  /// **'Nước đứng: cá ít ăn — nước chảy lại khoảng {time}'**
  String advice_slackAt(String time);

  /// No description provided for @advice_windStrong.
  ///
  /// In vi, this message translates to:
  /// **'Gió mạnh: khó quăng xa — câu sát bờ khuất gió, không nên ra thuyền'**
  String get advice_windStrong;

  /// No description provided for @advice_windDown.
  ///
  /// In vi, this message translates to:
  /// **'Có gió: câu phía cuối gió, nơi sóng dồn mồi'**
  String get advice_windDown;

  /// No description provided for @advice_rain.
  ///
  /// In vi, this message translates to:
  /// **'Khả năng mưa cao — mang theo áo mưa'**
  String get advice_rain;

  /// No description provided for @advice_flood.
  ///
  /// In vi, this message translates to:
  /// **'Nước sông lên nhanh, đục: câu chỗ nước quẩn sau mỏ kè, gốc cây'**
  String get advice_flood;

  /// No description provided for @advice_light.
  ///
  /// In vi, this message translates to:
  /// **'Sắp bình minh/hoàng hôn — giờ cá ăn mạnh'**
  String get advice_light;

  /// No description provided for @advice_good.
  ///
  /// In vi, this message translates to:
  /// **'Điểm câu đang tốt — tranh thủ ra câu'**
  String get advice_good;

  /// No description provided for @point_reference.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính theo trạm {station}, cách {distance}'**
  String point_reference(String station, String distance);

  /// No description provided for @point_referenceRiver.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính theo trạm {station} (sông {river}), cách {distance}'**
  String point_referenceRiver(String station, String river, String distance);

  /// No description provided for @point_title.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đã chọn'**
  String get point_title;

  /// No description provided for @point_coords.
  ///
  /// In vi, this message translates to:
  /// **'Tọa độ: {coords}'**
  String point_coords(String coords);

  /// No description provided for @point_copy.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép tọa độ'**
  String get point_copy;

  /// No description provided for @point_copied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép tọa độ'**
  String get point_copied;

  /// No description provided for @point_noData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tính được số liệu cho điểm này.'**
  String get point_noData;

  /// No description provided for @point_nearby.
  ///
  /// In vi, this message translates to:
  /// **'Trạm gần nhất'**
  String get point_nearby;

  /// No description provided for @point_distance.
  ///
  /// In vi, this message translates to:
  /// **'cách {distance}'**
  String point_distance(String distance);

  /// No description provided for @point_openDetail.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết theo giờ'**
  String get point_openDetail;

  /// No description provided for @point_weatherNow.
  ///
  /// In vi, this message translates to:
  /// **'Thời tiết bây giờ: {temp}°C · gió {wind} km/h · mưa {rain}%'**
  String point_weatherNow(String temp, String wind, int rain);

  /// No description provided for @point_sun.
  ///
  /// In vi, this message translates to:
  /// **'Mặt trời mọc {rise} · lặn {set}'**
  String point_sun(String rise, String set);

  /// No description provided for @point_seaModel.
  ///
  /// In vi, this message translates to:
  /// **'Mô hình biển tính ngay tại điểm này'**
  String get point_seaModel;

  /// No description provided for @point_tapHint.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào bất kỳ đâu trên bản đồ để xem nước tại đó'**
  String get point_tapHint;

  /// No description provided for @source_shortGauge.
  ///
  /// In vi, this message translates to:
  /// **'IOC + utide'**
  String get source_shortGauge;

  /// No description provided for @source_shortModel.
  ///
  /// In vi, this message translates to:
  /// **'Open-Meteo'**
  String get source_shortModel;

  /// No description provided for @source_shortRiver.
  ///
  /// In vi, this message translates to:
  /// **'KTTV'**
  String get source_shortRiver;

  /// No description provided for @source_shortRiverTide.
  ///
  /// In vi, this message translates to:
  /// **'KTTV + triều Open-Meteo'**
  String get source_shortRiverTide;

  /// No description provided for @source_compact.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn: {source} · {updated}'**
  String source_compact(String source, String updated);

  /// No description provided for @source_details.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết nguồn'**
  String get source_details;

  /// No description provided for @map_credits.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn bản đồ'**
  String get map_credits;

  /// No description provided for @map_creditShort.
  ///
  /// In vi, this message translates to:
  /// **'© OpenFreeMap · © OpenStreetMap'**
  String get map_creditShort;

  /// No description provided for @map_creditShortSat.
  ///
  /// In vi, this message translates to:
  /// **'© EOX · Copernicus · © OpenStreetMap'**
  String get map_creditShortSat;

  /// No description provided for @station_datumNote.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao so với {datum}'**
  String station_datumNote(String datum);

  /// No description provided for @station_datumChart.
  ///
  /// In vi, this message translates to:
  /// **'số 0 hải đồ (quy đổi theo bản tin KTTV)'**
  String get station_datumChart;

  /// No description provided for @station_datumMsl.
  ///
  /// In vi, this message translates to:
  /// **'mực nước biển trung bình của mô hình'**
  String get station_datumMsl;

  /// No description provided for @station_lunarDay.
  ///
  /// In vi, this message translates to:
  /// **'{day}/{month} ÂL'**
  String station_lunarDay(int day, int month);

  /// No description provided for @station_dailyRange.
  ///
  /// In vi, this message translates to:
  /// **'Biên độ {range}'**
  String station_dailyRange(String range);

  /// No description provided for @station_coords.
  ///
  /// In vi, this message translates to:
  /// **'Tọa độ: {lat}, {lon}'**
  String station_coords(String lat, String lon);

  /// No description provided for @station_modelFit.
  ///
  /// In vi, this message translates to:
  /// **'Hằng số triều tính từ số liệu {from} đến {to}'**
  String station_modelFit(String from, String to);

  /// No description provided for @station_sourceGauge.
  ///
  /// In vi, this message translates to:
  /// **'IOC Sea Level Monitoring (thực đo) · dự báo tính bằng utide'**
  String get station_sourceGauge;

  /// No description provided for @station_sourceModel.
  ///
  /// In vi, this message translates to:
  /// **'Open-Meteo Marine (mô hình đại dương, không có thực đo)'**
  String get station_sourceModel;

  /// No description provided for @hourly_now.
  ///
  /// In vi, this message translates to:
  /// **'Bây giờ'**
  String get hourly_now;

  /// No description provided for @hourly_detailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết lúc {time}'**
  String hourly_detailTitle(String time);

  /// No description provided for @hourly_obsMinusPred.
  ///
  /// In vi, this message translates to:
  /// **'Thực đo − dự báo: {delta}'**
  String hourly_obsMinusPred(String delta);

  /// No description provided for @hourly_untilNext.
  ///
  /// In vi, this message translates to:
  /// **'{kind} tiếp theo sau {duration}'**
  String hourly_untilNext(String kind, String duration);

  /// No description provided for @hourly_fishScore.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ số câu cá: {score}/10'**
  String hourly_fishScore(String score);

  /// No description provided for @hourly_weather.
  ///
  /// In vi, this message translates to:
  /// **'{temp} °C · gió {wind} km/h · mưa {rain} mm'**
  String hourly_weather(String temp, String wind, String rain);

  /// No description provided for @hourly_empty.
  ///
  /// In vi, this message translates to:
  /// **'Không có số liệu theo giờ cho khoảng thời gian này.'**
  String get hourly_empty;

  /// No description provided for @chart_semantics.
  ///
  /// In vi, this message translates to:
  /// **'Biểu đồ mực nước, thực đo nét liền, dự báo nét đứt'**
  String get chart_semantics;

  /// No description provided for @watch_empty.
  ///
  /// In vi, this message translates to:
  /// **'Chạm một điểm trên bản đồ (hoặc một trạm) rồi bấm ⭐ để lưu. Điểm đã lưu xem nhanh ở đây, có báo thức và dùng được khi mất sóng.'**
  String get watch_empty;

  /// No description provided for @watch_emptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có điểm nào'**
  String get watch_emptyTitle;

  /// No description provided for @watch_openMap.
  ///
  /// In vi, this message translates to:
  /// **'Mở bản đồ'**
  String get watch_openMap;

  /// No description provided for @fishing_title.
  ///
  /// In vi, this message translates to:
  /// **'Câu cá'**
  String get fishing_title;

  /// No description provided for @fishing_pickStation.
  ///
  /// In vi, this message translates to:
  /// **'Chọn trạm'**
  String get fishing_pickStation;

  /// No description provided for @fishing_dayScore.
  ///
  /// In vi, this message translates to:
  /// **'Điểm hôm nay'**
  String get fishing_dayScore;

  /// No description provided for @fishing_reference.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ số mang tính tham khảo (công thức fs-1)'**
  String get fishing_reference;

  /// No description provided for @fishing_golden.
  ///
  /// In vi, this message translates to:
  /// **'Giờ vàng'**
  String get fishing_golden;

  /// No description provided for @fishing_noGolden.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay không có khung giờ đạt ≥ 7 điểm.'**
  String get fishing_noGolden;

  /// No description provided for @fishing_next7.
  ///
  /// In vi, this message translates to:
  /// **'7 ngày tới'**
  String get fishing_next7;

  /// No description provided for @fishing_level.
  ///
  /// In vi, this message translates to:
  /// **'{score}/10 · {label}'**
  String fishing_level(String score, String label);

  /// No description provided for @fishing_levelGood.
  ///
  /// In vi, this message translates to:
  /// **'Tốt'**
  String get fishing_levelGood;

  /// No description provided for @fishing_levelFair.
  ///
  /// In vi, this message translates to:
  /// **'Khá'**
  String get fishing_levelFair;

  /// No description provided for @fishing_levelPoor.
  ///
  /// In vi, this message translates to:
  /// **'Kém'**
  String get fishing_levelPoor;

  /// No description provided for @fishing_warnRed.
  ///
  /// In vi, this message translates to:
  /// **'Có dông/sét hoặc gió giật mạnh lúc {from}–{to} — không nên ra sông/biển trong khung giờ này.'**
  String fishing_warnRed(String from, String to);

  /// No description provided for @fishing_warnYellow.
  ///
  /// In vi, this message translates to:
  /// **'Có thể có dông hoặc mưa lớn lúc {from}–{to} — theo dõi thời tiết.'**
  String fishing_warnYellow(String from, String to);

  /// No description provided for @fishing_levelOutsideWarning.
  ///
  /// In vi, this message translates to:
  /// **'{score}/10 · {label} ngoài khung giờ cảnh báo'**
  String fishing_levelOutsideWarning(String score, String label);

  /// No description provided for @fishing_factor_tide.
  ///
  /// In vi, this message translates to:
  /// **'con nước'**
  String get fishing_factor_tide;

  /// No description provided for @fishing_factor_flow.
  ///
  /// In vi, this message translates to:
  /// **'dòng chảy'**
  String get fishing_factor_flow;

  /// No description provided for @fishing_factor_solunar.
  ///
  /// In vi, this message translates to:
  /// **'giờ trăng'**
  String get fishing_factor_solunar;

  /// No description provided for @fishing_factor_pressure.
  ///
  /// In vi, this message translates to:
  /// **'áp suất'**
  String get fishing_factor_pressure;

  /// No description provided for @fishing_factor_daytime.
  ///
  /// In vi, this message translates to:
  /// **'bình minh/hoàng hôn'**
  String get fishing_factor_daytime;

  /// No description provided for @fishing_factor_weather.
  ///
  /// In vi, this message translates to:
  /// **'thời tiết'**
  String get fishing_factor_weather;

  /// No description provided for @fishing_factor_season.
  ///
  /// In vi, this message translates to:
  /// **'mùa cá'**
  String get fishing_factor_season;

  /// No description provided for @fishing_moon.
  ///
  /// In vi, this message translates to:
  /// **'Trăng: {phase} ({pct}%)'**
  String fishing_moon(String phase, int pct);

  /// No description provided for @fishing_weatherSource.
  ///
  /// In vi, this message translates to:
  /// **'Open-Meteo (dự báo thời tiết)'**
  String get fishing_weatherSource;

  /// No description provided for @moon_newMoon.
  ///
  /// In vi, this message translates to:
  /// **'Trăng non'**
  String get moon_newMoon;

  /// No description provided for @moon_waxingCrescent.
  ///
  /// In vi, this message translates to:
  /// **'Trăng lưỡi liềm đầu tháng'**
  String get moon_waxingCrescent;

  /// No description provided for @moon_firstQuarter.
  ///
  /// In vi, this message translates to:
  /// **'Trăng thượng huyền'**
  String get moon_firstQuarter;

  /// No description provided for @moon_waxingGibbous.
  ///
  /// In vi, this message translates to:
  /// **'Trăng khuyết đầu tháng'**
  String get moon_waxingGibbous;

  /// No description provided for @moon_fullMoon.
  ///
  /// In vi, this message translates to:
  /// **'Trăng tròn'**
  String get moon_fullMoon;

  /// No description provided for @moon_waningGibbous.
  ///
  /// In vi, this message translates to:
  /// **'Trăng khuyết cuối tháng'**
  String get moon_waningGibbous;

  /// No description provided for @moon_lastQuarter.
  ///
  /// In vi, this message translates to:
  /// **'Trăng hạ huyền'**
  String get moon_lastQuarter;

  /// No description provided for @moon_waningCrescent.
  ///
  /// In vi, this message translates to:
  /// **'Trăng lưỡi liềm cuối tháng'**
  String get moon_waningCrescent;

  /// No description provided for @more_info.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin ứng dụng'**
  String get more_info;

  /// No description provided for @more_appName.
  ///
  /// In vi, this message translates to:
  /// **'Con Nước'**
  String get more_appName;

  /// No description provided for @more_build.
  ///
  /// In vi, this message translates to:
  /// **'Bản dựng {sha}'**
  String more_build(String sha);

  /// No description provided for @more_update.
  ///
  /// In vi, this message translates to:
  /// **'Có phiên bản mới — tải lại trang để cập nhật'**
  String get more_update;

  /// No description provided for @more_close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get more_close;

  /// No description provided for @more_title.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get more_title;

  /// No description provided for @more_explore.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get more_explore;

  /// No description provided for @more_app.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng'**
  String get more_app;

  /// No description provided for @more_journalHint.
  ///
  /// In vi, this message translates to:
  /// **'Mẻ cá của bạn và thói quen câu'**
  String get more_journalHint;

  /// No description provided for @more_profileHint.
  ///
  /// In vi, this message translates to:
  /// **'Tên hiện trên bình luận, kèo câu, đánh giá'**
  String get more_profileHint;

  /// No description provided for @more_editName.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên'**
  String get more_editName;

  /// No description provided for @more_theme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get more_theme;

  /// No description provided for @more_themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo máy'**
  String get more_themeSystem;

  /// No description provided for @more_themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get more_themeLight;

  /// No description provided for @more_themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get more_themeDark;

  /// No description provided for @more_sources.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn dữ liệu'**
  String get more_sources;

  /// No description provided for @more_sourcesBody.
  ///
  /// In vi, this message translates to:
  /// **'• IOC Sea Level Monitoring — thực đo mực nước biển Vũng Tàu, Quy Nhơn (mỗi phút). Dự báo triều tại 2 trạm này tính bằng phân tích điều hòa (utide) từ 12 tháng số liệu; kiểm thử ngược: sai số ±10 cm (Vũng Tàu), ±7 cm (Quy Nhơn).\n• Trung tâm Dự báo KTTV quốc gia — bản tin thủy văn hạn ngắn: mực nước sông 4 mốc/ngày + dự báo. Đường từng giờ do app ước tính (ghép triều cửa sông); kiểm thử ngược: ±12 cm (Hà Nội), ±11 cm (Nam Đàn).\n• Open-Meteo — thời tiết, sóng và mô hình mực nước biển ven bờ.\n• GloFAS (qua Open-Meteo Flood) — lưu lượng dòng chính các sông, theo ngày.\n• Điểm bất kỳ trên bản đồ: mô hình biển tại điểm đó; trên sông Hồng, sông Cả thì tính theo vị trí dọc sông; nơi khác dùng trạm sông KTTV gần nhất (trong 40 km), triều ven bờ (ước tính) hoặc lưu lượng sông.\n• Bản đồ nền: OpenFreeMap · © OpenMapTiles · dữ liệu © OpenStreetMap.\n• Ảnh vệ tinh: EOxCloudless (EOX IT Services GmbH), chứa dữ liệu Copernicus Sentinel 2025.\nMọi số liệu dự báo/ước tính chỉ mang tính tham khảo. Chi tiết nguồn, mốc cao độ và độ tin cậy của từng trạm xem ở tab Thông tin của trạm.'**
  String get more_sourcesBody;

  /// No description provided for @more_version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {version}'**
  String more_version(String version);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
