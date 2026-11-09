import 'dart:math' as math;

import 'package:collection/collection.dart';

/// High or low water.
enum TideExtremeKind { high, low }

/// A predicted or observed turning point of the water level.
class TideExtreme {
  const TideExtreme({required this.timeUtc, required this.levelCm, required this.kind});

  final DateTime timeUtc;
  final int levelCm;
  final TideExtremeKind kind;
}

/// Regularly sampled tide prediction (PROJECT.md 8.5) with cubic interpolation.
class TideSeries {
  TideSeries({
    required this.startUtc,
    required this.stepMinutes,
    required List<int> levelsCm,
    required List<TideExtreme> extremes,
  }) : levelsCm = List.unmodifiable(levelsCm),
       extremes = List<TideExtreme>.unmodifiable(
         extremes.sorted((a, b) => a.timeUtc.compareTo(b.timeUtc)),
       ) {
    if (stepMinutes <= 0) throw ArgumentError.value(stepMinutes, 'stepMinutes');
    if (!startUtc.isUtc) throw ArgumentError.value(startUtc, 'startUtc', 'must be UTC');
  }

  final DateTime startUtc;
  final int stepMinutes;
  final List<int> levelsCm;
  final List<TideExtreme> extremes;

  DateTime get endUtc => startUtc.add(Duration(minutes: stepMinutes * (levelsCm.length - 1)));

  /// True when [t] can be interpolated (needs one sample on each side).
  bool covers(DateTime t) => levelsCm.length >= 2 && !t.isBefore(startUtc) && !t.isAfter(endUtc);

  double _position(DateTime t) =>
      t.difference(startUtc).inMilliseconds / (stepMinutes * Duration.millisecondsPerMinute);

  double _at(int i) => levelsCm[i.clamp(0, levelsCm.length - 1)].toDouble();

  /// Cubic Hermite (Catmull-Rom tangents) level at [t]; null outside coverage.
  double? levelAt(DateTime t) {
    if (!covers(t)) return null;
    final pos = _position(t);
    final i = math.min(pos.floor(), levelsCm.length - 2);
    final u = pos - i;
    final p0 = _at(i - 1);
    final p1 = _at(i);
    final p2 = _at(i + 1);
    final p3 = _at(i + 2);
    final m1 = (p2 - p0) / 2;
    final m2 = (p3 - p1) / 2;
    final u2 = u * u;
    final u3 = u2 * u;
    return (2 * u3 - 3 * u2 + 1) * p1 +
        (u3 - 2 * u2 + u) * m1 +
        (-2 * u3 + 3 * u2) * p2 +
        (u3 - u2) * m2;
  }

  /// Rate of change in cm per hour at [t]; null outside coverage.
  double? rateCmPerHAt(DateTime t) {
    if (!covers(t)) return null;
    final pos = _position(t);
    final i = math.min(pos.floor(), levelsCm.length - 2);
    final u = pos - i;
    final p0 = _at(i - 1);
    final p1 = _at(i);
    final p2 = _at(i + 1);
    final p3 = _at(i + 2);
    final m1 = (p2 - p0) / 2;
    final m2 = (p3 - p1) / 2;
    final u2 = u * u;
    final perStep =
        (6 * u2 - 6 * u) * p1 +
        (3 * u2 - 4 * u + 1) * m1 +
        (-6 * u2 + 6 * u) * p2 +
        (3 * u2 - 2 * u) * m2;
    return perStep * 60 / stepMinutes;
  }

  /// Joins consecutive yearly files; [next] must start exactly one step after this ends.
  TideSeries append(TideSeries next) {
    final expected = endUtc.add(Duration(minutes: stepMinutes));
    if (next.stepMinutes != stepMinutes || next.startUtc != expected) {
      throw ArgumentError('series are not contiguous');
    }
    return TideSeries(
      startUtc: startUtc,
      stepMinutes: stepMinutes,
      levelsCm: [...levelsCm, ...next.levelsCm],
      extremes: [...extremes, ...next.extremes],
    );
  }
}
