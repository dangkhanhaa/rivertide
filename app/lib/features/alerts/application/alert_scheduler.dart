import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/alerts/alert_plan.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/alerts/application/alert_settings.dart';
import 'package:rivertide/features/alerts/data/alert_notifier.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';

/// Alarm ids: place index × this + alarm index (< [maxAlertsPerPlace]).
const int _idsPerPlace = 100;

/// Replaces all scheduled tide alarms with fresh ones for the places that
/// have alarms on (called when the app opens and when a switch changes).
Future<void> rescheduleAlerts(WidgetRef ref) async {
  if (!AlertNotifier.supported) return;
  final l10n = lookupAppLocalizations(const Locale('vi'));
  final notifier = AlertNotifier(
    channelName: l10n.alert_channel,
    channelDescription: l10n.alert_channelHint,
  );
  final ids = (await ref.read(alertPlacesProvider.future)).toList()..sort();
  await notifier.cancelAll();
  if (ids.isEmpty) return;
  final db = ref.read(appDatabaseProvider);
  final names = {for (final f in await db.watchFavorites().first) f.stationId: ?f.label};
  final repo = ref.read(stationRepositoryProvider);
  final now = ref.read(clockProvider)();
  for (final (i, id) in ids.indexed) {
    try {
      final station = await repo.getById(id);
      final tide = (await repo.getTide(station)).data;
      final weather = (await repo.getWeather(station)).data;
      final hours = scoreStationHours(tide: tide, weather: weather, fromDayUtc: now);
      final windows = [for (final day in hours.slices(24)) ...goldenWindows(day)];
      final plan = planAlerts(
        nowUtc: now,
        lead: alertLead,
        extremes: tide.prediction?.extremes ?? const [],
        windows: windows,
      );
      final place = names[id] ?? station.name;
      for (final (n, a) in plan.indexed) {
        final (title, body) = _text(l10n, place, a);
        await notifier.schedule(id: i * _idsPerPlace + n, atUtc: a.atUtc, title: title, body: body);
      }
    } on AppException catch (e) {
      log.info('alerts: one place skipped', {'error': e.debugMessage});
    }
  }
}

(String, String) _text(AppLocalizations l10n, String place, PlannedAlert a) {
  final mins = alertLead.inMinutes;
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
      l10n.alert_fishBody(LevelFormat.decimal1(a.score ?? 0), mins),
    ),
  };
}
