import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';

/// Minimum hour score for a golden window (PROJECT.md 9.6).
const double goldenWindowThreshold = 7;

/// Gaps shorter than this between good hours are merged.
const Duration goldenWindowMergeGap = Duration(minutes: 30);

/// Maximum number of windows shown.
const int goldenWindowMaxCount = 3;

class GoldenWindow {
  const GoldenWindow({
    required this.startUtc,
    required this.endUtc,
    required this.peakScore,
    required this.reasons,
  });

  final DateTime startUtc;

  /// Exclusive end (start of the hour after the last good hour).
  final DateTime endUtc;
  final double peakScore;

  /// Positive factors of the peak hour, heaviest weight first.
  final List<FishingFactor> reasons;
}

/// Contiguous runs of S ≥ 7.0 (each score covers [hourUtc, hourUtc + [slot])),
/// merged when separated by < 30 min; best 3 by peak, sorted by start.
List<GoldenWindow> goldenWindows(
  List<FishingHourScore> hours, {
  Duration slot = const Duration(hours: 1),
  int maxCount = goldenWindowMaxCount,
}) {
  final good = hours.where((h) => h.score >= goldenWindowThreshold).toList()
    ..sort((a, b) => a.hourUtc.compareTo(b.hourUtc));
  final groups = <List<FishingHourScore>>[];
  for (final hour in good) {
    final current = groups.lastOrNull;
    final lastEnd = current?.last.hourUtc.add(slot);
    if (current != null &&
        lastEnd != null &&
        hour.hourUtc.difference(lastEnd) < goldenWindowMergeGap) {
      current.add(hour);
    } else {
      groups.add([hour]);
    }
  }
  final windows = groups.map((g) => _toWindow(g, slot)).toList()
    ..sort((a, b) {
      final byPeak = b.peakScore.compareTo(a.peakScore);
      return byPeak != 0 ? byPeak : a.startUtc.compareTo(b.startUtc);
    });
  return windows.take(maxCount).sortedBy((w) => w.startUtc);
}

GoldenWindow _toWindow(List<FishingHourScore> group, Duration slot) {
  // Strict `>` keeps the earliest hour on ties.
  final peak = group.reduce((a, b) => b.score > a.score ? b : a);
  return GoldenWindow(
    startUtc: group.first.hourUtc,
    endUtc: group.last.hourUtc.add(slot),
    peakScore: peak.score,
    reasons: peak.positiveFactors,
  );
}

/// Day score (fs-2): half the best 3 hours, half the typical (median) hour,
/// 1 decimal; 0 when no hours. fs-1 used only the top 4 hours, so almost
/// every day came out "good" — the median adds how good the rest of the day is.
double dayScore(List<FishingHourScore> hoursOfDay) {
  if (hoursOfDay.isEmpty) return 0;
  final sorted = hoursOfDay.map((h) => h.score).sorted((a, b) => b.compareTo(a));
  final top = sorted.take(3).average;
  final n = sorted.length;
  final median = n.isOdd ? sorted[n ~/ 2] : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
  return roundTo1((top + median) / 2);
}
