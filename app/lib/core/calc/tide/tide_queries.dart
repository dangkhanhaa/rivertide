import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';

/// Bias from the latest observation fades to zero over this horizon (PROJECT.md 9.1).
const Duration correctionHorizon = Duration(hours: 12);
const int _springNeapWindowDays = 14;

/// UTC instant of local midnight for a calendar day at [tzOffsetHours].
DateTime localDayStartUtc(int year, int month, int day, {double tzOffsetHours = 7}) =>
    DateTime.utc(year, month, day).subtract(Duration(minutes: (tzOffsetHours * 60).round()));

extension TideQueries on TideSeries {
  TideExtreme? nextExtreme(DateTime t) => extremes.firstWhereOrNull((e) => e.timeUtc.isAfter(t));

  TideExtreme? previousExtreme(DateTime t) =>
      extremes.lastWhereOrNull((e) => !e.timeUtc.isAfter(t));

  /// Extremes with fromUtc <= time < toUtc.
  List<TideExtreme> extremesBetween(DateTime fromUtc, DateTime toUtc) => extremes
      .where((e) => !e.timeUtc.isBefore(fromUtc) && e.timeUtc.isBefore(toUtc))
      .toList(growable: false);

  Duration? countdownToNext(DateTime t) => nextExtreme(t)?.timeUtc.difference(t);

  /// Within ±10 minutes of a high or low (AC-TIDE02-4).
  bool isTurning(DateTime t) => extremes.any((e) => e.timeUtc.difference(t).abs() <= turningWindow);

  TideState? stateAt(DateTime t) {
    final rate = rateCmPerHAt(t);
    return rate == null ? null : classifyRate(rate);
  }

  /// Highest high minus lowest low in the 24 h starting at [dayStartUtc].
  int? dailyRangeCm(DateTime dayStartUtc) {
    final day = extremesBetween(dayStartUtc, dayStartUtc.add(const Duration(days: 1)));
    final highs = day.where((e) => e.kind == TideExtremeKind.high).map((e) => e.levelCm);
    final lows = day.where((e) => e.kind == TideExtremeKind.low).map((e) => e.levelCm);
    if (highs.isEmpty || lows.isEmpty) return null;
    return highs.max - lows.min;
  }

  /// Spring/neap vs the mean daily range of the surrounding 29 days.
  SpringNeap? springNeapAt(DateTime dayStartUtc) {
    final range = dailyRangeCm(dayStartUtc);
    if (range == null) return null;
    final ranges = <int>[];
    for (var d = -_springNeapWindowDays; d <= _springNeapWindowDays; d++) {
      final r = dailyRangeCm(dayStartUtc.add(Duration(days: d)));
      if (r != null) ranges.add(r);
    }
    if (ranges.length < 7) return null; // too little context to judge
    final mean = ranges.average;
    if (mean <= 0) return null;
    final ratio = range / mean;
    if (ratio >= 1.2) return SpringNeap.spring;
    if (ratio <= 0.8) return SpringNeap.neap;
    return SpringNeap.normal;
  }

  /// Prediction nudged by the latest observation (F-TIDE-07).
  double? correctedLevelAt(DateTime t, {DateTime? obsTimeUtc, double? obsLevelCm}) {
    final predicted = levelAt(t);
    if (predicted == null || obsTimeUtc == null || obsLevelCm == null) return predicted;
    final predAtObs = levelAt(obsTimeUtc);
    if (predAtObs == null || t.isBefore(obsTimeUtc)) return predicted;
    final elapsed = t.difference(obsTimeUtc).inSeconds / correctionHorizon.inSeconds;
    if (elapsed >= 1) return predicted;
    return predicted + (obsLevelCm - predAtObs) * (1 - elapsed);
  }
}
