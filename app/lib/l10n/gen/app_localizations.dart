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
  /// **'Tìm trạm (gõ không dấu cũng được)'**
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
  /// **'App dùng vị trí để đưa bản đồ tới chỗ bạn đang đứng. Vị trí chỉ dùng trên máy, không lưu và không gửi đi.'**
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
  /// **'Vào Cài đặt → Ứng dụng → Con Nước → Quyền → Vị trí để bật lại.'**
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
  /// **'Mất dữ liệu quá 6 giờ'**
  String get map_legendStale;

  /// No description provided for @map_legendCluster.
  ///
  /// In vi, this message translates to:
  /// **'Vòng có số: nhóm trạm gần nhau, chạm để phóng to. Màu vòng là màu của trạm nghiêm trọng nhất.'**
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
  /// **'Chưa có dữ liệu mực nước cho điểm này: không có biển gần và không có trạm sông KTTV nào trong vòng 40 km.'**
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
  /// **'Hằng số triều tính từ số liệu {from} → {to}'**
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
  /// **'Bạn chưa theo dõi trạm nào. Mở một trạm và bấm ⭐ để thêm.'**
  String get watch_empty;

  /// No description provided for @fishing_title.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ số câu cá'**
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
  /// **'solunar'**
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

  /// No description provided for @more_title.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get more_title;

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
  /// **'• IOC Sea Level Monitoring — thực đo mực nước biển Vũng Tàu, Quy Nhơn (mỗi phút).\n• Open-Meteo — dự báo thời tiết và mô hình mực nước biển (gói miễn phí, phi thương mại).\n• Dự báo triều tại trạm có máy đo: tính bằng phân tích điều hòa (utide) từ 12 tháng số liệu IOC.\nMọi số liệu dự báo/ước tính chỉ mang tính tham khảo.'**
  String get more_sourcesBody;

  /// No description provided for @more_about.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get more_about;

  /// No description provided for @more_aboutBody.
  ///
  /// In vi, this message translates to:
  /// **'Con Nước — bản dùng thử V0. Không có máy chủ: app lấy dữ liệu trực tiếp từ nguồn miễn phí và tính toán trên máy.'**
  String get more_aboutBody;

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
