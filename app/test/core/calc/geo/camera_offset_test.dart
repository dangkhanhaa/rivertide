import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/geo/camera_offset.dart';

void main() {
  test('no offset → camera on the point', () {
    final c = cameraCenterFor(lat: 21, lon: 105.8, zoom: 11, dxPx: 0, dyPx: 0);
    expect(c.lat, 21);
    expect(c.lon, 105.8);
  });

  test('side panel on the right: camera moves east of the point', () {
    // Visible centre 210 px left of the view centre at zoom 11.
    final c = cameraCenterFor(lat: 21, lon: 105.8, zoom: 11, dxPx: 210, dyPx: 0);
    final degPerPx = 360 / (512 * math.pow(2, 11));
    expect(c.lon, closeTo(105.8 + 210 * degPerPx, 1e-9));
    expect(c.lat, 21);
  });

  test('bottom sheet: camera moves south so the point sits higher', () {
    final c = cameraCenterFor(lat: 21, lon: 105.8, zoom: 11, dxPx: 0, dyPx: 200);
    expect(c.lat, lessThan(21));
    expect(c.lon, 105.8);
  });

  test('one zoom level halves the shift', () {
    final a = cameraCenterFor(lat: 10, lon: 106, zoom: 10, dxPx: 100, dyPx: 0);
    final b = cameraCenterFor(lat: 10, lon: 106, zoom: 11, dxPx: 100, dyPx: 0);
    expect((a.lon - 106) / (b.lon - 106), closeTo(2, 1e-9));
  });
}
