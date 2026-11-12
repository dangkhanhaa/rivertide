import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/community_layer.dart';
import 'package:rivertide/features/map/presentation/widgets/river_flow_layer.dart';
import 'package:rivertide/features/map/presentation/widgets/weather_map_layer.dart';

const stationSourceId = 'stations';
const stationDotsLayerId = 'station-dots';
const clusterLayerId = 'station-clusters';
const meSourceId = 'me';
const riverReachSourceId = 'river-reach';
const pinSourceId = 'pin';
const _labelsSource = 'fixed-labels';

/// Features that are single stations, not clusters.
const List<Object> _notCluster = [
  '!',
  ['has', 'point_count'],
];

/// Adds sources and layers for stations, clusters, fixed labels and "me".
Future<void> addStationOverlay(
  MapLibreMapController c,
  MarkerPalette p,
  List<MapLabel> fixedLabels,
) async {
  await c.addSource(
    stationSourceId,
    GeojsonSourceProperties(
      data: markersToGeoJson(const []),
      cluster: true,
      clusterRadius: 40,
      clusterMaxZoom: 7,
      // Most severe flood alarm colours a cluster (AC-MAP01-2), else the
      // best fish activity inside it (-1 = no data).
      clusterProperties: {
        'fish': [
          'max',
          ['get', 'fish'],
        ],
        'sev': [
          'max',
          ['get', 'sev'],
        ],
      },
    ),
  );
  await addRiverReachLayer(c, p);
  await addRiverFlowLayer(c, p);
  await addWeatherLayers(c, p);
  await addCommunityLayers(c, p);
  await _addClusterLayers(c, p);
  await _addStationLayers(c, p);
  await _addFixedLabels(c, p, fixedLabels);
  await _addPointLayer(c, pinSourceId, 'pin-dot', p.pin, p, 9);
  await _addPointLayer(c, meSourceId, 'me-dot', p.me, p, 7);
}

/// Colour by fish activity band (`fish` property, -1 = no data).
List<Object> fishColor(MarkerPalette p) => [
  'match',
  ['get', 'fish'],
  for (final (i, color) in p.fish.indexed) ...[i, hexColor(color)],
  hexColor(p.fishNone),
];

Future<void> _addClusterLayers(MapLibreMapController c, MarkerPalette p) async {
  await c.addCircleLayer(
    stationSourceId,
    clusterLayerId,
    CircleLayerProperties(
      circleColor: [
        'case',
        [
          '>=',
          ['get', 'sev'],
          MarkerStatus.alarm1.index,
        ],
        [
          'match',
          ['get', 'sev'],
          for (final s in MarkerStatus.values) ...[s.index, hexColor(p.status[s] ?? p.stroke)],
          hexColor(p.stroke),
        ],
        fishColor(p),
      ],
      circleRadius: [
        'step',
        ['get', 'point_count'],
        17,
        5,
        21,
        10,
        25,
      ],
      circleStrokeWidth: 3,
      circleStrokeColor: hexColor(p.stroke),
      circleStrokeOpacity: 0.9,
    ),
    filter: ['has', 'point_count'],
  );
  await c.addSymbolLayer(
    stationSourceId,
    'station-cluster-count',
    SymbolLayerProperties(
      textField: ['get', 'point_count_abbreviated'],
      textFont: ['Noto Sans Bold'],
      textSize: 14,
      textColor: hexColor(p.stroke),
      textAllowOverlap: true,
    ),
    filter: ['has', 'point_count'],
    enableInteraction: false,
  );
}

/// Fish pins: drop images with activity colour and trend badge (P2-20).
Future<void> _addStationLayers(MapLibreMapController c, MarkerPalette p) async {
  await c.addSymbolLayer(
    stationSourceId,
    stationDotsLayerId,
    const SymbolLayerProperties(
      iconImage: ['get', 'icon'],
      iconAnchor: 'bottom',
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      // Livelier spots on top where pins overlap.
      symbolSortKey: ['get', 'fish'],
    ),
    filter: _notCluster,
  );
  await _addNameLayer(c, p);
}

Future<void> _addFixedLabels(
  MapLibreMapController c,
  MarkerPalette p,
  List<MapLabel> fixedLabels,
) async {
  await c.addGeoJsonSource(_labelsSource, {
    'type': 'FeatureCollection',
    'features': [
      for (final l in fixedLabels)
        {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [l.lon, l.lat],
          },
          'properties': {'text': l.text},
        },
    ],
  });
  await c.addSymbolLayer(
    _labelsSource,
    'fixed-labels-text',
    SymbolLayerProperties(
      textField: ['get', 'text'],
      textFont: ['Noto Sans Italic'],
      textSize: 12,
      textMaxWidth: 8,
      textColor: hexColor(p.label),
      textHaloColor: hexColor(p.labelHalo),
      textHaloWidth: 1.5,
      textAllowOverlap: true,
    ),
    enableInteraction: false,
  );
}

Future<void> _addNameLayer(MapLibreMapController c, MarkerPalette p) async {
  await c.addSymbolLayer(
    stationSourceId,
    'station-names',
    SymbolLayerProperties(
      textField: ['get', 'name'],
      textFont: ['Noto Sans Regular'],
      textSize: 12,
      textOffset: [0, 0.4],
      textAnchor: 'top',
      textColor: hexColor(p.label),
      textHaloColor: hexColor(p.labelHalo),
      textHaloWidth: 1.8,
      textOptional: true,
    ),
    filter: _notCluster,
    minzoom: 6,
    enableInteraction: false,
  );
}

Map<String, dynamic> meGeoJson(({double lat, double lon})? p) => {
  'type': 'FeatureCollection',
  'features': [
    if (p != null)
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [p.lon, p.lat],
        },
        'properties': <String, Object>{},
      },
  ],
};

String hexColor(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// One-feature source drawn as a ringed dot ("me", tapped pin).
Future<void> _addPointLayer(
  MapLibreMapController c,
  String source,
  String layer,
  Color color,
  MarkerPalette p,
  double radius,
) async {
  await c.addGeoJsonSource(source, meGeoJson(null));
  await c.addCircleLayer(
    source,
    layer,
    CircleLayerProperties(
      circleColor: hexColor(color),
      circleRadius: radius,
      circleStrokeWidth: 3,
      circleStrokeColor: hexColor(p.stroke),
    ),
    enableInteraction: false,
  );
}

/// Rivers where along-river estimates apply; firmer (more opaque) near stations.
Future<void> addRiverReachLayer(MapLibreMapController c, MarkerPalette p) async {
  await c.addGeoJsonSource(riverReachSourceId, {
    'type': 'FeatureCollection',
    'features': <Object>[],
  });
  await c.addLineLayer(
    riverReachSourceId,
    'river-reach-line',
    LineLayerProperties(
      lineColor: hexColor(p.river),
      lineWidth: [
        'interpolate',
        ['linear'],
        ['zoom'],
        6,
        2,
        12,
        6,
      ],
      lineOpacity: [
        '*',
        0.85,
        ['get', 'conf'],
      ],
      lineCap: 'round',
    ),
    enableInteraction: false,
  );
}
