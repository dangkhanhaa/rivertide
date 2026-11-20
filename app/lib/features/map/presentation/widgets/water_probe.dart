import 'dart:ui';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';

/// Water the base map draws at a tap (P2-47): the kind under it, a lagoon
/// name when a "lake" is labelled as one nearby, and for land the water
/// around it. [waterIds]/[nameIds] are the style's water and water-label
/// layers ([waterLayerIds], [waterNameLayerIds]).
Future<TapWater> probeWater(
  MapLibreMapController c, {
  required List<String> waterIds,
  required List<String> nameIds,
  required Offset at,
  required LatLng position,
}) async {
  final zoom = c.cameraPosition?.zoom ?? 0;
  final (lat, lon) = (position.latitude, position.longitude);
  Rect box(double half) => Rect.fromCenter(center: at, width: half * 2, height: half * 2);
  final hits = await c.queryRenderedFeaturesInRect(box(tapSlopPx), waterIds, null);
  final tap = classifyTap(hits, lat: lat, lon: lon, zoom: zoom);
  if (tap.kind == WaterKind.lake && nameIds.isNotEmpty) {
    final labels = await c.queryRenderedFeaturesInRect(box(lagoonLabelPx), nameIds, null);
    if (lagoonLabel(labels) case final name?) {
      return TapWater(kind: WaterKind.lagoon, name: name, inArea: true);
    }
  }
  if (tap.kind != WaterKind.land) return tap;
  final r = (nearbySearchM / metersPerPixel(lat, zoom)).clamp(tapSlopPx * 2, 160.0);
  final around = await c.queryRenderedFeaturesInRect(box(r), waterIds, null);
  return TapWater(
    kind: WaterKind.land,
    nearby: nearbyWater(around, lat: lat, lon: lon),
  );
}
