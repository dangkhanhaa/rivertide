import 'dart:math' as math;

import 'package:rivertide/core/calc/tide/tide_series.dart';

const double m2Hours = 12.4206012;

/// Pure M2 cosine: mean 200 cm, amplitude 100 cm, high water at [start].
double m2LevelCm(DateTime start, DateTime t) {
  final hours = t.difference(start).inSeconds / 3600;
  return 200 + 100 * math.cos(2 * math.pi * hours / m2Hours);
}

TideSeries syntheticM2({int days = 40, DateTime? start}) {
  final s = start ?? DateTime.utc(2026, 11);
  final steps = days * 144;
  final levels = [
    for (var i = 0; i < steps; i++) m2LevelCm(s, s.add(Duration(minutes: 10 * i))).round(),
  ];
  final extremes = <TideExtreme>[];
  for (var k = 0; k * m2Hours / 2 < days * 24; k++) {
    extremes.add(
      TideExtreme(
        timeUtc: s.add(Duration(seconds: (k * m2Hours / 2 * 3600).round())),
        levelCm: k.isEven ? 300 : 100,
        kind: k.isEven ? TideExtremeKind.high : TideExtremeKind.low,
      ),
    );
  }
  return TideSeries(startUtc: s, stepMinutes: 10, levelsCm: levels, extremes: extremes);
}
