import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/station_layers.dart';

const communitySourceId = 'community-spots';
const communityLayerId = 'community-spots-dot';
const communityLabelLayerId = 'community-spots-label';

/// Community spots: teal pins (fish colour) with their name from zoom 12.
Future<void> addCommunityLayers(MapLibreMapController c, MarkerPalette p) async {
  await c.addGeoJsonSource(communitySourceId, {
    'type': 'FeatureCollection',
    'features': <Object>[],
  });
  await c.addCircleLayer(
    communitySourceId,
    communityLayerId,
    CircleLayerProperties(
      circleColor: hexColor(p.community),
      circleRadius: [
        'interpolate',
        ['linear'],
        ['zoom'],
        6,
        5,
        14,
        10,
      ],
      circleStrokeWidth: 3,
      circleStrokeColor: hexColor(p.stroke),
    ),
  );
  await c.addSymbolLayer(
    communitySourceId,
    communityLabelLayerId,
    SymbolLayerProperties(
      textField: ['get', 'title'],
      textFont: ['Noto Sans Regular'],
      textSize: 12,
      textOffset: [0, 1.3],
      textAnchor: 'top',
      textMaxWidth: 10,
      textColor: hexColor(p.label),
      textHaloColor: hexColor(p.labelHalo),
      textHaloWidth: 1.5,
    ),
    minzoom: 12,
    enableInteraction: false,
  );
}
