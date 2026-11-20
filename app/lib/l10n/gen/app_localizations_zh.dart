// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Con Nước';

  @override
  String get common_retry => '重试';

  @override
  String get common_loading => '加载中…';

  @override
  String get common_empty => '暂无数据';

  @override
  String get common_reference => '仅供参考';

  @override
  String get common_estimate => '估算';

  @override
  String common_source(String source) {
    return '来源：$source';
  }

  @override
  String common_staleBanner(String time) {
    return '离线 · 更新于 $time';
  }

  @override
  String common_updatedAt(String time) {
    return '更新于 $time';
  }

  @override
  String get common_today => '今天';

  @override
  String get common_tomorrow => '明天';

  @override
  String get error_network => '无法连接。请检查网络后重试。';

  @override
  String get error_timeout => '数据源响应缓慢，请稍后重试。';

  @override
  String get error_server => '数据源暂时中断。';

  @override
  String get error_parse => '源数据无效。';

  @override
  String get error_notFound => '未找到。';

  @override
  String get error_offlineNoCache => '您处于离线状态，且尚无已保存的数据。';

  @override
  String get error_unknown => '出错了，请稍后重试。';

  @override
  String get dataKind_observed => '实测';

  @override
  String get dataKind_forecast => '预报 · 仅供参考';

  @override
  String get dataKind_estimate => '估算';

  @override
  String get tide_rising => '正在涨潮';

  @override
  String get tide_risingFast => '快速上涨';

  @override
  String get tide_slack => '平潮';

  @override
  String get tide_falling => '正在退潮';

  @override
  String get tide_fallingFast => '快速下降';

  @override
  String get tide_high => '高潮';

  @override
  String get tide_low => '低潮';

  @override
  String get tide_turning => '正在转潮';

  @override
  String get tide_spring => '大潮';

  @override
  String get tide_neap => '小潮';

  @override
  String get tide_normal => '中潮';

  @override
  String tide_countdownHigh(String duration) {
    return '$duration后高潮';
  }

  @override
  String tide_countdownLow(String duration) {
    return '$duration后低潮';
  }

  @override
  String tide_extremeAt(String time, String level) {
    return '$time · 预计 $level';
  }

  @override
  String tide_nextOther(String kind, String time, String level) {
    return '下一次$kind：$time · $level';
  }

  @override
  String get tide_noPrediction => '该站暂无潮汐预报';

  @override
  String tide_correctedBy(String delta) {
    return '已按实测校正（偏差 $delta）';
  }

  @override
  String duration_hm(int hours, int minutes) {
    return '$hours小时$minutes分钟';
  }

  @override
  String duration_m(int minutes) {
    return '$minutes分钟';
  }

  @override
  String confidence_label(String level) {
    return '预报可信度：$level';
  }

  @override
  String get confidence_high => '高';

  @override
  String get confidence_medium => '中';

  @override
  String get confidence_low => '低';

  @override
  String skill_backtest(String cm, String min) {
    return '回测：误差 ±$cm cm，高/低潮时间 ±$min 分钟';
  }

  @override
  String skill_live(int days, String cm, String min) {
    return '近 $days 天误差：±$cm cm，±$min 分钟';
  }

  @override
  String get skill_unknown => '此处尚未测得误差';

  @override
  String get nav_map => '地图';

  @override
  String get map_searchHint => '搜索乡、坊、桥、码头、坐标…';

  @override
  String get map_searchNone => '未找到匹配的站点';

  @override
  String get map_openDetail => '查看详情';

  @override
  String map_nextExtreme(String kind, String time, String level, String duration) {
    return '$kind $time ≈ $level · 还有 $duration';
  }

  @override
  String tide_moreRise(int cm) {
    return '水位还将上涨约 $cm cm';
  }

  @override
  String tide_moreFall(int cm) {
    return '水位还将下降约 $cm cm';
  }

  @override
  String get map_locate => '我的位置';

  @override
  String get map_locRationaleTitle => '使用您的位置？';

  @override
  String get map_locRationaleBody =>
      '应用使用位置将地图移到您所在的地方。位置只保存在本机（大致记住约 1 km 范围，以便下次更快打开），不会发送到任何地方。';

  @override
  String get map_locAllow => '允许';

  @override
  String get map_later => '以后再说';

  @override
  String get map_locServiceOff => '定位已关闭。请在设备上开启定位后重试。';

  @override
  String get map_locDenied => '尚未获得位置权限。';

  @override
  String get map_locDeniedForeverTitle => '位置权限已被阻止';

  @override
  String get map_locDeniedForeverBody => '前往 设置 > 应用 > Con Nước > 权限 > 位置 重新开启。';

  @override
  String get map_openSettings => '打开设置';

  @override
  String get map_locFailed => '无法获取位置，请稍后重试。';

  @override
  String get map_outsideVn => '该位置不在支持范围内';

  @override
  String get map_layers => '地图图层';

  @override
  String get map_layerStandard => '标准地图';

  @override
  String get map_layerStandardHint => '道路、地名、河流湖泊（OpenFreeMap）';

  @override
  String get map_layerSatellite => '卫星图像';

  @override
  String get map_layerSatelliteHint => 'Sentinel-2 2025 年，分辨率 10 m — 河流、滩地、农田清晰可见；看不清单栋房屋';

  @override
  String get map_satelliteCredit =>
      '卫星图像：EOxCloudless (EOX IT Services) · 含 Copernicus Sentinel 2025 数据';

  @override
  String get map_filter => '筛选';

  @override
  String get map_filterOnlyTide => '仅显示有潮汐的站点';

  @override
  String get map_filterOnlyAlarm => '仅显示正在警报的站点';

  @override
  String get map_filterHideStale => '隐藏无数据的站点';

  @override
  String get map_filterNone => '没有符合筛选条件的站点';

  @override
  String get map_legend => '图例';

  @override
  String get map_legendNormal => '正常';

  @override
  String get map_legendAlarm1 => 'I 级警报';

  @override
  String get map_legendAlarm2 => 'II 级警报';

  @override
  String get map_legendAlarm3 => 'III 级警报';

  @override
  String get map_legendStale => '超过 6 小时无数据（灰色图钉、淡色鱼）';

  @override
  String get map_legendSpot => '社区钓点';

  @override
  String get map_legendCluster => '带数字的圆圈：一组相近的站点，点按可放大。圆圈颜色为组内最高的鱼活跃度；如有站点处于警报，则显示警报颜色。';

  @override
  String get map_legendNote => '海洋站点尚无警报阈值；警报颜色将在后续阶段用于河流站点。';

  @override
  String get map_hoangSa => 'Hoàng Sa 群岛（越南）';

  @override
  String get map_truongSa => 'Trường Sa 群岛（越南）';

  @override
  String get map_close => '关闭';

  @override
  String get map_stationsError => '无法加载站点列表';

  @override
  String get map_baseMapCredit => '底图：OpenFreeMap · © OpenMapTiles · 数据 © OpenStreetMap';

  @override
  String get nav_stations => '站点';

  @override
  String get nav_watch => '关注';

  @override
  String get nav_fishing => '钓鱼';

  @override
  String get nav_more => '更多';

  @override
  String get stations_title => '水位与潮汐站';

  @override
  String get stations_kindGauge => '有测量仪';

  @override
  String get stations_kindModel => '模型';

  @override
  String get stations_coordApprox => '近似坐标';

  @override
  String get station_tabOverview => '概览';

  @override
  String get station_tabHourly => '逐时';

  @override
  String get station_tabCalendar => '潮汐日历';

  @override
  String get station_tabInfo => '信息';

  @override
  String level_lastKnown(String time) {
    return '最新读数于 $time · 本小时暂无读数';
  }

  @override
  String get calendar_prev => '上个月';

  @override
  String get calendar_next => '下个月';

  @override
  String calendar_month(int month, int year) {
    return '$year年$month月';
  }

  @override
  String get calendar_noTideDay => '这一天暂无潮汐预报';

  @override
  String get calendar_noTideMonth => '本月暂无潮汐预报，仍可查看农历和月相';

  @override
  String get calendar_rangeLegend => '日潮差';

  @override
  String get calendar_lunarLegend => '红字：农历初一、十五';

  @override
  String moon_times(String rise, String set) {
    return '月出 $rise · 月落 $set';
  }

  @override
  String get moon_alwaysUp => '月亮全天在天上';

  @override
  String get moon_alwaysDown => '今天月亮不升起';

  @override
  String get solunar_title => '月相觅食时间';

  @override
  String get solunar_titleGood => '月相觅食时间 · 好日子（临近满月/新月）';

  @override
  String solunar_major(String range) {
    return '主要时段 $range';
  }

  @override
  String solunar_minor(String range) {
    return '次要时段 $range';
  }

  @override
  String get solunar_now => '正在进行';

  @override
  String get summary_title => '此时此地';

  @override
  String summary_water(String state, String extreme, String time, String wait) {
    return '$state，$extreme于 $time（还有 $wait）';
  }

  @override
  String summary_fishing(String score, String label) {
    return '垂钓 $score/10 $label';
  }

  @override
  String summary_wind(int kmh) {
    return '风速 $kmh km/h';
  }

  @override
  String get map_goFishing => '马上去钓';

  @override
  String get hazard_title => '注意';

  @override
  String get hazard_titleSevere => '危险 — 不要下河';

  @override
  String hazard_at(String time) {
    return '$time';
  }

  @override
  String hazard_between(String from, String to) {
    return '$from–$to';
  }

  @override
  String get hazard_thunderstorm => '雷暴、闪电：上岸，远离空旷处和鱼竿';

  @override
  String get hazard_gust => '阵风超过 50 km/h：不要出船';

  @override
  String get hazard_heavyRain => '大雨超过 20 mm/小时';

  @override
  String get hazard_possibleStorm => '天气不稳定，可能有雷暴';

  @override
  String get hazard_risingFast => '水位异常快速上涨（明显快于前几天）：远离低洼河滩、沙洲';

  @override
  String get hazard_flood => '明天河流流量大幅增加（上游大雨）：水位升高、浑浊、湍急';

  @override
  String get watch_edit => '命名、备注、分组';

  @override
  String get watch_editTitle => '您的钓点';

  @override
  String get watch_label => '自定义名称';

  @override
  String get watch_labelHint => '例如 榕树下深坑';

  @override
  String get watch_note => '备注';

  @override
  String get watch_noteHint => '例如 用蚯蚓做饵，回水处';

  @override
  String get watch_group => '分组';

  @override
  String get watch_groupHint => '例如 红河、湖泊';

  @override
  String get watch_noGroup => '未分组';

  @override
  String get common_save => '保存';

  @override
  String get common_cancel => '取消';

  @override
  String get trip_title => '规划钓鱼行程';

  @override
  String get trip_open => '规划';

  @override
  String get trip_noPlaces => '保存几个钓点（在地图上点 ⭐），应用就能为您找出最佳垂钓时间。';

  @override
  String trip_intro(int count) {
    return '未来 7 天在 $count 个已保存钓点的最佳垂钓时间，按各钓点的潮汐、月亮和天气计算。';
  }

  @override
  String get trip_none => '未来 7 天已保存钓点中没有达到 7/10 及以上的时段。';

  @override
  String trip_score(String score) {
    return '最高垂钓评分 $score/10';
  }

  @override
  String trip_because(String reasons) {
    return '好在：$reasons';
  }

  @override
  String get trip_note => '备注';

  @override
  String get where_title => '今天去哪钓？';

  @override
  String get where_short => '去哪钓？';

  @override
  String get more_shortcuts => '快捷方式';

  @override
  String get trip_listDetail => '查看并加入附近的钓鱼约局';

  @override
  String get trip_createDetail => '约钓友一起去钓，附黄金时段建议';

  @override
  String get checkin_detail => '告诉钓友您正在这里钓鱼（匿名，4 小时）';

  @override
  String get checkin_peopleDetail => '哪里有人在钓，谁正在上鱼';

  @override
  String get spot_listDetail => '钓友标记的钓点，附照片和评论';

  @override
  String get where_entryHint => '未来 24 小时您附近的最佳钓点';

  @override
  String get where_radius => '范围';

  @override
  String where_km(int km) {
    return '$km 公里';
  }

  @override
  String where_around(String place) {
    return '$place附近';
  }

  @override
  String get where_aroundHere => '您所在位置附近';

  @override
  String get where_aroundLast => '您上次位置附近（点 ◎ 更新）';

  @override
  String get where_needLocation => '告诉应用您在哪里，以查找最近的钓点。';

  @override
  String get where_useLocation => '使用我的位置';

  @override
  String get where_refresh => '更新位置';

  @override
  String get where_kindHere => '您所在位置';

  @override
  String get where_kindStation => '测站';

  @override
  String get where_kindSaved => '已保存钓点';

  @override
  String get where_kindCommunity => '社区钓点';

  @override
  String where_distance(String km) {
    return '距离 $km km';
  }

  @override
  String where_golden(String when) {
    return '黄金时段 $when';
  }

  @override
  String where_bestHour(String when) {
    return '暂无黄金时段 · 较佳时间 $when';
  }

  @override
  String get where_unsafe => '该时段有天气警告';

  @override
  String get where_loading => '正在计算垂钓评分…';

  @override
  String get where_failed => '无法加载该钓点的数据';

  @override
  String get where_onMap => '查看地图';

  @override
  String get where_fishHere => '在这里钓';

  @override
  String where_rank(int rank) {
    return '第 $rank 名';
  }

  @override
  String get where_note =>
      '按未来 24 小时的估算垂钓评分排序（潮汐、月亮时段、昼夜、Open-Meteo 天气）— 仅供参考。社区钓点由用户标记。最多显示最近的 8 个钓点。';

  @override
  String get where_onlyHere => '此范围内没有测站、已保存钓点或社区钓点 — 只能计算您所在的位置。请尝试更大的范围。';

  @override
  String get habit_title => '您的垂钓习惯';

  @override
  String habit_needMore(int count) {
    return '再记录 $count 次渔获，应用就能找出您常上鱼的时机。';
  }

  @override
  String habit_progress(int have, int need) {
    return '$have/$need 次';
  }

  @override
  String habit_none(int count) {
    return '$count 次渔获中暂未发现突出的条件。继续记录吧。';
  }

  @override
  String habit_hits(int hits, int known) {
    return '$hits/$known 次';
  }

  @override
  String get habit_note => '根据您设备上的日志统计，并非确定规律。您常去钓的时段自然渔获更多。';

  @override
  String get habit_match => '与您以往上鱼时相似';

  @override
  String get habit_dawn => '黎明时';

  @override
  String get habit_morning => '上午';

  @override
  String get habit_midday => '中午';

  @override
  String get habit_afternoon => '下午';

  @override
  String get habit_dusk => '黄昏时';

  @override
  String get habit_night => '夜间';

  @override
  String get habit_rising => '涨潮时';

  @override
  String get habit_falling => '退潮时';

  @override
  String get habit_slack => '平潮时（转潮）';

  @override
  String get habit_newMoon => '新月前后（农历月末/月初）';

  @override
  String get habit_fullMoon => '满月前后（十五）';

  @override
  String get habit_quarter => '半月日';

  @override
  String get habit_major => '在主要月相时段内';

  @override
  String get habit_minor => '在次要月相时段内';

  @override
  String get habit_noSolunar => '在月相时段之外';

  @override
  String get habit_calm => '无风时（低于 10 km/h）';

  @override
  String get habit_light => '微风时（10–20 km/h）';

  @override
  String get habit_strong => '大风时（超过 20 km/h）';

  @override
  String get journal_title => '钓鱼日志';

  @override
  String get journal_open => '日志';

  @override
  String get journal_add => '记录渔获';

  @override
  String get journal_empty => '还没有渔获。每次钓到鱼后点“记录渔获”：应用会自动保存当时的水位、潮汐、天气和月亮。';

  @override
  String journal_place(String name) {
    return '地点：$name';
  }

  @override
  String get journal_placeHint => '这是“钓鱼”标签页中选中的钓点。如需更改请到那里修改。';

  @override
  String get journal_changeTime => '更改时间';

  @override
  String get journal_species => '鱼种';

  @override
  String get journal_weight => '重量 (kg)';

  @override
  String get journal_length => '长度 (cm)';

  @override
  String get journal_bait => '饵料';

  @override
  String get journal_note => '备注';

  @override
  String get journal_camera => '拍照';

  @override
  String get journal_gallery => '选择照片';

  @override
  String get journal_removePhoto => '移除照片';

  @override
  String get journal_photoError => '无法读取这张照片';

  @override
  String get journal_needSpecies => '请输入鱼种';

  @override
  String get journal_privacy => '日志和照片仅保存在本机。照片中的 GPS 位置信息已被移除。';

  @override
  String get journal_statsTitle => '您的垂钓情况';

  @override
  String journal_statsCount(int count, String kg) {
    return '$count 次 · 共 $kg kg';
  }

  @override
  String journal_statsTop(String species, int count) {
    return '钓到最多：$species（$count 次）';
  }

  @override
  String journal_statsRising(int pct) {
    return '$pct% 的渔获在涨潮时';
  }

  @override
  String journal_statsFalling(int pct) {
    return '$pct% 的渔获在退潮时';
  }

  @override
  String journal_water(String state) {
    return '水位$state';
  }

  @override
  String get journal_conditions => '垂钓时的条件';

  @override
  String journal_weightValue(String kg) {
    return '重 $kg kg';
  }

  @override
  String journal_lengthValue(int cm) {
    return '长 $cm cm';
  }

  @override
  String journal_baitValue(String bait) {
    return '饵料：$bait';
  }

  @override
  String journal_levelValue(String level) {
    return '水位 $level';
  }

  @override
  String journal_scoreValue(String score) {
    return '垂钓评分 $score/10';
  }

  @override
  String get journal_delete => '删除';

  @override
  String get journal_deleteTitle => '从日志中删除这条渔获？';

  @override
  String get place_city => '城市、市镇';

  @override
  String get place_ward => '居民区、村庄';

  @override
  String get place_bridge => '桥';

  @override
  String get place_ferry => '渡口';

  @override
  String get place_wharf => '码头';

  @override
  String place_near(String kind, String town) {
    return '$kind · 靠近 $town';
  }

  @override
  String get share_action => '分享';

  @override
  String share_text(String place) {
    return 'Con Nước · $place';
  }

  @override
  String share_level(String level) {
    return '水位 $level';
  }

  @override
  String share_score(String score) {
    return '垂钓评分 $score/10';
  }

  @override
  String get share_copied => '已复制内容和链接，粘贴到 Zalo/Facebook 即可发送';

  @override
  String get share_footer => '计算数据，仅供参考 · Con Nước';

  @override
  String get more_outdoor => '户外模式';

  @override
  String get more_outdoorHint => '高对比度、更大字体：烈日下也看得清';

  @override
  String get map_legendFlowRising => '正在涨水的河段';

  @override
  String get map_legendFlowFalling => '正在退水的河段';

  @override
  String get map_legendFlowSlack => '平潮的河段';

  @override
  String get map_legendFlowNote => '每段河道单独着色（潮水到达各段的时间不同），每 10 分钟更新一次。流动的条纹表示河水流向大海的方向。';

  @override
  String get map_layerWeather => '附近的雨和风';

  @override
  String get map_layerWeatherHint => '蓝点：未来 1 小时的降雨（越大雨越多）。箭头：风吹去的方向。放大想查看的区域。';

  @override
  String hazard_surge(int cm) {
    return '海平面比正常潮位高 $cm cm（强风或风暴推水入岸）：低洼海滩、河口易被淹';
  }

  @override
  String get more_install => '将 Con Nước 添加到主屏幕';

  @override
  String get more_installHow =>
      'Android（Chrome）：点 ⋮ 然后选择“安装应用”。iPhone（Safari）：点“分享”按钮然后选择“添加到主屏幕”。像真正的应用一样快速打开，无需应用商店。';

  @override
  String get alert_channel => '潮汐提醒';

  @override
  String get alert_channelHint => '在已保存钓点的高潮、低潮和适合垂钓的时段前提醒';

  @override
  String alert_highTitle(String place, String time) {
    return '$place：高潮 $time';
  }

  @override
  String alert_lowTitle(String place, String time) {
    return '$place：低潮 $time';
  }

  @override
  String alert_levelBody(String level, int minutes) {
    return '水位约 $level，还有 $minutes 分钟';
  }

  @override
  String alert_fishTitle(String place, String from, String to) {
    return '$place：适钓时段 $from–$to';
  }

  @override
  String alert_fishBody(String score, int minutes) {
    return '垂钓评分 $score/10，$minutes 分钟后开始';
  }

  @override
  String get alert_toggleOn => '开启潮汐提醒';

  @override
  String get alert_toggleOff => '关闭潮汐提醒';

  @override
  String get alert_onSnack => '已为此钓点开启提醒。可通过顶部的 ⚙ 按钮调整提醒类型和提前时间。';

  @override
  String alert_fishBodyLike(String score, int minutes) {
    return '✨ 与您以往上鱼时相似 · 垂钓评分 $score/10，$minutes 分钟后开始';
  }

  @override
  String get alert_settings => '提醒设置';

  @override
  String get alert_golden => '黄金时段前提醒';

  @override
  String get alert_goldenHint => '仅在该时段没有雷暴、阵风、大雨警告时提醒';

  @override
  String get alert_tides => '高潮 / 低潮前提醒';

  @override
  String get alert_lead => '提前提醒';

  @override
  String alert_leadMin(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get alert_howTo => '在“关注”列表中为每个钓点开启铃铛。应用每次打开时会重新安排提醒（未来 7 天）。';

  @override
  String get alert_getApk => '下载 Android 应用';

  @override
  String get alert_denied => '尚未允许发送通知。请在 设置 > 应用 > Con Nước > 通知 中开启。';

  @override
  String get alert_webOnly => '提醒仅在 Android 应用中可用（浏览器关闭后无法响铃）';

  @override
  String get more_apk => '下载 Android 应用（APK）';

  @override
  String get more_apkHint => '增加潮汐提醒和主屏幕小组件。下载后打开文件，并允许从此来源安装。';

  @override
  String get directions_action => '导航';

  @override
  String get directions_failed => '无法在本机打开 Google Maps';

  @override
  String get search_recent => '最近搜索';

  @override
  String get place_province => '省、直辖市';

  @override
  String get place_commune => '坊、乡';

  @override
  String get search_coordsHint => '打开此坐标的水位和垂钓时间';

  @override
  String place_in(String kind, String area) {
    return '$kind · $area';
  }

  @override
  String search_coords(String coords) {
    return '坐标 $coords';
  }

  @override
  String get spot_edit => '编辑';

  @override
  String get spot_editTitle => '编辑钓点';

  @override
  String get spot_save => '保存更改';

  @override
  String get spot_editSaved => '已保存更改';

  @override
  String spot_edited(String date) {
    return '编辑于 $date';
  }

  @override
  String get spot_tooMany => '本机今天已发布 10 个钓点，明天再继续吧。';

  @override
  String spot_comments(int count) {
    return '$count 条评论';
  }

  @override
  String get cmt_title => '评论';

  @override
  String cmt_count(int count) {
    return '评论（$count）';
  }

  @override
  String get cmt_hint => '分享饵料、鱼咬钩时间、怎么去…';

  @override
  String get cmt_send => '发表评论';

  @override
  String get cmt_empty => '还没有评论，来抢沙发吧！';

  @override
  String get cmt_anon => '匿名钓友';

  @override
  String cmt_asName(String name) {
    return '以 $name 的身份评论 · 更改';
  }

  @override
  String get cmt_asAnon => '匿名中 · 设置显示名称';

  @override
  String get cmt_edited => '已编辑';

  @override
  String get cmt_mine => '您的';

  @override
  String get cmt_more => '更多';

  @override
  String get cmt_edit => '编辑评论';

  @override
  String get cmt_delete => '删除';

  @override
  String get cmt_report => '举报';

  @override
  String get cmt_deleteTitle => '删除您的评论？';

  @override
  String get cmt_reportTitle => '举报这条评论？';

  @override
  String get cmt_reportHint => '辱骂、诈骗、广告… 被 3 人举报的评论会自动隐藏。';

  @override
  String get cmt_error => '发送失败，请检查网络后重试';

  @override
  String get cmt_tooFast => '您发得有点快 — 稍等一下再发吧';

  @override
  String get cmt_loadError => '无法加载评论';

  @override
  String get name_title => '显示名称';

  @override
  String get name_hint => '例如 钓手阿庆';

  @override
  String get name_note => '显示在评论、钓鱼约局和消息中。留空 = 匿名。';

  @override
  String get social_save => '保存';

  @override
  String get nav_ponds => '钓场';

  @override
  String get pond_title => '钓鱼场';

  @override
  String get pond_tag => '收费钓场';

  @override
  String get pond_add => '添加钓场';

  @override
  String get pond_addTitle => '添加钓场';

  @override
  String get pond_addHere => '在此添加钓场';

  @override
  String pond_pill(int count) {
    return '$count 个钓场';
  }

  @override
  String pond_pillSoon(int count) {
    return '$count 个钓场即将放鱼';
  }

  @override
  String get pond_pillDetail => '附近的收费钓场与放鱼时间表';

  @override
  String get pond_editTitle => '编辑钓场信息';

  @override
  String get pond_empty => '40 km 内还没有钓场。知道哪里有？点「添加钓场」分享给大家。';

  @override
  String get pond_loadError => '无法加载钓场列表';

  @override
  String get pond_filterRelease => '即将放鱼';

  @override
  String get pond_filterVerified => '已验证';

  @override
  String get pond_filterFollowed => '已关注';

  @override
  String get pond_followedSoon => '你关注的钓场即将放鱼';

  @override
  String get pond_verified => '已验证';

  @override
  String get pond_owner => '场主已认领';

  @override
  String get pond_unverified => '未验证';

  @override
  String get pond_fromWeb => '信息来自网络，可能已过时。到场确认无误的话，请点「钓场真实存在」帮帮大家。';

  @override
  String get pond_approx => '位置按地址估算。附近的朋友可点「编辑」调整图钉。';

  @override
  String pond_distance(String km) {
    return '距离 $km';
  }

  @override
  String pond_rating(String rating, int count) {
    return '$rating ★（$count）';
  }

  @override
  String get pond_noRating => '暂无评分';

  @override
  String pond_releaseChip(String when) {
    return '$when 放鱼';
  }

  @override
  String pond_releaseKg(String when, String amount) {
    return '$when · $amount';
  }

  @override
  String pond_kg(String kg) {
    return '$kg 公斤';
  }

  @override
  String pond_ta(String ta) {
    return '$ta 公担';
  }

  @override
  String pond_ton(String ton) {
    return '$ton 吨';
  }

  @override
  String get pond_releases => '放鱼时间表';

  @override
  String get pond_noRelease => '暂无即将到来的放鱼。';

  @override
  String get pond_official => '场主发布';

  @override
  String get pond_relayed => '用户报告 · 未确认';

  @override
  String get pond_releasePast => '已放鱼';

  @override
  String get pond_releaseCancelled => '已取消';

  @override
  String get pond_postRelease => '报告放鱼';

  @override
  String get pond_showSource => '查看原帖';

  @override
  String get pond_cancelRelease => '取消此次放鱼';

  @override
  String get pond_reportRelease => '报告错误';

  @override
  String get pond_follow => '关注';

  @override
  String get pond_following => '已关注';

  @override
  String get pond_followHint => '此钓场有新放鱼时会显示在列表顶部（Android 应用会响铃提醒）。';

  @override
  String get pond_call => '拨打';

  @override
  String get pond_price => '票价';

  @override
  String get pond_hours => '营业时间';

  @override
  String get pond_species => '塘中鱼种';

  @override
  String get pond_note => '备注';

  @override
  String get pond_sources => '来源';

  @override
  String get pond_pulseTitle => '钓场现况（过去 6 小时）';

  @override
  String get pond_pulseBusy => '人多';

  @override
  String get pond_pulseQuiet => '人少';

  @override
  String get pond_pulseBiting => '鱼在咬钩';

  @override
  String get pond_pulseReleased => '刚放鱼';

  @override
  String pond_pulseCount(String label, int count) {
    return '$label · $count';
  }

  @override
  String get pond_pulseSent => '已发送，谢谢你！';

  @override
  String get pond_pulseWait => '每 30 分钟只能报告一次哦';

  @override
  String get pond_confirm => '钓场真实存在';

  @override
  String get pond_confirmed => '你已确认';

  @override
  String get pond_confirmDone => '谢谢！满 3 人确认后钓场会显示 ✓';

  @override
  String get pond_edit => '编辑';

  @override
  String get pond_claim => '我是场主';

  @override
  String get pond_claimTitle => '认领钓场';

  @override
  String get pond_claimBody => '为防冒充，管理员会致电或通过 Zalo 联系你确认。审核通过后，你可以发布「官方」放鱼时间表，并修改票价和营业时间。';

  @override
  String get pond_claimContact => '钓场电话 / Zalo';

  @override
  String get pond_claimNote => '留言（选填）';

  @override
  String get pond_claimSend => '发送申请';

  @override
  String get pond_claimSent => '已发送！管理员会尽快联系你。';

  @override
  String get pond_claimPending => '你的申请正在等待审核。';

  @override
  String get pond_claimOwned => '此钓场已有场主管理。';

  @override
  String get pond_claimYours => '你是此钓场的场主。';

  @override
  String get pond_report => '举报';

  @override
  String get pond_reportTitle => '举报此钓场？';

  @override
  String get pond_reportHint => '钓场不存在、已关闭、位置错误……无场主的钓场被 3 人举报后会自动隐藏。';

  @override
  String get pond_error => '发送失败，请检查网络后重试';

  @override
  String get pond_tooMany => '你今天操作有点多，明天再试吧';

  @override
  String get pond_duplicate => '这里已有钓场在列表中。打开它？';

  @override
  String get pond_open => '打开';

  @override
  String get pond_name => '钓场名称';

  @override
  String get pond_nameHint => '例：Thanh Hà 钓场';

  @override
  String get pond_address => '地址';

  @override
  String get pond_phone => '电话 / Zalo';

  @override
  String get pond_priceHint => '例：200k/场 4 小时，350k/天';

  @override
  String get pond_hoursHint => '例：6:00–18:00，周一休息';

  @override
  String pond_location(String coords) {
    return '图钉位置：$coords';
  }

  @override
  String get pond_locationHint => '图钉放在你在地图上选的位置。要更改：在地图上点准钓场 → 添加钓场。';

  @override
  String get pond_save => '保存';

  @override
  String get pond_added => '钓场已添加！谢谢你。';

  @override
  String get pond_saved => '已保存';

  @override
  String get pond_needName => '请输入钓场名称（至少 2 个字符）';

  @override
  String get pond_reviews => '评价';

  @override
  String get pond_writeReview => '写评价';

  @override
  String get pond_reviewHint => '鱼好不好钓、价格、服务、钓位……';

  @override
  String get pond_reviewSend => '发布评价';

  @override
  String get pond_reviewEmpty => '暂无评价。';

  @override
  String get pond_deleteReview => '删除我的评价';

  @override
  String get pond_noStars => '请选择星级';

  @override
  String get release_title => '报告放鱼';

  @override
  String get release_paste => '粘贴钓场的帖子';

  @override
  String get release_pasteHint => '复制钓场的 Facebook 帖子 / TikTok 文案后粘贴到这里。应用会自动读取日期、时间、鱼种和数量。';

  @override
  String get release_pasteButton => '粘贴';

  @override
  String get release_read => '应用识别到';

  @override
  String get release_notFound => '帖子里没找到放鱼日期，请在下方选择日期。';

  @override
  String get release_day => '日期';

  @override
  String get release_time => '时间';

  @override
  String get release_fish => '放流鱼种';

  @override
  String get release_addFish => '添加鱼种';

  @override
  String get release_fishName => '鱼种';

  @override
  String get release_fishKg => '公斤';

  @override
  String release_total(String amount) {
    return '共 $amount';
  }

  @override
  String get release_asOwner => '你是场主：此时间表将显示为「场主发布」。';

  @override
  String get release_asUser => '你报告的时间表会显示为「用户报告」，直到场主确认。请只在看到钓场真实发布时再报告哦。';

  @override
  String get release_post => '发布放鱼时间';

  @override
  String get release_posted => '放鱼时间已发布！';

  @override
  String get release_needDay => '请选择放鱼日期';

  @override
  String get stations_menu => '测站列表';

  @override
  String get stations_menuHint => 'KTTV、IOC 各测站的水位';

  @override
  String get trip_tag => '钓鱼约局';

  @override
  String trip_pill(int count) {
    return '$count 个钓鱼约局';
  }

  @override
  String get trip_create => '约人钓鱼';

  @override
  String get trip_createHere => '约人来这里钓鱼';

  @override
  String get trip_formTitle => '创建钓鱼约局';

  @override
  String get trip_editTitle => '编辑钓鱼约局';

  @override
  String get trip_name => '约局名称';

  @override
  String get trip_nameHint => '例：Thanh Trì 桥石滩夜钓';

  @override
  String get trip_place => '集合地点';

  @override
  String get trip_placeHint => '例：桥下石滩，3 号门';

  @override
  String get trip_whereHint => '约局图钉放在这里。想约别处：在地图上点那个位置 → 「约人来这里钓鱼」。';

  @override
  String get trip_when => '时间';

  @override
  String get trip_date => '日期';

  @override
  String get trip_start => '开始';

  @override
  String get trip_duration => '钓多久';

  @override
  String trip_hours(int hours) {
    return '$hours 小时';
  }

  @override
  String get trip_golden => '此地黄金时段（点击选择）';

  @override
  String trip_goldenChip(String when, String score) {
    return '$when · $score';
  }

  @override
  String get trip_noGolden => '未来 3 天此地没有黄金时段';

  @override
  String get trip_people => '最多人数（含你自己）';

  @override
  String get trip_contact => '联系方式（选填）';

  @override
  String get trip_contactHint => 'Zalo/Facebook 群链接或电话号码';

  @override
  String get trip_contactNote => '只有已加入的人才能看到。';

  @override
  String get trip_noteHint => '钓什么、用什么饵、骑摩托还是拼车、分摊油费……';

  @override
  String get trip_submit => '创建约局';

  @override
  String get trip_save => '保存更改';

  @override
  String get trip_created => '约局已创建！附近的钓友会在地图上看到。';

  @override
  String get trip_saved => '约局已保存';

  @override
  String get trip_needName => '请为约局命名（至少 2 个字符）';

  @override
  String get trip_badTime => '开始时间须在未来 30 天内';

  @override
  String get trip_tooMany => '此设备今天已创建 5 个约局，明天再来吧。';

  @override
  String get trip_error => '发送失败，请检查网络后重试';

  @override
  String get trip_tooFew => '约局已有的人数多于此数';

  @override
  String get trip_running => '进行中';

  @override
  String get trip_cancelled => '已取消';

  @override
  String get trip_full => '已满员';

  @override
  String trip_left(int count) {
    return '还剩 $count 个名额';
  }

  @override
  String trip_members(int count, int max) {
    return '$count/$max 人';
  }

  @override
  String trip_owner(String name) {
    return '发起人：$name';
  }

  @override
  String get trip_yours => '你的约局';

  @override
  String get trip_joinedTag => '你已加入';

  @override
  String get trip_join => '加入';

  @override
  String get trip_joinedSnack => '已加入！在下方查看联系方式并与大家聊天。';

  @override
  String get trip_joinFull => '约局已满员';

  @override
  String get trip_joinClosed => '约局已结束或已取消';

  @override
  String get trip_leave => '退出约局';

  @override
  String get trip_leaveTitle => '退出这个约局？';

  @override
  String get trip_cancel => '取消约局';

  @override
  String get trip_cancelTitle => '取消约局？已加入的人会看到「已取消」。';

  @override
  String get trip_edit => '编辑';

  @override
  String get trip_keep => '保留约局';

  @override
  String get trip_share => '邀请更多朋友';

  @override
  String trip_shareText(String title, String when, String place, String map, String app) {
    return '🎣 钓鱼约局：$title\n🕐 $when\n📍 $place\n地图：$map\n在 Con Nước 应用中查看并加入：$app';
  }

  @override
  String get trip_report => '举报';

  @override
  String get trip_reportTitle => '举报此约局？';

  @override
  String get trip_reportHint => '诈骗、广告、不良内容……被 3 人举报的约局会自动隐藏。';

  @override
  String get trip_membersOnly => '加入后可查看联系方式、参加名单并与大家聊天。';

  @override
  String get trip_contactLabel => '联系方式';

  @override
  String get trip_openContact => '打开';

  @override
  String get trip_memberList => '参加的人';

  @override
  String get trip_chat => '约局聊天';

  @override
  String get trip_chatEmpty => '还没有消息。在这里约好碰面时间和停车地点吧。';

  @override
  String get trip_chatHint => '发给全组……';

  @override
  String get trip_send => '发送';

  @override
  String get trip_refresh => '刷新';

  @override
  String get trip_nearbyTitle => '附近的钓鱼约局';

  @override
  String get trip_nearbyEmpty => '30 km 内还没有约局。创建第一个，约上钓友吧！';

  @override
  String get trip_loadError => '无法加载钓鱼约局';

  @override
  String get trip_notice => '约局对附近用户公开。不要约在禁钓区；结伴出行，夜钓注意安全。';

  @override
  String get checkin_pill => '我在钓鱼';

  @override
  String checkin_pillOn(String time) {
    return '钓鱼中 · 剩余 $time';
  }

  @override
  String checkin_count(int count) {
    return '$count 人正在钓鱼';
  }

  @override
  String get checkin_title => '报告「正在这里钓鱼」';

  @override
  String get checkin_body => '附近的钓友会看到这片区域有人在钓鱼。只显示人数，不显示名字；位置约取整到 200 m；4 小时后自动关闭。';

  @override
  String get checkin_biting => '正在上鱼 🐟';

  @override
  String get checkin_noBite => '还没上鱼';

  @override
  String get checkin_start => '开始';

  @override
  String get checkin_update => '更新';

  @override
  String get checkin_stop => '收竿回家';

  @override
  String get checkin_on => '已报告正在钓鱼。祝你钓到大鱼！';

  @override
  String get checkin_off => '已关闭。平安回家哦！';

  @override
  String get checkin_error => '发送失败，请检查网络后重试';

  @override
  String get checkin_needLocation => '需要你的位置才能报告正在钓鱼';

  @override
  String checkin_cellTitle(int count) {
    return '附近有 $count 人正在钓鱼';
  }

  @override
  String checkin_cellBiting(int count) {
    return '$count 人报告正在上鱼';
  }

  @override
  String get checkin_cellNoBite => '还没有人报告上鱼';

  @override
  String checkin_cellLatest(String time) {
    return '最近一人于 $time 到达';
  }

  @override
  String get checkin_cellYou => '包括你';

  @override
  String get checkin_listTitle => '有人在钓鱼的地方';

  @override
  String get checkin_hint => '位置取整约 200 m，不显示任何人的名字。';

  @override
  String get spot_publicTag => '社区钓点';

  @override
  String get spot_pinAction => '公开标记';

  @override
  String spot_nearbyChip(int count) {
    return '$count 个社区钓点';
  }

  @override
  String get spot_nearbyTitle => '附近的钓点';

  @override
  String get spot_nearbyEmpty => '30 km 内还没有钓点。在地图上点一个位置，再点「公开标记」分享你的钓点。';

  @override
  String spot_postedAgo(String date) {
    return '发布于 $date';
  }

  @override
  String spot_distance(String km) {
    return '距离 $km';
  }

  @override
  String get spot_viewWater => '查看此处水情';

  @override
  String get spot_report => '举报';

  @override
  String get spot_reportTitle => '举报此钓点？';

  @override
  String get spot_reportHint => '位置错误、照片不当、广告……被多人举报的钓点会自动隐藏。';

  @override
  String get spot_reportDone => '举报已发送，谢谢你！';

  @override
  String get spot_reportTwice => '你已经举报过这个钓点了';

  @override
  String get spot_delete => '删除我的钓点';

  @override
  String get spot_deleteTitle => '从社区地图上删除这个钓点？';

  @override
  String get spot_ownedByYou => '你的钓点';

  @override
  String get spot_publishTitle => '公开标记钓点';

  @override
  String get spot_name => '钓点名称';

  @override
  String get spot_nameHint => '例：Thanh Trì 桥石滩';

  @override
  String get spot_species => '常钓到的鱼';

  @override
  String get spot_note => '经验';

  @override
  String get spot_noteHint => '鱼饵、好时段、停车处、水深……';

  @override
  String get spot_photos => '照片（最多 3 张）';

  @override
  String get spot_addPhoto => '添加照片';

  @override
  String get spot_publicNotice => '此钓点将对所有 Con Nước 用户公开。请勿发布禁钓区，或未经同意拍到他人的照片。';

  @override
  String get spot_agree => '我已了解并同意分享';

  @override
  String get spot_publish => '发布钓点';

  @override
  String get spot_published => '已标记！附近的人会看到你的钓点。';

  @override
  String get spot_needName => '请为钓点命名（至少 2 个字符）';

  @override
  String get spot_error => '发送失败，请检查网络后重试';

  @override
  String get spot_photoError => '无法读取这张照片';

  @override
  String spot_location(String coords) {
    return '位置：$coords';
  }

  @override
  String get station_levelNow => '当前水位';

  @override
  String get station_follow => '关注测站';

  @override
  String get station_unfollow => '取消关注';

  @override
  String get stations_kindRiver => '河流测站（KTTV）';

  @override
  String get stations_kindRiverDaily => '感潮河段（KTTV）';

  @override
  String get station_sourceRiver => 'KTTV 水文公报（每天 4 次实测 + 预报）· 逐时曲线由应用插值';

  @override
  String get station_sourceRiverTide => 'KTTV 水文公报 + 河口潮汐（Open-Meteo Marine）· 逐时曲线由应用估算';

  @override
  String get station_datumNational => '测站高程基准（依 KTTV 公报）';

  @override
  String station_issued(String time) {
    return 'KTTV 公报发布于 $time';
  }

  @override
  String station_backtestMae(String cm) {
    return '回测：平均误差 ±$cm cm';
  }

  @override
  String station_dailyTitle(int hours) {
    return '$hours 小时内水位（KTTV 公报）';
  }

  @override
  String station_dailyObs(String max, String min) {
    return '实测：最高 $max · 最低 $min';
  }

  @override
  String station_dailyFc(String max, String min) {
    return '预报：最高 $max · 最低 $min';
  }

  @override
  String get station_dailyNoCurve => '公报只给出最高和最低水位，没有时间。为避免误猜涨落时间，应用不绘制曲线。';

  @override
  String station_dailyRangeNow(String range) {
    return '预报变幅 $range — 水位将在此范围内涨落';
  }

  @override
  String get point_estimateHere => '此处估算水位';

  @override
  String get point_onWater => '此点位于水面上（河流、湖泊或海洋）';

  @override
  String get point_onLand => '此点不在河流、湖泊或海洋上。下面的数值是最近水体的水位。';

  @override
  String point_basisRiver(String station, String river, String distance) {
    return '依据 $station 测站（$river 河）· 距离 $distance';
  }

  @override
  String point_basisStation(String station, String distance) {
    return '依据 $station 测站 · 距离 $distance';
  }

  @override
  String point_alongDown(String station, String distance, String river) {
    return '位于 $station 测站下游 $distance，沿 $river 河测量';
  }

  @override
  String point_alongUp(String station, String distance, String river) {
    return '位于 $station 测站上游 $distance，沿 $river 河测量';
  }

  @override
  String point_lagEarlier(int minutes) {
    return '涨落比测站早约 $minutes 分钟';
  }

  @override
  String point_lagLater(int minutes) {
    return '涨落比测站晚约 $minutes 分钟';
  }

  @override
  String get point_lagSame => '涨落与测站几乎同时';

  @override
  String point_meanLower(int cm) {
    return '水面比测站低约 $cm cm';
  }

  @override
  String point_meanHigher(int cm) {
    return '水面比测站高约 $cm cm';
  }

  @override
  String point_celerity(String speed) {
    return '潮波沿河上溯速度约 $speed km/h';
  }

  @override
  String get point_reachNote => '根据沿河位置、在河口潮汐与测站之间估算；尚未用第二个测站验证。';

  @override
  String get flow_unknown => '此处不在任何大河上，暂时无法计算水位和流量。钓鱼时间和天气仍按此确切位置计算。';

  @override
  String get flow_headRising => '河水正在上涨';

  @override
  String get flow_headFalling => '河水正在消退';

  @override
  String get flow_headSteady => '河水平稳';

  @override
  String flow_dayValue(String day, String q) {
    return '$day：$q m³/s';
  }

  @override
  String get loc_nearCoast => '靠近河口';

  @override
  String get point_basisCoast => '潮汐按最近的近岸海域估算；在河内，涨落时间通常更晚，变幅更小。';

  @override
  String get info_noLevelSources =>
      '此处暂无水位数据源。河流流量：GloFAS 模型（经 Open-Meteo Flood），按日。天气、钓鱼时间：Open-Meteo 及按确切坐标的天文计算。所有数据仅供参考。';

  @override
  String get flow_title => '河流流量';

  @override
  String flow_today(String q) {
    return '今日流量 ≈ $q m³/s';
  }

  @override
  String flow_tomorrow(String q, String trend) {
    return '明天 ≈ $q m³/s · $trend';
  }

  @override
  String get flow_rising => '增加中（河水逐渐上涨）';

  @override
  String get flow_falling => '减少中（河水逐渐消退）';

  @override
  String get flow_steady => '平稳';

  @override
  String get flow_note => '按日估算此河段主河道的流量。';

  @override
  String chart_band(String cm) {
    return '曲线周围的阴影带：误差约 ±$cm cm，由测站回测得出';
  }

  @override
  String turn_in(String duration) {
    return '还有 $duration';
  }

  @override
  String day_high(String level, String time) {
    return '最高 $level · $time';
  }

  @override
  String day_low(String level, String time) {
    return '最低 $level · $time';
  }

  @override
  String day_range(int cm) {
    return '差 $cm cm';
  }

  @override
  String get fishAct_title => '鱼活跃度';

  @override
  String get fishAct_low => '低';

  @override
  String get fishAct_fair => '中';

  @override
  String get fishAct_high => '高';

  @override
  String get fishAct_peak => '很高';

  @override
  String fishAct_score(String score) {
    return '$score/10';
  }

  @override
  String fishAct_meter(int count) {
    return '5 条鱼中 $count 条';
  }

  @override
  String fishAct_because(String reasons) {
    return '得益于 $reasons';
  }

  @override
  String fishAct_next(String when) {
    return '下一个黄金时段：$when';
  }

  @override
  String fishAct_inWindow(String to) {
    return '正处于黄金时段，至 $to';
  }

  @override
  String get fishAct_noWindow => '未来 2 天暂无黄金时段';

  @override
  String get fishAct_source => '根据潮汐、月相时间、昼夜和天气（Open-Meteo）估算 — 仅供参考，无法确定哪里有鱼。';

  @override
  String get fishAct_quick => '暂无天气数据：先按潮汐和月相时间估算。';

  @override
  String get fishTime_now => '现在';

  @override
  String fishTime_today(String time) {
    return '今天 $time';
  }

  @override
  String fishTime_tomorrow(String time) {
    return '明天 $time';
  }

  @override
  String fishTime_dayAfter(String time) {
    return '后天 $time';
  }

  @override
  String get fishTime_title => '鱼活跃时间';

  @override
  String get fishTime_slider => '选择时间查看鱼活跃度';

  @override
  String get fishTime_reset => '回到现在';

  @override
  String get fishTime_legendNote => '图钉颜色 = 估算的鱼活跃度。点图钉查看详情。';

  @override
  String get fishTime_collapse => '收起';

  @override
  String get fishTime_expand => '按小时查看鱼活跃度';

  @override
  String get fishing_changeSpot => '更换';

  @override
  String get fishing_plan => '计划';

  @override
  String get pond_search => '按名称搜索钓场…';

  @override
  String pond_header(int count) {
    return '你附近有 $count 个钓场';
  }

  @override
  String pond_headerSoon(int count) {
    return '$count 个钓场将在 3 天内放鱼';
  }

  @override
  String get pond_headerNone => '暂无即将到来的放鱼';

  @override
  String fishing_nextGolden(String range) {
    return '黄金时段 $range';
  }

  @override
  String get fishing_hourly => '今日逐时';

  @override
  String get fish_now_title => '此刻钓鱼';

  @override
  String get fish_unsafe => '有天气预警 — 不宜下水';

  @override
  String get fish_noWindow => '今天没有特别突出的时段';

  @override
  String fish_best(String from, String to) {
    return '今天好时段：$from–$to';
  }

  @override
  String get cond_title => '天气与天象';

  @override
  String loc_river(String river) {
    return '$river 河';
  }

  @override
  String loc_nearRiver(String river) {
    return '靠近 $river 河';
  }

  @override
  String get loc_sea => '海域';

  @override
  String get loc_water => '在水面上';

  @override
  String get spot_title => '钓点';

  @override
  String get spot_mine => '我的位置';

  @override
  String get spot_point => '已选地点';

  @override
  String get spot_useMine => '我的位置';

  @override
  String get spot_pickMap => '在地图上选择';

  @override
  String get spot_pickHint => '点按你打算钓鱼的位置，再点“在此钓鱼”';

  @override
  String get spot_saved => '已保存的钓点';

  @override
  String get fish_here => '在此钓鱼';

  @override
  String get advice_title => '当前钓鱼建议';

  @override
  String get advice_note => '基于常见钓鱼经验，针对此钓点计算。';

  @override
  String get advice_unsafe => '有雷暴或强阵风 — 现在不宜钓鱼';

  @override
  String get advice_rising => '涨水中：鱼游到岸边、草边和浅滩觅食，宜近岸钓';

  @override
  String get advice_falling => '退水中：鱼退到深水、航道边和小河口，宜钓远一些';

  @override
  String get advice_slack => '平潮：鱼少吃口，等水流恢复';

  @override
  String advice_slackAt(String time) {
    return '平潮：鱼少吃口 — 约 $time 水流恢复';
  }

  @override
  String get advice_windStrong => '风大：难以远抛 — 在避风岸边钓，不宜乘船出钓';

  @override
  String get advice_windDown => '有风：钓下风处，浪会把饵料推过去';

  @override
  String get advice_rain => '降雨可能性高 — 请带雨衣';

  @override
  String get advice_flood => '河水上涨快且浑浊：钓丁坝后、树根旁的回水区';

  @override
  String get advice_light => '即将日出/日落 — 鱼进食旺盛时段';

  @override
  String get advice_good => '钓点状况良好 — 抓紧出钓';

  @override
  String point_reference(String station, String distance) {
    return '根据 $station 站估算，距离 $distance';
  }

  @override
  String point_referenceRiver(String station, String river, String distance) {
    return '根据 $station 站（$river 河）估算，距离 $distance';
  }

  @override
  String get point_title => '已选位置';

  @override
  String point_coords(String coords) {
    return '坐标：$coords';
  }

  @override
  String get point_copy => '复制坐标';

  @override
  String get point_copied => '已复制坐标';

  @override
  String get point_noData => '暂时无法计算此位置的数据。';

  @override
  String get point_nearby => '最近的站点';

  @override
  String point_distance(String distance) {
    return '距离 $distance';
  }

  @override
  String get point_openDetail => '查看逐小时详情';

  @override
  String point_weatherNow(String temp, String wind, int rain) {
    return '当前天气：$temp°C · 风 $wind km/h · 降雨 $rain%';
  }

  @override
  String point_sun(String rise, String set) {
    return '日出 $rise · 日落 $set';
  }

  @override
  String get point_seaModel => '海洋模型直接在此位置计算';

  @override
  String get point_tapHint => '点按地图任意位置，查看那里的水情';

  @override
  String get source_shortGauge => 'IOC + utide';

  @override
  String get source_shortModel => 'Open-Meteo';

  @override
  String get source_shortRiver => 'KTTV';

  @override
  String get source_shortRiverTide => 'KTTV + Open-Meteo 潮汐';

  @override
  String source_compact(String source, String updated) {
    return '来源：$source · $updated';
  }

  @override
  String get source_details => '来源详情';

  @override
  String get map_credits => '地图来源';

  @override
  String get map_creditShort => '© OpenStreetMap';

  @override
  String get map_creditShortSat => '© EOX · © OpenStreetMap';

  @override
  String station_datumNote(String datum) {
    return '相对于$datum的高度';
  }

  @override
  String get station_datumChart => '海图基准面（按 KTTV 公报换算）';

  @override
  String get station_datumMsl => '模型平均海平面';

  @override
  String station_lunarDay(int day, int month) {
    return '农历 $month/$day';
  }

  @override
  String station_dailyRange(String range) {
    return '潮差 $range';
  }

  @override
  String station_coords(String lat, String lon) {
    return '坐标：$lat, $lon';
  }

  @override
  String station_modelFit(String from, String to) {
    return '潮汐常数由 $from 至 $to 的数据计算';
  }

  @override
  String get station_sourceGauge => 'IOC Sea Level Monitoring（实测）· 预报由 utide 计算';

  @override
  String get station_sourceModel => 'Open-Meteo Marine（海洋模型，无实测）';

  @override
  String get hourly_now => '现在';

  @override
  String hourly_detailTitle(String time) {
    return '$time 详情';
  }

  @override
  String hourly_obsMinusPred(String delta) {
    return '实测 − 预报：$delta';
  }

  @override
  String hourly_untilNext(String kind, String duration) {
    return '下一次$kind还有 $duration';
  }

  @override
  String hourly_fishScore(String score) {
    return '钓鱼指数：$score/10';
  }

  @override
  String hourly_weather(String temp, String wind, String rain) {
    return '$temp °C · 风 $wind km/h · 降雨 $rain mm';
  }

  @override
  String get hourly_empty => '此时间段没有逐小时数据。';

  @override
  String get chart_semantics => '水位图，实测为实线，预报为虚线';

  @override
  String get watch_empty => '点按地图上的一个位置（或一个站点），再点 ⭐ 保存。已保存的钓点在这里快速查看，可设提醒，离线也能用。';

  @override
  String get watch_emptyTitle => '还没有钓点';

  @override
  String get watch_openMap => '打开地图';

  @override
  String get fishing_title => '钓鱼';

  @override
  String get fishing_pickStation => '选择站点';

  @override
  String get fishing_dayScore => '今日评分';

  @override
  String fishing_reference(String version) {
    return '估算指数，仅供参考（公式 $version：潮汐、月相时段、日出/日落、24 小时气压、气温、风雨）';
  }

  @override
  String get fishing_golden => '即将到来的黄金时段';

  @override
  String get fishing_noGolden => '今天没有达到 ≥ 7 分的时段。';

  @override
  String get fishing_next7 => '未来 7 天';

  @override
  String get fishing_nowMark => '此刻';

  @override
  String fishing_hourShort(int hour) {
    return '$hour时';
  }

  @override
  String fishing_level(String score, String label) {
    return '$score/10 · $label';
  }

  @override
  String get fishing_levelGood => '好';

  @override
  String get fishing_levelFair => '较好';

  @override
  String get fishing_levelPoor => '差';

  @override
  String fishing_warnRed(String from, String to) {
    return '$from–$to 有雷暴/闪电或强阵风 — 此时段请勿去江河/海上。';
  }

  @override
  String fishing_warnYellow(String from, String to) {
    return '$from–$to 可能有雷暴或大雨 — 请留意天气。';
  }

  @override
  String fishing_levelOutsideWarning(String score, String label) {
    return '$score/10 · $label（预警时段以外）';
  }

  @override
  String get fishing_factor_tide => '潮汐';

  @override
  String get fishing_factor_flow => '水流';

  @override
  String get fishing_factor_solunar => '月相时段';

  @override
  String get fishing_factor_pressure => '气压';

  @override
  String get fishing_factor_daytime => '日出/日落';

  @override
  String get fishing_factor_weather => '天气';

  @override
  String get fishing_factor_temperature => '气温适宜';

  @override
  String get fishing_factor_season => '鱼汛季节';

  @override
  String fishing_moon(String phase, int pct) {
    return '$phase · 亮度 $pct%';
  }

  @override
  String get fishing_weatherSource => 'Open-Meteo（天气预报）';

  @override
  String get moon_newMoon => '新月';

  @override
  String get moon_waxingCrescent => '娥眉月';

  @override
  String get moon_firstQuarter => '上弦月';

  @override
  String get moon_waxingGibbous => '盈凸月';

  @override
  String get moon_fullMoon => '满月';

  @override
  String get moon_waningGibbous => '亏凸月';

  @override
  String get moon_lastQuarter => '下弦月';

  @override
  String get moon_waningCrescent => '残月';

  @override
  String get more_info => '应用信息';

  @override
  String get more_appName => 'Con Nước';

  @override
  String more_build(String sha) {
    return '构建 $sha';
  }

  @override
  String get more_update => '有新版本 — 刷新页面即可更新';

  @override
  String get more_close => '关闭';

  @override
  String get more_title => '更多';

  @override
  String get more_explore => '探索';

  @override
  String get more_app => '应用';

  @override
  String get more_journalHint => '你的渔获和钓鱼习惯';

  @override
  String get more_profileHint => '在评论、约钓和评价中显示的名字';

  @override
  String get more_editName => '改名';

  @override
  String get more_theme => '外观';

  @override
  String get more_themeSystem => '跟随系统';

  @override
  String get more_themeLight => '浅色';

  @override
  String get more_themeDark => '深色';

  @override
  String get more_sources => '数据来源';

  @override
  String get more_sourcesBody =>
      '• IOC Sea Level Monitoring — Vũng Tàu、Quy Nhơn 实测海平面（每分钟）。这 2 个站的潮汐预报由 12 个月数据经调和分析（utide）计算；回测误差：±10 cm（Vũng Tàu），±7 cm（Quy Nhơn）。\n• 越南国家水文气象预报中心（KTTV）— 短期水文公报：河流水位每天 4 次 + 预报。逐小时曲线由应用估算（结合河口潮汐）；回测：±12 cm（河内），±11 cm（Nam Đàn）。\n• Open-Meteo — 天气、海浪和近岸海平面模型。\n• GloFAS（通过 Open-Meteo Flood）— 各河流干流逐日流量。\n• 地图上任意位置：该处的海洋模型；在红河、Cả 河上按沿河位置计算；其他地方使用最近的 KTTV 河流站（40 km 以内）、近岸潮汐（估算）或河流流量。\n• 底图：OpenFreeMap · © OpenMapTiles · 数据 © OpenStreetMap。\n• 卫星影像：EOxCloudless（EOX IT Services GmbH），包含 Copernicus Sentinel 2025 数据。\n所有预报/估算数据仅供参考。各站的来源详情、高程基准和可靠性请查看站点的“信息”标签页。';

  @override
  String more_version(String version) {
    return '版本 $version';
  }

  @override
  String get set_title => '设置';

  @override
  String get set_entry => '外观与设置';

  @override
  String get set_entryHint => '颜色、背景、字体、字号、语言、通知';

  @override
  String get set_previewTitle => '鱼活跃度：高 · 8.2';

  @override
  String get set_previewBody => '黄金时段 17:00–18:30 · 正在涨水';

  @override
  String get set_look => '外观';

  @override
  String get set_mode => '浅色或深色';

  @override
  String get set_accent => '主题色';

  @override
  String get set_backdrop => '背景';

  @override
  String get set_font => '字体';

  @override
  String get set_textSize => '字号';

  @override
  String get accent_ocean => '海洋';

  @override
  String get accent_jade => '翡翠';

  @override
  String get accent_leaf => '绿叶';

  @override
  String get accent_sunset => '日落';

  @override
  String get accent_coral => '珊瑚';

  @override
  String get accent_violet => '紫罗兰';

  @override
  String get accent_slate => '石墨';

  @override
  String get accent_gold => '青铜';

  @override
  String get backdrop_mist => '薄雾';

  @override
  String get backdrop_warm => '暖色纸张';

  @override
  String get backdrop_pure => '纯白 / AMOLED';

  @override
  String get backdrop_tinted => '跟随主题色';

  @override
  String get font_beVietnam => 'Be Vietnam';

  @override
  String get font_nunito => 'Nunito 圆体';

  @override
  String get font_system => '设备字体';

  @override
  String get size_small => '小';

  @override
  String get size_normal => '中';

  @override
  String get size_large => '大';

  @override
  String get size_huge => '特大';

  @override
  String get set_general => '通用';

  @override
  String get set_language => '语言';

  @override
  String get lang_system => '跟随系统';

  @override
  String get lang_vi => 'Tiếng Việt';

  @override
  String get lang_en => 'English';

  @override
  String get set_start => '打开应用时显示';

  @override
  String get set_notifications => '通知';

  @override
  String get set_notificationsHint => '黄金时段、高潮/低潮、提前多久';

  @override
  String get set_motion => '减少动态效果';

  @override
  String get set_motionHint => '关闭游鱼、流水和动画 — 旧手机更流畅，更省电';

  @override
  String get set_data => '数据与存储';

  @override
  String set_cache(String mb) {
    return '缓存数据：$mb MB';
  }

  @override
  String get set_cacheHint => '预报、天气、底图 — 需要时会重新下载。日志、已保存的钓点和设置不会被删除。';

  @override
  String get set_cacheClear => '清除';

  @override
  String get set_cacheCleared => '已清除缓存数据';

  @override
  String get set_reset => '恢复默认外观';

  @override
  String get set_resetDone => '已恢复默认外观';

  @override
  String get sp_title => '今天钓什么鱼？';

  @override
  String get sp_seeAll => '查看全部';

  @override
  String get sp_guideTitle => '鱼种手册';

  @override
  String get sp_today => '今天';

  @override
  String sp_bestTime(String range) {
    return '合适时段：$range';
  }

  @override
  String get sp_noTime => '今天暂无合适时段';

  @override
  String get sp_inSeason => '当季';

  @override
  String get sp_offSeason => '非当季';

  @override
  String get sp_season => '主要季节';

  @override
  String get sp_where => '在哪里';

  @override
  String get sp_bait => '鱼饵';

  @override
  String get sp_chum => '窝料';

  @override
  String get sp_how => '钓法';

  @override
  String get sp_todayTips => '今日注意';

  @override
  String get sp_note => '常见钓鱼经验，已结合此处的真实潮汐和天气调整。仅供参考。';

  @override
  String get sp_noTips => '今天条件正常，按你平常的方式钓就行。';

  @override
  String get habitat_pond => '池塘湖泊';

  @override
  String get habitat_river => '河流';

  @override
  String get habitat_estuary => '河口';

  @override
  String get habitat_sea => '海';

  @override
  String get depth_surface => '上层';

  @override
  String get depth_middle => '中层';

  @override
  String get depth_bottom => '底层';

  @override
  String get spTip_outOfSeason => '还没到主要季节：仍能钓到，但会少一些。';

  @override
  String get spTip_waitForCurrent => '这种鱼在水流动时进食：现在是平潮，等水流恢复。';

  @override
  String get spTip_murkyStrongBait => '雨后水浑：用味道重的腥饵，在近岸水较清处钓。';

  @override
  String get spTip_coldSmallBaitDeep => '天气转冷：鱼吃口慢，用小饵、钓深、耐心等。';

  @override
  String get spTip_hotGoDeepShade => '天气炎热：清晨或傍晚钓，或去深水和树荫处。';

  @override
  String get spTip_pressureFallingBite => '气压下降中：变天前鱼常大量进食，抓紧时间。';

  @override
  String get spTip_pressureRisingFinesse => '大风过后气压大幅上升：鱼口差，用细线、小钩。';

  @override
  String get spTip_windDownwind => '风大：去迎风的岸边，饵料和食物会漂到那里。';

  @override
  String get spTip_risingNearBank => '涨水中：鱼靠近岸边觅食，钓近处。';

  @override
  String get spTip_fallingDeeper => '退水中：鱼退到深沟、渠口，钓远一些。';

  @override
  String get nb_button => '鱼不咬钩？';

  @override
  String get nb_title => '鱼不咬钩？试试这些方法';

  @override
  String get nb_now => '根据当前情况';

  @override
  String get nb_always => '值得检查的几件事';

  @override
  String nb_waitCurrent(String time) {
    return '现在是平潮：约 $time 水流恢复，鱼会更爱吃。趁机换饵、打窝。';
  }

  @override
  String get nb_goDeepShade => '烈日：鱼下沉到深处，钓深一些或移到树荫、树根处。';

  @override
  String get nb_coldSlow => '天冷：饵换小一点，收线放慢，在深水处贴底钓。';

  @override
  String get nb_murkySmell => '水浑：换味道重的腥饵，找近岸水较清的地方。';

  @override
  String get nb_finesse => '大风过后气压上升：鱼胆小，用细线、小钩、少饵。';

  @override
  String get nb_downwind => '风大：去迎风的岸边，食物会漂到那里。';

  @override
  String nb_nextGolden(String time) {
    return '下一个黄金时段在 $time：先休息，准时回来。';
  }

  @override
  String get nb_changeDepth => '调整深度：先贴底，再每次上调 20–30 cm。';

  @override
  String get nb_moveSpot => '20–30 分钟没有鱼星：换地方，找水草、树根、回水处。';

  @override
  String get nb_freshBait => '换新饵并露出钩尖；放久的饵料和窝料会失去味道。';

  @override
  String get nb_stayQuiet => '保持安静，别让人影投到水面上。';

  @override
  String get nb_finerLine => '鱼胆小就换更细的线、更小的钩。';

  @override
  String get fishing_species => '鱼种';

  @override
  String get sp_carp => '鲤鱼';

  @override
  String get sp_carp_where => '池塘、湖泊、缓流河段；水草丛、沉没树根、泥底周围。';

  @override
  String get sp_carp_bait => '炒米糠、玉米粉、泡玉米、红虫。';

  @override
  String get sp_carp_chum => '酸味窝料（米糠 + 玉米粉发酵）或奶香、菠萝味。提前 15–20 分钟打窝。';

  @override
  String get sp_carp_how => '台钓或底钓贴底，用灵敏的浮漂；鲤鱼常先顶漂再拖走。';

  @override
  String get sp_tilapia => '罗非鱼';

  @override
  String get sp_tilapia_where => '池塘、湖泊、水渠、缓流河段；温暖、向阳的岸边。';

  @override
  String get sp_tilapia_bait => '颗粒饵、面团、蚯蚓、小虾。';

  @override
  String get sp_tilapia_chum => '香味（奶香、香草）或微腥窝料，少量多次撒。';

  @override
  String get sp_tilapia_how => '小钩，钓中层到近底；浮漂一沉就轻轻提竿。';

  @override
  String get sp_grassCarp => '草鱼';

  @override
  String get sp_grassCarp_where => '湖泊、大河、收费钓场；有草、浮萍的岸边。';

  @override
  String get sp_grassCarp_bait => '嫩草、木薯叶、煮玉米、米糠面团。';

  @override
  String get sp_grassCarp_chum => '发酵玉米、米糠拌玉米粉。';

  @override
  String get sp_grassCarp_how => '线和竿要结实，卸力适中；鱼冲劲大，耐心遛鱼。';

  @override
  String get sp_snakehead => '黑鱼（乌鳢）';

  @override
  String get sp_snakehead_where => '稻田、水渠、多草和水葫芦的池塘；贴岸、漂浮物周围。';

  @override
  String get sp_snakehead_bait => '小青蛙、活小鱼、路亚假饵（雷蛙、亮片）。';

  @override
  String get sp_snakehead_chum => '无需打窝。';

  @override
  String get sp_snakehead_how => '沿草边拖钓或抽动，轻手轻脚少出声；鱼猛咬后会往草里钻。';

  @override
  String get sp_walkingCatfish => '胡子鲶';

  @override
  String get sp_walkingCatfish_where => '池塘、稻田、泥底水渠；岸边洞穴。';

  @override
  String get sp_walkingCatfish_bait => '蚯蚓、鸡肠、虾、腥饵。';

  @override
  String get sp_walkingCatfish_chum => '腥味窝料（臭鱼、鱼粉）。';

  @override
  String get sp_walkingCatfish_how => '夜间或雨后底钓；钓组结实，钩中号。';

  @override
  String get sp_pangasius => '巴沙鱼（tra、basa）';

  @override
  String get sp_pangasius_where => '湄公河流域大河、收费钓场；深水航道。';

  @override
  String get sp_pangasius_bait => '颗粒饵、鸡肠、臭鱼、面团。';

  @override
  String get sp_pangasius_chum => '腥味或酸味窝料。';

  @override
  String get sp_pangasius_how => '钓中层到底层，线要结实；鱼拉力非常大。';

  @override
  String get sp_mystus => '鮠鱼（Mystus）';

  @override
  String get sp_mystus_where => '流水河溪、砾石浅滩；每段河的鱼进食时间各不相同。';

  @override
  String get sp_mystus_bait => '蚯蚓、虾、虫。';

  @override
  String get sp_mystus_chum => '微腥，少量即可。';

  @override
  String get sp_mystus_how => '水刚开始流动时沿水流线底钓；问问当地钓友鱼几点进来。';

  @override
  String get sp_mullet => '鲻鱼';

  @override
  String get sp_mullet_where => '河口、潟湖、港口；涨潮时鱼进渠口，退潮时出去。';

  @override
  String get sp_mullet_bait => '青苔、面粉拌米糠、面包芯。';

  @override
  String get sp_mullet_chum => '酸中带微腥的窝料，顺水流均匀撒。';

  @override
  String get sp_mullet_how => '小而灵敏的浮漂、小钩，趁水流动时顺流钓。';

  @override
  String get sp_seabass => '尖吻鲈（金目鲈）';

  @override
  String get sp_seabass_where => '河口、潟湖、礁石；桥墩、闸口、回水处周围。';

  @override
  String get sp_seabass_bait => '活虾、小鱼、路亚假饵。';

  @override
  String get sp_seabass_chum => '无需打窝。';

  @override
  String get sp_seabass_how => '抛路亚或让活虾顺流漂；水流急时以及黎明、黄昏最好。';

  @override
  String get sp_snapper => '笛鲷';

  @override
  String get sp_snapper_where => '海里、礁石、岩礁；深礁底部。';

  @override
  String get sp_snapper_bait => '鱿鱼、虾、新鲜饵鱼。';

  @override
  String get sp_snapper_chum => '不需要，或在底部放碎饵。';

  @override
  String get sp_snapper_how => '底钓，铅坠刚好压住底，用耐磨子线；大潮时最好。';

  @override
  String get sp_grouper => '石斑鱼';

  @override
  String get sp_grouper_where => '沿海礁石、岩岸；岩底洞穴。';

  @override
  String get sp_grouper_bait => '活小鱼、鱿鱼、虾。';

  @override
  String get sp_grouper_chum => '无需打窝。';

  @override
  String get sp_grouper_how => '一咬钩就立刻控住鱼，别让它钻洞；线要结实。';

  @override
  String get sp_goby => '虾虎鱼';

  @override
  String get sp_goby_where => '水渠、半咸水河；沙泥底。';

  @override
  String get sp_goby_bait => '小虾、蚯蚓。';

  @override
  String get sp_goby_chum => '无需打窝。';

  @override
  String get sp_goby_how => '轻钓组底钓，小钩；鱼口轻，等浮漂明显走动再提竿。';

  @override
  String get sp_climbingPerch => '攀鲈';

  @override
  String get sp_climbingPerch_where => '稻田、沟渠、池塘；草边；初雨过后最旺。';

  @override
  String get sp_climbingPerch_bait => '蚯蚓、蚱蜢、饭团。';

  @override
  String get sp_climbingPerch_chum => '在岸边撒少量炒米糠。';

  @override
  String get sp_climbingPerch_how => '手竿贴着草岸钓，小钩，快速提竿。';

  @override
  String get sp_crucian => '鲫鱼';

  @override
  String get sp_crucian_where => '池塘、湖泊；底层和中层，喜凉水。';

  @override
  String get sp_crucian_bait => '红虫、面团。';

  @override
  String get sp_crucian_chum => '细腻香味窝料，少量。';

  @override
  String get sp_crucian_how => '小钩、灵敏浮漂，台钓；凉季多。';

  @override
  String get sp_bighead => '鳙鱼、鲢鱼';

  @override
  String get sp_bighead_where => '大湖、收费钓场；晴暖天在上层和中层。';

  @override
  String get sp_bighead_bait => '雾化饵：米糠、豆粉捏松，在水中悬浮化开。';

  @override
  String get sp_bighead_chum => '浮性窝料，在水中化成雾状。';

  @override
  String get sp_bighead_how => '浮漂悬钓上层到中层，配易化的面饵团；浮漂缓缓下沉时提竿。';

  @override
  String get nav_backAgain => '再滑动返回一次即可退出';

  @override
  String get map_hereNow => '此刻你周围';

  @override
  String map_nextGolden(String time) {
    return '黄金时段 $time';
  }

  @override
  String get fishing_noGoldenShort => '暂无黄金时段';

  @override
  String get flood_entry => '几点水会淹没回去的路？';

  @override
  String get flood_title => '几点水会淹没回去的路？';

  @override
  String get flood_ask => '现在水面比你站的地方（或回去的路）低大约多少？';

  @override
  String flood_margin(int cm) {
    return '$cm 厘米';
  }

  @override
  String get flood_noTide => '这里还没有潮汐预报，所以无法计算。';

  @override
  String get flood_safe => '未来 24 小时水不会涨到那里';

  @override
  String flood_at(String time) {
    return '水在 $time 到达';
  }

  @override
  String get flood_already => '水已到这个高度，请立即离开。';

  @override
  String flood_leave(String time) {
    return '请在 $time 前离开。';
  }

  @override
  String flood_in(String duration) {
    return '还剩约 $duration。';
  }

  @override
  String flood_recede(String time) {
    return '约 $time 水会退回去。';
  }

  @override
  String flood_peak(String time, String level) {
    return '高潮 $time，相对站点基准约 $level。';
  }

  @override
  String get flood_windy => '风大：水位可能高于预报，应用已提前 20 cm 计算。请更早离开。';

  @override
  String get flood_note => '根据此处的潮汐预报估算，仅供参考。浪、风和洪水可能让水涨得更快：务必留好退路。';

  @override
  String flood_minutes(int m) {
    return '$m 分钟';
  }

  @override
  String flood_hoursMinutes(int h, int m) {
    return '$h 小时 $m 分钟';
  }

  @override
  String flood_alarmButton(String time) {
    return '$time 响铃提醒';
  }

  @override
  String flood_alarmSet(String time) {
    return '已设 $time 响铃 · 点按取消';
  }

  @override
  String get flood_alarmApk => '响铃提醒仅在 Android 应用中可用（在“更多”标签页下载 APK）。';

  @override
  String flood_alarmTitle(String place) {
    return '即将被淹：$place';
  }

  @override
  String flood_alarmBody(String time) {
    return '水约在 $time 到达。收竿，立即离开所在位置。';
  }

  @override
  String get flood_channel => '回程路被淹提醒';

  @override
  String get shift_title => '天气即将变化';

  @override
  String get shift_dayAfter => '后天';

  @override
  String shift_coldFront(String when) {
    return '$when天气转冷（季风）：之前鱼常大量进食，值得去钓。之后 1–2 天鱼口差。';
  }

  @override
  String shift_heavyRain(String when) {
    return '$when有大雨：雨后水浑，贴底钓，用腥饵，去近岸水较清处。';
  }

  @override
  String shift_pressureDrop(String when) {
    return '从$when起气压大幅下降：天气转差，请留意雷暴、低压预警。';
  }

  @override
  String shift_heatWave(String when) {
    return '$when炎热超过 36°C：清晨、傍晚钓，去深水和树荫处。';
  }

  @override
  String get shift_note => '根据 Open-Meteo 天气预报，仅供参考。';

  @override
  String get alert_evening => '前一晚提醒（20:00）';

  @override
  String get alert_eveningHint => '“明天去钓鱼吗？”：你的钓点明天最佳的黄金时段';

  @override
  String digest_title(String place) {
    return '明天去钓鱼吗？· $place';
  }

  @override
  String digest_body(String range, String band, String score) {
    return '黄金时段 $range：鱼活跃度$band（$score）。今晚就准备好钓具吧！';
  }

  @override
  String get digest_none => '明天这里没有黄金时段。打开应用查看“去哪钓？”找更好的地方。';

  @override
  String get brag_open => '晒渔获照片';

  @override
  String get brag_title => '晒鱼';

  @override
  String get brag_share => '分享图片';

  @override
  String get brag_showPlace => '显示钓点名称';

  @override
  String get brag_showPlaceHint => '默认关闭，为好钓点保密';

  @override
  String brag_score(String score) {
    return '鱼活跃度 $score';
  }

  @override
  String brag_text(String species, String link) {
    return '刚钓到一条$species！在 Con Nước 查看鱼口时间和潮汐：$link';
  }

  @override
  String get bite_question => '你在这里钓鱼吗？有口吗？';

  @override
  String get bite_yes => '有口';

  @override
  String get bite_no => '没口';

  @override
  String get bite_thanks => '谢谢！你的反馈能让附近钓友知道鱼有没有开口。';

  @override
  String get bite_tooSoon => '你刚反馈过，30 分钟后再来吧。';

  @override
  String get bite_failed => '暂时发送失败，请稍后再试。';

  @override
  String bite_summary(int bites, int misses) {
    return '附近过去 3 小时：$bites 人有口，$misses 人没口。';
  }

  @override
  String get bite_first => '附近还没人反馈，你来当第一个吧！';

  @override
  String bite_pattern(String state, int rate) {
    return '这一带$state时鱼最爱咬钩（$rate% 反馈有口，近 60 天）。';
  }

  @override
  String get bite_rising => '涨潮';

  @override
  String get bite_falling => '退潮';

  @override
  String get bite_slack => '平潮';

  @override
  String get bite_note => '汇总自钓友反馈，仅保存约 2 公里范围的区域，不保存身份信息。';

  @override
  String get gear_title => '钓具与绑结';

  @override
  String get gear_entry => '钓具与绑结';

  @override
  String get gear_entryHint => '出钓装备清单，6 种常用结的绑法';

  @override
  String get gear_tabPack => '装备清单';

  @override
  String get gear_tabKnots => '绑结';

  @override
  String gear_progress(int done, int total) {
    return '$done/$total 件';
  }

  @override
  String get gear_clear => '全部取消勾选，留给下次出钓';

  @override
  String get trip_night => '夜钓';

  @override
  String get trip_sea => '海钓、矶钓';

  @override
  String get trip_pond => '收费鱼塘';

  @override
  String get trip_river => '江河、渠道';

  @override
  String get gear_rodReel => '鱼竿、渔轮（检查渔轮顺滑、卸力）';

  @override
  String get gear_spareLine => '备用钓线';

  @override
  String get gear_hooksWeights => '备用鱼钩、铅坠、浮漂、别针';

  @override
  String get gear_baitChum => '饵料和窝料';

  @override
  String get gear_netTowel => '抄网和擦手毛巾';

  @override
  String get gear_waterFood => '饮用水、食物';

  @override
  String get gear_sunHat => '帽子、防晒霜、墨镜';

  @override
  String get gear_raincoat => '雨衣';

  @override
  String get gear_phonePower => '充满电的手机、充电宝';

  @override
  String get gear_trashBag => '垃圾袋（把垃圾带走）';

  @override
  String get gear_headlamp => '头灯、备用电池';

  @override
  String get gear_glowSticks => '荧光棒、夜光漂灯';

  @override
  String get gear_mosquito => '驱蚊液';

  @override
  String get gear_jacket => '外套（夜里风大寒冷）';

  @override
  String get gear_nonSlipShoes => '防滑鞋';

  @override
  String get gear_lifeJacket => '救生衣';

  @override
  String get gear_tideCheck => '在应用里查看潮汐时间和“回程路被淹”';

  @override
  String get gear_leader => '耐磨前导线（子线）';

  @override
  String get gear_pliers => '摘钩钳';

  @override
  String get gear_pondCall => '打电话问鱼塘：价格、营业时间、放鱼时间';

  @override
  String get gear_chairUmbrella => '钓椅、遮阳伞';

  @override
  String get gear_keepNet => '鱼护或养鱼箱';

  @override
  String get gear_boots => '雨靴或涉水鞋';

  @override
  String get gear_rodRest => '竿架、炮台地插';

  @override
  String knot_strength(int pct) {
    return '约保留钓线 $pct% 的强度';
  }

  @override
  String get knot_note => '通用技巧：收紧前先用口水润湿，慢慢拉紧以免发热，剪线头时留 2–3 毫米。图为示意图。';

  @override
  String get knot_improvedClinch => '改良克林奇结';

  @override
  String get knot_improvedClinch_use => '用尼龙线绑鱼钩、别针。最简单，人人都该会。';

  @override
  String get knot_improvedClinch_steps =>
      '将钓线穿过钩眼，留出约 15 厘米。\n用线头绕主线 5–7 圈。\n线头穿过钩眼旁的小圈，再穿过刚形成的大圈。\n润湿后拉主线收紧，剪掉线头。';

  @override
  String get knot_palomar => '帕洛马结（Palomar）';

  @override
  String get knot_palomar_use => '用 PE 线绑鱼钩、路亚饵。非常牢固，绑得快。';

  @override
  String get knot_palomar_steps =>
      '将约 15 厘米的线对折，把折头穿过钩眼。\n用双股线打一个松的单结。\n把整个鱼钩穿过对折形成的线圈。\n润湿后拉两端收紧，剪掉线头。';

  @override
  String get knot_uni => 'Uni 结';

  @override
  String get knot_uni_use => '绑鱼钩、别针、路亚饵；尼龙线和 PE 线都适用。';

  @override
  String get knot_uni_steps =>
      '将钓线穿过钩眼，线头与主线平行折回形成一个圈。\n用线头在圈内缠绕两股线 5–6 圈。\n拉线头让线圈排列整齐。\n润湿后拉主线把结推到钩眼处，剪掉线头。';

  @override
  String get knot_doubleUni => '双 Uni 接线结';

  @override
  String get knot_doubleUni_use => '连接两根线（PE 线接尼龙前导线，或接断线）。';

  @override
  String get knot_doubleUni_steps =>
      '将两根线头重叠约 20 厘米。\n用第一根线头绕第二根线打 Uni 结（3–4 圈；PE 线 6–8 圈）。\n第二根线头同样操作。\n润湿后拉两根主线使两个结滑到一起，剪掉线头。';

  @override
  String get knot_perfectionLoop => '完美环结（Perfection）';

  @override
  String get knot_perfectionLoop_use => '在线端做一个环，快速挂接线组、前导线。';

  @override
  String get knot_perfectionLoop_steps =>
      '在线端做一个小圈，线头在后。\n用线头绕过小圈，在前面形成第二个圈。\n把线头从两个圈之间穿过。\n将第二个圈从第一个圈中拉出，收紧，剪掉线头。';

  @override
  String get knot_snell => 'Snell 绑钩结';

  @override
  String get knot_snell_use => '绑台钓、单钩，让线顺着钩柄笔直走，提高中鱼率。';

  @override
  String get knot_snell_steps =>
      '将钓线穿过钩眼，沿钩柄放置形成一个圈。\n用线圈从钩眼往下缠绕钩柄和线 7–8 圈。\n按住线圈，拉主线收紧。\n润湿后再收紧一次，剪掉线头。';

  @override
  String get font_quicksand => 'Quicksand';

  @override
  String get set_navStyle => '标签栏样式';

  @override
  String get nav_styleDot => '圆点';

  @override
  String get lang_zh => '中文';

  @override
  String get lang_ko => '한국어';

  @override
  String get lang_ja => '日本語';

  @override
  String get pond_zalo => 'Zalo 聊天';

  @override
  String get pond_filterWeekend => '周末放鱼';

  @override
  String get release_alarmPond => '你关注的钓场';

  @override
  String release_alarmTitle(String pond) {
    return '即将放鱼：$pond';
  }

  @override
  String release_alarmBody(String when) {
    return '$when 放鱼。早点去占个好位置！';
  }

  @override
  String release_alarmBodyKg(String when, int kg) {
    return '$when 放约 $kg 公斤鱼。早点去占个好位置！';
  }

  @override
  String get nav_styleArc => '弧光';

  @override
  String get nav_styleNotch => '凹槽';

  @override
  String get nav_styleGlass => '玻璃';

  @override
  String get map_layerPonds => '钓场';

  @override
  String get map_layerSpots => '社区钓点';

  @override
  String get map_layerTrips => '钓鱼约局';

  @override
  String get map_layerCheckins => '正在钓鱼的人';

  @override
  String get social_tooFast => '发送太快了——请稍等再试';

  @override
  String get social_daily => '今天已达到发送上限，请明天再试。';

  @override
  String get social_newDevice => '新设备暂时有限制——大约10分钟后再试';

  @override
  String get social_banned => '此设备的内容被多人举报，暂停发布';

  @override
  String social_bannedUntil(String time) {
    return '此设备的内容被多人举报，暂停发布至 $time';
  }

  @override
  String get blocked_link => '公开内容中请不要发链接';

  @override
  String get blocked_phone => '公开内容中请不要写电话号码（防止广告和诈骗）';

  @override
  String get blocked_contactAd => '公开内容中请不要邀请加 Zalo、Telegram 或私信';

  @override
  String get blocked_spam => '内容像赌博或借贷广告，无法发布';

  @override
  String get blocked_offensive => '内容含有粗俗用语，请修改';

  @override
  String get blocked_chars => '请不要重复字母（如 \"好好好好好\"）';

  @override
  String get blocked_shouting => '请关闭大写锁定（Caps Lock）';

  @override
  String get blocked_impersonation => '此名称容易与管理团队混淆，请换一个';

  @override
  String get blocked_repeat => '您刚刚发送过完全相同的内容';

  @override
  String get blocked_other => '此内容暂不适合发布，请修改';
}
