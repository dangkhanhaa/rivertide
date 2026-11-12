import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/alerts/alert_plan.dart';
import 'package:rivertide/core/calc/fishing/catch_patterns.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/alerts/application/alert_settings.dart';
import 'package:rivertide/features/alerts/data/alert_notifier.dart';
import 'package:rivertide/features/journal/journal.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';

/// Alarm ids: place index × this + alarm index (< [maxAlertsPerPlace]).
const int _idsPerPlace = 100;

/// Replaces all scheduled alarms with fresh ones for the places that have
/// alarms on (called when the app opens and when a switch or option changes).
Future<void> rescheduleAlerts(WidgetRef ref) async {
  if (!AlertNotifier.supported) return;
  final l10n = lookupAppLocalizations(const Locale('vi'));
  final notifier = AlertNotifier(
    channelName: l10n.alert_channel,
    channelDescription: l10n.alert_channelHint,
  );
  final ids = (await ref.read(alertPlacesProvider.future)).toList()..sort();
  final options = await ref.read(alertOptionsProvider.future);
  await notifier.cancelAll();
  if (ids.isEmpty || (!options.golden && !options.tides)) return;
  final db = ref.read(appDatabaseProvider);
  final names = {for (final f in await db.watchFavorites().first) f.stationId: ?f.label};
  final patterns = patternsOf(await db.watchCatches().first);
  final now = ref.read(clockProvider)();
  for (final (i, id) in ids.indexed) {
    try {
      final plan = await _planFor(ref, id, now, options, patterns);
      final place = names[id] ?? plan.name;
      for (final (n, a) in plan.alerts.indexed) {
        final (title, body) = _text(l10n, place, a, options, like: plan.like.contains(a));
        await notifier.schedule(id: i * _idsPerPlace + n, atUtc: a.atUtc, title: title, body: body);
      }
    } on AppException catch (e) {
      log.info('alerts: one place skipped', {'error': e.debugMessage});
    }
  }
}

typedef _Plan = ({String name, List<PlannedAlert> alerts, Set<PlannedAlert> like});

Future<_Plan> _planFor(
  WidgetRef ref,
  String id,
  DateTime now,
  AlertOptions options,
  PatternReport patterns,
) async {
  final repo = ref.read(stationRepositoryProvider);
  final station = await repo.getById(id);
  final tide = (await repo.getTide(station)).data;
  final weather = (await repo.getWeather(station)).data;
  // From the start of today (whole hours), so each hour meets its weather row.
  final hours = scoreStationHours(
    tide: tide,
    weather: weather,
    fromDayUtc: TimeFormat.vnDayStartUtc(now),
  );
  // Only windows with no weather warning inside them (P2-22).
  final windows = [
    for (final day in hours.slices(24))
      for (final w in goldenWindows(day))
        if (!_unsafe(hours, w)) w,
  ];
  final plan = planAlerts(
    nowUtc: now,
    lead: options.lead,
    extremes: options.tides ? tide.prediction?.extremes ?? const [] : const [],
    windows: options.golden ? windows : const [],
  );
  final like = {
    for (final a in plan)
      if (a.kind == AlertKind.goodFishing &&
          looksLikeYourCatches(patterns, placeConditionsAt(tide, weather, a.eventUtc)))
        a,
  };
  return (name: station.name, alerts: plan, like: like);
}

bool _unsafe(List<FishingHourScore> hours, GoldenWindow w) => hours.any(
  (h) =>
      h.safety != SafetyLevel.none &&
      !h.hourUtc.isBefore(w.startUtc) &&
      h.hourUtc.isBefore(w.endUtc),
);

(String, String) _text(
  AppLocalizations l10n,
  String place,
  PlannedAlert a,
  AlertOptions options, {
  required bool like,
}) {
  final mins = options.leadMinutes;
  final at = TimeFormat.hm(a.eventUtc);
  return switch (a.kind) {
    AlertKind.high => (
      l10n.alert_highTitle(place, at),
      l10n.alert_levelBody(LevelFormat.meters(a.levelCm ?? 0), mins),
    ),
    AlertKind.low => (
      l10n.alert_lowTitle(place, at),
      l10n.alert_levelBody(LevelFormat.meters(a.levelCm ?? 0), mins),
    ),
    AlertKind.goodFishing => (
      l10n.alert_fishTitle(place, at, TimeFormat.hm(a.endUtc ?? a.eventUtc)),
      like
          ? l10n.alert_fishBodyLike(LevelFormat.decimal1(a.score ?? 0), mins)
          : l10n.alert_fishBody(LevelFormat.decimal1(a.score ?? 0), mins),
    ),
  };
}
