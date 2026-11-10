import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/data/flood_parser.dart';
import 'package:rivertide/features/stations/domain/river_flow.dart';

void main() {
  // Real Open-Meteo Flood response, 3×3 cells around the Hà Nội gauge (2026-11-10).
  final body = File('test/fixtures/flood_hanoi_3x3_20261110.json').readAsStringSync();

  test('picks the Red River main stem, not the canal cell at the gauge', () {
    final f = parseMainStemFlow(body)!;
    // The cell at the gauge itself (21.025, 105.875) is ~3 m³/s; main stem ≈ 2 170.
    expect((f.cellLat, f.cellLon), isNot((closeTo(21.025, 1e-3), closeTo(105.875, 1e-3))));
    final mean = f.days.map((d) => d.$2).reduce((a, b) => a + b) / f.days.length;
    expect(mean, greaterThan(1000));
    expect(f.on(DateTime.utc(2026, 11, 10, 9)), isNotNull);
  });

  test('trend thresholds', () {
    expect(flowTrend(1000, 1100), FlowTrend.rising);
    expect(flowTrend(1000, 900), FlowTrend.falling);
    expect(flowTrend(1000, 1030), FlowTrend.steady);
    expect(flowTrend(null, 1000), isNull);
  });

  test('no channel nearby → null; junk → ParseException', () {
    const noRiver =
        '[{"latitude":1,"longitude":1,"daily":{"time":["2026-11-10"],"river_discharge":[3.2]}}]';
    expect(parseMainStemFlow(noRiver), isNull);
    expect(() => parseMainStemFlow('nope'), throwsA(isA<ParseException>()));
    const negative =
        '[{"latitude":1,"longitude":1,"daily":{"time":["2026-11-10"],"river_discharge":[-5]}}]';
    expect(() => parseMainStemFlow(negative), throwsA(isA<ParseException>()));
  });
}
