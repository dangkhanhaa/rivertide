import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
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
    final first = favs.firstOrNull;
    if (first == null) {
      await HomeWidget.saveWidgetData<String>('place', null);
      await HomeWidget.saveWidgetData<String>('levels', null);
      await HomeWidget.saveWidgetData<String>('extremes', null);
      await HomeWidget.updateWidget(androidName: _androidName);
      return;
    }
    final repo = ref.read(stationRepositoryProvider);
    final station = await repo.getById(first.stationId);
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
    final extremes = [
      for (final e
          in p?.extremesBetween(now, now.add(const Duration(hours: widgetHours))) ??
              const <TideExtreme>[])
        [
          e.timeUtc.millisecondsSinceEpoch ~/ 1000,
          e.levelCm,
          if (e.kind == TideExtremeKind.high) 'H' else 'L',
        ],
    ];
    await HomeWidget.saveWidgetData<String>('place', first.label ?? station.name);
    await HomeWidget.saveWidgetData<String>('levels', jsonEncode(levels));
    await HomeWidget.saveWidgetData<String>('extremes', jsonEncode(extremes));
    await HomeWidget.updateWidget(androidName: _androidName);
  } on AppException catch (e) {
    log.info('home widget not updated', {'error': e.debugMessage});
  } on PlatformException catch (e) {
    log.info('home widget unavailable', {'error': '$e'});
  }
}
