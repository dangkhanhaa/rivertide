import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';

enum AlertKind { high, low, goodFishing }

/// One reminder to schedule: [atUtc] = [eventUtc] − lead.
class PlannedAlert {
  const PlannedAlert({
    required this.kind,
    required this.atUtc,
    required this.eventUtc,
    this.levelCm,
    this.endUtc,
    this.score,
  });

  final AlertKind kind;
  final DateTime atUtc;
  final DateTime eventUtc;
  final double? levelCm;

  /// End of a good-fishing window.
  final DateTime? endUtc;
  final double? score;
}

/// Days ahead that get reminders (rescheduled each time the app opens).
const Duration alertHorizon = Duration(days: 7);

/// Per place, so a long list never hits the OS alarm limit (~500).
const int maxAlertsPerPlace = 40;

/// Reminders [lead] before each high/low and each good fishing window in the
/// next [alertHorizon], skipping those whose reminder time already passed.
List<PlannedAlert> planAlerts({
  required DateTime nowUtc,
  required Duration lead,
  List<TideExtreme> extremes = const [],
  List<GoldenWindow> windows = const [],
}) {
  final until = nowUtc.add(alertHorizon);
  bool soon(DateTime at, DateTime event) => at.isAfter(nowUtc) && event.isBefore(until);
  final out = <PlannedAlert>[
    for (final e in extremes)
      if (soon(e.timeUtc.subtract(lead), e.timeUtc))
        PlannedAlert(
          kind: e.kind == TideExtremeKind.high ? AlertKind.high : AlertKind.low,
          atUtc: e.timeUtc.subtract(lead),
          eventUtc: e.timeUtc,
          levelCm: e.levelCm.toDouble(),
        ),
    for (final w in windows)
      if (soon(w.startUtc.subtract(lead), w.startUtc))
        PlannedAlert(
          kind: AlertKind.goodFishing,
          atUtc: w.startUtc.subtract(lead),
          eventUtc: w.startUtc,
          endUtc: w.endUtc,
          score: w.peakScore,
        ),
  ]..sort((a, b) => a.atUtc.compareTo(b.atUtc));
  return out.take(maxAlertsPerPlace).toList();
}
