// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Con Nước';

  @override
  String get common_retry => '再試行';

  @override
  String get common_loading => '読み込み中…';

  @override
  String get common_empty => 'データがまだありません';

  @override
  String get common_reference => '参考';

  @override
  String get common_estimate => '推定';

  @override
  String common_source(String source) {
    return '出典：$source';
  }

  @override
  String common_staleBanner(String time) {
    return 'オフライン · $time 更新';
  }

  @override
  String common_updatedAt(String time) {
    return '$time 更新';
  }

  @override
  String get common_today => '今日';

  @override
  String get common_tomorrow => '明日';

  @override
  String get error_network => '接続できません。ネットワークを確認して再試行してください。';

  @override
  String get error_timeout => 'データ元の応答が遅れています。しばらくしてから再試行してください。';

  @override
  String get error_server => 'データ元が一時的に停止しています。';

  @override
  String get error_parse => '元データが無効です。';

  @override
  String get error_notFound => '見つかりません。';

  @override
  String get error_offlineNoCache => 'オフラインで、保存済みのデータがまだありません。';

  @override
  String get error_unknown => 'エラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get dataKind_observed => '実測';

  @override
  String get dataKind_forecast => '予報 · 参考';

  @override
  String get dataKind_estimate => '推定';

  @override
  String get tide_rising => '上げ潮';

  @override
  String get tide_risingFast => '急上昇';

  @override
  String get tide_slack => '潮止まり';

  @override
  String get tide_falling => '下げ潮';

  @override
  String get tide_fallingFast => '急低下';

  @override
  String get tide_high => '満潮';

  @override
  String get tide_low => '干潮';

  @override
  String get tide_turning => '潮の変わり目';

  @override
  String get tide_spring => '大潮';

  @override
  String get tide_neap => '小潮';

  @override
  String get tide_normal => '中潮';

  @override
  String tide_countdownHigh(String duration) {
    return '満潮まで $duration';
  }

  @override
  String tide_countdownLow(String duration) {
    return '干潮まで $duration';
  }

  @override
  String tide_extremeAt(String time, String level) {
    return '$time · 予想 $level';
  }

  @override
  String tide_nextOther(String kind, String time, String level) {
    return '次の$kind：$time · $level';
  }

  @override
  String get tide_noPrediction => 'この観測所の潮汐予報はまだありません';

  @override
  String tide_correctedBy(String delta) {
    return '実測値で補正済み（差 $delta）';
  }

  @override
  String duration_hm(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String duration_m(int minutes) {
    return '$minutes分';
  }

  @override
  String confidence_label(String level) {
    return '予報の信頼度：$level';
  }

  @override
  String get confidence_high => '高';

  @override
  String get confidence_medium => '中';

  @override
  String get confidence_low => '低';

  @override
  String skill_backtest(String cm, String min) {
    return 'バックテスト：誤差 ±$cm cm、満潮/干潮時刻 ±$min分';
  }

  @override
  String skill_live(int days, String cm, String min) {
    return '過去 $days 日の誤差：±$cm cm、±$min分';
  }

  @override
  String get skill_unknown => 'この地点の誤差はまだ測定されていません';

  @override
  String get nav_map => '地図';

  @override
  String get map_searchHint => '村・坊・橋・船着き場・座標を検索…';

  @override
  String get map_searchNone => '一致する観測所が見つかりません';

  @override
  String get map_openDetail => '詳細を見る';

  @override
  String map_nextExtreme(String kind, String time, String level, String duration) {
    return '$kind $time ≈ $level · あと $duration';
  }

  @override
  String tide_moreRise(int cm) {
    return '水位はあと約 $cm cm 上がります';
  }

  @override
  String tide_moreFall(int cm) {
    return '水位はあと約 $cm cm 下がります';
  }

  @override
  String get map_locate => '現在地';

  @override
  String get map_locRationaleTitle => '現在地を使用しますか？';

  @override
  String get map_locRationaleBody =>
      'アプリは現在地を使って地図をあなたのいる場所に移動します。位置情報は端末内にのみ保存され（次回すばやく開けるよう約 1 km 単位でおおまかに記憶）、どこにも送信されません。';

  @override
  String get map_locAllow => '許可';

  @override
  String get map_later => '後で';

  @override
  String get map_locServiceOff => '位置情報がオフです。端末で位置情報をオンにして再試行してください。';

  @override
  String get map_locDenied => '位置情報の権限がありません。';

  @override
  String get map_locDeniedForeverTitle => '位置情報の権限がブロックされています';

  @override
  String get map_locDeniedForeverBody => '設定 > アプリ > Con Nước > 権限 > 位置情報 で再度オンにしてください。';

  @override
  String get map_openSettings => '設定を開く';

  @override
  String get map_locFailed => '現在地を取得できません。しばらくしてから再試行してください。';

  @override
  String get map_outsideVn => '対応エリア外の位置です';

  @override
  String get map_layers => '地図レイヤー';

  @override
  String get map_layerStandard => '標準地図';

  @override
  String get map_layerStandardHint => '道路、地名、川や湖（OpenFreeMap）';

  @override
  String get map_layerSatellite => '衛星写真';

  @override
  String get map_layerSatelliteHint => 'Sentinel-2 2025年、解像度 10 m — 川、砂州、田畑ははっきり見えますが、個々の家は見えません';

  @override
  String get map_satelliteCredit =>
      '衛星写真：EOxCloudless (EOX IT Services) · Copernicus Sentinel 2025 データを含む';

  @override
  String get map_filter => 'フィルター';

  @override
  String get map_filterOnlyTide => '潮汐のある観測所のみ';

  @override
  String get map_filterOnlyAlarm => '警報中の観測所のみ';

  @override
  String get map_filterHideStale => 'データのない観測所を隠す';

  @override
  String get map_filterNone => 'フィルターに一致する観測所はありません';

  @override
  String get map_legend => '凡例';

  @override
  String get map_legendNormal => '通常';

  @override
  String get map_legendAlarm1 => '警報レベル I';

  @override
  String get map_legendAlarm2 => '警報レベル II';

  @override
  String get map_legendAlarm3 => '警報レベル III';

  @override
  String get map_legendStale => '6時間以上データなし（灰色のピン、薄い魚）';

  @override
  String get map_legendSpot => 'コミュニティの釣り場';

  @override
  String get map_legendCluster =>
      '数字入りの円：近くの観測所のグループです。タップで拡大します。円の色はグループ内で最も高い魚の活性を示し、警報中の観測所があれば警報の色になります。';

  @override
  String get map_legendNote => '海の観測所にはまだ警報基準がありません。警報の色は今後の段階で川の観測所に使われます。';

  @override
  String get map_hoangSa => 'Hoàng Sa 諸島（ベトナム）';

  @override
  String get map_truongSa => 'Trường Sa 諸島（ベトナム）';

  @override
  String get map_close => '閉じる';

  @override
  String get map_stationsError => '観測所リストを読み込めません';

  @override
  String get map_baseMapCredit => '背景地図：OpenFreeMap · © OpenMapTiles · データ © OpenStreetMap';

  @override
  String get nav_stations => '観測所';

  @override
  String get nav_watch => 'ウォッチ';

  @override
  String get nav_fishing => '釣り';

  @override
  String get nav_more => 'その他';

  @override
  String get stations_title => '水位・潮汐観測所';

  @override
  String get stations_kindGauge => '計測器あり';

  @override
  String get stations_kindModel => 'モデル';

  @override
  String get stations_coordApprox => 'おおよその座標';

  @override
  String get station_tabOverview => '概要';

  @override
  String get station_tabHourly => '時間別';

  @override
  String get station_tabCalendar => '潮見表';

  @override
  String get station_tabInfo => '情報';

  @override
  String level_lastKnown(String time) {
    return '最新の値は $time · この時間の値はまだありません';
  }

  @override
  String get calendar_prev => '前の月';

  @override
  String get calendar_next => '次の月';

  @override
  String calendar_month(int month, int year) {
    return '$year年$month月';
  }

  @override
  String get calendar_noTideDay => 'この日の潮汐予報はまだありません';

  @override
  String get calendar_noTideMonth => '今月の潮汐予報はまだありませんが、旧暦の日付と月は見られます';

  @override
  String get calendar_rangeLegend => '1日の潮位差';

  @override
  String get calendar_lunarLegend => '赤字：旧暦の1日、15日';

  @override
  String moon_times(String rise, String set) {
    return '月の出 $rise · 月の入り $set';
  }

  @override
  String get moon_alwaysUp => '月は一日中空に出ています';

  @override
  String get moon_alwaysDown => '今日は月が昇りません';

  @override
  String get solunar_title => '月による時合い';

  @override
  String get solunar_titleGood => '月による時合い · 好日（満月/新月の近く）';

  @override
  String solunar_major(String range) {
    return 'メイン $range';
  }

  @override
  String solunar_minor(String range) {
    return 'サブ $range';
  }

  @override
  String get solunar_now => '進行中';

  @override
  String get summary_title => '今ここでは';

  @override
  String summary_water(String state, String extreme, String time, String wait) {
    return '$state、$time に$extreme（あと $wait）';
  }

  @override
  String summary_fishing(String score, String label) {
    return '釣り $score/10 $label';
  }

  @override
  String summary_wind(int kmh) {
    return '風 $kmh km/h';
  }

  @override
  String get map_goFishing => '今すぐ釣りへ';

  @override
  String get hazard_title => '注意';

  @override
  String get hazard_titleSevere => '危険 — 川に出ないでください';

  @override
  String hazard_at(String time) {
    return '$time';
  }

  @override
  String hazard_between(String from, String to) {
    return '$from–$to';
  }

  @override
  String get hazard_thunderstorm => '雷雨・落雷：岸に上がり、開けた場所や釣り竿から離れてください';

  @override
  String get hazard_gust => '突風 50 km/h 超：船を出さないでください';

  @override
  String get hazard_heavyRain => '1時間に 20 mm を超える大雨';

  @override
  String get hazard_possibleStorm => '天気が不安定で、雷雨の可能性があります';

  @override
  String get hazard_risingFast => '水位が異常に速く上昇中（ここ数日よりかなり速い）：低い河原や砂州を避けてください';

  @override
  String get hazard_flood => '明日は川の流量が急増（上流で大雨）：増水、濁り、急流';

  @override
  String get watch_edit => '名前・メモ・グループ';

  @override
  String get watch_editTitle => 'あなたのポイント';

  @override
  String get watch_label => '独自の名前';

  @override
  String get watch_labelHint => '例：ガジュマルの根元の深み';

  @override
  String get watch_note => 'メモ';

  @override
  String get watch_noteHint => '例：ミミズ餌、渦のあるところ';

  @override
  String get watch_group => 'グループ';

  @override
  String get watch_groupHint => '例：紅河、湖';

  @override
  String get watch_noGroup => '未分類';

  @override
  String get common_save => '保存';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get trip_title => '釣行を計画する';

  @override
  String get trip_open => '計画する';

  @override
  String get trip_noPlaces => '釣り場をいくつか保存すると（地図で ⭐ をタップ）、アプリが最適な釣りの時間を探します。';

  @override
  String trip_intro(int count) {
    return '保存した $count か所の今後 7 日間で最適な釣りの時間です。各ポイントの潮、月、天気から計算しています。';
  }

  @override
  String get trip_none => '今後 7 日間、保存したポイントで 7/10 以上になる時間はありません。';

  @override
  String trip_score(String score) {
    return '最高釣りスコア $score/10';
  }

  @override
  String trip_because(String reasons) {
    return '良い理由：$reasons';
  }

  @override
  String get trip_note => 'メモ';

  @override
  String get where_title => '今日はどこで釣る？';

  @override
  String get where_short => 'どこで？';

  @override
  String get more_shortcuts => 'ショートカット';

  @override
  String get trip_listDetail => '近くの釣り仲間の集まりを見て参加';

  @override
  String get trip_createDetail => '仲間を釣りに誘う、ゴールデンタイムの提案つき';

  @override
  String get checkin_detail => 'ここで釣りをしていることを知らせる（匿名、4時間）';

  @override
  String get checkin_peopleDetail => '今釣りをしている場所、誰が釣れているか';

  @override
  String get spot_listDetail => '釣り仲間がピン留めしたポイント、写真とコメントつき';

  @override
  String get where_entryHint => '今後 24 時間で近くの最高の釣り場';

  @override
  String get where_radius => '範囲';

  @override
  String where_km(int km) {
    return '$km km';
  }

  @override
  String where_around(String place) {
    return '$place 周辺';
  }

  @override
  String get where_aroundHere => '現在地周辺';

  @override
  String get where_aroundLast => '前回の位置周辺（◎ をタップで更新）';

  @override
  String get where_needLocation => '最寄りの釣り場を探すため、現在地を教えてください。';

  @override
  String get where_useLocation => '現在地を使う';

  @override
  String get where_refresh => '位置を更新';

  @override
  String get where_kindHere => '現在地';

  @override
  String get where_kindStation => '観測所';

  @override
  String get where_kindSaved => '保存したポイント';

  @override
  String get where_kindCommunity => 'コミュニティのポイント';

  @override
  String where_distance(String km) {
    return '$km km 先';
  }

  @override
  String where_golden(String when) {
    return 'ゴールデンタイム $when';
  }

  @override
  String where_bestHour(String when) {
    return 'ゴールデンタイムなし · 一番良い時間 $when';
  }

  @override
  String get where_unsafe => 'この時間帯に気象警報があります';

  @override
  String get where_loading => '釣りスコアを計算中…';

  @override
  String get where_failed => 'このポイントのデータを読み込めません';

  @override
  String get where_onMap => '地図で見る';

  @override
  String get where_fishHere => 'ここで釣る';

  @override
  String where_rank(int rank) {
    return '$rank位';
  }

  @override
  String get where_note =>
      '今後 24 時間の推定釣りスコア（潮、月の時間、昼/夜、Open-Meteo の天気）順に並べています — 参考としてご覧ください。コミュニティのポイントはユーザーがピン留めしたものです。最寄り最大 8 か所。';

  @override
  String get where_onlyHere => 'この範囲内に観測所、保存したポイント、コミュニティのポイントがないため、現在地のみ計算できます。範囲を広げてみてください。';

  @override
  String get habit_title => 'あなたの釣りの傾向';

  @override
  String habit_needMore(int count) {
    return 'あと $count 回釣果を記録すると、よく釣れるタイミングをアプリが見つけます。';
  }

  @override
  String habit_progress(int have, int need) {
    return '$have/$need 回';
  }

  @override
  String habit_none(int count) {
    return '$count 回の釣果ではまだ目立った条件はありません。記録を続けましょう。';
  }

  @override
  String habit_hits(int hits, int known) {
    return '$hits/$known 回';
  }

  @override
  String get habit_note => '端末内の日誌から集計したもので、確かな法則ではありません。よく釣りに行く時間帯ほど釣果も多くなります。';

  @override
  String get habit_match => 'よく釣れたときと似ています';

  @override
  String get habit_dawn => '夜明け';

  @override
  String get habit_morning => '朝';

  @override
  String get habit_midday => '昼';

  @override
  String get habit_afternoon => '午後';

  @override
  String get habit_dusk => '夕暮れ';

  @override
  String get habit_night => '夜';

  @override
  String get habit_rising => '上げ潮のとき';

  @override
  String get habit_falling => '下げ潮のとき';

  @override
  String get habit_slack => '潮止まりのとき（潮の変わり目）';

  @override
  String get habit_newMoon => '新月の前後（旧暦の月末/月初）';

  @override
  String get habit_fullMoon => '満月の前後（15日）';

  @override
  String get habit_quarter => '半月の日';

  @override
  String get habit_major => '月のメイン時間内';

  @override
  String get habit_minor => '月のサブ時間内';

  @override
  String get habit_noSolunar => '月の時間外';

  @override
  String get habit_calm => '無風のとき（10 km/h 未満）';

  @override
  String get habit_light => '弱い風のとき（10–20 km/h）';

  @override
  String get habit_strong => '強い風のとき（20 km/h 超）';

  @override
  String get journal_title => '釣り日誌';

  @override
  String get journal_open => '日誌';

  @override
  String get journal_add => '釣果を記録';

  @override
  String get journal_empty => 'まだ釣果がありません。釣れるたびに「釣果を記録」をタップすると、そのときの水位、潮、天気、月が自動で保存されます。';

  @override
  String journal_place(String name) {
    return '場所：$name';
  }

  @override
  String get journal_placeHint => '「釣り」タブで選択中のポイントです。必要ならそちらで変更してください。';

  @override
  String get journal_changeTime => '時刻を変更';

  @override
  String get journal_species => '魚種';

  @override
  String get journal_weight => '重さ (kg)';

  @override
  String get journal_length => '長さ (cm)';

  @override
  String get journal_bait => '餌';

  @override
  String get journal_note => 'メモ';

  @override
  String get journal_camera => '写真を撮る';

  @override
  String get journal_gallery => '写真を選ぶ';

  @override
  String get journal_removePhoto => '写真を削除';

  @override
  String get journal_photoError => 'この写真を読み込めません';

  @override
  String get journal_needSpecies => '魚種を入力してください';

  @override
  String get journal_privacy => '日誌と写真はこの端末にのみ保存されます。写真の GPS 位置情報は削除されます。';

  @override
  String get journal_statsTitle => 'あなたの釣り';

  @override
  String journal_statsCount(int count, String kg) {
    return '$count 回 · 合計 $kg kg';
  }

  @override
  String journal_statsTop(String species, int count) {
    return '一番よく釣れた魚：$species（$count 回）';
  }

  @override
  String journal_statsRising(int pct) {
    return '釣果の $pct% は上げ潮のとき';
  }

  @override
  String journal_statsFalling(int pct) {
    return '釣果の $pct% は下げ潮のとき';
  }

  @override
  String journal_water(String state) {
    return '水位 $state';
  }

  @override
  String get journal_conditions => '釣ったときの条件';

  @override
  String journal_weightValue(String kg) {
    return '重さ $kg kg';
  }

  @override
  String journal_lengthValue(int cm) {
    return '長さ $cm cm';
  }

  @override
  String journal_baitValue(String bait) {
    return '餌：$bait';
  }

  @override
  String journal_levelValue(String level) {
    return '水位 $level';
  }

  @override
  String journal_scoreValue(String score) {
    return '釣りスコア $score/10';
  }

  @override
  String get journal_delete => '削除';

  @override
  String get journal_deleteTitle => 'この釣果を日誌から削除しますか？';

  @override
  String get place_city => '市・町';

  @override
  String get place_ward => '住宅地・村';

  @override
  String get place_bridge => '橋';

  @override
  String get place_ferry => 'フェリー乗り場';

  @override
  String get place_wharf => '船着き場';

  @override
  String place_near(String kind, String town) {
    return '$kind · $town 付近';
  }

  @override
  String get share_action => '共有';

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
    return '釣りスコア $score/10';
  }

  @override
  String get share_copied => '内容とリンクをコピーしました。Zalo/Facebook に貼り付けて送信してください';

  @override
  String get share_footer => '計算データ、参考値です · Con Nước';

  @override
  String get more_outdoor => '屋外モード';

  @override
  String get more_outdoorHint => '高コントラスト、大きな文字：強い日差しの下でも読みやすい';

  @override
  String get map_legendFlowRising => '水位が上がっている川の区間';

  @override
  String get map_legendFlowFalling => '水位が下がっている川の区間';

  @override
  String get map_legendFlowSlack => '潮止まりの川の区間';

  @override
  String get map_legendFlowNote =>
      '川の区間ごとに色分けしています（潮が届く時刻は区間ごとに異なります）。10 分ごとに更新。動く筋は川が海へ流れる方向を示します。';

  @override
  String get map_layerWeather => '周辺の雨と風';

  @override
  String get map_layerWeatherHint => '青い点：今後 1 時間の雨（大きいほど多い）。矢印：風が吹いていく方向。見たいエリアを拡大してください。';

  @override
  String hazard_surge(int cm) {
    return '海面が通常の潮位より $cm cm 高くなっています（強風や台風が水を押し寄せている）：低い浜辺や河口は浸水しやすいです';
  }

  @override
  String get more_install => 'Con Nước をホーム画面に追加';

  @override
  String get more_installHow =>
      'Android（Chrome）：⋮ をタップして「アプリをインストール」を選択。iPhone（Safari）：共有ボタンをタップして「ホーム画面に追加」を選択。ストア不要で本物のアプリのようにすばやく開けます。';

  @override
  String get alert_channel => '潮アラーム';

  @override
  String get alert_channelHint => '保存したポイントの満潮・干潮・釣りに良い時間の前にお知らせ';

  @override
  String alert_highTitle(String place, String time) {
    return '$place：満潮 $time';
  }

  @override
  String alert_lowTitle(String place, String time) {
    return '$place：干潮 $time';
  }

  @override
  String alert_levelBody(String level, int minutes) {
    return '水位 約 $level、あと $minutes 分';
  }

  @override
  String alert_fishTitle(String place, String from, String to) {
    return '$place：釣りに良い時間 $from–$to';
  }

  @override
  String alert_fishBody(String score, int minutes) {
    return '釣りスコア $score/10、$minutes 分後に開始';
  }

  @override
  String get alert_toggleOn => '潮アラームをオン';

  @override
  String get alert_toggleOff => '潮アラームをオフ';

  @override
  String get alert_onSnack => 'このポイントのアラームをオンにしました。アラームの種類と通知タイミングは上部の ⚙ ボタンで設定できます。';

  @override
  String alert_fishBodyLike(String score, int minutes) {
    return '✨ よく釣れたときと似ています · 釣りスコア $score/10、$minutes 分後に開始';
  }

  @override
  String get alert_settings => 'アラーム設定';

  @override
  String get alert_golden => 'ゴールデンタイム前に通知';

  @override
  String get alert_goldenHint => 'その時間帯に雷雨・突風・大雨の警報がない場合のみ通知します';

  @override
  String get alert_tides => '満潮 / 干潮の前に通知';

  @override
  String get alert_lead => '事前通知';

  @override
  String alert_leadMin(int minutes) {
    return '$minutes 分';
  }

  @override
  String get alert_howTo => 'ウォッチリストの各ポイントでベルをオンにしてください。アプリは開くたびにアラームを再設定します（今後 7 日間）。';

  @override
  String get alert_getApk => 'Android アプリを入手';

  @override
  String get alert_denied => '通知が許可されていません。設定 > アプリ > Con Nước > 通知 でオンにしてください。';

  @override
  String get alert_webOnly => 'アラームは Android アプリのみ対応です（ブラウザは閉じていると鳴らせません）';

  @override
  String get more_apk => 'Android アプリをダウンロード（APK）';

  @override
  String get more_apkHint => '潮アラームとホーム画面ウィジェットが使えます。ダウンロード後にファイルを開き、この提供元からのインストールを許可してください。';

  @override
  String get directions_action => '経路';

  @override
  String get directions_failed => 'この端末で Google Maps を開けません';

  @override
  String get search_recent => '最近の検索';

  @override
  String get place_province => '省・市';

  @override
  String get place_commune => '坊・社';

  @override
  String get search_coordsHint => 'この座標の水位と釣りの時間を開く';

  @override
  String place_in(String kind, String area) {
    return '$kind · $area';
  }

  @override
  String search_coords(String coords) {
    return '座標 $coords';
  }

  @override
  String get spot_edit => '編集';

  @override
  String get spot_editTitle => '釣り場を編集';

  @override
  String get spot_save => '変更を保存';

  @override
  String get spot_editSaved => '変更を保存しました';

  @override
  String spot_edited(String date) {
    return '$date 編集';
  }

  @override
  String get spot_tooMany => 'この端末は今日 10 か所を投稿済みです。また明日投稿してください。';

  @override
  String spot_comments(int count) {
    return 'コメント $count 件';
  }

  @override
  String get cmt_title => 'コメント';

  @override
  String cmt_count(int count) {
    return 'コメント（$count）';
  }

  @override
  String get cmt_hint => '餌、食いの時間、行き方などを共有…';

  @override
  String get cmt_send => 'コメントを投稿';

  @override
  String get cmt_empty => 'まだコメントはありません。最初の一人になりましょう！';

  @override
  String get cmt_anon => '匿名の釣り人';

  @override
  String cmt_asName(String name) {
    return '$name としてコメント · 変更';
  }

  @override
  String get cmt_asAnon => '匿名 · 表示名を設定';

  @override
  String get cmt_edited => '編集済み';

  @override
  String get cmt_mine => 'あなた';

  @override
  String get cmt_more => 'その他';

  @override
  String get cmt_edit => 'コメントを編集';

  @override
  String get cmt_delete => '削除';

  @override
  String get cmt_report => '報告';

  @override
  String get cmt_deleteTitle => '自分のコメントを削除しますか？';

  @override
  String get cmt_reportTitle => 'このコメントを報告しますか？';

  @override
  String get cmt_reportHint => '暴言、詐欺、広告など… 3 人に報告されたコメントは自動で非表示になります。';

  @override
  String get cmt_error => '送信できませんでした。ネットワークを確認して再試行してください';

  @override
  String get cmt_tooFast => '投稿が少し速すぎます — 少し待ってから送ってください';

  @override
  String get cmt_loadError => 'コメントを読み込めません';

  @override
  String get name_title => '表示名';

  @override
  String get name_hint => '例：釣り師カイン';

  @override
  String get name_note => 'コメント、釣りの集まり、メッセージに表示されます。空欄 = 匿名。';

  @override
  String get social_save => '保存';

  @override
  String get nav_ponds => '釣り堀';

  @override
  String get pond_title => '釣り堀';

  @override
  String get pond_tag => '有料釣り堀';

  @override
  String get pond_add => '釣り堀を追加';

  @override
  String get pond_addTitle => '釣り堀を追加';

  @override
  String get pond_addHere => 'ここに釣り堀を追加';

  @override
  String pond_pill(int count) {
    return '釣り堀 $count件';
  }

  @override
  String pond_pillSoon(int count) {
    return 'まもなく放流 $count件';
  }

  @override
  String get pond_pillDetail => '近くの有料釣り堀・放流スケジュール';

  @override
  String get pond_editTitle => '釣り堀情報を編集';

  @override
  String get pond_empty => '40 km 以内に釣り堀がまだありません。ご存じなら「釣り堀を追加」でみんなに教えてください。';

  @override
  String get pond_loadError => '釣り堀一覧を読み込めませんでした';

  @override
  String get pond_filterRelease => 'まもなく放流';

  @override
  String get pond_filterVerified => '確認済み';

  @override
  String get pond_filterFollowed => 'フォロー中';

  @override
  String get pond_followedSoon => 'フォロー中の釣り堀がまもなく放流';

  @override
  String get pond_verified => '確認済み';

  @override
  String get pond_owner => 'オーナー登録済み';

  @override
  String get pond_unverified => '未確認';

  @override
  String get pond_fromWeb => 'ウェブから集めた情報で、古い可能性があります。現地で正しければ「実在する釣り堀」を押してみんなを助けてください。';

  @override
  String get pond_approx => '住所からのおおよその位置です。近くの方は「編集」でピンを直してください。';

  @override
  String pond_distance(String km) {
    return '$km先';
  }

  @override
  String pond_rating(String rating, int count) {
    return '$rating ★（$count）';
  }

  @override
  String get pond_noRating => '評価はまだありません';

  @override
  String pond_releaseChip(String when) {
    return '$when 放流';
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
    return '$taキンタル';
  }

  @override
  String pond_ton(String ton) {
    return '$tonトン';
  }

  @override
  String get pond_releases => '放流スケジュール';

  @override
  String get pond_noRelease => '予定されている放流はありません。';

  @override
  String get pond_official => 'オーナー投稿';

  @override
  String get pond_relayed => 'ユーザー報告 · 未確認';

  @override
  String get pond_releasePast => '放流済み';

  @override
  String get pond_releaseCancelled => '中止';

  @override
  String get pond_postRelease => '放流を報告';

  @override
  String get pond_showSource => '元の投稿を見る';

  @override
  String get pond_cancelRelease => 'この予定を取り消す';

  @override
  String get pond_reportRelease => '誤りを報告';

  @override
  String get pond_follow => 'フォロー';

  @override
  String get pond_following => 'フォロー中';

  @override
  String get pond_followHint => 'この釣り堀に新しい放流があると一覧の先頭に表示されます（Android アプリは通知が鳴ります）。';

  @override
  String get pond_call => '電話';

  @override
  String get pond_price => '料金';

  @override
  String get pond_hours => '営業時間';

  @override
  String get pond_species => '釣り堀の魚';

  @override
  String get pond_note => 'メモ';

  @override
  String get pond_sources => '出典';

  @override
  String get pond_pulseTitle => 'いまの釣り堀（過去6時間）';

  @override
  String get pond_pulseBusy => '混雑';

  @override
  String get pond_pulseQuiet => '空いている';

  @override
  String get pond_pulseBiting => '釣れている';

  @override
  String get pond_pulseReleased => '放流直後';

  @override
  String pond_pulseCount(String label, int count) {
    return '$label · $count';
  }

  @override
  String get pond_pulseSent => '送信しました。ありがとうございます！';

  @override
  String get pond_pulseWait => '報告は30分に1回までです';

  @override
  String get pond_confirm => '実在する釣り堀';

  @override
  String get pond_confirmed => '確認済み';

  @override
  String get pond_confirmDone => 'ありがとう！3人が確認すると釣り堀に ✓ が付きます';

  @override
  String get pond_edit => '編集';

  @override
  String get pond_claim => '私がオーナーです';

  @override
  String get pond_claimTitle => '釣り堀の管理を申請';

  @override
  String get pond_claimBody =>
      'なりすまし防止のため、管理者が電話または Zalo で確認のご連絡をします。承認後は「公式」の放流予定を投稿し、料金や営業時間を編集できます。';

  @override
  String get pond_claimContact => '釣り堀の電話番号 / Zalo';

  @override
  String get pond_claimNote => 'メッセージ（任意）';

  @override
  String get pond_claimSend => '申請を送信';

  @override
  String get pond_claimSent => '送信しました！管理者からまもなくご連絡します。';

  @override
  String get pond_claimPending => '申請は審査待ちです。';

  @override
  String get pond_claimOwned => 'この釣り堀はすでにオーナーが管理しています。';

  @override
  String get pond_claimYours => 'あなたはこの釣り堀のオーナーです。';

  @override
  String get pond_report => '報告';

  @override
  String get pond_reportTitle => 'この釣り堀を報告しますか？';

  @override
  String get pond_reportHint => '存在しない、閉業、場所違い…オーナー未登録の釣り堀は3人が報告すると自動で非表示になります。';

  @override
  String get pond_error => '送信できませんでした。通信を確認して再試行してください';

  @override
  String get pond_tooMany => '今日は操作が多すぎます。明日また試してください';

  @override
  String get pond_duplicate => 'ここにはすでに釣り堀が登録されています。開きますか？';

  @override
  String get pond_open => '開く';

  @override
  String get pond_name => '釣り堀の名前';

  @override
  String get pond_nameHint => '例：Thanh Hà 釣り堀';

  @override
  String get pond_address => '住所';

  @override
  String get pond_phone => '電話番号 / Zalo';

  @override
  String get pond_priceHint => '例：200k/4時間、350k/日';

  @override
  String get pond_hoursHint => '例：6時–18時、月曜定休';

  @override
  String pond_location(String coords) {
    return 'ピンの位置：$coords';
  }

  @override
  String get pond_locationHint => 'ピンは地図で選んだ場所に置かれます。変更するには：地図上の釣り堀をタップ → 釣り堀を追加。';

  @override
  String get pond_save => '保存';

  @override
  String get pond_added => '釣り堀を追加しました！ありがとうございます。';

  @override
  String get pond_saved => '保存しました';

  @override
  String get pond_needName => '釣り堀の名前を入力してください（2文字以上）';

  @override
  String get pond_reviews => 'レビュー';

  @override
  String get pond_writeReview => 'レビューを書く';

  @override
  String get pond_reviewHint => '釣れ具合、料金、サービス、釣り座…';

  @override
  String get pond_reviewSend => 'レビューを投稿';

  @override
  String get pond_reviewEmpty => 'レビューはまだありません。';

  @override
  String get pond_deleteReview => '自分のレビューを削除';

  @override
  String get pond_noStars => '星の数を選んでください';

  @override
  String get release_title => '放流を報告';

  @override
  String get release_paste => '釣り堀の投稿を貼り付け';

  @override
  String get release_pasteHint =>
      '釣り堀の Facebook 投稿 / TikTok キャプションをコピーしてここに貼り付けてください。アプリが日付・時間・魚種・量を読み取ります。';

  @override
  String get release_pasteButton => '貼り付け';

  @override
  String get release_read => 'アプリが読み取った内容';

  @override
  String get release_notFound => '投稿に放流日が見つかりません。下で日付を選んでください。';

  @override
  String get release_day => '日付';

  @override
  String get release_time => '時間';

  @override
  String get release_fish => '放流する魚';

  @override
  String get release_addFish => '魚種を追加';

  @override
  String get release_fishName => '魚種';

  @override
  String get release_fishKg => 'kg';

  @override
  String release_total(String amount) {
    return '合計 $amount';
  }

  @override
  String get release_asOwner => 'あなたはオーナーです：この予定は「オーナー投稿」として表示されます。';

  @override
  String get release_asUser => '報告した予定はオーナーが確認するまで「ユーザー報告」と表示されます。釣り堀の実際の投稿を見たときだけ報告してください。';

  @override
  String get release_post => '放流予定を投稿';

  @override
  String get release_posted => '放流予定を投稿しました！';

  @override
  String get release_needDay => '放流日を選んでください';

  @override
  String get stations_menu => '観測所一覧';

  @override
  String get stations_menuHint => 'KTTV・IOC 観測所の水位';

  @override
  String get trip_tag => '釣り会';

  @override
  String trip_pill(int count) {
    return '釣り会 $count件';
  }

  @override
  String get trip_create => '釣りに誘う';

  @override
  String get trip_createHere => 'ここで釣りに誘う';

  @override
  String get trip_formTitle => '釣り会を作成';

  @override
  String get trip_editTitle => '釣り会を編集';

  @override
  String get trip_name => '釣り会の名前';

  @override
  String get trip_nameHint => '例：Thanh Trì 橋の岩場で夜釣り';

  @override
  String get trip_place => '集合場所';

  @override
  String get trip_placeHint => '例：橋の下の岩場、3番ゲート';

  @override
  String get trip_whereHint => '釣り会のピンはここに置かれます。別の場所にするには：地図でその場所をタップ → 「ここで釣りに誘う」。';

  @override
  String get trip_when => '日時';

  @override
  String get trip_date => '日付';

  @override
  String get trip_start => '開始';

  @override
  String get trip_duration => '釣りの時間';

  @override
  String trip_hours(int hours) {
    return '$hours時間';
  }

  @override
  String get trip_golden => 'ここのゴールデンタイム（タップで選択）';

  @override
  String trip_goldenChip(String when, String score) {
    return '$when · $score';
  }

  @override
  String get trip_noGolden => '今後3日間、ここにゴールデンタイムはありません';

  @override
  String get trip_people => '最大人数（自分を含む）';

  @override
  String get trip_contact => '連絡先（任意）';

  @override
  String get trip_contactHint => 'Zalo/Facebook グループのリンクまたは電話番号';

  @override
  String get trip_contactNote => '参加した人だけが見られます。';

  @override
  String get trip_noteHint => '狙う魚、エサ、バイクか相乗りか、ガソリン代の割り勘…';

  @override
  String get trip_submit => '釣り会を作成';

  @override
  String get trip_save => '変更を保存';

  @override
  String get trip_created => '釣り会を作成しました！近くの釣り人が地図で見られます。';

  @override
  String get trip_saved => '釣り会を保存しました';

  @override
  String get trip_needName => '釣り会の名前を付けてください（2文字以上）';

  @override
  String get trip_badTime => '開始時刻は今後30日以内にしてください';

  @override
  String get trip_tooMany => 'この端末は今日すでに釣り会を5件作成しました。また明日どうぞ。';

  @override
  String get trip_error => '送信できませんでした。通信を確認して再試行してください';

  @override
  String get trip_tooFew => 'すでにこの人数より多く参加しています';

  @override
  String get trip_running => '開催中';

  @override
  String get trip_cancelled => '中止';

  @override
  String get trip_full => '満員';

  @override
  String trip_left(int count) {
    return '残り $count 枠';
  }

  @override
  String trip_members(int count, int max) {
    return '$count/$max人';
  }

  @override
  String trip_owner(String name) {
    return '主催：$name';
  }

  @override
  String get trip_yours => '自分の釣り会';

  @override
  String get trip_joinedTag => '参加中';

  @override
  String get trip_join => '参加';

  @override
  String get trip_joinedSnack => '参加しました！下で連絡先を確認し、グループとチャットできます。';

  @override
  String get trip_joinFull => 'この釣り会は満員です';

  @override
  String get trip_joinClosed => 'この釣り会は終了したか中止されました';

  @override
  String get trip_leave => '釣り会を抜ける';

  @override
  String get trip_leaveTitle => 'この釣り会を抜けますか？';

  @override
  String get trip_cancel => '釣り会を中止';

  @override
  String get trip_cancelTitle => '釣り会を中止しますか？参加者には「中止」と表示されます。';

  @override
  String get trip_edit => '編集';

  @override
  String get trip_keep => '釣り会を続ける';

  @override
  String get trip_share => '友だちを誘う';

  @override
  String trip_shareText(String title, String when, String place, String map, String app) {
    return '🎣 釣り会：$title\n🕐 $when\n📍 $place\n地図：$map\nCon Nước アプリで見て参加：$app';
  }

  @override
  String get trip_report => '報告';

  @override
  String get trip_reportTitle => 'この釣り会を報告しますか？';

  @override
  String get trip_reportHint => '詐欺、広告、不適切な内容…3人が報告した釣り会は自動で非表示になります。';

  @override
  String get trip_membersOnly => '参加すると連絡先・参加者一覧を見て、グループとチャットできます。';

  @override
  String get trip_contactLabel => '連絡先';

  @override
  String get trip_openContact => '開く';

  @override
  String get trip_memberList => '参加者';

  @override
  String get trip_chat => '釣り会チャット';

  @override
  String get trip_chatEmpty => 'メッセージはまだありません。集合時間や駐車場所をここで決めましょう。';

  @override
  String get trip_chatHint => 'グループにメッセージ…';

  @override
  String get trip_send => '送信';

  @override
  String get trip_refresh => '再読み込み';

  @override
  String get trip_nearbyTitle => '近くの釣り会';

  @override
  String get trip_nearbyEmpty => '30 km 以内に釣り会はまだありません。最初の釣り会を作って仲間を誘いましょう！';

  @override
  String get trip_loadError => '釣り会を読み込めませんでした';

  @override
  String get trip_notice => '釣り会は近くのユーザーに公開されます。釣り禁止の場所で集まらないでください。複数人で行動し、夜釣りでは安全に注意しましょう。';

  @override
  String get checkin_pill => '釣り中';

  @override
  String checkin_pillOn(String time) {
    return '釣り中 · 残り $time';
  }

  @override
  String checkin_count(int count) {
    return '$count人が釣り中';
  }

  @override
  String get checkin_title => '「ここで釣り中」を知らせる';

  @override
  String get checkin_body =>
      '近くの釣り人に、このエリアで誰かが釣りをしていることが表示されます。人数だけで名前は表示されません。位置は約200 m 単位に丸められ、4時間後に自動でオフになります。';

  @override
  String get checkin_biting => '釣れてる 🐟';

  @override
  String get checkin_noBite => 'まだ釣れない';

  @override
  String get checkin_start => '開始';

  @override
  String get checkin_update => '更新';

  @override
  String get checkin_stop => '帰ります';

  @override
  String get checkin_on => '釣り中を知らせました。大物が釣れますように！';

  @override
  String get checkin_off => 'オフにしました。気をつけて帰ってね！';

  @override
  String get checkin_error => '送信できませんでした。通信を確認して再試行してください';

  @override
  String get checkin_needLocation => '釣り中を知らせるには位置情報が必要です';

  @override
  String checkin_cellTitle(int count) {
    return '近くで$count人が釣り中';
  }

  @override
  String checkin_cellBiting(int count) {
    return '$count人が釣れていると報告';
  }

  @override
  String get checkin_cellNoBite => 'まだ誰も釣れたと報告していません';

  @override
  String checkin_cellLatest(String time) {
    return '最後の到着 $time';
  }

  @override
  String get checkin_cellYou => 'あなたも含む';

  @override
  String get checkin_listTitle => '釣り人がいる場所';

  @override
  String get checkin_hint => '位置は約200 m 単位に丸められ、名前は表示されません。';

  @override
  String get spot_publicTag => 'コミュニティ釣り場';

  @override
  String get spot_pinAction => '公開でピン留め';

  @override
  String spot_nearbyChip(int count) {
    return 'コミュニティ釣り場 $count件';
  }

  @override
  String get spot_nearbyTitle => '近くの釣り場';

  @override
  String get spot_nearbyEmpty => '30 km 以内に釣り場はまだありません。地図で場所をタップし、「公開でピン留め」で釣り場を共有しましょう。';

  @override
  String spot_postedAgo(String date) {
    return '$date に投稿';
  }

  @override
  String spot_distance(String km) {
    return '$km先';
  }

  @override
  String get spot_viewWater => 'ここの水位を見る';

  @override
  String get spot_report => '報告';

  @override
  String get spot_reportTitle => 'この釣り場を報告しますか？';

  @override
  String get spot_reportHint => '場所違い、不適切な写真、広告…多くの人が報告した釣り場は自動で非表示になります。';

  @override
  String get spot_reportDone => '報告を送信しました。ありがとうございます！';

  @override
  String get spot_reportTwice => 'この釣り場はすでに報告済みです';

  @override
  String get spot_delete => '自分の釣り場を削除';

  @override
  String get spot_deleteTitle => 'この釣り場をコミュニティマップから削除しますか？';

  @override
  String get spot_ownedByYou => '自分の釣り場';

  @override
  String get spot_publishTitle => '釣り場を公開でピン留め';

  @override
  String get spot_name => '釣り場の名前';

  @override
  String get spot_nameHint => '例：Thanh Trì 橋の岩場';

  @override
  String get spot_species => 'よく釣れる魚';

  @override
  String get spot_note => 'コツ';

  @override
  String get spot_noteHint => 'エサ、よい時間帯、駐車場所、水深…';

  @override
  String get spot_photos => '写真（最大3枚）';

  @override
  String get spot_addPhoto => '写真を追加';

  @override
  String get spot_publicNotice => 'この釣り場は Con Nước の全ユーザーに公開されます。釣り禁止の場所や、同意なく他人が写った写真は投稿しないでください。';

  @override
  String get spot_agree => '理解し、共有に同意します';

  @override
  String get spot_publish => '釣り場を投稿';

  @override
  String get spot_published => 'ピン留めしました！近くの人があなたの釣り場を見られます。';

  @override
  String get spot_needName => '釣り場の名前を付けてください（2文字以上）';

  @override
  String get spot_error => '送信できませんでした。通信を確認して再試行してください';

  @override
  String get spot_photoError => 'この写真を読み込めません';

  @override
  String spot_location(String coords) {
    return '位置：$coords';
  }

  @override
  String get station_levelNow => '現在の水位';

  @override
  String get station_follow => '観測所をフォロー';

  @override
  String get station_unfollow => 'フォロー解除';

  @override
  String get stations_kindRiver => '河川観測所（KTTV）';

  @override
  String get stations_kindRiverDaily => '感潮河川（KTTV）';

  @override
  String get station_sourceRiver => 'KTTV 水文速報（1日4回の観測＋予報）· 毎時の線はアプリが補間';

  @override
  String get station_sourceRiverTide => 'KTTV 水文速報＋河口の潮汐（Open-Meteo Marine）· 毎時の線はアプリが推定';

  @override
  String get station_datumNational => '観測所の基準面（KTTV 速報による）';

  @override
  String station_issued(String time) {
    return 'KTTV 速報 $time 発表';
  }

  @override
  String station_backtestMae(String cm) {
    return 'バックテスト：平均誤差 ±$cm cm';
  }

  @override
  String station_dailyTitle(int hours) {
    return '$hours時間の水位（KTTV 速報）';
  }

  @override
  String station_dailyObs(String max, String min) {
    return '実測：最高 $max · 最低 $min';
  }

  @override
  String station_dailyFc(String max, String min) {
    return '予報：最高 $max · 最低 $min';
  }

  @override
  String get station_dailyNoCurve => '速報には最高・最低水位だけで時刻がありません。満ち引きの時刻を誤って推測しないよう、アプリは線を描きません。';

  @override
  String station_dailyRangeNow(String range) {
    return '予報の変動幅 $range — 水位はこの範囲で上下します';
  }

  @override
  String get point_estimateHere => 'この地点の推定水位';

  @override
  String get point_onWater => 'この地点は水面上です（川・湖・海）';

  @override
  String get point_onLand => 'この地点は川・湖・海の上ではありません。下の数値は最寄りの水域の水位です。';

  @override
  String point_basisRiver(String station, String river, String distance) {
    return '$station 観測所（$river 川）に基づく · $distance先';
  }

  @override
  String point_basisStation(String station, String distance) {
    return '$station 観測所に基づく · $distance先';
  }

  @override
  String point_alongDown(String station, String distance, String river) {
    return '$station 観測所から下流へ $distance（$river 川沿いに計測）';
  }

  @override
  String point_alongUp(String station, String distance, String river) {
    return '$station 観測所から上流へ $distance（$river 川沿いに計測）';
  }

  @override
  String point_lagEarlier(int minutes) {
    return '満ち引きは観測所より約$minutes分早い';
  }

  @override
  String point_lagLater(int minutes) {
    return '満ち引きは観測所より約$minutes分遅い';
  }

  @override
  String get point_lagSame => '満ち引きは観測所とほぼ同時';

  @override
  String point_meanLower(int cm) {
    return '水面は観測所より約 $cm cm 低い';
  }

  @override
  String point_meanHigher(int cm) {
    return '水面は観測所より約 $cm cm 高い';
  }

  @override
  String point_celerity(String speed) {
    return '潮は川を約 $speed km/h でさかのぼります';
  }

  @override
  String get point_reachNote => '川沿いの位置から、河口の潮汐と観測所の間で推定。2つ目の観測所での検証はまだです。';

  @override
  String get flow_unknown => 'ここは大きな川の上ではないため、水位と流量は計算できません。釣りの時間と天気はこの位置で計算されます。';

  @override
  String get flow_headRising => '川の水位が上昇中';

  @override
  String get flow_headFalling => '川の水位が低下中';

  @override
  String get flow_headSteady => '川の水位は安定';

  @override
  String flow_dayValue(String day, String q) {
    return '$day：$q m³/s';
  }

  @override
  String get loc_nearCoast => '河口付近';

  @override
  String get point_basisCoast => '最寄りの沿岸海域から潮汐を推定。川の中では満潮・干潮が遅れ、潮位差も小さくなるのが普通です。';

  @override
  String get info_noLevelSources =>
      'ここには水位データ源がまだありません。河川流量：GloFAS モデル（Open-Meteo Flood 経由）、日単位。天気・釣りの時間：Open-Meteo と正確な座標での天文計算。すべての数値は参考です。';

  @override
  String get flow_title => '川の流れ';

  @override
  String flow_today(String q) {
    return '今日の流量 ≈ $q m³/s';
  }

  @override
  String flow_tomorrow(String q, String trend) {
    return '明日 ≈ $q m³/s · $trend';
  }

  @override
  String get flow_rising => '増加中（川の水位が徐々に上昇）';

  @override
  String get flow_falling => '減少中（川の水位が徐々に低下）';

  @override
  String get flow_steady => '安定';

  @override
  String get flow_note => 'この区間の本流の日単位の推定値です。';

  @override
  String chart_band(String cm) {
    return '線の周りの帯：観測所でのバックテストによる誤差 約 ±$cm cm';
  }

  @override
  String turn_in(String duration) {
    return 'あと $duration';
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
  String get fishAct_title => '魚の活性';

  @override
  String get fishAct_low => '低い';

  @override
  String get fishAct_fair => '普通';

  @override
  String get fishAct_high => '高い';

  @override
  String get fishAct_peak => 'とても高い';

  @override
  String fishAct_score(String score) {
    return '$score/10';
  }

  @override
  String fishAct_meter(int count) {
    return '5匹中$count匹';
  }

  @override
  String fishAct_because(String reasons) {
    return '$reasons のおかげ';
  }

  @override
  String fishAct_next(String when) {
    return '次のゴールデンタイム：$when';
  }

  @override
  String fishAct_inWindow(String to) {
    return '$to までゴールデンタイム';
  }

  @override
  String get fishAct_noWindow => '今後2日間はゴールデンタイムがありません';

  @override
  String get fishAct_source => '潮、月の時刻、昼夜、天気（Open-Meteo）から推定 — 参考であり、どこに魚がいるかはわかりません。';

  @override
  String get fishAct_quick => '天気データなし：ひとまず潮と月の時刻で推定しています。';

  @override
  String get fishTime_now => '今';

  @override
  String fishTime_today(String time) {
    return '今日 $time';
  }

  @override
  String fishTime_tomorrow(String time) {
    return '明日 $time';
  }

  @override
  String fishTime_dayAfter(String time) {
    return '明後日 $time';
  }

  @override
  String get fishTime_title => '魚の活性の時刻';

  @override
  String get fishTime_slider => '時刻を選んで魚の活性を見る';

  @override
  String get fishTime_reset => '今に戻る';

  @override
  String get fishTime_legendNote => 'ピンの色 = 推定の魚の活性。ピンをタップで詳細。';

  @override
  String get fishTime_collapse => '閉じる';

  @override
  String get fishTime_expand => '時間ごとの魚の活性を見る';

  @override
  String get fishing_changeSpot => '変更';

  @override
  String get fishing_plan => '計画';

  @override
  String get pond_search => '名前で釣り堀を検索…';

  @override
  String pond_header(int count) {
    return '近くの釣り堀 $count件';
  }

  @override
  String pond_headerSoon(int count) {
    return '3日以内に放流する釣り堀 $count件';
  }

  @override
  String get pond_headerNone => '予定されている放流はありません';

  @override
  String fishing_nextGolden(String range) {
    return 'ゴールデンタイム $range';
  }

  @override
  String get fishing_hourly => '今日の毎時';

  @override
  String get fish_now_title => 'いまの釣り';

  @override
  String get fish_unsafe => '気象警報が発表中 — 水辺に出ないでください';

  @override
  String get fish_noWindow => '今日は特に良い時間帯がありません';

  @override
  String fish_best(String from, String to) {
    return '今日のおすすめ：$from–$to';
  }

  @override
  String get cond_title => '天気と空';

  @override
  String loc_river(String river) {
    return '$river 川';
  }

  @override
  String loc_nearRiver(String river) {
    return '$river 川の近く';
  }

  @override
  String get loc_sea => '海域';

  @override
  String get loc_water => '水面上';

  @override
  String get spot_title => '釣り場';

  @override
  String get spot_mine => '現在地';

  @override
  String get spot_point => '選んだ地点';

  @override
  String get spot_useMine => '現在地';

  @override
  String get spot_pickMap => '地図で選ぶ';

  @override
  String get spot_pickHint => '釣る予定の場所をタップしてから「ここで釣る」を押してください';

  @override
  String get spot_saved => '保存したポイント';

  @override
  String get fish_here => 'ここで釣る';

  @override
  String get advice_title => '今の釣りアドバイス';

  @override
  String get advice_note => '一般的な釣りの経験則をもとに、このポイントに合わせて計算しています。';

  @override
  String get advice_unsafe => '雷雨または強い突風 — 今は釣りを控えましょう';

  @override
  String get advice_rising => '上げ潮：魚は岸際、草の際、浅場にエサを探しに来ます — 近くを狙いましょう';

  @override
  String get advice_falling => '下げ潮：魚は深場、流れのヨレ、小川の河口へ移ります — 遠めを狙いましょう';

  @override
  String get advice_slack => '潮止まり：食いが落ちます。流れが戻るのを待ちましょう';

  @override
  String advice_slackAt(String time) {
    return '潮止まり：食いが落ちます — $timeごろ流れが戻ります';
  }

  @override
  String get advice_windStrong => '強風：遠投しにくい — 風裏の岸で釣り、船は出さないでください';

  @override
  String get advice_windDown => '風あり：風下側、波がエサを寄せる場所を狙いましょう';

  @override
  String get advice_rain => '雨の可能性が高い — レインウェアを持っていきましょう';

  @override
  String get advice_flood => '川が急に増水して濁っています：水制の裏や木の根元の反転流を狙いましょう';

  @override
  String get advice_light => 'もうすぐ日の出/日の入り — 魚がよく食う時間';

  @override
  String get advice_good => 'ポイントは好条件 — 今のうちに釣りへ';

  @override
  String point_reference(String station, String distance) {
    return '$station 観測所から推定、$distance 先';
  }

  @override
  String point_referenceRiver(String station, String river, String distance) {
    return '$station 観測所（$river 川）から推定、$distance 先';
  }

  @override
  String get point_title => '選んだ地点';

  @override
  String point_coords(String coords) {
    return '座標：$coords';
  }

  @override
  String get point_copy => '座標をコピー';

  @override
  String get point_copied => '座標をコピーしました';

  @override
  String get point_noData => 'この地点のデータはまだ計算できていません。';

  @override
  String get point_nearby => '最寄りの観測所';

  @override
  String point_distance(String distance) {
    return '$distance 先';
  }

  @override
  String get point_openDetail => '時間ごとの詳細を見る';

  @override
  String point_weatherNow(String temp, String wind, int rain) {
    return '現在の天気：$temp°C · 風 $wind km/h · 雨 $rain%';
  }

  @override
  String point_sun(String rise, String set) {
    return '日の出 $rise · 日の入り $set';
  }

  @override
  String get point_seaModel => 'この地点で直接計算した海洋モデル';

  @override
  String get point_tapHint => '地図のどこでもタップすると、その場所の水位がわかります';

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
    return '出典：$source · $updated';
  }

  @override
  String get source_details => '出典の詳細';

  @override
  String get map_credits => '地図の出典';

  @override
  String get map_creditShort => '© OpenStreetMap';

  @override
  String get map_creditShortSat => '© EOX · © OpenStreetMap';

  @override
  String station_datumNote(String datum) {
    return '$datumからの高さ';
  }

  @override
  String get station_datumChart => '海図基準面（KTTV 速報に基づき換算）';

  @override
  String get station_datumMsl => 'モデルの平均海面';

  @override
  String station_lunarDay(int day, int month) {
    return '旧暦 $month/$day';
  }

  @override
  String station_dailyRange(String range) {
    return '潮位差 $range';
  }

  @override
  String station_coords(String lat, String lon) {
    return '座標：$lat, $lon';
  }

  @override
  String station_modelFit(String from, String to) {
    return '$from〜$toのデータから算出した潮汐定数';
  }

  @override
  String get station_sourceGauge => 'IOC Sea Level Monitoring（実測）· 予報は utide で計算';

  @override
  String get station_sourceModel => 'Open-Meteo Marine（海洋モデル、実測なし）';

  @override
  String get hourly_now => '今';

  @override
  String hourly_detailTitle(String time) {
    return '$time の詳細';
  }

  @override
  String hourly_obsMinusPred(String delta) {
    return '実測 − 予報：$delta';
  }

  @override
  String hourly_untilNext(String kind, String duration) {
    return '次の$kindまで $duration';
  }

  @override
  String hourly_fishScore(String score) {
    return '釣り指数：$score/10';
  }

  @override
  String hourly_weather(String temp, String wind, String rain) {
    return '$temp °C · 風 $wind km/h · 雨 $rain mm';
  }

  @override
  String get hourly_empty => 'この時間帯の時間別データはありません。';

  @override
  String get chart_semantics => '水位グラフ、実測は実線、予報は破線';

  @override
  String get watch_empty =>
      '地図上の地点（または観測所）をタップし、⭐ を押して保存しましょう。保存したポイントはここですぐ確認でき、アラームが使え、オフラインでも見られます。';

  @override
  String get watch_emptyTitle => 'ポイントがまだありません';

  @override
  String get watch_openMap => '地図を開く';

  @override
  String get fishing_title => '釣り';

  @override
  String get fishing_pickStation => '観測所を選ぶ';

  @override
  String get fishing_dayScore => '今日のスコア';

  @override
  String fishing_reference(String version) {
    return '推定指数、参考値です（計算式 $version：潮、月の時間、日の出/日の入り、24時間の気圧、気温、風雨）';
  }

  @override
  String get fishing_golden => 'これからのゴールデンタイム';

  @override
  String get fishing_noGolden => '今日は 7 点以上の時間帯がありません。';

  @override
  String get fishing_next7 => '今後 7 日間';

  @override
  String get fishing_nowMark => '今';

  @override
  String fishing_hourShort(int hour) {
    return '$hour時';
  }

  @override
  String fishing_level(String score, String label) {
    return '$score/10 · $label';
  }

  @override
  String get fishing_levelGood => '良い';

  @override
  String get fishing_levelFair => 'まずまず';

  @override
  String get fishing_levelPoor => '悪い';

  @override
  String fishing_warnRed(String from, String to) {
    return '$from–$to に雷雨/落雷または強い突風 — この時間帯は川や海に出ないでください。';
  }

  @override
  String fishing_warnYellow(String from, String to) {
    return '$from–$to に雷雨または大雨の可能性 — 天気に注意してください。';
  }

  @override
  String fishing_levelOutsideWarning(String score, String label) {
    return '$score/10 · $label（警報時間帯以外）';
  }

  @override
  String get fishing_factor_tide => '潮';

  @override
  String get fishing_factor_flow => '流れ';

  @override
  String get fishing_factor_solunar => '月の時間';

  @override
  String get fishing_factor_pressure => '気圧';

  @override
  String get fishing_factor_daytime => '日の出/日の入り';

  @override
  String get fishing_factor_weather => '天気';

  @override
  String get fishing_factor_temperature => '快適な気温';

  @override
  String get fishing_factor_season => '魚のシーズン';

  @override
  String fishing_moon(String phase, int pct) {
    return '$phase · 輝面 $pct%';
  }

  @override
  String get fishing_weatherSource => 'Open-Meteo（天気予報）';

  @override
  String get moon_newMoon => '新月';

  @override
  String get moon_waxingCrescent => '三日月';

  @override
  String get moon_firstQuarter => '上弦の月';

  @override
  String get moon_waxingGibbous => '十三夜月';

  @override
  String get moon_fullMoon => '満月';

  @override
  String get moon_waningGibbous => '寝待月';

  @override
  String get moon_lastQuarter => '下弦の月';

  @override
  String get moon_waningCrescent => '有明月';

  @override
  String get more_info => 'アプリ情報';

  @override
  String get more_appName => 'Con Nước';

  @override
  String more_build(String sha) {
    return 'ビルド $sha';
  }

  @override
  String get more_update => '新しいバージョンがあります — ページを再読み込みして更新してください';

  @override
  String get more_close => '閉じる';

  @override
  String get more_title => 'その他';

  @override
  String get more_explore => '探す';

  @override
  String get more_app => 'アプリ';

  @override
  String get more_journalHint => 'あなたの釣果と釣りの傾向';

  @override
  String get more_profileHint => 'コメント、釣行、レビューに表示される名前';

  @override
  String get more_editName => '名前を変更';

  @override
  String get more_theme => 'テーマ';

  @override
  String get more_themeSystem => '端末の設定';

  @override
  String get more_themeLight => 'ライト';

  @override
  String get more_themeDark => 'ダーク';

  @override
  String get more_sources => 'データの出典';

  @override
  String get more_sourcesBody =>
      '• IOC Sea Level Monitoring — Vũng Tàu、Quy Nhơn の海面実測（毎分）。この 2 観測所の潮汐予報は 12 か月分のデータを調和解析（utide）して計算。バックテスト誤差：±10 cm（Vũng Tàu）、±7 cm（Quy Nhơn）。\n• ベトナム国立水文気象予報センター（KTTV）— 短期水文速報：河川水位 1 日 4 回 + 予報。時間ごとの線はアプリが推定（河口の潮汐と組み合わせ）。バックテスト：±12 cm（ハノイ）、±11 cm（Nam Đàn）。\n• Open-Meteo — 天気、波、沿岸海面モデル。\n• GloFAS（Open-Meteo Flood 経由）— 各河川本流の日別流量。\n• 地図上の任意の地点：その地点の海洋モデル。紅河（ホン川）、Cả 川では川沿いの位置から計算。それ以外は最寄りの KTTV 河川観測所（40 km 以内）、沿岸の潮汐（推定）または河川流量を使用。\n• ベースマップ：OpenFreeMap · © OpenMapTiles · データ © OpenStreetMap。\n• 衛星画像：EOxCloudless（EOX IT Services GmbH）、Copernicus Sentinel 2025 のデータを含みます。\n予報・推定の数値はすべて参考値です。出典、基準面、信頼性の詳細は各観測所の「情報」タブをご覧ください。';

  @override
  String more_version(String version) {
    return 'バージョン $version';
  }

  @override
  String get set_title => '設定';

  @override
  String get set_entry => '外観と設定';

  @override
  String get set_entryHint => '色、背景、フォント、文字サイズ、言語、通知';

  @override
  String get set_previewTitle => '魚の活性：高 · 8.2';

  @override
  String get set_previewBody => 'ゴールデンタイム 17:00–18:30 · 上げ潮';

  @override
  String get set_look => '外観';

  @override
  String get set_mode => 'ライトまたはダーク';

  @override
  String get set_accent => 'アクセントカラー';

  @override
  String get set_backdrop => '背景';

  @override
  String get set_font => 'フォント';

  @override
  String get set_textSize => '文字サイズ';

  @override
  String get accent_ocean => 'オーシャン';

  @override
  String get accent_jade => '翡翠';

  @override
  String get accent_leaf => 'リーフ';

  @override
  String get accent_sunset => '夕焼け';

  @override
  String get accent_coral => 'コーラル';

  @override
  String get accent_violet => 'バイオレット';

  @override
  String get accent_slate => 'グラファイト';

  @override
  String get accent_gold => 'ブロンズ';

  @override
  String get backdrop_mist => 'ミスト';

  @override
  String get backdrop_warm => '温かみのある紙';

  @override
  String get backdrop_pure => 'ホワイト / AMOLED';

  @override
  String get backdrop_tinted => 'アクセントカラーに合わせる';

  @override
  String get font_beVietnam => 'Be Vietnam';

  @override
  String get font_nunito => 'Nunito 丸ゴシック';

  @override
  String get font_system => '端末のフォント';

  @override
  String get size_small => '小';

  @override
  String get size_normal => '中';

  @override
  String get size_large => '大';

  @override
  String get size_huge => '特大';

  @override
  String get set_general => '一般';

  @override
  String get set_language => '言語';

  @override
  String get lang_system => '端末の設定';

  @override
  String get lang_vi => 'Tiếng Việt';

  @override
  String get lang_en => 'English';

  @override
  String get set_start => '起動時に開く画面';

  @override
  String get set_notifications => '通知';

  @override
  String get set_notificationsHint => 'ゴールデンタイム、満潮/干潮、何分前に知らせるか';

  @override
  String get set_motion => 'アニメーションを減らす';

  @override
  String get set_motionHint => '泳ぐ魚、流れる水、アニメーションをオフ — 古い端末でも滑らかに、バッテリーも節約';

  @override
  String get set_data => 'データとストレージ';

  @override
  String set_cache(String mb) {
    return 'キャッシュデータ：$mb MB';
  }

  @override
  String get set_cacheHint => '予報、天気、ベースマップ — 必要なときに再ダウンロードします。日誌、保存したポイント、設定は消えません。';

  @override
  String get set_cacheClear => '削除';

  @override
  String get set_cacheCleared => 'キャッシュデータを削除しました';

  @override
  String get set_reset => 'デフォルトの外観に戻す';

  @override
  String get set_resetDone => 'デフォルトの外観に戻しました';

  @override
  String get sp_title => '今日は何を釣る？';

  @override
  String get sp_seeAll => 'すべて見る';

  @override
  String get sp_guideTitle => '魚種ガイド';

  @override
  String get sp_today => '今日';

  @override
  String sp_bestTime(String range) {
    return '狙い目：$range';
  }

  @override
  String get sp_noTime => '今日は狙い目の時間がありません';

  @override
  String get sp_inSeason => '旬';

  @override
  String get sp_offSeason => 'シーズンオフ';

  @override
  String get sp_season => 'メインシーズン';

  @override
  String get sp_where => '釣り場';

  @override
  String get sp_bait => 'エサ';

  @override
  String get sp_chum => '寄せエサ';

  @override
  String get sp_how => '釣り方';

  @override
  String get sp_todayTips => '今日のポイント';

  @override
  String get sp_note => '一般的な釣りの経験則を、この場所の実際の潮と天気に合わせて調整しています。参考情報です。';

  @override
  String get sp_noTips => '今日は普段どおりの条件です。いつもの釣り方でどうぞ。';

  @override
  String get habitat_pond => '池・湖';

  @override
  String get habitat_river => '川';

  @override
  String get habitat_estuary => '河口';

  @override
  String get habitat_sea => '海';

  @override
  String get depth_surface => '表層';

  @override
  String get depth_middle => '中層';

  @override
  String get depth_bottom => '底';

  @override
  String get spTip_outOfSeason => 'まだメインシーズン前：釣れますが数は少なめです。';

  @override
  String get spTip_waitForCurrent => '流れがあるときに食う魚です：今は潮止まり、流れが戻るのを待ちましょう。';

  @override
  String get spTip_murkyStrongBait => '雨後の濁り：匂いの強い（生臭い）エサを使い、岸寄りの澄んだ場所を狙いましょう。';

  @override
  String get spTip_coldSmallBaitDeep => '冷え込み：食いが渋いので、小さいエサで深めを、じっくり。';

  @override
  String get spTip_hotGoDeepShade => '猛暑：早朝か夕方に、または深場や木陰を狙いましょう。';

  @override
  String get spTip_pressureFallingBite => '気圧低下中：天気が崩れる前は魚がよく食うことが多いので、今のうちに。';

  @override
  String get spTip_pressureRisingFinesse => '強風の後に気圧が急上昇：食いが渋いので、細い糸と小さい針で。';

  @override
  String get spTip_windDownwind => '強風：風が当たる側の岸へ。エサや餌生物が寄ってきます。';

  @override
  String get spTip_risingNearBank => '上げ潮：魚が岸際にエサを探しに来るので、近くを狙いましょう。';

  @override
  String get spTip_fallingDeeper => '下げ潮：魚は深いみお筋や水路の出口へ下がるので、遠めを狙いましょう。';

  @override
  String get nb_button => '釣れない？';

  @override
  String get nb_title => '釣れない？こんな方法を試してみて';

  @override
  String get nb_now => '今の状況に合わせて';

  @override
  String get nb_always => '確認したいこと';

  @override
  String nb_waitCurrent(String time) {
    return '今は潮止まり：$timeごろ流れが戻ると食いが良くなります。その間にエサを替え、寄せエサをまきましょう。';
  }

  @override
  String get nb_goDeepShade => '強い日差し：魚は深場へ。深めを探るか、木陰や木の根元に移動しましょう。';

  @override
  String get nb_coldSlow => '寒い日：エサを小さく、ゆっくり巻いて、深場の底を狙いましょう。';

  @override
  String get nb_murkySmell => '濁り：匂いの強い（生臭い）エサに替え、岸寄りの澄んだ場所を探しましょう。';

  @override
  String get nb_finesse => '強風の後で気圧上昇：魚が警戒しています。細い糸、小さい針、エサは少なめに。';

  @override
  String get nb_downwind => '強風：風が当たる側の岸へ。エサが流れ寄ります。';

  @override
  String nb_nextGolden(String time) {
    return '次のゴールデンタイムは $time：一休みして時間どおりに戻りましょう。';
  }

  @override
  String get nb_changeDepth => 'タナを変える：底から始めて、20–30 cm ずつ上げてみましょう。';

  @override
  String get nb_moveSpot => '20–30 分気泡もアタリもなければ：場所を移動し、藻、木の根、反転流を探しましょう。';

  @override
  String get nb_freshBait => '新しいエサに替え、針先を出しましょう。古いエサや寄せエサは匂いが抜けます。';

  @override
  String get nb_stayQuiet => '静かにして、人影が水面に落ちないようにしましょう。';

  @override
  String get nb_finerLine => '魚が警戒しているなら、より細い糸と小さい針に替えましょう。';

  @override
  String get fishing_species => '魚種';

  @override
  String get sp_carp => 'コイ';

  @override
  String get sp_carp_where => '池、湖、流れの緩い川。藻場、沈んだ木の根、泥底のまわり。';

  @override
  String get sp_carp_bait => '炒った米ぬか、コーンフラワー、ふやかしたトウモロコシ、赤虫（ミミズ）。';

  @override
  String get sp_carp_chum => '酸っぱい寄せエサ（米ぬか + コーンフラワーを発酵）またはミルク、パイナップルの香り。15–20 分前に寄せエサを打ちましょう。';

  @override
  String get sp_carp_how => 'ヘラ式またはぶっこみで底べったり、感度の良いウキで。コイはウキを持ち上げてから引き込むことが多いです。';

  @override
  String get sp_tilapia => 'ティラピア';

  @override
  String get sp_tilapia_where => '池、湖、水路、流れの緩い川。暖かく日当たりの良い岸際。';

  @override
  String get sp_tilapia_bait => 'ペレット、練った小麦粉、ミミズ、小エビ。';

  @override
  String get sp_tilapia_chum => '甘い香り（ミルク、バニラ）または少し生臭い寄せエサを、少しずつまんべんなく。';

  @override
  String get sp_tilapia_how => '小さい針で中層から底近く。ウキが沈んだらすぐ軽くアワセ。';

  @override
  String get sp_grassCarp => 'ソウギョ';

  @override
  String get sp_grassCarp_where => '湖、大きな川、釣り堀。草や浮草のある岸際。';

  @override
  String get sp_grassCarp_bait => '若草、キャッサバの葉、ゆでトウモロコシ、練った米ぬか。';

  @override
  String get sp_grassCarp_chum => '発酵トウモロコシ、米ぬかにコーンフラワーを混ぜたもの。';

  @override
  String get sp_grassCarp_how => '丈夫な糸と竿、ドラグは適度に。強く走るので、じっくりやり取りを。';

  @override
  String get sp_snakehead => 'ライギョ';

  @override
  String get sp_snakehead_where => '田んぼ、水路、草やホテイアオイの多い池。岸際、浮遊物のまわり。';

  @override
  String get sp_snakehead_bait => 'カエル、小さな生き魚、ルアー（フロッグ、スプーン）。';

  @override
  String get sp_snakehead_chum => '寄せエサは不要。';

  @override
  String get sp_snakehead_how => '草の際に沿って引くかアクションを付け、静かに移動。強く食いついて草の中へ潜ります。';

  @override
  String get sp_walkingCatfish => 'ヒレナマズ';

  @override
  String get sp_walkingCatfish_where => '池、田んぼ、泥底の水路。岸の穴。';

  @override
  String get sp_walkingCatfish_bait => 'ミミズ、鶏の内臓、エビ、生臭いエサ。';

  @override
  String get sp_walkingCatfish_chum => '生臭い寄せエサ（傷んだ魚、魚粉）。';

  @override
  String get sp_walkingCatfish_how => '夜や雨の後に底釣り。仕掛けは丈夫に、針は中くらい。';

  @override
  String get sp_pangasius => 'パンガシウス（tra、basa）';

  @override
  String get sp_pangasius_where => 'メコン流域の大河、釣り堀。深いみお筋。';

  @override
  String get sp_pangasius_bait => 'ペレット、鶏の内臓、傷んだ魚、練りエサ。';

  @override
  String get sp_pangasius_chum => '生臭いまたは酸っぱい寄せエサ。';

  @override
  String get sp_pangasius_how => '中層から底を丈夫な糸で。引きがとても強いです。';

  @override
  String get sp_mystus => 'ミストゥス（ギギの仲間）';

  @override
  String get sp_mystus_where => '流れのある川や渓流、砂利の瀬。区間ごとに食う時間が違います。';

  @override
  String get sp_mystus_bait => 'ミミズ、エビ、虫。';

  @override
  String get sp_mystus_chum => '少し生臭いものを控えめに。';

  @override
  String get sp_mystus_how => '流れが出始めたら流れの筋に沿って底釣り。いつ入ってくるか地元の釣り人に聞いてみましょう。';

  @override
  String get sp_mullet => 'ボラ';

  @override
  String get sp_mullet_where => '河口、潟湖、港。上げ潮で水路の入口に入り、下げ潮で出ていきます。';

  @override
  String get sp_mullet_bait => 'コケ、小麦粉と米ぬかの練りエサ、パンの白い部分。';

  @override
  String get sp_mullet_chum => '酸味に少し生臭さのある寄せエサを、流れに沿って均等に。';

  @override
  String get sp_mullet_how => '小さく感度の良いウキと小さい針で、流れがある間に流れに沿って釣ります。';

  @override
  String get sp_seabass => 'バラマンディ（アカメの仲間）';

  @override
  String get sp_seabass_where => '河口、潟湖、磯。橋脚、水門、反転流のまわり。';

  @override
  String get sp_seabass_bait => '活きエビ、小魚、ルアー。';

  @override
  String get sp_seabass_chum => '寄せエサは不要。';

  @override
  String get sp_seabass_how => 'ルアーを投げるか活きエビを流れに乗せて流します。流れが強いときと朝夕まずめが一番。';

  @override
  String get sp_snapper => 'フエダイ';

  @override
  String get sp_snapper_where => '海、磯、岩礁。深い岩礁の底。';

  @override
  String get sp_snapper_bait => 'イカ、エビ、新鮮なエサ用の小魚。';

  @override
  String get sp_snapper_chum => '不要、または刻んだエサを底へ。';

  @override
  String get sp_snapper_how => '底釣り、底を取れるだけのオモリ、耐摩耗性のハリス。大潮が一番。';

  @override
  String get sp_grouper => 'ハタ';

  @override
  String get sp_grouper_where => '岩礁、海岸の磯。岩底の穴。';

  @override
  String get sp_grouper_bait => '小さな生き魚、イカ、エビ。';

  @override
  String get sp_grouper_chum => '寄せエサは不要。';

  @override
  String get sp_grouper_how => '食ったらすぐに主導権を取り、穴に潜らせないように。丈夫な糸で。';

  @override
  String get sp_goby => 'ハゼ';

  @override
  String get sp_goby_where => '水路、汽水の川。砂泥底。';

  @override
  String get sp_goby_bait => '小エビ、ミミズ。';

  @override
  String get sp_goby_chum => '寄せエサは不要。';

  @override
  String get sp_goby_how => '軽い底釣り仕掛けに小さい針。アタリが小さいので、ウキがはっきり動くまで待ちましょう。';

  @override
  String get sp_climbingPerch => 'キノボリウオ';

  @override
  String get sp_climbingPerch_where => '田んぼ、用水路、池。草の際。雨季最初の雨の後が一番。';

  @override
  String get sp_climbingPerch_bait => 'ミミズ、バッタ、練ったご飯。';

  @override
  String get sp_climbingPerch_chum => '炒った米ぬかを岸際に少し。';

  @override
  String get sp_climbingPerch_how => '草の岸際で手釣り、小さい針、素早くアワセ。';

  @override
  String get sp_crucian => 'フナ';

  @override
  String get sp_crucian_where => '池、湖。底と中層、冷たい水を好みます。';

  @override
  String get sp_crucian_bait => '赤虫（ミミズ）、練った小麦粉。';

  @override
  String get sp_crucian_chum => '細かく甘い寄せエサを少し。';

  @override
  String get sp_crucian_how => '小さい針、感度の良いウキ、ヘラ式で。涼しい季節によく釣れます。';

  @override
  String get sp_bighead => 'コクレン・ハクレン';

  @override
  String get sp_bighead_where => '大きな湖、釣り堀。晴れて暖かい日は表層と中層。';

  @override
  String get sp_bighead_bait => 'バラケエサ：米ぬかと豆の粉をふんわり練り、水中で漂いながらほどける。';

  @override
  String get sp_bighead_chum => '浮く寄せエサ、水中で雲のように広がります。';

  @override
  String get sp_bighead_how => '表層〜中層にウキで宙づりにし、ほどける練りエサの塊で。ウキがゆっくり沈んだらアワセ。';

  @override
  String get nav_backAgain => 'もう一度戻るスワイプで終了します';

  @override
  String get map_hereNow => '今、あなたの周り';

  @override
  String map_nextGolden(String time) {
    return 'ゴールデンタイム $time';
  }

  @override
  String get fishing_noGoldenShort => 'ゴールデンタイムはまだなし';

  @override
  String get flood_entry => '帰り道が水没するのは何時？';

  @override
  String get flood_title => '帰り道が水没するのは何時？';

  @override
  String get flood_ask => '今の水面は、立っている場所（または帰り道）よりおよそ何 cm 低いですか？';

  @override
  String flood_margin(int cm) {
    return '$cm cm';
  }

  @override
  String get flood_noTide => 'この場所にはまだ潮汐予報がないため計算できません。';

  @override
  String get flood_safe => '今後 24 時間、水はそこまで上がりません';

  @override
  String flood_at(String time) {
    return '水が届くのは $time';
  }

  @override
  String get flood_already => '水はすでにこの高さです。すぐに離れてください。';

  @override
  String flood_leave(String time) {
    return '$time までに離れましょう。';
  }

  @override
  String flood_in(String duration) {
    return 'あと約 $duration。';
  }

  @override
  String flood_recede(String time) {
    return '$timeごろ水が再び引きます。';
  }

  @override
  String flood_peak(String time, String level) {
    return '満潮 $time、観測所基準面から約 $level。';
  }

  @override
  String get flood_windy => '強風：予報より水位が上がるおそれがあるため、アプリは 20 cm 早めに計算しています。早めに離れましょう。';

  @override
  String get flood_note => 'この地点の潮汐予報からの推定で、参考値です。波、風、洪水で水位が早く上がることがあります。常に逃げ道を確保してください。';

  @override
  String flood_minutes(int m) {
    return '$m 分';
  }

  @override
  String flood_hoursMinutes(int h, int m) {
    return '$h 時間 $m 分';
  }

  @override
  String flood_alarmButton(String time) {
    return '$time にアラーム';
  }

  @override
  String flood_alarmSet(String time) {
    return '$time にアラーム設定済み · タップで解除';
  }

  @override
  String get flood_alarmApk => 'アラームは Android アプリで使えます（「その他」タブから APK をダウンロード）。';

  @override
  String flood_alarmTitle(String place) {
    return 'まもなく水没：$place';
  }

  @override
  String flood_alarmBody(String time) {
    return '$timeごろ水が届きます。竿を片付けて、すぐにその場を離れてください。';
  }

  @override
  String get flood_channel => '帰り道の水没アラート';

  @override
  String get shift_title => 'まもなく天気が変わります';

  @override
  String get shift_dayAfter => 'あさって';

  @override
  String shift_coldFront(String when) {
    return '$when冷え込み（季節風）：その直前は魚がよく食うことが多いので、行く価値あり。その後 1–2 日は食いが渋くなります。';
  }

  @override
  String shift_heavyRain(String when) {
    return '$when大雨：雨の後は濁るので、底を生臭いエサで、岸寄りの澄んだ場所を狙いましょう。';
  }

  @override
  String shift_pressureDrop(String when) {
    return '$whenから気圧が急低下：天気が悪化します。雷雨や低気圧の警報に注意してください。';
  }

  @override
  String shift_heatWave(String when) {
    return '${when}36°C 超の猛暑：早朝と夕方に、深場や木陰を狙いましょう。';
  }

  @override
  String get shift_note => 'Open-Meteo の天気予報に基づく参考情報です。';

  @override
  String get alert_evening => '前日夜のお知らせ（20:00）';

  @override
  String get alert_eveningHint => '「明日、釣りに行く？」：あなたのポイントの明日のベストなゴールデンタイム';

  @override
  String digest_title(String place) {
    return '明日、釣りに行く？ · $place';
  }

  @override
  String digest_body(String range, String band, String score) {
    return 'ゴールデンタイム $range：魚の活性 $band（$score）。今夜のうちに道具を準備しよう！';
  }

  @override
  String get digest_none => '明日はここにゴールデンタイムがありません。アプリの「どこで釣る？」でもっと良い場所を探しましょう。';

  @override
  String get brag_open => '釣果写真を自慢する';

  @override
  String get brag_title => '釣果自慢';

  @override
  String get brag_share => '写真を共有';

  @override
  String get brag_showPlace => '釣り場の名前を表示';

  @override
  String get brag_showPlaceHint => '穴場を秘密にするため、初期設定はオフです';

  @override
  String brag_score(String score) {
    return '魚の活性 $score';
  }

  @override
  String brag_text(String species, String link) {
    return '$speciesを釣りました！釣れる時間と潮は Con Nước で：$link';
  }

  @override
  String get bite_question => 'ここで釣りをしていますか？アタリはありますか？';

  @override
  String get bite_yes => 'アタリあり';

  @override
  String get bite_no => 'アタリなし';

  @override
  String get bite_thanks => 'ありがとうございます！あなたの報告で近くの釣り人が魚の食いを知ることができます。';

  @override
  String get bite_tooSoon => 'さっき報告しました。30分後にまた報告してください。';

  @override
  String get bite_failed => '送信できませんでした。後でもう一度お試しください。';

  @override
  String bite_summary(int bites, int misses) {
    return 'この付近の過去3時間：アタリあり $bites 人、アタリなし $misses 人。';
  }

  @override
  String get bite_first => 'この付近ではまだ報告がありません。最初の一人になりましょう！';

  @override
  String bite_pattern(String state, int rate) {
    return 'この場所は$stateのときによく釣れます（アタリあり $rate%、過去60日）。';
  }

  @override
  String get bite_rising => '上げ潮';

  @override
  String get bite_falling => '下げ潮';

  @override
  String get bite_slack => '潮止まり';

  @override
  String get bite_note => '釣り人の報告をまとめたものです。約2 kmの範囲だけを保存し、個人は特定しません。';

  @override
  String get gear_title => '道具と結び';

  @override
  String get gear_entry => '道具と結び';

  @override
  String get gear_entryHint => '持ち物リスト、よく使う6つの結び方';

  @override
  String get gear_tabPack => '持ち物';

  @override
  String get gear_tabKnots => '結び';

  @override
  String gear_progress(int done, int total) {
    return '$done/$total 点';
  }

  @override
  String get gear_clear => '次の釣行のためにチェックを全解除';

  @override
  String get trip_night => '夜釣り';

  @override
  String get trip_sea => '海・磯';

  @override
  String get trip_pond => '釣り堀';

  @override
  String get trip_river => '川・水路';

  @override
  String get gear_rodReel => '竿・リール（回転とドラグを確認）';

  @override
  String get gear_spareLine => '予備のライン';

  @override
  String get gear_hooksWeights => '予備の針・オモリ・ウキ・スナップ';

  @override
  String get gear_baitChum => 'エサと寄せエサ';

  @override
  String get gear_netTowel => 'タモ網と手拭きタオル';

  @override
  String get gear_waterFood => '飲み水・食べ物';

  @override
  String get gear_sunHat => '帽子・日焼け止め・サングラス';

  @override
  String get gear_raincoat => 'レインウェア';

  @override
  String get gear_phonePower => '充電済みのスマホ・モバイルバッテリー';

  @override
  String get gear_trashBag => 'ゴミを持ち帰る袋';

  @override
  String get gear_headlamp => 'ヘッドライト・予備電池';

  @override
  String get gear_glowSticks => 'ケミホタル・電気ウキ';

  @override
  String get gear_mosquito => '虫よけ';

  @override
  String get gear_jacket => '上着（風が冷たい夜に）';

  @override
  String get gear_nonSlipShoes => '滑りにくい靴';

  @override
  String get gear_lifeJacket => 'ライフジャケット';

  @override
  String get gear_tideCheck => 'アプリで潮汐時刻と「帰り道の水没」を確認';

  @override
  String get gear_leader => '耐摩耗リーダー';

  @override
  String get gear_pliers => '針外し用プライヤー';

  @override
  String get gear_pondCall => '釣り堀に電話：料金・営業時間・放流日';

  @override
  String get gear_chairUmbrella => '椅子・日よけパラソル';

  @override
  String get gear_keepNet => 'スカリ・クーラーボックス';

  @override
  String get gear_boots => '長靴またはウェーディングシューズ';

  @override
  String get gear_rodRest => '竿掛け・竿受け';

  @override
  String knot_strength(int pct) {
    return 'ライン強度の約$pct%を保持';
  }

  @override
  String get knot_note => '共通のコツ：締める前に唾で湿らせ、熱を持たないようゆっくり締め、端糸は2–3 mm残して切ります。図は模式図です。';

  @override
  String get knot_improvedClinch => '改良クリンチノット';

  @override
  String get knot_improvedClinch_use => 'ナイロンラインに針・スナップを結ぶ。一番簡単で、誰もが覚えておきたい結び。';

  @override
  String get knot_improvedClinch_steps =>
      'ラインを針のアイに通し、約15 cm余らせます。\n端糸を本線に5–7回巻き付けます。\n端糸をアイ近くの小さな輪に通し、できた大きな輪にも通します。\n湿らせて本線を引いて締め、端糸を切ります。';

  @override
  String get knot_palomar => 'パロマーノット';

  @override
  String get knot_palomar_use => 'PEラインに針・ルアーを結ぶ。とても強く、素早く結べる。';

  @override
  String get knot_palomar_steps =>
      'ラインを約15 cm二つ折りにし、折り目を針のアイに通します。\n二重のラインでゆるくひと結びします。\n針全体を折り返しの輪にくぐらせます。\n湿らせて両端を引いて締め、端糸を切ります。';

  @override
  String get knot_uni => 'ユニノット';

  @override
  String get knot_uni_use => '針・スナップ・ルアーを結ぶ。ナイロンにもPEにも使える。';

  @override
  String get knot_uni_steps =>
      'ラインをアイに通し、端糸を本線に沿わせて折り返し輪を作ります。\n端糸で輪の中の2本を5–6回巻きます。\n端糸を引いて巻きをきれいに揃えます。\n湿らせて本線を引き、結び目をアイまで寄せて端糸を切ります。';

  @override
  String get knot_doubleUni => 'ダブルユニノット';

  @override
  String get knot_doubleUni_use => '2本のラインをつなぐ（PEとナイロンリーダー、または切れたライン）。';

  @override
  String get knot_doubleUni_steps =>
      '2本のラインの端を約20 cm重ねます。\n1本目の端でもう1本にユニノットを結びます（3–4回巻き、PEは6–8回）。\n2本目の端も同じように結びます。\n湿らせて両方の本線を引き、2つの結び目を寄せて端糸を切ります。';

  @override
  String get knot_perfectionLoop => 'パーフェクションループ';

  @override
  String get knot_perfectionLoop_use => 'ライン先端に輪を作り、仕掛けやリーダーを素早く接続。';

  @override
  String get knot_perfectionLoop_steps =>
      'ライン先端に小さな輪を作り、端糸を後ろ側に置きます。\n端糸を回して前側に2つ目の輪を作ります。\n端糸を2つの輪の間に通します。\n2つ目の輪を1つ目の輪から引き出し、締めて端糸を切ります。';

  @override
  String get knot_snell => 'スネルノット（外掛け結び）';

  @override
  String get knot_snell_use => 'へら・単針の針結び。ラインが軸に沿ってまっすぐ出るので掛かりが良くなる。';

  @override
  String get knot_snell_steps =>
      'ラインをアイに通し、針の軸に沿わせて輪を作ります。\n輪で軸とラインをアイから下へ7–8回巻きます。\n巻きを押さえて本線を引き締めます。\n湿らせてもう一度締め、端糸を切ります。';

  @override
  String get font_quicksand => 'Quicksand';

  @override
  String get set_navStyle => 'タブバーのスタイル';

  @override
  String get nav_styleDot => 'ドット';

  @override
  String get lang_zh => '中文';

  @override
  String get lang_ko => '한국어';

  @override
  String get lang_ja => '日本語';

  @override
  String get pond_zalo => 'Zaloで連絡';

  @override
  String get pond_filterWeekend => '週末の放流';

  @override
  String get release_alarmPond => 'フォロー中の釣り堀';

  @override
  String release_alarmTitle(String pond) {
    return 'まもなく放流：$pond';
  }

  @override
  String release_alarmBody(String when) {
    return '$when に放流。早めに行って良い場所を！';
  }

  @override
  String release_alarmBodyKg(String when, int kg) {
    return '$when に約 $kg kg 放流。早めに行って良い場所を！';
  }

  @override
  String get nav_styleArc => 'アーク';

  @override
  String get nav_styleNotch => 'ノッチ';

  @override
  String get nav_styleGlass => 'ガラス';

  @override
  String get map_layerPonds => '釣り堀';

  @override
  String get map_layerSpots => 'みんなの釣り場';

  @override
  String get map_layerTrips => '釣り会';

  @override
  String get map_layerCheckins => '釣り中の人';

  @override
  String get social_tooFast => '送信が少し速すぎます — 少し待ってからもう一度どうぞ';

  @override
  String get social_daily => '今日の上限に達しました。明日もう一度お試しください。';

  @override
  String get social_newDevice => '新しい端末は最初は制限があります — 約10分後にもう一度どうぞ';

  @override
  String get social_banned => 'この端末の投稿は多くの通報を受けたため、投稿を一時停止しています';

  @override
  String social_bannedUntil(String time) {
    return 'この端末の投稿は多くの通報を受けたため、$time まで投稿を停止しています';
  }

  @override
  String get blocked_link => '公開内容にリンクは載せないでください';

  @override
  String get blocked_phone => '公開内容に電話番号を書かないでください（広告・詐欺防止）';

  @override
  String get blocked_contactAd => '公開内容で Zalo、Telegram、DM への誘導はしないでください';

  @override
  String get blocked_spam => '賭博や貸金の広告のような内容は投稿できません';

  @override
  String get blocked_offensive => '不適切な言葉が含まれています。修正してください';

  @override
  String get blocked_chars => '同じ文字を繰り返さないでください（例：\"goooood\"）';

  @override
  String get blocked_shouting => 'Caps Lock をオフにしてください';

  @override
  String get blocked_impersonation => '運営チームと紛らわしい名前です。別の名前にしてください';

  @override
  String get blocked_repeat => 'まったく同じ内容をさっき送りました';

  @override
  String get blocked_other => 'この内容は投稿できません。修正してください';
}
