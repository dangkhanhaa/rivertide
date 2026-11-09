import 'package:rivertide/core/calc/tide/extreme_finder.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

/// Measured in P0-05 at Vũng Tàu over 30 days (docs/tide-validation.md); other points
/// are unverified, hence "medium" rather than "high".
const openMeteoMarineModel = TideModelInfo(
  sourceName: 'Open-Meteo Marine',
  confidence: TideConfidence.medium,
);

/// Builds an hourly [TideSeries] from Open-Meteo Marine; keeps the longest run without
/// gaps (the model returns null over land or outside its grid). Null if < 24 h usable.
TideSeries? marineToSeries(List<(DateTime, double?)> hourly) {
  var bestStart = 0;
  var bestLen = 0;
  var runStart = 0;
  for (var i = 0; i <= hourly.length; i++) {
    final isGap = i == hourly.length || hourly[i].$2 == null;
    if (!isGap) continue;
    if (i - runStart > bestLen) {
      bestStart = runStart;
      bestLen = i - runStart;
    }
    runStart = i + 1;
  }
  if (bestLen < 24) return null;
  final run = hourly.sublist(bestStart, bestStart + bestLen);
  final levels = [for (final r in run) r.$2 ?? 0.0]; // run has no nulls by construction
  final start = run.first.$1;
  return TideSeries(
    startUtc: start,
    stepMinutes: 60,
    levelsCm: [for (final v in levels) v.round()],
    extremes: findExtremes(startUtc: start, stepMinutes: 60, levelsCm: levels),
  );
}
