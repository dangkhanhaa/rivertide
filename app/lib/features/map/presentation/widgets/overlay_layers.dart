import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/station_layers.dart';

/// Community layers over the base map, drawn in this order (last on top):
/// "đang câu" bubbles (P2-27), community spots (P2-19), trips (P2-26).
enum MapOverlayId { checkins, community, trips }

/// Points of one overlay: feature `id` = index into the caller's list.
/// Pins read `title`; bubbles read `people` and `biting`.
class MapOverlay {
  const MapOverlay({required this.geojson, required this.onTap});

  final Map<String, Object?> geojson;
  final ValueChanged<int> onTap;
}

/// Image ids of the pins (registered by the map widget).
const String communityPinImage = 'spot-pin';
const String tripPinImage = 'trip-pin';

String overlaySource(MapOverlayId id) => 'ov-${id.name}';
String overlayLayer(MapOverlayId id) => 'ov-${id.name}-dot';
String _labelLayer(MapOverlayId id) => 'ov-${id.name}-label';

/// The overlay a tapped layer belongs to, if any.
MapOverlayId? overlayOfLayer(String layerId) =>
    MapOverlayId.values.where((o) => overlayLayer(o) == layerId).firstOrNull;

const Map<String, Object?> emptyGeo = {'type': 'FeatureCollection', 'features': <Object>[]};

Future<void> addOverlayLayers(MapLibreMapController c, MarkerPalette p) async {
  for (final id in MapOverlayId.values) {
    await c.addGeoJsonSource(overlaySource(id), emptyGeo);
    switch (id) {
      case MapOverlayId.checkins:
        await _addBubbles(c, p, id);
      case MapOverlayId.community:
        await _addPins(c, p, id, communityPinImage);
      case MapOverlayId.trips:
        await _addPins(c, p, id, tripPinImage);
    }
  }
}

Future<void> _addPins(
  MapLibreMapController c,
  MarkerPalette p,
  MapOverlayId id,
  String image,
) async {
  await c.addSymbolLayer(
    overlaySource(id),
    overlayLayer(id),
    SymbolLayerProperties(
      iconImage: image,
      iconAnchor: 'bottom',
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ),
  );
  await c.addSymbolLayer(
    overlaySource(id),
    _labelLayer(id),
    SymbolLayerProperties(
      textField: ['get', 'title'],
      textFont: ['Noto Sans Regular'],
      textSize: 12,
      textOffset: [0, 0.4],
      textAnchor: 'top',
      textMaxWidth: 10,
      textColor: hexColor(p.label),
      textHaloColor: hexColor(p.labelHalo),
      textHaloWidth: 1.5,
      textOptional: true,
    ),
    minzoom: 12,
    enableInteraction: false,
  );
}

/// "N người đang câu": a round badge sized by people, brighter when someone
/// reports bites (the number is the text, so colour is never the only cue).
Future<void> _addBubbles(MapLibreMapController c, MarkerPalette p, MapOverlayId id) async {
  final fish = p.fish;
  await c.addCircleLayer(
    overlaySource(id),
    overlayLayer(id),
    CircleLayerProperties(
      circleColor: [
        'case',
        [
          '>',
          ['get', 'biting'],
          0,
        ],
        hexColor(fish.last),
        hexColor(fish[2]),
      ],
      circleRadius: [
        'interpolate',
        ['linear'],
        ['get', 'people'],
        1,
        13,
        10,
        22,
      ],
      circleOpacity: 0.9,
      circleStrokeWidth: 3,
      circleStrokeColor: hexColor(p.stroke),
    ),
  );
  await c.addSymbolLayer(
    overlaySource(id),
    _labelLayer(id),
    SymbolLayerProperties(
      textField: [
        'to-string',
        ['get', 'people'],
      ],
      textFont: ['Noto Sans Bold'],
      textSize: 13,
      textColor: hexColor(p.stroke),
      textAllowOverlap: true,
      textIgnorePlacement: true,
    ),
    enableInteraction: false,
  );
}
