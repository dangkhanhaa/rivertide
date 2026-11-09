import 'dart:math' as math;

/// MapLibre zoom levels count 512-px tiles.
const double _tilePx = 512;

/// Camera centre that puts ([lat], [lon]) at a point [dxPx] left of and [dyPx]
/// above the view centre — i.e. in the middle of the part of the map not
/// covered by a side panel or bottom sheet. Pixels are logical; local
/// Web-Mercator approximation, exact enough for a few hundred pixels.
({double lat, double lon}) cameraCenterFor({
  required double lat,
  required double lon,
  required double zoom,
  required double dxPx,
  required double dyPx,
}) {
  final degPerPx = 360 / (_tilePx * math.pow(2, zoom));
  final cosLat = math.cos(lat * math.pi / 180);
  return (lat: (lat - dyPx * degPerPx * cosLat).clamp(-85.0, 85.0), lon: lon + dxPx * degPerPx);
}
