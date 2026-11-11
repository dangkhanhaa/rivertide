import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/station_layers.dart';

const riverFlowSourceId = 'river-flow';
const riverFlowLayerId = 'river-flow-line';

/// Moving dashes (seaward) coloured by rising / falling / slack water.
Future<void> addRiverFlowLayer(MapLibreMapController c, MarkerPalette p) async {
  await c.addGeoJsonSource(riverFlowSourceId, {
    'type': 'FeatureCollection',
    'features': <Object>[],
  });
  await c.addLineLayer(
    riverFlowSourceId,
    riverFlowLayerId,
    riverFlowProps(p, flowDashFrames.first),
    enableInteraction: false,
  );
}

/// "Marching ants" frames: stepping through them moves the dashes along the
/// line direction (paint property only, cheap to update).
const List<List<double>> flowDashFrames = [
  [0, 4, 3],
  [0.5, 4, 2.5],
  [1, 4, 2],
  [1.5, 4, 1.5],
  [2, 4, 1],
  [2.5, 4, 0.5],
  [3, 4, 0],
  [0, 0.5, 3, 3.5],
  [0, 1, 3, 3],
  [0, 1.5, 3, 2.5],
  [0, 2, 3, 2],
  [0, 2.5, 3, 1.5],
  [0, 3, 3, 1],
  [0, 3.5, 3, 0.5],
];

/// All properties every time: the plugin resets the ones left out.
LineLayerProperties riverFlowProps(MarkerPalette p, List<double> dash) => LineLayerProperties(
  lineColor: [
    'match',
    ['get', 'state'],
    'rising',
    hexColor(p.flowRising),
    'falling',
    hexColor(p.flowFalling),
    hexColor(p.flowSlack),
  ],
  lineWidth: [
    'interpolate',
    ['linear'],
    ['zoom'],
    6,
    1.5,
    12,
    4,
  ],
  lineDasharray: dash,
  lineCap: 'butt',
);
