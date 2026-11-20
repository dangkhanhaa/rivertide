// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Con Nước';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading…';

  @override
  String get common_empty => 'No data yet';

  @override
  String get common_reference => 'for reference';

  @override
  String get common_estimate => 'estimated';

  @override
  String common_source(String source) {
    return 'Source: $source';
  }

  @override
  String common_staleBanner(String time) {
    return 'Offline · updated at $time';
  }

  @override
  String common_updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String get common_today => 'Today';

  @override
  String get common_tomorrow => 'Tomorrow';

  @override
  String get error_network => 'Can\'t connect. Check your network and try again.';

  @override
  String get error_timeout => 'The data source is slow to respond. Try again later.';

  @override
  String get error_server => 'The data source is temporarily unavailable.';

  @override
  String get error_parse => 'The source data is invalid.';

  @override
  String get error_notFound => 'Not found.';

  @override
  String get error_offlineNoCache => 'You\'re offline and no data is saved yet.';

  @override
  String get error_unknown => 'Something went wrong. Try again later.';

  @override
  String get dataKind_observed => 'Measured';

  @override
  String get dataKind_forecast => 'Forecast · for reference';

  @override
  String get dataKind_estimate => 'Estimated';

  @override
  String get tide_rising => 'Rising';

  @override
  String get tide_risingFast => 'Rising fast';

  @override
  String get tide_slack => 'Slack water';

  @override
  String get tide_falling => 'Falling';

  @override
  String get tide_fallingFast => 'Falling fast';

  @override
  String get tide_high => 'High tide';

  @override
  String get tide_low => 'Low tide';

  @override
  String get tide_turning => 'Tide turning';

  @override
  String get tide_spring => 'Spring tide';

  @override
  String get tide_neap => 'Neap tide';

  @override
  String get tide_normal => 'Mid tide';

  @override
  String tide_countdownHigh(String duration) {
    return 'High tide in $duration';
  }

  @override
  String tide_countdownLow(String duration) {
    return 'Low tide in $duration';
  }

  @override
  String tide_extremeAt(String time, String level) {
    return '$time · expected $level';
  }

  @override
  String tide_nextOther(String kind, String time, String level) {
    return 'Next $kind: $time · $level';
  }

  @override
  String get tide_noPrediction => 'No tide forecast for this station yet';

  @override
  String tide_correctedBy(String delta) {
    return 'Adjusted to measured data (off by $delta)';
  }

  @override
  String duration_hm(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String duration_m(int minutes) {
    return '$minutes min';
  }

  @override
  String confidence_label(String level) {
    return 'Forecast confidence: $level';
  }

  @override
  String get confidence_high => 'High';

  @override
  String get confidence_medium => 'Medium';

  @override
  String get confidence_low => 'Low';

  @override
  String skill_backtest(String cm, String min) {
    return 'Backtest: error ±$cm cm, high/low times ±$min min';
  }

  @override
  String skill_live(int days, String cm, String min) {
    return 'Error over the last $days days: ±$cm cm, ±$min min';
  }

  @override
  String get skill_unknown => 'Error not yet measured at this spot';

  @override
  String get nav_map => 'Map';

  @override
  String get map_searchHint => 'Search commune, ward, bridge, wharf, coordinates…';

  @override
  String get map_searchNone => 'No matching stations found';

  @override
  String get map_openDetail => 'View details';

  @override
  String map_nextExtreme(String kind, String time, String level, String duration) {
    return '$kind $time ≈ $level · in $duration';
  }

  @override
  String tide_moreRise(int cm) {
    return 'Water will rise about $cm cm more';
  }

  @override
  String tide_moreFall(int cm) {
    return 'Water will fall about $cm cm more';
  }

  @override
  String get map_locate => 'My location';

  @override
  String get map_locRationaleTitle => 'Use your location?';

  @override
  String get map_locRationaleBody =>
      'The app uses your location to center the map on where you are. It stays on your device (remembered roughly to ~1 km so it opens faster next time) and is never sent anywhere.';

  @override
  String get map_locAllow => 'Allow';

  @override
  String get map_later => 'Later';

  @override
  String get map_locServiceOff => 'Location is off. Turn on location on your device and try again.';

  @override
  String get map_locDenied => 'Location permission not granted.';

  @override
  String get map_locDeniedForeverTitle => 'Location permission is blocked';

  @override
  String get map_locDeniedForeverBody =>
      'Go to Settings > Apps > Con Nước > Permissions > Location to turn it back on.';

  @override
  String get map_openSettings => 'Open Settings';

  @override
  String get map_locFailed => 'Couldn\'t get your location. Try again later.';

  @override
  String get map_outsideVn => 'Location is outside the supported area';

  @override
  String get map_layers => 'Map layers';

  @override
  String get map_layerStandard => 'Standard map';

  @override
  String get map_layerStandardHint => 'Roads, places, rivers and lakes (OpenFreeMap)';

  @override
  String get map_layerSatellite => 'Satellite';

  @override
  String get map_layerSatelliteHint =>
      'Sentinel-2 2025, 10 m resolution — rivers, sandbanks and fields are clear; individual houses are not';

  @override
  String get map_satelliteCredit =>
      'Satellite imagery: EOxCloudless (EOX IT Services) · contains Copernicus Sentinel 2025 data';

  @override
  String get map_filter => 'Filter';

  @override
  String get map_filterOnlyTide => 'Tidal stations only';

  @override
  String get map_filterOnlyAlarm => 'Stations on alert only';

  @override
  String get map_filterHideStale => 'Hide stations with no data';

  @override
  String get map_filterNone => 'No stations match the filter';

  @override
  String get map_legend => 'Legend';

  @override
  String get map_legendNormal => 'Normal';

  @override
  String get map_legendAlarm1 => 'Alert level I';

  @override
  String get map_legendAlarm2 => 'Alert level II';

  @override
  String get map_legendAlarm3 => 'Alert level III';

  @override
  String get map_legendStale => 'No data for over 6 hours (gray pin, faded fish)';

  @override
  String get map_legendSpot => 'Community fishing spot';

  @override
  String get map_legendCluster =>
      'Numbered circle: a group of nearby stations, tap to zoom in. The circle color is the highest fish activity in the group; if any station is on alert, it shows the alert color.';

  @override
  String get map_legendNote =>
      'Sea stations have no alert thresholds yet; alert colors will be used for river stations in a later phase.';

  @override
  String get map_hoangSa => 'Hoang Sa (Paracel) Islands (Vietnam)';

  @override
  String get map_truongSa => 'Truong Sa (Spratly) Islands (Vietnam)';

  @override
  String get map_close => 'Close';

  @override
  String get map_stationsError => 'Couldn\'t load the station list';

  @override
  String get map_baseMapCredit => 'Base map: OpenFreeMap · © OpenMapTiles · data © OpenStreetMap';

  @override
  String get nav_stations => 'Stations';

  @override
  String get nav_watch => 'Watchlist';

  @override
  String get nav_fishing => 'Fishing';

  @override
  String get nav_more => 'More';

  @override
  String get stations_title => 'Water level & tide stations';

  @override
  String get stations_kindGauge => 'Gauged';

  @override
  String get stations_kindModel => 'Model';

  @override
  String get stations_coordApprox => 'Approximate coordinates';

  @override
  String get station_tabOverview => 'Overview';

  @override
  String get station_tabHourly => 'Hourly';

  @override
  String get station_tabCalendar => 'Tide calendar';

  @override
  String get station_tabInfo => 'Info';

  @override
  String level_lastKnown(String time) {
    return 'Latest reading at $time · no reading for this hour yet';
  }

  @override
  String get calendar_prev => 'Previous month';

  @override
  String get calendar_next => 'Next month';

  @override
  String calendar_month(int month, int year) {
    return '$month/$year';
  }

  @override
  String get calendar_noTideDay => 'No tide forecast for this day yet';

  @override
  String get calendar_noTideMonth =>
      'No tide forecast for this month yet; lunar dates and moon phases are still shown';

  @override
  String get calendar_rangeLegend => 'Daily range';

  @override
  String get calendar_lunarLegend => 'Red text: 1st and 15th of the lunar month';

  @override
  String moon_times(String rise, String set) {
    return 'Moonrise $rise · moonset $set';
  }

  @override
  String get moon_alwaysUp => 'The moon is up all day';

  @override
  String get moon_alwaysDown => 'The moon doesn\'t rise today';

  @override
  String get solunar_title => 'Solunar fishing times';

  @override
  String get solunar_titleGood => 'Solunar fishing times · good day (near full/new moon)';

  @override
  String solunar_major(String range) {
    return 'Major $range';
  }

  @override
  String solunar_minor(String range) {
    return 'Minor $range';
  }

  @override
  String get solunar_now => 'now';

  @override
  String get summary_title => 'Right now, here';

  @override
  String summary_water(String state, String extreme, String time, String wait) {
    return '$state, $extreme at $time (in $wait)';
  }

  @override
  String summary_fishing(String score, String label) {
    return 'fishing $score/10 $label';
  }

  @override
  String summary_wind(int kmh) {
    return 'wind $kmh km/h';
  }

  @override
  String get map_goFishing => 'Go fishing';

  @override
  String get hazard_title => 'Heads up';

  @override
  String get hazard_titleSevere => 'Danger — stay off the river';

  @override
  String hazard_at(String time) {
    return 'at $time';
  }

  @override
  String hazard_between(String from, String to) {
    return '$from–$to';
  }

  @override
  String get hazard_thunderstorm =>
      'Thunder and lightning: get ashore, avoid open ground and fishing rods';

  @override
  String get hazard_gust => 'Gusts over 50 km/h: don\'t take the boat out';

  @override
  String get hazard_heavyRain => 'Heavy rain over 20 mm/h';

  @override
  String get hazard_possibleStorm => 'Unstable weather, thunderstorms possible';

  @override
  String get hazard_risingFast =>
      'Water rising unusually fast (much faster than recent days): stay off low banks and sandbars';

  @override
  String get hazard_flood =>
      'River flow rising sharply tomorrow (heavy rain upstream): higher, muddy, fast water';

  @override
  String get watch_edit => 'Name, note, group';

  @override
  String get watch_editTitle => 'Your spot';

  @override
  String get watch_label => 'Custom name';

  @override
  String get watch_labelHint => 'e.g. Deep hole by the banyan';

  @override
  String get watch_note => 'Note';

  @override
  String get watch_noteHint => 'e.g. Worm bait, eddy spot';

  @override
  String get watch_group => 'Group';

  @override
  String get watch_groupHint => 'e.g. Red River, Lakes';

  @override
  String get watch_noGroup => 'Ungrouped';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get trip_title => 'Plan a fishing trip';

  @override
  String get trip_open => 'Plan';

  @override
  String get trip_noPlaces =>
      'Save a few fishing spots (tap ⭐ on the map) so the app can find your best fishing times.';

  @override
  String trip_intro(int count) {
    return 'Best fishing times in the next 7 days across $count saved spots, based on each spot\'s tide, moon and weather.';
  }

  @override
  String get trip_none => 'No time in the next 7 days scores 7/10 or higher at your saved spots.';

  @override
  String trip_score(String score) {
    return 'Top fishing score $score/10';
  }

  @override
  String trip_because(String reasons) {
    return 'Good because: $reasons';
  }

  @override
  String get trip_note => 'Note';

  @override
  String get where_title => 'Where to fish today?';

  @override
  String get where_short => 'Where?';

  @override
  String get more_shortcuts => 'Shortcuts';

  @override
  String get trip_listDetail => 'See and join fishing trips nearby';

  @override
  String get trip_createDetail => 'Invite friends fishing, with golden-hour suggestions';

  @override
  String get checkin_detail => 'Let others know you\'re fishing here (anonymous, 4 hours)';

  @override
  String get checkin_peopleDetail => 'Where people are fishing now, and who\'s getting bites';

  @override
  String get spot_listDetail => 'Spots pinned by fellow anglers, with photos and comments';

  @override
  String get where_entryHint => 'Best fishing spots near you in the next 24 hours';

  @override
  String get where_radius => 'Within';

  @override
  String where_km(int km) {
    return '$km km';
  }

  @override
  String where_around(String place) {
    return 'Around $place';
  }

  @override
  String get where_aroundHere => 'Around where you are';

  @override
  String get where_aroundLast => 'Around your last location (tap ◎ to update)';

  @override
  String get where_needLocation => 'Tell the app where you are to find the nearest fishing spots.';

  @override
  String get where_useLocation => 'Use my location';

  @override
  String get where_refresh => 'Update location';

  @override
  String get where_kindHere => 'Your location';

  @override
  String get where_kindStation => 'Station';

  @override
  String get where_kindSaved => 'Saved spot';

  @override
  String get where_kindCommunity => 'Community spot';

  @override
  String where_distance(String km) {
    return '$km km away';
  }

  @override
  String where_golden(String when) {
    return 'Golden hours $when';
  }

  @override
  String where_bestHour(String when) {
    return 'No golden hours · best time $when';
  }

  @override
  String get where_unsafe => 'Weather warning during this time';

  @override
  String get where_loading => 'Scoring fishing spots…';

  @override
  String get where_failed => 'Couldn\'t load data for this spot';

  @override
  String get where_onMap => 'View map';

  @override
  String get where_fishHere => 'Fish here';

  @override
  String where_rank(int rank) {
    return 'Rank $rank';
  }

  @override
  String get where_note =>
      'Ranked by estimated fishing score (tide, moon times, day/night, Open-Meteo weather) over the next 24 hours — for reference only. Community spots are pinned by users. Up to 8 nearest spots.';

  @override
  String get where_onlyHere =>
      'No stations, saved spots or community spots within this radius — only your location can be scored. Try a larger radius.';

  @override
  String get habit_title => 'Your fishing habits';

  @override
  String habit_needMore(int count) {
    return 'Log $count more catches so the app can find when you usually get lucky.';
  }

  @override
  String habit_progress(int have, int need) {
    return '$have/$need catches';
  }

  @override
  String habit_none(int count) {
    return 'No standout conditions yet across $count catches. Keep logging.';
  }

  @override
  String habit_hits(int hits, int known) {
    return '$hits/$known catches';
  }

  @override
  String get habit_note =>
      'Counted from the journal on your device, not a sure rule. The hours you fish most will naturally have more catches.';

  @override
  String get habit_match => 'Like your past catches';

  @override
  String get habit_dawn => 'At dawn';

  @override
  String get habit_morning => 'Morning';

  @override
  String get habit_midday => 'Midday';

  @override
  String get habit_afternoon => 'Afternoon';

  @override
  String get habit_dusk => 'At dusk';

  @override
  String get habit_night => 'Night';

  @override
  String get habit_rising => 'On a rising tide';

  @override
  String get habit_falling => 'On a falling tide';

  @override
  String get habit_slack => 'At slack water (tide turning)';

  @override
  String get habit_newMoon => 'Around the new moon (end/start of lunar month)';

  @override
  String get habit_fullMoon => 'Around the full moon (15th)';

  @override
  String get habit_quarter => 'Half-moon days';

  @override
  String get habit_major => 'During major solunar times';

  @override
  String get habit_minor => 'During minor solunar times';

  @override
  String get habit_noSolunar => 'Outside solunar times';

  @override
  String get habit_calm => 'In calm wind (under 10 km/h)';

  @override
  String get habit_light => 'In light wind (10–20 km/h)';

  @override
  String get habit_strong => 'In strong wind (over 20 km/h)';

  @override
  String get journal_title => 'Fishing journal';

  @override
  String get journal_open => 'Journal';

  @override
  String get journal_add => 'Log catch';

  @override
  String get journal_empty =>
      'No catches yet. Tap \"Log catch\" after each catch: the app saves the water level, tide, weather and moon at that moment.';

  @override
  String journal_place(String name) {
    return 'At: $name';
  }

  @override
  String get journal_placeHint =>
      'This is the spot selected in the Fishing tab. Change it there if needed.';

  @override
  String get journal_changeTime => 'Change time';

  @override
  String get journal_species => 'Species';

  @override
  String get journal_weight => 'Weight (kg)';

  @override
  String get journal_length => 'Length (cm)';

  @override
  String get journal_bait => 'Bait';

  @override
  String get journal_note => 'Note';

  @override
  String get journal_camera => 'Take photo';

  @override
  String get journal_gallery => 'Choose photo';

  @override
  String get journal_removePhoto => 'Remove photo';

  @override
  String get journal_photoError => 'Couldn\'t read this photo';

  @override
  String get journal_needSpecies => 'Enter the species';

  @override
  String get journal_privacy =>
      'Your journal and photos are stored only on this device. GPS location is removed from photos.';

  @override
  String get journal_statsTitle => 'How you fish';

  @override
  String journal_statsCount(int count, String kg) {
    return '$count catches · $kg kg total';
  }

  @override
  String journal_statsTop(String species, int count) {
    return 'Most caught: $species ($count times)';
  }

  @override
  String journal_statsRising(int pct) {
    return '$pct% of catches on a rising tide';
  }

  @override
  String journal_statsFalling(int pct) {
    return '$pct% of catches on a falling tide';
  }

  @override
  String journal_water(String state) {
    return 'water $state';
  }

  @override
  String get journal_conditions => 'Conditions at catch time';

  @override
  String journal_weightValue(String kg) {
    return 'Weight $kg kg';
  }

  @override
  String journal_lengthValue(int cm) {
    return 'Length $cm cm';
  }

  @override
  String journal_baitValue(String bait) {
    return 'Bait: $bait';
  }

  @override
  String journal_levelValue(String level) {
    return 'Water level $level';
  }

  @override
  String journal_scoreValue(String score) {
    return 'fishing score $score/10';
  }

  @override
  String get journal_delete => 'Delete';

  @override
  String get journal_deleteTitle => 'Delete this catch from the journal?';

  @override
  String get place_city => 'City, town';

  @override
  String get place_ward => 'Neighborhood, village';

  @override
  String get place_bridge => 'Bridge';

  @override
  String get place_ferry => 'Ferry landing';

  @override
  String get place_wharf => 'Wharf';

  @override
  String place_near(String kind, String town) {
    return '$kind · near $town';
  }

  @override
  String get share_action => 'Share';

  @override
  String share_text(String place) {
    return 'Con Nước · $place';
  }

  @override
  String share_level(String level) {
    return 'Water level $level';
  }

  @override
  String share_score(String score) {
    return 'Fishing score $score/10';
  }

  @override
  String get share_copied => 'Text and link copied — paste into Zalo/Facebook to send';

  @override
  String get share_footer => 'Calculated data, for reference only · Con Nước';

  @override
  String get more_outdoor => 'Outdoor mode';

  @override
  String get more_outdoorHint => 'High contrast, larger text: easy to read in bright sun';

  @override
  String get map_legendFlowRising => 'River section with rising water';

  @override
  String get map_legendFlowFalling => 'River section with falling water';

  @override
  String get map_legendFlowSlack => 'River section with slack water';

  @override
  String get map_legendFlowNote =>
      'Each river section is colored separately (the tide reaches each section at a different time), updated every 10 minutes. Moving streaks show the river\'s flow toward the sea.';

  @override
  String get map_layerWeather => 'Rain and wind nearby';

  @override
  String get map_layerWeatherHint =>
      'Blue dots: rain in the next hour (bigger = heavier). Arrows: where the wind blows to. Zoom in to the area you want.';

  @override
  String hazard_surge(int cm) {
    return 'Sea level is $cm cm above the normal tide (strong wind or a storm pushing water in): low beaches and river mouths may flood';
  }

  @override
  String get more_install => 'Add Con Nước to your home screen';

  @override
  String get more_installHow =>
      'Android (Chrome): tap ⋮ then Install app. iPhone (Safari): tap Share then Add to Home Screen. Opens fast like a real app, no store needed.';

  @override
  String get alert_channel => 'Tide alarms';

  @override
  String get alert_channelHint =>
      'Reminders before high tide, low tide and good fishing hours at saved spots';

  @override
  String alert_highTitle(String place, String time) {
    return '$place: high tide $time';
  }

  @override
  String alert_lowTitle(String place, String time) {
    return '$place: low tide $time';
  }

  @override
  String alert_levelBody(String level, int minutes) {
    return 'Water level about $level, in $minutes min';
  }

  @override
  String alert_fishTitle(String place, String from, String to) {
    return '$place: good fishing $from–$to';
  }

  @override
  String alert_fishBody(String score, int minutes) {
    return 'Fishing score $score/10, starts in $minutes min';
  }

  @override
  String get alert_toggleOn => 'Turn on tide alarm';

  @override
  String get alert_toggleOff => 'Turn off tide alarm';

  @override
  String get alert_onSnack =>
      'Alarm on for this spot. Choose alarm types and lead time with the ⚙ button at the top.';

  @override
  String alert_fishBodyLike(String score, int minutes) {
    return '✨ Like your past good catches · fishing score $score/10, starts in $minutes min';
  }

  @override
  String get alert_settings => 'Alarm settings';

  @override
  String get alert_golden => 'Alert before golden hours';

  @override
  String get alert_goldenHint =>
      'Only when that time has no thunderstorm, gust or heavy rain warning';

  @override
  String get alert_tides => 'Alert before high / low tide';

  @override
  String get alert_lead => 'Alert ahead';

  @override
  String alert_leadMin(int minutes) {
    return '$minutes min';
  }

  @override
  String get alert_howTo =>
      'Turn on the bell for each spot in your Watchlist. The app reschedules alarms each time it opens (next 7 days).';

  @override
  String get alert_getApk => 'Get the Android app';

  @override
  String get alert_denied =>
      'Notifications not allowed. Turn them on in Settings > Apps > Con Nước > Notifications.';

  @override
  String get alert_webOnly =>
      'Alarms are only in the Android app (the browser can\'t ring when closed)';

  @override
  String get more_apk => 'Download Android app (APK)';

  @override
  String get more_apkHint =>
      'Adds tide alarms and a home screen widget. Open the file after downloading and allow installs from this source.';

  @override
  String get directions_action => 'Directions';

  @override
  String get directions_failed => 'Couldn\'t open Google Maps on this device';

  @override
  String get search_recent => 'Recent searches';

  @override
  String get place_province => 'Province, city';

  @override
  String get place_commune => 'Ward, commune';

  @override
  String get search_coordsHint => 'Open water level and fishing hours at these coordinates';

  @override
  String place_in(String kind, String area) {
    return '$kind · $area';
  }

  @override
  String search_coords(String coords) {
    return 'Coordinates $coords';
  }

  @override
  String get spot_edit => 'Edit';

  @override
  String get spot_editTitle => 'Edit fishing spot';

  @override
  String get spot_save => 'Save changes';

  @override
  String get spot_editSaved => 'Changes saved';

  @override
  String spot_edited(String date) {
    return 'edited $date';
  }

  @override
  String get spot_tooMany => 'This device has posted 10 spots today. Post more tomorrow.';

  @override
  String spot_comments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get cmt_title => 'Comments';

  @override
  String cmt_count(int count) {
    return 'Comments ($count)';
  }

  @override
  String get cmt_hint => 'Share bait, feeding times, how to get there…';

  @override
  String get cmt_send => 'Post comment';

  @override
  String get cmt_empty => 'No comments yet. Be the first!';

  @override
  String get cmt_anon => 'Anonymous angler';

  @override
  String cmt_asName(String name) {
    return 'Commenting as $name · change';
  }

  @override
  String get cmt_asAnon => 'Anonymous · set display name';

  @override
  String get cmt_edited => 'edited';

  @override
  String get cmt_mine => 'yours';

  @override
  String get cmt_more => 'More';

  @override
  String get cmt_edit => 'Edit comment';

  @override
  String get cmt_delete => 'Delete';

  @override
  String get cmt_report => 'Report';

  @override
  String get cmt_deleteTitle => 'Delete your comment?';

  @override
  String get cmt_reportTitle => 'Report this comment?';

  @override
  String get cmt_reportHint =>
      'Abuse, scams, ads… Comments reported by 3 people are hidden automatically.';

  @override
  String get cmt_error => 'Couldn\'t send. Check your connection and try again';

  @override
  String get cmt_tooFast => 'You\'re posting a bit fast — wait a moment and try again';

  @override
  String get cmt_loadError => 'Couldn\'t load comments';

  @override
  String get name_title => 'Display name';

  @override
  String get name_hint => 'e.g. Khanh the Angler';

  @override
  String get name_note => 'Shown on comments, fishing trips and messages. Leave blank = anonymous.';

  @override
  String get social_save => 'Save';

  @override
  String get nav_ponds => 'Ponds';

  @override
  String get pond_title => 'Fishing ponds';

  @override
  String get pond_tag => 'Paid fishing pond';

  @override
  String get pond_add => 'Add pond';

  @override
  String get pond_addTitle => 'Add fishing pond';

  @override
  String get pond_addHere => 'Add a fishing pond here';

  @override
  String pond_pill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fishing ponds',
      one: '1 fishing pond',
    );
    return '$_temp0';
  }

  @override
  String pond_pillSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ponds stocking soon',
      one: '1 pond stocking soon',
    );
    return '$_temp0';
  }

  @override
  String get pond_pillDetail => 'Paid fishing ponds nearby, stocking schedules';

  @override
  String get pond_editTitle => 'Edit pond info';

  @override
  String get pond_empty =>
      'No fishing ponds within 40 km yet. Know one? Tap \"Add pond\" so others can find it.';

  @override
  String get pond_loadError => 'Couldn\'t load ponds';

  @override
  String get pond_filterRelease => 'Stocking soon';

  @override
  String get pond_filterVerified => 'Verified';

  @override
  String get pond_filterFollowed => 'Following';

  @override
  String get pond_followedSoon => 'Ponds you follow are stocking soon';

  @override
  String get pond_verified => 'Verified';

  @override
  String get pond_owner => 'Claimed by owner';

  @override
  String get pond_unverified => 'Unverified';

  @override
  String get pond_fromWeb =>
      'Info gathered from the web, may be outdated. If it\'s right when you get there, tap \"Pond is real\" to help others.';

  @override
  String get pond_approx =>
      'Approximate location from the address. If you\'re nearby, tap \"Edit\" to fix the pin.';

  @override
  String pond_distance(String km) {
    return '$km away';
  }

  @override
  String pond_rating(String rating, int count) {
    return '$rating ★ ($count)';
  }

  @override
  String get pond_noRating => 'No ratings yet';

  @override
  String pond_releaseChip(String when) {
    return 'Stocking $when';
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
    return '$ta quintals';
  }

  @override
  String pond_ton(String ton) {
    return '$ton tons';
  }

  @override
  String get pond_releases => 'Stocking schedule';

  @override
  String get pond_noRelease => 'No upcoming stocking.';

  @override
  String get pond_official => 'Posted by owner';

  @override
  String get pond_relayed => 'Reported by user · unconfirmed';

  @override
  String get pond_releasePast => 'Stocked';

  @override
  String get pond_releaseCancelled => 'Cancelled';

  @override
  String get pond_postRelease => 'Report fish stocking';

  @override
  String get pond_showSource => 'View original post';

  @override
  String get pond_cancelRelease => 'Cancel this stocking';

  @override
  String get pond_reportRelease => 'Report as wrong';

  @override
  String get pond_follow => 'Follow';

  @override
  String get pond_following => 'Following';

  @override
  String get pond_followHint =>
      'New stocking at this pond will show at the top of the list (the Android app rings an alert).';

  @override
  String get pond_call => 'Call';

  @override
  String get pond_price => 'Ticket price';

  @override
  String get pond_hours => 'Opening hours';

  @override
  String get pond_species => 'Fish in pond';

  @override
  String get pond_note => 'Notes';

  @override
  String get pond_sources => 'Sources';

  @override
  String get pond_pulseTitle => 'At the pond now (last 6 hours)';

  @override
  String get pond_pulseBusy => 'Busy';

  @override
  String get pond_pulseQuiet => 'Quiet';

  @override
  String get pond_pulseBiting => 'Biting';

  @override
  String get pond_pulseReleased => 'Just stocked';

  @override
  String pond_pulseCount(String label, int count) {
    return '$label · $count';
  }

  @override
  String get pond_pulseSent => 'Sent. Thank you!';

  @override
  String get pond_pulseWait => 'Only one report every 30 minutes, please';

  @override
  String get pond_confirm => 'Pond is real';

  @override
  String get pond_confirmed => 'You confirmed';

  @override
  String get pond_confirmDone => 'Thanks! Once 3 people confirm, the pond gets a ✓';

  @override
  String get pond_edit => 'Edit';

  @override
  String get pond_claim => 'I own this pond';

  @override
  String get pond_claimTitle => 'Claim this pond';

  @override
  String get pond_claimBody =>
      'To prevent impersonation, an admin will call or message you on Zalo to verify. Once approved, you can post \"official\" stocking schedules and edit prices and hours.';

  @override
  String get pond_claimContact => 'Pond phone / Zalo';

  @override
  String get pond_claimNote => 'Message (optional)';

  @override
  String get pond_claimSend => 'Send request';

  @override
  String get pond_claimSent => 'Sent! An admin will contact you soon.';

  @override
  String get pond_claimPending => 'Your request is awaiting review.';

  @override
  String get pond_claimOwned => 'This pond already has an owner.';

  @override
  String get pond_claimYours => 'You own this pond.';

  @override
  String get pond_report => 'Report';

  @override
  String get pond_reportTitle => 'Report this pond?';

  @override
  String get pond_reportHint =>
      'Not real, closed, wrong location… Unclaimed ponds reported by 3 people are hidden automatically.';

  @override
  String get pond_error => 'Couldn\'t send. Check your connection and try again';

  @override
  String get pond_tooMany => 'You\'ve done a lot today, try again tomorrow';

  @override
  String get pond_duplicate => 'There\'s already a pond here. Open it?';

  @override
  String get pond_open => 'Open';

  @override
  String get pond_name => 'Pond name';

  @override
  String get pond_nameHint => 'e.g. Thanh Ha Fishing Pond';

  @override
  String get pond_address => 'Address';

  @override
  String get pond_phone => 'Phone / Zalo';

  @override
  String get pond_priceHint => 'e.g. 200k per 4-hour session, 350k/day';

  @override
  String get pond_hoursHint => 'e.g. 6am–6pm, closed Mondays';

  @override
  String pond_location(String coords) {
    return 'Pin location: $coords';
  }

  @override
  String get pond_locationHint =>
      'The pin is where you picked on the map. To change it: tap the pond on the map → Add pond.';

  @override
  String get pond_save => 'Save';

  @override
  String get pond_added => 'Pond added! Thank you.';

  @override
  String get pond_saved => 'Saved';

  @override
  String get pond_needName => 'Enter a pond name (at least 2 characters)';

  @override
  String get pond_reviews => 'Reviews';

  @override
  String get pond_writeReview => 'Write a review';

  @override
  String get pond_reviewHint => 'Are fish biting, price, service, seating…';

  @override
  String get pond_reviewSend => 'Post review';

  @override
  String get pond_reviewEmpty => 'No reviews yet.';

  @override
  String get pond_deleteReview => 'Delete my review';

  @override
  String get pond_noStars => 'Pick a star rating';

  @override
  String get release_title => 'Report fish stocking';

  @override
  String get release_paste => 'Paste the pond\'s post';

  @override
  String get release_pasteHint =>
      'Copy the pond\'s Facebook post / TikTok caption and paste it here. The app reads the date, time, fish type and amount.';

  @override
  String get release_pasteButton => 'Paste';

  @override
  String get release_read => 'App found';

  @override
  String get release_notFound => 'No stocking date found in the post. Pick a date below.';

  @override
  String get release_day => 'Date';

  @override
  String get release_time => 'Time';

  @override
  String get release_fish => 'Fish stocked';

  @override
  String get release_addFish => 'Add fish type';

  @override
  String get release_fishName => 'Fish type';

  @override
  String get release_fishKg => 'kg';

  @override
  String release_total(String amount) {
    return 'Total $amount';
  }

  @override
  String get release_asOwner => 'You own this pond: this schedule shows as \"Posted by owner\".';

  @override
  String get release_asUser =>
      'Your report shows as \"Reported by user\" until the owner confirms. Only report when you\'ve seen the pond\'s real post.';

  @override
  String get release_post => 'Post stocking';

  @override
  String get release_posted => 'Stocking posted!';

  @override
  String get release_needDay => 'Pick a stocking date';

  @override
  String get stations_menu => 'Station list';

  @override
  String get stations_menuHint => 'Water levels at KTTV and IOC stations';

  @override
  String get trip_tag => 'Fishing trip';

  @override
  String trip_pill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fishing trips',
      one: '1 fishing trip',
    );
    return '$_temp0';
  }

  @override
  String get trip_create => 'Invite to fish';

  @override
  String get trip_createHere => 'Invite to fish here';

  @override
  String get trip_formTitle => 'Create fishing trip';

  @override
  String get trip_editTitle => 'Edit fishing trip';

  @override
  String get trip_name => 'Trip name';

  @override
  String get trip_nameHint => 'e.g. Night fishing at Thanh Tri bridge rocks';

  @override
  String get trip_place => 'Meeting place';

  @override
  String get trip_placeHint => 'e.g. Rocks under the bridge, gate 3';

  @override
  String get trip_whereHint =>
      'The trip pin is placed here. To meet elsewhere: tap that place on the map → \"Invite to fish here\".';

  @override
  String get trip_when => 'Time';

  @override
  String get trip_date => 'Date';

  @override
  String get trip_start => 'Start';

  @override
  String get trip_duration => 'Duration';

  @override
  String trip_hours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get trip_golden => 'Golden hours here (tap to pick)';

  @override
  String trip_goldenChip(String when, String score) {
    return '$when · $score';
  }

  @override
  String get trip_noGolden => 'No golden hours here in the next 3 days';

  @override
  String get trip_people => 'Max people (including you)';

  @override
  String get trip_contact => 'Contact (optional)';

  @override
  String get trip_contactHint => 'Zalo/Facebook group link or phone number';

  @override
  String get trip_contactNote => 'Only people who joined can see it.';

  @override
  String get trip_noteHint => 'Target fish, bait, motorbike or carpool, sharing fuel costs…';

  @override
  String get trip_submit => 'Create trip';

  @override
  String get trip_save => 'Save changes';

  @override
  String get trip_created => 'Trip created! Anglers nearby will see it on the map.';

  @override
  String get trip_saved => 'Trip saved';

  @override
  String get trip_needName => 'Name the trip (at least 2 characters)';

  @override
  String get trip_badTime => 'Start time must be within the next 30 days';

  @override
  String get trip_tooMany => 'This device has created 5 trips today. Create more tomorrow.';

  @override
  String get trip_error => 'Couldn\'t send. Check your connection and try again';

  @override
  String get trip_tooFew => 'The trip already has more people than this';

  @override
  String get trip_running => 'Happening now';

  @override
  String get trip_cancelled => 'Cancelled';

  @override
  String get trip_full => 'Full';

  @override
  String trip_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots left',
      one: '1 spot left',
    );
    return '$_temp0';
  }

  @override
  String trip_members(int count, int max) {
    return '$count/$max people';
  }

  @override
  String trip_owner(String name) {
    return 'Host: $name';
  }

  @override
  String get trip_yours => 'Your trip';

  @override
  String get trip_joinedTag => 'You joined';

  @override
  String get trip_join => 'Join';

  @override
  String get trip_joinedSnack => 'Joined! See the contact and chat with the group below.';

  @override
  String get trip_joinFull => 'This trip is full';

  @override
  String get trip_joinClosed => 'This trip has ended or was cancelled';

  @override
  String get trip_leave => 'Leave trip';

  @override
  String get trip_leaveTitle => 'Leave this trip?';

  @override
  String get trip_cancel => 'Cancel trip';

  @override
  String get trip_cancelTitle => 'Cancel the trip? People who joined will see \"Cancelled\".';

  @override
  String get trip_edit => 'Edit';

  @override
  String get trip_keep => 'Keep trip';

  @override
  String get trip_share => 'Invite friends';

  @override
  String trip_shareText(String title, String when, String place, String map, String app) {
    return '🎣 Fishing trip: $title\n🕐 $when\n📍 $place\nMap: $map\nView and join on the Con Nước app: $app';
  }

  @override
  String get trip_report => 'Report';

  @override
  String get trip_reportTitle => 'Report this trip?';

  @override
  String get trip_reportHint =>
      'Scams, ads, bad content… Trips reported by 3 people are hidden automatically.';

  @override
  String get trip_membersOnly => 'Join to see the contact, who\'s going and chat with the group.';

  @override
  String get trip_contactLabel => 'Contact';

  @override
  String get trip_openContact => 'Open';

  @override
  String get trip_memberList => 'Who\'s going';

  @override
  String get trip_chat => 'Trip chat';

  @override
  String get trip_chatEmpty => 'No messages yet. Agree on meeting time and parking here.';

  @override
  String get trip_chatHint => 'Message the group…';

  @override
  String get trip_send => 'Send';

  @override
  String get trip_refresh => 'Refresh';

  @override
  String get trip_nearbyTitle => 'Fishing trips nearby';

  @override
  String get trip_nearbyEmpty =>
      'No trips within 30 km yet. Create the first one and invite others!';

  @override
  String get trip_loadError => 'Couldn\'t load fishing trips';

  @override
  String get trip_notice =>
      'Trips are public to users nearby. Don\'t meet where fishing is banned; go in groups and stay safe when night fishing.';

  @override
  String get checkin_pill => 'I\'m fishing';

  @override
  String checkin_pillOn(String time) {
    return 'Fishing · $time left';
  }

  @override
  String checkin_count(int count) {
    return '$count fishing now';
  }

  @override
  String get checkin_title => 'Check in \"fishing here\"';

  @override
  String get checkin_body =>
      'Anglers nearby will see someone is fishing in this area. Only a count is shown, never names; location is rounded to about 200 m; turns off automatically after 4 hours.';

  @override
  String get checkin_biting => 'Biting 🐟';

  @override
  String get checkin_noBite => 'No bites yet';

  @override
  String get checkin_start => 'Start';

  @override
  String get checkin_update => 'Update';

  @override
  String get checkin_stop => 'Heading home';

  @override
  String get checkin_on => 'You\'re checked in. Tight lines!';

  @override
  String get checkin_off => 'Checked out. Get home safe!';

  @override
  String get checkin_error => 'Couldn\'t send. Check your connection and try again';

  @override
  String get checkin_needLocation => 'Your location is needed to check in';

  @override
  String checkin_cellTitle(int count) {
    return '$count fishing nearby';
  }

  @override
  String checkin_cellBiting(int count) {
    return 'Fish biting for $count';
  }

  @override
  String get checkin_cellNoBite => 'No one has reported bites yet';

  @override
  String checkin_cellLatest(String time) {
    return 'Latest arrival at $time';
  }

  @override
  String get checkin_cellYou => 'Including you';

  @override
  String get checkin_listTitle => 'Where people are fishing';

  @override
  String get checkin_hint => 'Location rounded to ~200 m, no names shown.';

  @override
  String get spot_publicTag => 'Community spot';

  @override
  String get spot_pinAction => 'Pin publicly';

  @override
  String spot_nearbyChip(int count) {
    return 'Community spots: $count';
  }

  @override
  String get spot_nearbyTitle => 'Nearby fishing spots';

  @override
  String get spot_nearbyEmpty =>
      'No fishing spots within 30 km yet. Tap a place on the map, then tap \"Pin publicly\" to share your spot.';

  @override
  String spot_postedAgo(String date) {
    return 'Posted $date';
  }

  @override
  String spot_distance(String km) {
    return '$km away';
  }

  @override
  String get spot_viewWater => 'See water here';

  @override
  String get spot_report => 'Report';

  @override
  String get spot_reportTitle => 'Report this fishing spot?';

  @override
  String get spot_reportHint =>
      'Wrong location, inappropriate photos, ads… Spots reported by many people are hidden automatically.';

  @override
  String get spot_reportDone => 'Report sent. Thank you!';

  @override
  String get spot_reportTwice => 'You\'ve already reported this spot';

  @override
  String get spot_delete => 'Delete my spot';

  @override
  String get spot_deleteTitle => 'Remove this spot from the community map?';

  @override
  String get spot_ownedByYou => 'Your spot';

  @override
  String get spot_publishTitle => 'Pin a public fishing spot';

  @override
  String get spot_name => 'Spot name';

  @override
  String get spot_nameHint => 'e.g. Thanh Tri bridge rocks';

  @override
  String get spot_species => 'Fish often caught';

  @override
  String get spot_note => 'Tips';

  @override
  String get spot_noteHint => 'Bait, best hours, parking, depth…';

  @override
  String get spot_photos => 'Photos (up to 3)';

  @override
  String get spot_addPhoto => 'Add photo';

  @override
  String get spot_publicNotice =>
      'This spot will be public to all Con Nước users. Don\'t post no-fishing areas, or photos showing other people without their consent.';

  @override
  String get spot_agree => 'I understand and agree to share';

  @override
  String get spot_publish => 'Post spot';

  @override
  String get spot_published => 'Pinned! People nearby will see your spot.';

  @override
  String get spot_needName => 'Name your spot (at least 2 characters)';

  @override
  String get spot_error => 'Couldn\'t send. Check your connection and try again';

  @override
  String get spot_photoError => 'Couldn\'t read this photo';

  @override
  String spot_location(String coords) {
    return 'Location: $coords';
  }

  @override
  String get station_levelNow => 'Current water level';

  @override
  String get station_follow => 'Follow station';

  @override
  String get station_unfollow => 'Unfollow';

  @override
  String get stations_kindRiver => 'River station (KTTV)';

  @override
  String get stations_kindRiverDaily => 'Tidal river (KTTV)';

  @override
  String get station_sourceRiver =>
      'KTTV hydrological bulletin (4 readings/day + forecast) · hourly line interpolated by the app';

  @override
  String get station_sourceRiverTide =>
      'KTTV hydrological bulletin + estuary tide (Open-Meteo Marine) · hourly line estimated by the app';

  @override
  String get station_datumNational => 'station datum (per KTTV bulletin)';

  @override
  String station_issued(String time) {
    return 'KTTV bulletin issued $time';
  }

  @override
  String station_backtestMae(String cm) {
    return 'Backtest: mean error ±$cm cm';
  }

  @override
  String station_dailyTitle(int hours) {
    return 'Water level over $hours hours (KTTV bulletin)';
  }

  @override
  String station_dailyObs(String max, String min) {
    return 'Measured: high $max · low $min';
  }

  @override
  String station_dailyFc(String max, String min) {
    return 'Forecast: high $max · low $min';
  }

  @override
  String get station_dailyNoCurve =>
      'The bulletin gives only the high and low, with no times. The app doesn\'t draw a line to avoid guessing when the water rises and falls.';

  @override
  String station_dailyRangeNow(String range) {
    return 'Forecast range $range — water will rise/fall within this range';
  }

  @override
  String get point_estimateHere => 'Estimated water level at this point';

  @override
  String get point_onWater => 'Point is on water (river, lake or sea)';

  @override
  String get point_onLand =>
      'This point isn\'t on a river, lake or sea. The figures below are for the nearest body of water.';

  @override
  String point_basisRiver(String station, String river, String distance) {
    return 'Based on $station station ($river River) · $distance away';
  }

  @override
  String point_basisStation(String station, String distance) {
    return 'Based on $station station · $distance away';
  }

  @override
  String point_alongDown(String station, String distance, String river) {
    return '$distance downstream of $station station, measured along the $river River';
  }

  @override
  String point_alongUp(String station, String distance, String river) {
    return '$distance upstream of $station station, measured along the $river River';
  }

  @override
  String point_lagEarlier(int minutes) {
    return 'Water rises/falls about $minutes min earlier than at the station';
  }

  @override
  String point_lagLater(int minutes) {
    return 'Water rises/falls about $minutes min later than at the station';
  }

  @override
  String get point_lagSame => 'Water rises/falls at about the same time as the station';

  @override
  String point_meanLower(int cm) {
    return 'Water surface about $cm cm lower than at the station';
  }

  @override
  String point_meanHigher(int cm) {
    return 'Water surface about $cm cm higher than at the station';
  }

  @override
  String point_celerity(String speed) {
    return 'The tide travels upriver at about $speed km/h';
  }

  @override
  String get point_reachNote =>
      'Estimated from position along the river, between the estuary tide and the gauge; not yet verified against a second station.';

  @override
  String get flow_unknown =>
      'This place isn\'t on any major river, so water level and flow can\'t be calculated. Fishing times and weather are still calculated for this exact location.';

  @override
  String get flow_headRising => 'River is rising';

  @override
  String get flow_headFalling => 'River is falling';

  @override
  String get flow_headSteady => 'River is steady';

  @override
  String flow_dayValue(String day, String q) {
    return '$day: $q m³/s';
  }

  @override
  String get loc_nearCoast => 'Near the river mouth';

  @override
  String get point_basisCoast =>
      'Tide estimated from the nearest coastal waters; inside the river, highs and lows usually come later and the range is smaller.';

  @override
  String get info_noLevelSources =>
      'No water level source here yet. River flow: GloFAS model (via Open-Meteo Flood), daily. Weather and fishing times: Open-Meteo and astronomical calculations at the exact coordinates. All figures are for reference only.';

  @override
  String get flow_title => 'River flow';

  @override
  String flow_today(String q) {
    return 'Flow today ≈ $q m³/s';
  }

  @override
  String flow_tomorrow(String q, String trend) {
    return 'Tomorrow ≈ $q m³/s · $trend';
  }

  @override
  String get flow_rising => 'rising (river level going up)';

  @override
  String get flow_falling => 'falling (river level going down)';

  @override
  String get flow_steady => 'steady';

  @override
  String get flow_note => 'Estimated for the main channel of this river section, daily.';

  @override
  String chart_band(String cm) {
    return 'Shaded band around the line: error of about ±$cm cm, measured in station backtests';
  }

  @override
  String turn_in(String duration) {
    return 'in $duration';
  }

  @override
  String day_high(String level, String time) {
    return 'High $level · $time';
  }

  @override
  String day_low(String level, String time) {
    return 'Low $level · $time';
  }

  @override
  String day_range(int cm) {
    return 'Range $cm cm';
  }

  @override
  String get fishAct_title => 'Fish activity';

  @override
  String get fishAct_low => 'Low';

  @override
  String get fishAct_fair => 'Fair';

  @override
  String get fishAct_high => 'High';

  @override
  String get fishAct_peak => 'Very high';

  @override
  String fishAct_score(String score) {
    return '$score/10';
  }

  @override
  String fishAct_meter(int count) {
    return '$count of 5 fish';
  }

  @override
  String fishAct_because(String reasons) {
    return 'Thanks to $reasons';
  }

  @override
  String fishAct_next(String when) {
    return 'Next golden hours: $when';
  }

  @override
  String fishAct_inWindow(String to) {
    return 'In golden hours until $to';
  }

  @override
  String get fishAct_noWindow => 'No golden hours in the next 2 days';

  @override
  String get fishAct_source =>
      'Estimated from tides, moon times, day/night and weather (Open-Meteo) — for reference only; it can\'t tell where the fish are.';

  @override
  String get fishAct_quick => 'No weather yet: estimated from tides and moon times for now.';

  @override
  String get fishTime_now => 'Now';

  @override
  String fishTime_today(String time) {
    return 'Today $time';
  }

  @override
  String fishTime_tomorrow(String time) {
    return 'Tomorrow $time';
  }

  @override
  String fishTime_dayAfter(String time) {
    return 'Day after $time';
  }

  @override
  String get fishTime_title => 'Fish activity at';

  @override
  String get fishTime_slider => 'Pick a time to see fish activity';

  @override
  String get fishTime_reset => 'Back to now';

  @override
  String get fishTime_legendNote => 'Pin color = estimated fish activity. Tap a pin for details.';

  @override
  String get fishTime_collapse => 'Collapse';

  @override
  String get fishTime_expand => 'See fish activity by hour';

  @override
  String get fishing_changeSpot => 'Change';

  @override
  String get fishing_plan => 'Plan';

  @override
  String get pond_search => 'Search ponds by name…';

  @override
  String pond_header(int count) {
    return 'Ponds near you: $count';
  }

  @override
  String pond_headerSoon(int count) {
    return 'Stocking in the next 3 days: $count ponds';
  }

  @override
  String get pond_headerNone => 'No upcoming fish stocking';

  @override
  String fishing_nextGolden(String range) {
    return 'Golden hours $range';
  }

  @override
  String get fishing_hourly => 'Hourly today';

  @override
  String get fish_now_title => 'Fishing right now';

  @override
  String get fish_unsafe => 'Weather warning in effect — stay off the water';

  @override
  String get fish_noWindow => 'No standout hours today';

  @override
  String fish_best(String from, String to) {
    return 'Best time today: $from–$to';
  }

  @override
  String get cond_title => 'Weather & sky';

  @override
  String loc_river(String river) {
    return '$river River';
  }

  @override
  String loc_nearRiver(String river) {
    return 'Near the $river River';
  }

  @override
  String get loc_sea => 'Sea area';

  @override
  String get loc_water => 'On the water';

  @override
  String get spot_title => 'Fishing spot';

  @override
  String get spot_mine => 'My location';

  @override
  String get spot_point => 'Selected point';

  @override
  String get spot_useMine => 'My location';

  @override
  String get spot_pickMap => 'Pick on map';

  @override
  String get spot_pickHint => 'Tap where you plan to fish, then tap \"Fish here\"';

  @override
  String get spot_saved => 'Saved spots';

  @override
  String get fish_here => 'Fish here';

  @override
  String get advice_title => 'Fishing tips now';

  @override
  String get advice_note => 'Tips based on common fishing experience, tailored to this spot.';

  @override
  String get advice_unsafe => 'Thunderstorms or strong gusts — don\'t fish right now';

  @override
  String get advice_rising =>
      'Rising water: fish move to the banks, grass edges and shallows to feed — fish close in';

  @override
  String get advice_falling =>
      'Falling water: fish move to deep water, channel edges and creek mouths — fish farther out';

  @override
  String get advice_slack => 'Slack water: fish feed less, wait for the current to return';

  @override
  String advice_slackAt(String time) {
    return 'Slack water: fish feed less — current returns around $time';
  }

  @override
  String get advice_windStrong =>
      'Strong wind: hard to cast far — fish a sheltered bank, avoid going out by boat';

  @override
  String get advice_windDown => 'Windy: fish the downwind side, where waves push the bait';

  @override
  String get advice_rain => 'High chance of rain — bring a raincoat';

  @override
  String get advice_flood =>
      'River rising fast and muddy: fish eddies behind groynes and tree roots';

  @override
  String get advice_light => 'Dawn/dusk coming up — prime feeding time';

  @override
  String get advice_good => 'Conditions are good — go fish now';

  @override
  String point_reference(String station, String distance) {
    return 'Estimated from $station station, $distance away';
  }

  @override
  String point_referenceRiver(String station, String river, String distance) {
    return 'Estimated from $station station ($river River), $distance away';
  }

  @override
  String get point_title => 'Selected point';

  @override
  String point_coords(String coords) {
    return 'Coordinates: $coords';
  }

  @override
  String get point_copy => 'Copy coordinates';

  @override
  String get point_copied => 'Coordinates copied';

  @override
  String get point_noData => 'Couldn\'t calculate data for this point yet.';

  @override
  String get point_nearby => 'Nearest stations';

  @override
  String point_distance(String distance) {
    return '$distance away';
  }

  @override
  String get point_openDetail => 'See hourly details';

  @override
  String point_weatherNow(String temp, String wind, int rain) {
    return 'Weather now: $temp°C · wind $wind km/h · rain $rain%';
  }

  @override
  String point_sun(String rise, String set) {
    return 'Sunrise $rise · sunset $set';
  }

  @override
  String get point_seaModel => 'Ocean model calculated right at this point';

  @override
  String get point_tapHint => 'Tap anywhere on the map to see the water there';

  @override
  String get source_shortGauge => 'IOC + utide';

  @override
  String get source_shortModel => 'Open-Meteo';

  @override
  String get source_shortRiver => 'KTTV';

  @override
  String get source_shortRiverTide => 'KTTV + Open-Meteo tide';

  @override
  String source_compact(String source, String updated) {
    return 'Source: $source · $updated';
  }

  @override
  String get source_details => 'Source details';

  @override
  String get map_credits => 'Map sources';

  @override
  String get map_creditShort => '© OpenStreetMap';

  @override
  String get map_creditShortSat => '© EOX · © OpenStreetMap';

  @override
  String station_datumNote(String datum) {
    return 'Height relative to $datum';
  }

  @override
  String get station_datumChart => 'chart datum (converted per KTTV bulletin)';

  @override
  String get station_datumMsl => 'model mean sea level';

  @override
  String station_lunarDay(int day, int month) {
    return '$day/$month lunar';
  }

  @override
  String station_dailyRange(String range) {
    return 'Range $range';
  }

  @override
  String station_coords(String lat, String lon) {
    return 'Coordinates: $lat, $lon';
  }

  @override
  String station_modelFit(String from, String to) {
    return 'Tidal constants computed from data $from to $to';
  }

  @override
  String get station_sourceGauge =>
      'IOC Sea Level Monitoring (measured) · forecast computed with utide';

  @override
  String get station_sourceModel => 'Open-Meteo Marine (ocean model, no measurements)';

  @override
  String get hourly_now => 'Now';

  @override
  String hourly_detailTitle(String time) {
    return 'Details at $time';
  }

  @override
  String hourly_obsMinusPred(String delta) {
    return 'Measured − forecast: $delta';
  }

  @override
  String hourly_untilNext(String kind, String duration) {
    return 'Next $kind in $duration';
  }

  @override
  String hourly_fishScore(String score) {
    return 'Fishing score: $score/10';
  }

  @override
  String hourly_weather(String temp, String wind, String rain) {
    return '$temp °C · wind $wind km/h · rain $rain mm';
  }

  @override
  String get hourly_empty => 'No hourly data for this time range.';

  @override
  String get chart_semantics =>
      'Water level chart, measured as solid line, forecast as dashed line';

  @override
  String get watch_empty =>
      'Tap a point on the map (or a station), then tap ⭐ to save it. Saved spots show here for quick viewing, with alarms, and work offline.';

  @override
  String get watch_emptyTitle => 'No spots yet';

  @override
  String get watch_openMap => 'Open map';

  @override
  String get fishing_title => 'Fishing';

  @override
  String get fishing_pickStation => 'Pick station';

  @override
  String get fishing_dayScore => 'Today\'s score';

  @override
  String fishing_reference(String version) {
    return 'Estimated score, for reference only (formula $version: tide, moon times, sunrise/sunset, 24-hour pressure, temperature, wind and rain)';
  }

  @override
  String get fishing_golden => 'Upcoming golden hours';

  @override
  String get fishing_noGolden => 'No hours scoring ≥ 7 today.';

  @override
  String get fishing_next7 => 'Next 7 days';

  @override
  String get fishing_nowMark => 'Now';

  @override
  String fishing_hourShort(int hour) {
    return '${hour}h';
  }

  @override
  String fishing_level(String score, String label) {
    return '$score/10 · $label';
  }

  @override
  String get fishing_levelGood => 'Good';

  @override
  String get fishing_levelFair => 'Fair';

  @override
  String get fishing_levelPoor => 'Poor';

  @override
  String fishing_warnRed(String from, String to) {
    return 'Thunderstorms/lightning or strong gusts $from–$to — stay off the river/sea during these hours.';
  }

  @override
  String fishing_warnYellow(String from, String to) {
    return 'Possible thunderstorms or heavy rain $from–$to — keep an eye on the weather.';
  }

  @override
  String fishing_levelOutsideWarning(String score, String label) {
    return '$score/10 · $label outside warning hours';
  }

  @override
  String get fishing_factor_tide => 'tide';

  @override
  String get fishing_factor_flow => 'current';

  @override
  String get fishing_factor_solunar => 'moon times';

  @override
  String get fishing_factor_pressure => 'pressure';

  @override
  String get fishing_factor_daytime => 'sunrise/sunset';

  @override
  String get fishing_factor_weather => 'weather';

  @override
  String get fishing_factor_temperature => 'pleasant temperature';

  @override
  String get fishing_factor_season => 'fish season';

  @override
  String fishing_moon(String phase, int pct) {
    return '$phase · $pct% lit';
  }

  @override
  String get fishing_weatherSource => 'Open-Meteo (weather forecast)';

  @override
  String get moon_newMoon => 'New moon';

  @override
  String get moon_waxingCrescent => 'Waxing crescent';

  @override
  String get moon_firstQuarter => 'First quarter';

  @override
  String get moon_waxingGibbous => 'Waxing gibbous';

  @override
  String get moon_fullMoon => 'Full moon';

  @override
  String get moon_waningGibbous => 'Waning gibbous';

  @override
  String get moon_lastQuarter => 'Last quarter';

  @override
  String get moon_waningCrescent => 'Waning crescent';

  @override
  String get more_info => 'App info';

  @override
  String get more_appName => 'Con Nước';

  @override
  String more_build(String sha) {
    return 'Build $sha';
  }

  @override
  String get more_update => 'New version available — reload the page to update';

  @override
  String get more_close => 'Close';

  @override
  String get more_title => 'More';

  @override
  String get more_explore => 'Explore';

  @override
  String get more_app => 'App';

  @override
  String get more_journalHint => 'Your catches and fishing habits';

  @override
  String get more_profileHint => 'Name shown on comments, fishing trips and reviews';

  @override
  String get more_editName => 'Change name';

  @override
  String get more_theme => 'Theme';

  @override
  String get more_themeSystem => 'System';

  @override
  String get more_themeLight => 'Light';

  @override
  String get more_themeDark => 'Dark';

  @override
  String get more_sources => 'Data sources';

  @override
  String get more_sourcesBody =>
      '• IOC Sea Level Monitoring — measured sea level at Vung Tau and Quy Nhon (every minute). Tide forecasts at these 2 stations are computed by harmonic analysis (utide) from 12 months of data; backtest error: ±10 cm (Vung Tau), ±7 cm (Quy Nhon).\n• National Center for Hydro-Meteorological Forecasting (KTTV) — short-range hydrological bulletins: river levels 4 times/day + forecast. Hourly lines are estimated by the app (combined with estuary tide); backtest: ±12 cm (Hanoi), ±11 cm (Nam Dan).\n• Open-Meteo — weather, waves and coastal sea level model.\n• GloFAS (via Open-Meteo Flood) — daily main-channel river flow.\n• Any point on the map: ocean model at that point; on the Red River and Ca River, calculated from position along the river; elsewhere uses the nearest KTTV river station (within 40 km), coastal tide (estimated) or river flow.\n• Base map: OpenFreeMap · © OpenMapTiles · data © OpenStreetMap.\n• Satellite imagery: EOxCloudless (EOX IT Services GmbH), contains Copernicus Sentinel 2025 data.\nAll forecast/estimated figures are for reference only. See each station\'s Info tab for source details, datum and reliability.';

  @override
  String more_version(String version) {
    return 'Version $version';
  }

  @override
  String get set_title => 'Settings';

  @override
  String get set_entry => 'Appearance & settings';

  @override
  String get set_entryHint => 'Colours, background, font, text size, language, notifications';

  @override
  String get set_previewTitle => 'Fish activity: HIGH · 8.2';

  @override
  String get set_previewBody => 'Golden hours 17:00–18:30 · tide rising';

  @override
  String get set_look => 'Appearance';

  @override
  String get set_mode => 'Light or dark';

  @override
  String get set_accent => 'Accent colour';

  @override
  String get set_backdrop => 'Background';

  @override
  String get set_font => 'Font';

  @override
  String get set_textSize => 'Text size';

  @override
  String get accent_ocean => 'Ocean';

  @override
  String get accent_jade => 'Jade';

  @override
  String get accent_leaf => 'Leaf';

  @override
  String get accent_sunset => 'Sunset';

  @override
  String get accent_coral => 'Coral';

  @override
  String get accent_violet => 'Violet';

  @override
  String get accent_slate => 'Graphite';

  @override
  String get accent_gold => 'Bronze';

  @override
  String get backdrop_mist => 'Mist';

  @override
  String get backdrop_warm => 'Warm paper';

  @override
  String get backdrop_pure => 'White / AMOLED';

  @override
  String get backdrop_tinted => 'Accent tint';

  @override
  String get font_beVietnam => 'Be Vietnam';

  @override
  String get font_nunito => 'Nunito round';

  @override
  String get font_system => 'Device';

  @override
  String get size_small => 'Small';

  @override
  String get size_normal => 'Normal';

  @override
  String get size_large => 'Large';

  @override
  String get size_huge => 'Extra large';

  @override
  String get set_general => 'General';

  @override
  String get set_language => 'Language';

  @override
  String get lang_system => 'Phone setting';

  @override
  String get lang_vi => 'Tiếng Việt';

  @override
  String get lang_en => 'English';

  @override
  String get set_start => 'Open the app on';

  @override
  String get set_notifications => 'Notifications';

  @override
  String get set_notificationsHint => 'Golden hours, high/low tide, how early';

  @override
  String get set_motion => 'Reduce motion';

  @override
  String get set_motionHint =>
      'Turns off swimming fish, flowing water and animations — smoother on older phones, saves battery';

  @override
  String get set_data => 'Data & storage';

  @override
  String set_cache(String mb) {
    return 'Cached data: $mb MB';
  }

  @override
  String get set_cacheHint =>
      'Forecasts, weather, base map — downloaded again when needed. Journal, saved places and settings are kept.';

  @override
  String get set_cacheClear => 'Clear';

  @override
  String get set_cacheCleared => 'Cached data cleared';

  @override
  String get set_reset => 'Restore default look';

  @override
  String get set_resetDone => 'Default look restored';

  @override
  String get sp_title => 'What to fish for today?';

  @override
  String get sp_seeAll => 'See all';

  @override
  String get sp_guideTitle => 'Species guide';

  @override
  String get sp_today => 'Today';

  @override
  String sp_bestTime(String range) {
    return 'Best time: $range';
  }

  @override
  String get sp_noTime => 'No good time today';

  @override
  String get sp_inSeason => 'In season';

  @override
  String get sp_offSeason => 'Off season';

  @override
  String get sp_season => 'Main season';

  @override
  String get sp_where => 'Where';

  @override
  String get sp_bait => 'Bait';

  @override
  String get sp_chum => 'Groundbait';

  @override
  String get sp_how => 'How to fish';

  @override
  String get sp_todayTips => 'Today';

  @override
  String get sp_note =>
      'Common angling practice, adjusted for the real tide and weather here. For reference only.';

  @override
  String get sp_noTips => 'Normal conditions today; fish the way you usually do.';

  @override
  String get habitat_pond => 'Ponds';

  @override
  String get habitat_river => 'Rivers';

  @override
  String get habitat_estuary => 'Estuaries';

  @override
  String get habitat_sea => 'Sea';

  @override
  String get depth_surface => 'Surface';

  @override
  String get depth_middle => 'Mid-water';

  @override
  String get depth_bottom => 'Bottom';

  @override
  String get spTip_outOfSeason => 'Not its main season yet: you can still catch it, just fewer.';

  @override
  String get spTip_waitForCurrent =>
      'It feeds when the water runs: slack now, wait for the current.';

  @override
  String get spTip_murkyStrongBait =>
      'Murky after rain: use strong-smelling bait, fish near the bank where it is clearer.';

  @override
  String get spTip_coldSmallBaitDeep =>
      'Turning cold: fish feed slowly; smaller bait, deeper, be patient.';

  @override
  String get spTip_hotGoDeepShade => 'Hot: fish early or late, or go deep and into shade.';

  @override
  String get spTip_pressureFallingBite =>
      'Pressure falling: fish often feed hard before the weather turns.';

  @override
  String get spTip_pressureRisingFinesse =>
      'Pressure rising after a front: fish are shy; finer line, smaller hook.';

  @override
  String get spTip_windDownwind =>
      'Strong wind: fish the bank the wind blows onto, food collects there.';

  @override
  String get spTip_risingNearBank => 'Rising water: fish move to the banks to feed, fish close.';

  @override
  String get spTip_fallingDeeper =>
      'Falling water: fish drop back to deeper channels and creek mouths, fish farther out.';

  @override
  String get nb_button => 'No bites?';

  @override
  String get nb_title => 'No bites? Try these';

  @override
  String get nb_now => 'For right now';

  @override
  String get nb_always => 'Things to check';

  @override
  String nb_waitCurrent(String time) {
    return 'Slack water: the current picks up around $time, fish will feed better. Re-bait and chum meanwhile.';
  }

  @override
  String get nb_goDeepShade =>
      'Harsh sun: fish go deep; fish deeper or move to shade and tree roots.';

  @override
  String get nb_coldSlow => 'Cold: smaller bait, slower retrieve, on the bottom in deeper water.';

  @override
  String get nb_murkySmell =>
      'Murky water: switch to strong-smelling bait, find clearer water near the bank.';

  @override
  String get nb_finesse =>
      'After a front, pressure rising: shy fish; finer line, smaller hook, less bait.';

  @override
  String get nb_downwind => 'Strong wind: move to the bank the wind blows onto, food drifts there.';

  @override
  String nb_nextGolden(String time) {
    return 'Next golden hour at $time: take a break and come back on time.';
  }

  @override
  String get nb_changeDepth => 'Change depth: start on the bottom, then raise 20–30 cm at a time.';

  @override
  String get nb_moveSpot => 'No bites in 20–30 minutes: move; look for weed, roots, eddies.';

  @override
  String get nb_freshBait =>
      'Fresh bait, hook point showing; old bait and groundbait lose their smell.';

  @override
  String get nb_stayQuiet => 'Keep quiet and keep your shadow off the water.';

  @override
  String get nb_finerLine => 'Shy fish: go to finer line and a smaller hook.';

  @override
  String get fishing_species => 'Species';

  @override
  String get sp_carp => 'Common carp';

  @override
  String get sp_carp_where =>
      'Ponds, lakes, slow rivers; around weed beds, sunken roots, muddy bottoms.';

  @override
  String get sp_carp_bait => 'Roasted rice bran, corn flour, soaked corn, red worms.';

  @override
  String get sp_carp_chum =>
      'Sour groundbait (bran + corn flour fermented) or milk/pineapple scent. Bait the swim 15–20 min first.';

  @override
  String get sp_carp_how =>
      'Float or ledger right on the bottom with a sensitive float; carp often lift the float before pulling.';

  @override
  String get sp_tilapia => 'Tilapia';

  @override
  String get sp_tilapia_where => 'Ponds, lakes, canals, slow rivers; warm, sunny margins.';

  @override
  String get sp_tilapia_bait => 'Pellets, kneaded flour, worms, small shrimp.';

  @override
  String get sp_tilapia_chum =>
      'Sweet (milk, vanilla) or mildly fishy groundbait, a little and often.';

  @override
  String get sp_tilapia_how =>
      'Small hooks, mid-water to just off the bottom; strike lightly as the float dips.';

  @override
  String get sp_grassCarp => 'Grass carp';

  @override
  String get sp_grassCarp_where => 'Lakes, big rivers, stocked ponds; grassy, weedy margins.';

  @override
  String get sp_grassCarp_bait => 'Young grass, cassava leaves, boiled corn, kneaded bran.';

  @override
  String get sp_grassCarp_chum => 'Fermented corn, bran mixed with corn flour.';

  @override
  String get sp_grassCarp_how =>
      'Strong line and rod, moderate drag; it runs hard, play it patiently.';

  @override
  String get sp_snakehead => 'Snakehead';

  @override
  String get sp_snakehead_where =>
      'Paddies, canals, weedy ponds; tight to banks and floating vegetation.';

  @override
  String get sp_snakehead_bait => 'Frogs, small live fish, lures (frog, spoon).';

  @override
  String get sp_snakehead_chum => 'No groundbait needed.';

  @override
  String get sp_snakehead_how =>
      'Twitch or drag the bait along weed edges, move quietly; it strikes hard and heads for cover.';

  @override
  String get sp_walkingCatfish => 'Walking catfish';

  @override
  String get sp_walkingCatfish_where => 'Ponds, paddies, muddy canals; holes along the bank.';

  @override
  String get sp_walkingCatfish_bait => 'Worms, chicken guts, shrimp, smelly baits.';

  @override
  String get sp_walkingCatfish_chum => 'Fishy groundbait (old fish, fish meal).';

  @override
  String get sp_walkingCatfish_how =>
      'Bottom fish at night or after rain; strong rig, medium hook.';

  @override
  String get sp_pangasius => 'Pangasius (tra, basa)';

  @override
  String get sp_pangasius_where => 'Big Mekong rivers, stocked ponds; deep channels.';

  @override
  String get sp_pangasius_bait => 'Pellets, chicken guts, old fish, dough.';

  @override
  String get sp_pangasius_chum => 'Fishy or sour groundbait.';

  @override
  String get sp_pangasius_how => 'Mid-water to bottom with strong line; it pulls very hard.';

  @override
  String get sp_mystus => 'Mystus catfish';

  @override
  String get sp_mystus_where =>
      'Running rivers and streams, gravel runs; each stretch feeds at its own time.';

  @override
  String get sp_mystus_bait => 'Worms, shrimp, grubs.';

  @override
  String get sp_mystus_chum => 'Lightly fishy, sparingly.';

  @override
  String get sp_mystus_how =>
      'Bottom fish along the current seams as the water starts to run; ask local anglers when it comes in.';

  @override
  String get sp_mullet => 'Mullet';

  @override
  String get sp_mullet_where =>
      'Estuaries, lagoons, harbours; they come in on the rising tide and leave on the ebb.';

  @override
  String get sp_mullet_bait => 'Weed, flour mixed with bran, bread.';

  @override
  String get sp_mullet_chum => 'Sour, lightly fishy groundbait spread along the current.';

  @override
  String get sp_mullet_how =>
      'Small sensitive float and hook, fish the current while the water runs.';

  @override
  String get sp_seabass => 'Barramundi (seabass)';

  @override
  String get sp_seabass_where =>
      'Estuaries, lagoons, rocks; around bridge piles, sluice gates, eddies.';

  @override
  String get sp_seabass_bait => 'Live shrimp, small fish, lures.';

  @override
  String get sp_seabass_chum => 'No groundbait needed.';

  @override
  String get sp_seabass_how =>
      'Cast lures or drift live shrimp with the current; best on strong flow and at dawn and dusk.';

  @override
  String get sp_snapper => 'Snapper';

  @override
  String get sp_snapper_where => 'Sea, rocks, reefs; deep reef bottoms.';

  @override
  String get sp_snapper_bait => 'Squid, prawns, fresh baitfish.';

  @override
  String get sp_snapper_chum => 'None, or chopped bait on the bottom.';

  @override
  String get sp_snapper_how =>
      'Bottom fish with just enough lead to hold, abrasion-resistant leader; best on spring tides.';

  @override
  String get sp_grouper => 'Grouper';

  @override
  String get sp_grouper_where => 'Reefs and rocky shores; holes in the rock.';

  @override
  String get sp_grouper_bait => 'Live small fish, squid, prawns.';

  @override
  String get sp_grouper_chum => 'No groundbait needed.';

  @override
  String get sp_grouper_how =>
      'Lock up as soon as it bites so it cannot reach its hole; strong line.';

  @override
  String get sp_goby => 'Goby';

  @override
  String get sp_goby_where => 'Canals, brackish rivers; sandy or muddy bottoms.';

  @override
  String get sp_goby_bait => 'Small shrimp, worms.';

  @override
  String get sp_goby_chum => 'No groundbait needed.';

  @override
  String get sp_goby_how =>
      'Light bottom rig with a small hook; bites are gentle, wait for the float to move off.';

  @override
  String get sp_climbingPerch => 'Climbing perch';

  @override
  String get sp_climbingPerch_where =>
      'Paddies, ditches, ponds; grassy edges; best after the first rains.';

  @override
  String get sp_climbingPerch_bait => 'Worms, grasshoppers, kneaded rice.';

  @override
  String get sp_climbingPerch_chum => 'A little roasted bran along the bank.';

  @override
  String get sp_climbingPerch_how => 'Hand line close to grassy banks, small hook, quick strike.';

  @override
  String get sp_crucian => 'Crucian carp';

  @override
  String get sp_crucian_where => 'Ponds and lakes; bottom and mid-water, likes cooler water.';

  @override
  String get sp_crucian_bait => 'Red worms, flour paste.';

  @override
  String get sp_crucian_chum => 'Fine sweet groundbait, sparingly.';

  @override
  String get sp_crucian_how => 'Small hook, sensitive float; good in the cool season.';

  @override
  String get sp_bighead => 'Bighead and silver carp';

  @override
  String get sp_bighead_where =>
      'Large lakes, stocked ponds; surface and mid-water on warm sunny days.';

  @override
  String get sp_bighead_bait => 'Cloud bait: bran and bean flour that breaks up in the water.';

  @override
  String get sp_bighead_chum => 'Floating groundbait that forms a cloud.';

  @override
  String get sp_bighead_how =>
      'Suspended float at surface to mid-water with a dissolving bait ball; strike as the float sinks slowly.';

  @override
  String get nav_backAgain => 'Swipe back again to exit';

  @override
  String get map_hereNow => 'Around you now';

  @override
  String map_nextGolden(String time) {
    return 'golden hour $time';
  }

  @override
  String get fishing_noGoldenShort => 'no golden hour yet';

  @override
  String get flood_entry => 'When does the water cut me off?';

  @override
  String get flood_title => 'When does the water cut me off?';

  @override
  String get flood_ask =>
      'Roughly how far below your spot (or your way back) is the water right now?';

  @override
  String flood_margin(int cm) {
    return '$cm cm';
  }

  @override
  String get flood_noTide => 'No tide forecast here, so this cannot be worked out.';

  @override
  String get flood_safe => 'The water stays below it for 24 hours';

  @override
  String flood_at(String time) {
    return 'Water arrives at $time';
  }

  @override
  String get flood_already => 'The water is already at this level, leave now.';

  @override
  String flood_leave(String time) {
    return 'Leave before $time.';
  }

  @override
  String flood_in(String duration) {
    return 'About $duration from now.';
  }

  @override
  String flood_recede(String time) {
    return 'It drops back below around $time.';
  }

  @override
  String flood_peak(String time, String level) {
    return 'High water $time, about $level on the station datum.';
  }

  @override
  String get flood_windy =>
      'Strong wind: water may rise above the forecast; the app already counts 20 cm earlier. Leave sooner.';

  @override
  String get flood_note =>
      'Estimated from the tide forecast here, for reference only. Waves, wind and floods can raise the water faster: always keep a way out.';

  @override
  String flood_minutes(int m) {
    return '$m min';
  }

  @override
  String flood_hoursMinutes(int h, int m) {
    return '$h h $m min';
  }

  @override
  String flood_alarmButton(String time) {
    return 'Ring at $time';
  }

  @override
  String flood_alarmSet(String time) {
    return 'Alarm set for $time · tap to cancel';
  }

  @override
  String get flood_alarmApk => 'Alarms work in the Android app (download the APK in More).';

  @override
  String flood_alarmTitle(String place) {
    return 'Water coming: $place';
  }

  @override
  String flood_alarmBody(String time) {
    return 'Water arrives around $time. Pack up and leave your spot now.';
  }

  @override
  String get flood_channel => 'Cut-off by rising water';

  @override
  String get shift_title => 'Weather is changing';

  @override
  String get shift_dayAfter => 'In two days';

  @override
  String shift_coldFront(String when) {
    return '$when turns cold (monsoon): fish often feed hard just before, worth going. They bite poorly for 1–2 days after.';
  }

  @override
  String shift_heavyRain(String when) {
    return '$when heavy rain: murky water afterwards, fish the bottom with smelly bait, near clearer banks.';
  }

  @override
  String shift_pressureDrop(String when) {
    return 'From $when pressure drops fast: weather worsening, watch for storm and depression warnings.';
  }

  @override
  String shift_heatWave(String when) {
    return '$when heat above 36°C: fish early and late, deep water and shade.';
  }

  @override
  String get shift_note => 'From the Open-Meteo forecast, for reference only.';

  @override
  String get alert_evening => 'Evening heads-up (20:00)';

  @override
  String get alert_eveningHint =>
      '\"Fishing tomorrow?\": tomorrow\'s best golden hours at your spot';

  @override
  String digest_title(String place) {
    return 'Fishing tomorrow? · $place';
  }

  @override
  String digest_body(String range, String band, String score) {
    return 'Golden hours $range: fish activity $band ($score). Get your gear ready tonight!';
  }

  @override
  String get digest_none =>
      'No golden hours here tomorrow. Open \"Where to fish?\" to find a better spot.';

  @override
  String get brag_open => 'Show off this catch';

  @override
  String get brag_title => 'Show off';

  @override
  String get brag_share => 'Share picture';

  @override
  String get brag_showPlace => 'Show the place name';

  @override
  String get brag_showPlaceHint => 'Off by default to keep your spot secret';

  @override
  String brag_score(String score) {
    return 'Fish activity $score';
  }

  @override
  String brag_text(String species, String link) {
    return 'Just landed a $species! Fish times and tides on Con Nước: $link';
  }

  @override
  String get bite_question => 'Fishing here? Getting bites?';

  @override
  String get bite_yes => 'Biting';

  @override
  String get bite_no => 'No bites';

  @override
  String get bite_thanks => 'Thanks! Your answer tells anglers nearby whether fish are biting.';

  @override
  String get bite_tooSoon => 'You just answered; try again in 30 minutes.';

  @override
  String get bite_failed => 'Could not send, please try again later.';

  @override
  String bite_summary(int bites, int misses) {
    return 'Around here, last 3 hours: $bites biting, $misses no bites.';
  }

  @override
  String get bite_first => 'Nobody nearby has answered yet. Be the first!';

  @override
  String bite_pattern(String state, int rate) {
    return 'Fish here bite best on $state ($rate% biting, last 60 days).';
  }

  @override
  String get bite_rising => 'a rising tide';

  @override
  String get bite_falling => 'a falling tide';

  @override
  String get bite_slack => 'slack water';

  @override
  String get bite_note => 'From anglers\' answers; only a ~2 km area is stored, never who you are.';

  @override
  String get gear_title => 'Gear & knots';

  @override
  String get gear_entry => 'Gear & knots';

  @override
  String get gear_entryHint => 'What to pack, how to tie the six most used knots';

  @override
  String get gear_tabPack => 'What to pack';

  @override
  String get gear_tabKnots => 'Knots';

  @override
  String gear_progress(int done, int total) {
    return '$done/$total items';
  }

  @override
  String get gear_clear => 'Untick all for the next trip';

  @override
  String get trip_night => 'Night fishing';

  @override
  String get trip_sea => 'Sea, rocks';

  @override
  String get trip_pond => 'Paid pond';

  @override
  String get trip_river => 'River, canal';

  @override
  String get gear_rodReel => 'Rod and reel (check reel and drag)';

  @override
  String get gear_spareLine => 'Spare line';

  @override
  String get gear_hooksWeights => 'Spare hooks, sinkers, floats, snaps';

  @override
  String get gear_baitChum => 'Bait and groundbait';

  @override
  String get gear_netTowel => 'Landing net and towel';

  @override
  String get gear_waterFood => 'Water and food';

  @override
  String get gear_sunHat => 'Hat, sunscreen, sunglasses';

  @override
  String get gear_raincoat => 'Raincoat';

  @override
  String get gear_phonePower => 'Charged phone, power bank';

  @override
  String get gear_trashBag => 'Bag to take your rubbish home';

  @override
  String get gear_headlamp => 'Headlamp, spare batteries';

  @override
  String get gear_glowSticks => 'Glow sticks, float lights';

  @override
  String get gear_mosquito => 'Mosquito repellent';

  @override
  String get gear_jacket => 'Jacket (cold, windy nights)';

  @override
  String get gear_nonSlipShoes => 'Non-slip shoes';

  @override
  String get gear_lifeJacket => 'Life jacket';

  @override
  String get gear_tideCheck => 'Check tide times and \"water cuts me off\" in the app';

  @override
  String get gear_leader => 'Abrasion-resistant leader';

  @override
  String get gear_pliers => 'Pliers to unhook';

  @override
  String get gear_pondCall => 'Call the pond: price, hours, stocking';

  @override
  String get gear_chairUmbrella => 'Chair, sun umbrella';

  @override
  String get gear_keepNet => 'Keep net or fish box';

  @override
  String get gear_boots => 'Boots or wading shoes';

  @override
  String get gear_rodRest => 'Rod rests, bank sticks';

  @override
  String knot_strength(int pct) {
    return 'Keeps about $pct% of line strength';
  }

  @override
  String get knot_note =>
      'General tips: wet the knot before tightening, pull slowly so it does not heat up, trim leaving 2–3 mm. Drawings are diagrams.';

  @override
  String get knot_improvedClinch => 'Improved clinch knot';

  @override
  String get knot_improvedClinch_use =>
      'Hooks and snaps on mono. The easiest one; everyone should know it.';

  @override
  String get knot_improvedClinch_steps =>
      'Pass the line through the hook eye, leaving about 15 cm.\nWrap the tag end around the main line 5–7 times.\nPass the tag through the small loop by the eye, then through the big loop you just made.\nWet it, pull the main line tight, trim.';

  @override
  String get knot_palomar => 'Palomar knot';

  @override
  String get knot_palomar_use => 'Hooks and lures on braid (PE). Very strong and quick.';

  @override
  String get knot_palomar_steps =>
      'Double about 15 cm of line and push the fold through the hook eye.\nTie a loose overhand knot with the doubled line.\nPass the whole hook through the folded loop.\nWet it, pull both ends tight, trim.';

  @override
  String get knot_uni => 'Uni knot';

  @override
  String get knot_uni_use => 'Hooks, snaps and lures; works on mono and braid.';

  @override
  String get knot_uni_steps =>
      'Pass the line through the eye and lay the tag alongside the main line to form a loop.\nWrap the tag around both lines inside the loop 5–6 times.\nPull the tag so the wraps sit neatly.\nWet it, pull the main line to slide the knot to the eye, trim.';

  @override
  String get knot_doubleUni => 'Double uni knot';

  @override
  String get knot_doubleUni_use => 'Joins two lines (braid to mono leader, or a broken line).';

  @override
  String get knot_doubleUni_steps =>
      'Overlap the two line ends by about 20 cm.\nWith the first end tie a uni knot around the second line (3–4 wraps; 6–8 for braid).\nDo the same with the second end.\nWet them, pull the main lines so the knots slide together, trim.';

  @override
  String get knot_perfectionLoop => 'Perfection loop';

  @override
  String get knot_perfectionLoop_use => 'A loop at the line end to clip rigs and leaders on fast.';

  @override
  String get knot_perfectionLoop_steps =>
      'Make a small loop at the end, tag behind.\nWrap the tag around to make a second loop in front.\nPass the tag between the two loops.\nPull the second loop through the first, tighten, trim.';

  @override
  String get knot_snell => 'Snell knot';

  @override
  String get knot_snell_use =>
      'Ties a hook so the line runs straight down the shank, hooking more fish.';

  @override
  String get knot_snell_steps =>
      'Pass the line through the eye and lay it along the shank to make a loop.\nWrap the loop around the shank and line 7–8 times, from the eye down.\nHold the wraps and pull the main line tight.\nWet it, tighten again, trim.';

  @override
  String get font_quicksand => 'Quicksand';

  @override
  String get set_navStyle => 'Tab bar style';

  @override
  String get nav_styleDot => 'Dot';

  @override
  String get lang_zh => '中文';

  @override
  String get lang_ko => '한국어';

  @override
  String get lang_ja => '日本語';

  @override
  String get pond_zalo => 'Zalo chat';

  @override
  String get pond_filterWeekend => 'Weekend stocking';

  @override
  String get release_alarmPond => 'A pond you follow';

  @override
  String release_alarmTitle(String pond) {
    return 'Stocking soon: $pond';
  }

  @override
  String release_alarmBody(String when) {
    return 'Fish go in at $when. Go early for a good spot!';
  }

  @override
  String release_alarmBodyKg(String when, int kg) {
    return 'About $kg kg go in at $when. Go early for a good spot!';
  }

  @override
  String get nav_styleArc => 'Arc';

  @override
  String get nav_styleNotch => 'Notch';

  @override
  String get nav_styleGlass => 'Glass';

  @override
  String get map_layerPonds => 'Fishing ponds';

  @override
  String get map_layerSpots => 'Community spots';

  @override
  String get map_layerTrips => 'Fishing trips';

  @override
  String get map_layerCheckins => 'People fishing now';

  @override
  String get onb_skip => 'Skip';

  @override
  String get onb_back => 'Back';

  @override
  String get onb_next => 'Continue';

  @override
  String get onb_start => 'Get started';

  @override
  String get onb_finish => 'Open the app';

  @override
  String onb_progress(int step, int total) {
    return 'Step $step/$total';
  }

  @override
  String get onb_welcomeTitle => 'Welcome to Con Nước';

  @override
  String get onb_welcomeBody =>
      'Tides, golden hours and fishing spots around you — quick to read, works offline too.';

  @override
  String get onb_welcomeTide => 'Tides and weather for any place';

  @override
  String get onb_welcomeGolden => 'Golden hours and a daily fishing score';

  @override
  String get onb_welcomeCommunity => 'Ponds, spots and fishing trips from the community';

  @override
  String get onb_welcomeTime => 'Takes under a minute · skip any time';

  @override
  String get onb_langTitle => 'Choose a language';

  @override
  String get onb_langBody => 'Changes right away. You can switch it in Settings.';

  @override
  String get onb_nameTitle => 'What should we call you?';

  @override
  String get onb_nameBody =>
      'Shown on comments, trips and pond reviews. Optional: leave it empty to stay anonymous.';

  @override
  String get onb_nameShownAs => 'Others will see';

  @override
  String get onb_nameErrShort => 'Use at least 2 characters.';

  @override
  String get onb_nameErrLong => 'Use at most 30 characters.';

  @override
  String get onb_nameErrChars => 'The name has hidden characters.';

  @override
  String get onb_nameErrLink => 'Names can\'t contain links.';

  @override
  String get onb_nameErrPhone => 'Names can\'t contain phone numbers.';

  @override
  String get onb_nameErrReserved =>
      'This could be mistaken for the team or the app. Please pick another name.';

  @override
  String get onb_kindTitle => 'Who are you?';

  @override
  String get onb_kindBody =>
      'Pick one or more. The app opens the tab and map layers that suit you.';

  @override
  String get onb_kindWeekend => 'Weekend angler';

  @override
  String get onb_kindWeekendHint => 'See whether today is a good day to go';

  @override
  String get onb_kindPro => 'Serious angler (river, sea)';

  @override
  String get onb_kindProHint => 'Tides, golden hours, wind and waves';

  @override
  String get onb_kindPond => 'Fishing pond visitor';

  @override
  String get onb_kindPondHint => 'Find ponds, restocking days and reviews';

  @override
  String get onb_kindOwner => 'Pond owner';

  @override
  String get onb_kindOwnerHint => 'List your pond, announce restocking';

  @override
  String get onb_kindBoater => 'Boater, seafarer';

  @override
  String get onb_kindBoaterHint => 'Tides, wind and waves before heading out';

  @override
  String get onb_kindTide => 'Just checking tides';

  @override
  String get onb_kindTideHint => 'A clean map: stations and water levels only';

  @override
  String get onb_prefsTitle => 'A few more touches';

  @override
  String get onb_prefsBody => 'All optional, change them any time.';

  @override
  String get onb_waterTitle => 'Where do you usually fish?';

  @override
  String get onb_waterRiver => 'Rivers, canals';

  @override
  String get onb_waterSea => 'Sea';

  @override
  String get onb_waterLake => 'Lakes, ponds';

  @override
  String get onb_notifyTitle => 'Notifications';

  @override
  String get onb_notifyAlarms => 'Golden hour & tide alarms';

  @override
  String get onb_notifyAlarmsHint => 'Turn on per place in the Watch tab';

  @override
  String get onb_notifyDenied =>
      'Notifications aren\'t allowed. You can turn them on in your phone settings.';

  @override
  String get onb_locTitle => 'Your location';

  @override
  String get onb_locAllow => 'Allow location';

  @override
  String get onb_locOn => 'Location is on';

  @override
  String get onb_lookTitle => 'Choose a look';

  @override
  String get onb_lookBody => 'Accent colour, light or dark, and tab bar style. Preview below.';

  @override
  String get onb_rerun => 'Replay the welcome';

  @override
  String get onb_rerunHint => 'Name, language, who you are and look, step by step';

  @override
  String get social_tooFast => 'You\'re sending a bit fast — wait a moment and try again';

  @override
  String get social_daily => 'You\'ve reached today\'s limit. Please try again tomorrow.';

  @override
  String get social_newDevice => 'New devices are limited at first — try again in about 10 minutes';

  @override
  String get social_banned =>
      'Posting from this device is paused because its content got many reports';

  @override
  String social_bannedUntil(String time) {
    return 'Posting from this device is paused until $time because its content got many reports';
  }

  @override
  String get blocked_link => 'Please don\'t post links in public content';

  @override
  String get blocked_phone =>
      'Please don\'t put phone numbers in public content (to stop ads and scams)';

  @override
  String get blocked_contactAd =>
      'Please don\'t invite people to Zalo, Telegram or inbox in public content';

  @override
  String get blocked_spam => 'This looks like gambling or loan ads — it can\'t be posted';

  @override
  String get blocked_offensive => 'Please remove the offensive words';

  @override
  String get blocked_chars => 'Please don\'t repeat letters (e.g. \"goooood\")';

  @override
  String get blocked_shouting => 'Please turn off Caps Lock';

  @override
  String get blocked_impersonation =>
      'This name looks like the app\'s team — please choose another';

  @override
  String get blocked_repeat => 'You just sent exactly the same text';

  @override
  String get blocked_other => 'This content can\'t be posted — please edit it';
}
