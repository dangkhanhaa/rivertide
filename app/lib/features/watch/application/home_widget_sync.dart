import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/compute/heavy.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Hours of levels handed to the widget (it shows the current one by itself).
const int widgetHours = 48;

/// Android name of the home-screen widget provider (TideWidgetProvider.kt).
const String _androidName = 'TideWidgetProvider';

/// Hands the first saved place's next 48 h of levels and next highs/lows to
/// the Android home-screen widget. No-op elsewhere.
Future<void> syncHomeWidget(WidgetRef ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    final favs = await ref.read(appDatabaseProvider).watchFavorites().first;
    // Saved place first; without one, the user's own position (P2-35).
    final spot = ref.read(fishingSpotProvider);
    final first = favs.firstOrNull;
    final placeId = first?.stationId ?? (spot.mine ? spot.id : null);
    if (placeId == null) return await _clear();
    final repo = ref.read(stationRepositoryProvider);
    final station = await repo.getById(placeId);
    final tide = (await repo.getTide(station)).data;
    final p = tide.prediction;
    final now = ref.read(clockProvider)();
    final start = DateTime.utc(now.year, now.month, now.day, now.hour);
    final anchor = tide.anchor;
    final levels = [
      if (p != null)
        for (var h = 0; h <= widgetHours; h++)
          if (p.correctedLevelAt(
                start.add(Duration(hours: h)),
                obsTimeUtc: anchor?.timeUtc,
                obsLevelCm: anchor?.levelCm,
              )
              case final v?)
            [start.add(Duration(hours: h)).millisecondsSinceEpoch ~/ 1000, v.round()],
    ];
    final name = first?.label ?? (first == null ? null : station.name);
    await HomeWidget.saveWidgetData<String>('place', name ?? station.name);
    final weather = (await repo.getWeather(station)).data;
    final from = TimeFormat.vnDayStartUtc(now);
    final scored = (await runHeavy(
      () => scoreStationHours(tide: tide, weather: weather, fromDayUtc: from, days: 3),
    )).where((h) => !h.hourUtc.isBefore(start)).take(widgetHours).toList();
    await _saveFish(scored);
    await HomeWidget.saveWidgetData<String>('levels', jsonEncode(levels));
    await HomeWidget.saveWidgetData<String>('extremes', jsonEncode(_extremes(p, now)));
    await HomeWidget.updateWidget(androidName: _androidName);
  } on AppException catch (e) {
    log.info('home widget not updated', {'error': e.debugMessage});
  } on PlatformException catch (e) {
    log.info('home widget unavailable', {'error': '$e'});
  }
}

/// Empties the home-screen widget ("Xoá dữ liệu của tôi", P2-60). No-op
/// outside Android.
Future<void> clearHomeWidget() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await _clear();
  } on PlatformException catch (e) {
    log.info('home widget unavailable', {'error': '$e'});
  }
}

Future<void> _clear() async {
  for (final k in ['place', 'levels', 'extremes', 'fish', 'golden']) {
    await HomeWidget.saveWidgetData<String>(k, null);
  }
  await HomeWidget.updateWidget(androidName: _androidName);
}

List<List<Object>> _extremes(TideSeries? p, DateTime now) => [
  for (final e
      in p?.extremesBetween(now, now.add(const Duration(hours: widgetHours))) ??
          const <TideExtreme>[])
    [
      e.timeUtc.millisecondsSinceEpoch ~/ 1000,
      e.levelCm,
      if (e.kind == TideExtremeKind.high) 'H' else 'L',
    ],
];

/// Hourly fish scores + golden windows (48 h) so the widget shows
/// "Cá ăn: Cao · Giờ vàng 18:00–20:00" for the current time by itself.
Future<void> _saveFish(List<FishingHourScore> scored) async {
  final fish = [
    for (final h in scored) [h.hourUtc.millisecondsSinceEpoch ~/ 1000, h.score],
  ];
  final golden = [
    for (final w in goldenWindows(scored, maxCount: 6))
      [w.startUtc.millisecondsSinceEpoch ~/ 1000, w.endUtc.millisecondsSinceEpoch ~/ 1000],
  ];
  await HomeWidget.saveWidgetData<String>('fish', jsonEncode(fish));
  await HomeWidget.saveWidgetData<String>('golden', jsonEncode(golden));
}
