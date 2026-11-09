import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';

/// Measured accuracy of a prediction against observations (F-TIDE-09 "sai số 30 ngày qua").
class TideSkill {
  const TideSkill({
    required this.sampleCount,
    required this.rmseCm,
    required this.meanAbsErrorCm,
    required this.extremeCount,
    this.meanAbsExtremeTimeMin,
    this.meanAbsExtremeHeightCm,
  });

  final int sampleCount;
  final double rmseCm;
  final double meanAbsErrorCm;
  final int extremeCount;
  final double? meanAbsExtremeTimeMin;
  final double? meanAbsExtremeHeightCm;
}

const int _minHourlySamples = 24;
const Duration _matchWindow = Duration(hours: 3);
const int _extremeHalfWindowHours = 3;

/// Compares hourly observed means with the prediction at the same hours.
/// Returns null when there is too little overlap to say anything honest.
TideSkill? computeSkill(Map<DateTime, double> observedHourly, TideSeries prediction) {
  final errors = <double>[];
  observedHourly.forEach((t, obs) {
    final pred = prediction.levelAt(t);
    if (pred != null) errors.add(obs - pred);
  });
  if (errors.length < _minHourlySamples) return null;
  final pairs = _matchExtremes(observedHourly, prediction);
  return TideSkill(
    sampleCount: errors.length,
    rmseCm: math.sqrt(errors.map((e) => e * e).average),
    meanAbsErrorCm: errors.map((e) => e.abs()).average,
    extremeCount: pairs.length,
    meanAbsExtremeTimeMin: pairs.isEmpty ? null : pairs.map((p) => p.dtMin.abs()).average,
    meanAbsExtremeHeightCm: pairs.isEmpty ? null : pairs.map((p) => p.dhCm.abs()).average,
  );
}

/// For each predicted extreme inside the observed span, find the observed turning
/// point (parabola through the hourly max/min) within ±3 h.
List<({double dtMin, double dhCm})> _matchExtremes(
  Map<DateTime, double> observed,
  TideSeries prediction,
) {
  if (observed.isEmpty) return const [];
  final times = observed.keys.sorted((a, b) => a.compareTo(b));
  final first = times.first;
  final last = times.last;
  final out = <({double dtMin, double dhCm})>[];
  for (final e in prediction.extremes) {
    if (e.timeUtc.isBefore(first.add(_matchWindow)) ||
        e.timeUtc.isAfter(last.subtract(_matchWindow))) {
      continue;
    }
    final turn = _observedTurn(observed, e);
    if (turn == null) continue;
    final dt = turn.timeUtc.difference(e.timeUtc);
    if (dt.abs() <= _matchWindow) {
      out.add((dtMin: dt.inSeconds / 60, dhCm: turn.levelCm - e.levelCm));
    }
  }
  return out;
}

({DateTime timeUtc, double levelCm})? _observedTurn(Map<DateTime, double> observed, TideExtreme e) {
  final center = DateTime.utc(e.timeUtc.year, e.timeUtc.month, e.timeUtc.day, e.timeUtc.hour);
  final candidates = <DateTime, double>{};
  for (var k = -_extremeHalfWindowHours; k <= _extremeHalfWindowHours; k++) {
    final t = center.add(Duration(hours: k));
    final v = observed[t];
    if (v != null) candidates[t] = v;
  }
  if (candidates.length < 5) return null;
  final isHigh = e.kind == TideExtremeKind.high;
  final best = candidates.entries.reduce(
    (a, b) => (isHigh ? a.value >= b.value : a.value <= b.value) ? a : b,
  );
  final prev = observed[best.key.subtract(const Duration(hours: 1))];
  final next = observed[best.key.add(const Duration(hours: 1))];
  if (prev == null || next == null) return (timeUtc: best.key, levelCm: best.value);
  final denom = prev - 2 * best.value + next;
  final offset = denom == 0 ? 0.0 : (0.5 * (prev - next) / denom).clamp(-1.0, 1.0);
  final level = best.value - 0.25 * (prev - next) * offset;
  return (timeUtc: best.key.add(Duration(seconds: (offset * 3600).round())), levelCm: level);
}
