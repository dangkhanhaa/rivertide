import 'dart:math' as math;

import 'package:rivertide/core/calc/tide/tide_series.dart';

/// Ignore wiggles smaller than this (cm) when picking highs/lows.
const double minProminenceCm = 5;

/// Highs and lows of a regularly sampled series, with parabolic refinement so the
/// time is not snapped to the sampling step (needed for hourly model data).
List<TideExtreme> findExtremes({
  required DateTime startUtc,
  required int stepMinutes,
  required List<double> levelsCm,
}) {
  final out = <TideExtreme>[];
  final reach = math.max(1, (120 / stepMinutes).round()); // ±2 h neighbourhood
  for (var i = 1; i < levelsCm.length - 1; i++) {
    final kind = _localKind(levelsCm, i, reach);
    if (kind == null || !_isProminent(levelsCm, i, kind, reach * 3)) continue;
    if (out.isNotEmpty && out.last.kind == kind) continue; // plateau duplicate
    out.add(_refine(startUtc, stepMinutes, levelsCm, i, kind));
  }
  return out;
}

TideExtremeKind? _localKind(List<double> y, int i, int reach) {
  final from = math.max(0, i - reach);
  final to = math.min(y.length - 1, i + reach);
  var isMax = true;
  var isMin = true;
  for (var j = from; j <= to; j++) {
    if (j == i) continue;
    // Ties count only on the right so a flat top yields one extreme.
    if (j < i ? y[j] >= y[i] : y[j] > y[i]) isMax = false;
    if (j < i ? y[j] <= y[i] : y[j] < y[i]) isMin = false;
  }
  if (isMax) return TideExtremeKind.high;
  if (isMin) return TideExtremeKind.low;
  return null;
}

bool _isProminent(List<double> y, int i, TideExtremeKind kind, int reach) {
  final left = y.sublist(math.max(0, i - reach), i);
  final right = y.sublist(i + 1, math.min(y.length, i + reach + 1));
  if (left.isEmpty || right.isEmpty) return false;
  final isHigh = kind == TideExtremeKind.high;
  double drop(List<double> side) =>
      isHigh ? y[i] - side.reduce(math.min) : side.reduce(math.max) - y[i];
  return drop(left) >= minProminenceCm && drop(right) >= minProminenceCm;
}

TideExtreme _refine(DateTime start, int step, List<double> y, int i, TideExtremeKind kind) {
  final denom = y[i - 1] - 2 * y[i] + y[i + 1];
  final offset = denom == 0 ? 0.0 : (0.5 * (y[i - 1] - y[i + 1]) / denom).clamp(-1.0, 1.0);
  final level = y[i] - 0.25 * (y[i - 1] - y[i + 1]) * offset;
  final seconds = ((i + offset) * step * 60).round();
  return TideExtreme(
    timeUtc: start.add(Duration(seconds: seconds)),
    levelCm: level.round(),
    kind: kind,
  );
}
