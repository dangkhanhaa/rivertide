import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/features/map/domain/river_reach_geojson.dart';
import 'package:rivertide/features/stations/data/rivers_parser.dart';

void main() {
  final rivers = parseRivers(File('assets/data/rivers.json').readAsStringSync());

  test('reach segments: only within range of a station, firmer near it', () {
    final g = riverReachGeoJson(rivers);
    final features = (g['features']! as List<Object?>).cast<Map<String, Object?>>();
    expect(features, isNotEmpty);
    final conf = [
      for (final f in features) (f['properties']! as Map<String, Object?>)['conf']! as double,
    ];
    expect(conf.every((c) => c > 0 && c <= 1), isTrue);
    expect(conf.reduce((a, b) => a > b ? a : b), greaterThan(0.95)); // a segment at the gauge
  });

  test('thousands separator', () {
    expect(LevelFormat.thousands(1790), '1.790');
    expect(LevelFormat.thousands(12345678), '12.345.678');
    expect(LevelFormat.thousands(999), '999');
  });
}
