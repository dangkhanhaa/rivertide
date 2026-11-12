import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/station_layers.dart';

const communitySourceId = 'community-spots';
const communityLayerId = 'community-spots-dot';
const communityLabelLayerId = 'community-spots-label';

/// Image id of the community pin (registered by the map widget).
const communityPinImage = 'spot-pin';

/// Community spots: orange star pins with their name from zoom 12.
Future<void> addCommunityLayers(MapLibreMapController c, MarkerPalette p) async {
  await c.addGeoJsonSource(communitySourceId, {
    'type': 'FeatureCollection',
    'features': <Object>[],
  });
  await c.addSymbolLayer(
    communitySourceId,
    communityLayerId,
    const SymbolLayerProperties(
      iconImage: communityPinImage,
      iconAnchor: 'bottom',
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ),
  );
  await c.addSymbolLayer(
    communitySourceId,
    communityLabelLayerId,
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
    ),
    minzoom: 12,
    enableInteraction: false,
  );
}
