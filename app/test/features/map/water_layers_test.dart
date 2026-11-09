import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';

void main() {
  test('finds river, lake and sea layers in the OpenFreeMap style, not labels', () {
    final ids = waterLayerIds(
      File('test/fixtures/openfreemap_liberty_20261109.json').readAsStringSync(),
    );
    expect(ids, containsAll(['water', 'waterway_river']));
    expect(ids, isNot(contains('waterway_other'))); // ditches would flag farmland
    expect(ids, isNot(contains('waterway_line_label')));
    expect(ids, isNot(contains('waterway_tunnel')));
  });

  test('URL fallback or junk → no layers (surface unknown)', () {
    expect(waterLayerIds('https://tiles.openfreemap.org/styles/liberty'), isEmpty);
    expect(waterLayerIds('{"layers": 3}'), isEmpty);
  });
}
