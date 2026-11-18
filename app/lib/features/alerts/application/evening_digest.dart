import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/features/alerts/data/alert_notifier.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';

/// Id of the 20:00 "Mai đi câu không?" notification (P2-35).
const int eveningDigestId = 990100;

/// Local hour of the summary.
const int eveningHour = 20;

/// Place the summary is about: the first place with alarms on, else the
/// first saved place, else the user's own position; null when none of these
/// is known (never a default place the user has nothing to do with).
Future<(String id, String? label)?> digestPlace(WidgetRef ref, List<String> alertIds) async {
  if (alertIds.isNotEmpty) return (alertIds.first, null);
  final favs = await ref.read(appDatabaseProvider).watchFavorites().first;
  if (favs.firstOrNull case final f?) return (f.stationId, f.label);
  final spot = ref.read(fishingSpotProvider);
  return spot.mine ? (spot.id, null) : null;
}

/// Schedules the next 20:00 summary about the following day's best golden
/// window. Rebuilt on every app start, like the other alarms.
Future<void> scheduleEveningDigest(
  WidgetRef ref,
  AlertNotifier notifier,
  AppLocalizations l10n,
  List<String> alertIds,
) async {
  final now = ref.read(clockProvider)();
  final today = TimeFormat.vnDayStartUtc(now);
  var at = today.add(const Duration(hours: eveningHour));
  if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
  final place0 = await digestPlace(ref, alertIds);
  if (place0 == null) return;
  final (id, label) = place0;
  final repo = ref.read(stationRepositoryProvider);
  final station = await repo.getById(id);
  final tide = (await repo.getTide(station)).data;
  final weather = (await repo.getWeather(station)).data;
  // The day after the notification, from its local midnight.
  final dayStart = TimeFormat.vnDayStartUtc(at).add(const Duration(days: 1));
  final hours = scoreStationHours(tide: tide, weather: weather, fromDayUtc: dayStart, days: 1);
  final best = goldenWindows(hours)
      .where(
        (w) => !hours.any(
          (h) =>
              h.safety != SafetyLevel.none &&
              !h.hourUtc.isBefore(w.startUtc) &&
              h.hourUtc.isBefore(w.endUtc),
        ),
      )
      .sortedBy<num>((w) => -w.peakScore)
      .firstOrNull;
  final place = label ?? (station.name.isEmpty ? l10n.spot_mine : station.name);
  final body = best == null
      ? l10n.digest_none
      : l10n.digest_body(
          '${TimeFormat.hm(best.startUtc)}–${TimeFormat.hm(best.endUtc)}',
          _band(l10n, best.peakScore),
          LevelFormat.decimal1(best.peakScore),
        );
  await notifier.schedule(
    id: eveningDigestId,
    atUtc: at,
    title: l10n.digest_title(place),
    body: body,
  );
}

String _band(AppLocalizations l, double score) => switch (fishActivity(score)) {
  FishActivity.low => l.fishAct_low,
  FishActivity.fair => l.fishAct_fair,
  FishActivity.high => l.fishAct_high,
  FishActivity.peak => l.fishAct_peak,
};
