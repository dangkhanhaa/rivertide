import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/tide/extreme_finder.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';

import 'tide_test_utils.dart';

void main() {
  final start = DateTime.utc(2026, 11);

  test('hourly M2 samples give extremes within 5 minutes of the true times', () {
    final levels = [for (var h = 0; h < 72; h++) m2LevelCm(start, start.add(Duration(hours: h)))];
    final ex = findExtremes(startUtc: start, stepMinutes: 60, levelsCm: levels);
    // Turning points at k·6.21 h for k = 1…11 (68.3 h < 71 h); the high at t=0 is an edge.
    expect(ex.length, 11);
    expect(ex.first.kind, TideExtremeKind.low);
    final trueLow = start.add(Duration(seconds: (m2Hours / 2 * 3600).round()));
    expect(ex.first.timeUtc.difference(trueLow).inMinutes.abs(), lessThanOrEqualTo(5));
    expect(ex.first.levelCm, closeTo(100, 2));
    for (var i = 1; i < ex.length; i++) {
      expect(ex[i].kind, isNot(ex[i - 1].kind), reason: 'highs and lows alternate');
    }
  });

  test('small wiggles below prominence are ignored', () {
    final levels = [for (var i = 0; i < 30; i++) 100.0 + (i.isEven ? 2 : 0)];
    expect(findExtremes(startUtc: start, stepMinutes: 60, levelsCm: levels), isEmpty);
  });

  test('flat top yields a single high', () {
    final levels = <double>[0, 20, 40, 60, 60, 40, 20, 0, 20, 40];
    final ex = findExtremes(startUtc: start, stepMinutes: 60, levelsCm: levels);
    expect(ex.where((e) => e.kind == TideExtremeKind.high).length, 1);
  });
}
