import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';

/// Dangers at a place in the hours ahead (F-SAFE-01), most serious first.
enum HazardKind {
  /// Thunderstorm forecast (WMO 95/96/99): lightning over open water.
  thunderstorm,

  /// Gusts above 50 km/h.
  strongGust,

  /// Rain above 20 mm/h.
  heavyRain,

  /// Unstable air with rain likely: storms can build.
  possibleThunderstorm,

  /// Water rising fast now AND much faster than in the past days — tides that
  /// rise 70 cm/h every day at Vũng Tàu are normal, not a warning.
  waterRisingFast,

  /// River discharge up sharply from today to tomorrow: rain upstream, flood.
  floodComing,
}

class Hazard {
  const Hazard({required this.kind, this.fromUtc, this.toUtc});

  final HazardKind kind;

  /// First and last forecast hour it applies to; null for "now"/"tomorrow".
  final DateTime? fromUtc;
  final DateTime? toUtc;

  /// Thunderstorm and gusts: get off the water.
  bool get isSevere => kind == HazardKind.thunderstorm || kind == HazardKind.strongGust;
}

/// Hours ahead that count for a warning.
const Duration hazardHorizon = Duration(hours: 12);

/// Discharge growth (tomorrow vs today) treated as a flood coming.
const double floodGrowthShare = 0.3;

/// How much faster than the past days' fastest rise counts as abnormal.
const double abnormalRiseFactor = 1.5;

/// True when [p] rises ≥ 20 cm/h at [nowUtc] and faster than
/// [abnormalRiseFactor] × the fastest rise of the previous 3 days.
bool risingAbnormally(TideSeries p, DateTime nowUtc) {
  final rate = p.rateCmPerHAt(nowUtc);
  if (rate == null || rate < fastThresholdCmPerH) return false;
  var maxPast = 0.0;
  for (var h = 72; h >= 6; h--) {
    final r = p.rateCmPerHAt(nowUtc.subtract(Duration(hours: h)));
    if (r != null && r > maxPast) maxPast = r;
  }
  return maxPast <= 0 || rate > abnormalRiseFactor * maxPast;
}

List<Hazard> hazardsAhead({
  required DateTime nowUtc,
  required List<FishingHourScore> hours,
  bool waterRisingFast = false,
  double? flowTodayM3s,
  double? flowTomorrowM3s,
}) {
  final from = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, nowUtc.hour);
  final until = nowUtc.add(hazardHorizon);
  final spans = <HazardKind, (DateTime, DateTime)>{};
  for (final h in hours) {
    if (h.hourUtc.isBefore(from) || h.hourUtc.isAfter(until)) continue;
    for (final r in h.safetyReasons) {
      final kind = switch (r) {
        SafetyReason.thunderstorm => HazardKind.thunderstorm,
        SafetyReason.strongGust => HazardKind.strongGust,
        SafetyReason.heavyRain => HazardKind.heavyRain,
        SafetyReason.possibleThunderstorm => HazardKind.possibleThunderstorm,
      };
      final span = spans[kind];
      spans[kind] = span == null ? (h.hourUtc, h.hourUtc) : (span.$1, h.hourUtc);
    }
  }
  final today = flowTodayM3s;
  final tomorrow = flowTomorrowM3s;
  final out = [
    for (final e in spans.entries) Hazard(kind: e.key, fromUtc: e.value.$1, toUtc: e.value.$2),
    if (waterRisingFast) const Hazard(kind: HazardKind.waterRisingFast),
    if (today != null &&
        tomorrow != null &&
        today > 0 &&
        (tomorrow - today) / today >= floodGrowthShare)
      const Hazard(kind: HazardKind.floodComing),
  ];
  // A real storm makes "possible storm" redundant.
  if (spans.containsKey(HazardKind.thunderstorm)) {
    out.removeWhere((h) => h.kind == HazardKind.possibleThunderstorm);
  }
  return out..sort((a, b) => a.kind.index.compareTo(b.kind.index));
}
