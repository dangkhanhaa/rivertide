import 'package:collection/collection.dart';

/// One measured water level.
class WaterObservation {
  const WaterObservation({required this.timeUtc, required this.levelCm});

  final DateTime timeUtc;
  final double levelCm;
}

/// Half-width of the averaging window around each hour (F-TIDE-09: 10-minute mean).
const Duration hourlyMeanHalfWindow = Duration(minutes: 5);

/// Minimum samples inside the window to trust a mean (1-min data → 10 per window).
const int minSamplesPerHourlyMean = 3;

/// Mean level around each whole UTC hour from [fromUtc] to [toUtc] inclusive.
/// Hours without enough samples are omitted (shown as gaps, never invented).
Map<DateTime, double> hourlyMeans(
  List<WaterObservation> observations,
  DateTime fromUtc,
  DateTime toUtc, {
  // Pre-binned 10-minute means need only the one bin centred on the hour.
  int minSamples = minSamplesPerHourlyMean,
}) {
  final sorted = observations.sortedBy((o) => o.timeUtc);
  final result = <DateTime, double>{};
  var cursor = DateTime.utc(fromUtc.year, fromUtc.month, fromUtc.day, fromUtc.hour);
  var startIdx = 0;
  while (!cursor.isAfter(toUtc)) {
    final lo = cursor.subtract(hourlyMeanHalfWindow);
    final hi = cursor.add(hourlyMeanHalfWindow);
    while (startIdx < sorted.length && sorted[startIdx].timeUtc.isBefore(lo)) {
      startIdx++;
    }
    final window = <double>[];
    for (var i = startIdx; i < sorted.length && sorted[i].timeUtc.isBefore(hi); i++) {
      window.add(sorted[i].levelCm);
    }
    if (window.length >= minSamples) result[cursor] = window.average;
    cursor = cursor.add(const Duration(hours: 1));
  }
  return result;
}

/// Latest observation, or null when empty.
WaterObservation? latestObservation(List<WaterObservation> observations) => observations.isEmpty
    ? null
    : observations.reduce((a, b) => a.timeUtc.isAfter(b.timeUtc) ? a : b);
