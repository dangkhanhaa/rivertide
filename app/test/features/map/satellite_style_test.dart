import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/map/data/map_style_source.dart';
import 'package:rivertide/features/map/data/satellite_style.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';

void main() {
  final vector = localizeStyle(
    File('test/fixtures/openfreemap_liberty_20261109.json').readAsStringSync(),
  );

  test('imagery at the bottom, Vietnamese labels and borders on top', () {
    final style = jsonDecode(satelliteStyle(vector)) as Map<String, Object?>;
    final layers = (style['layers']! as List<Object?>).cast<Map<String, Object?>>();
    expect(layers.first['id'], 'satellite');
    final src = (style['sources']! as Map<String, Object?>)['satellite']! as Map<String, Object?>;
    expect((src['tiles']! as List<Object?>).single, satelliteTiles);
    expect(src['attribution'], contains('EOX'));
    final city = layers.firstWhere((l) => l['id'] == 'label_city');
    expect(jsonEncode(city['layout']), contains('name:vi'));
    expect(layers.any((l) => (l['id']! as String).startsWith('boundary')), isTrue);
    // No opaque land/road fills hide the imagery.
    expect(layers.where((l) => l['type'] == 'fill' && l['source-layer'] != 'water'), isEmpty);
  });

  test('water stays queryable but invisible', () {
    final out = satelliteStyle(vector);
    expect(waterLayerIds(out), contains('water'));
    final decoded = jsonDecode(out) as Map<String, Object?>;
    final water = (decoded['layers']! as List<Object?>).cast<Map<String, Object?>>().firstWhere(
      (l) => l['id'] == 'water',
    );
    expect(water['paint'], {'fill-opacity': 0});
  });

  test('a URL fallback cannot be turned into a hybrid', () {
    expect(() => satelliteStyle(openFreeMapLight), throwsA(isA<ParseException>()));
  });
}
