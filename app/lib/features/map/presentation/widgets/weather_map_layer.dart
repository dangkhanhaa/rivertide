import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/station_layers.dart';

export 'package:rivertide/features/map/domain/weather_grid.dart'
    show windArrowDirections, windArrowName;

const weatherSourceId = 'weather-grid';
const weatherRainLayerId = 'weather-rain';
const weatherWindLayerId = 'weather-wind';

/// Rain next hour as blue discs (bigger and darker with more rain) and wind
/// as arrows pointing where it blows, with km/h under each.
Future<void> addWeatherLayers(MapLibreMapController c, MarkerPalette p) async {
  await c.addGeoJsonSource(weatherSourceId, {'type': 'FeatureCollection', 'features': <Object>[]});
  await c.addCircleLayer(
    weatherSourceId,
    weatherRainLayerId,
    CircleLayerProperties(
      circleColor: hexColor(p.river),
      circleRadius: [
        'interpolate',
        ['linear'],
        ['get', 'rain'],
        0.1,
        8,
        5,
        16,
        20,
        24,
      ],
      circleOpacity: [
        'interpolate',
        ['linear'],
        ['get', 'rain'],
        0.1,
        0.25,
        5,
        0.5,
        20,
        0.7,
      ],
    ),
    filter: [
      '>=',
      ['get', 'rain'],
      0.1,
    ],
    enableInteraction: false,
  );
  await c.addSymbolLayer(
    weatherSourceId,
    weatherWindLayerId,
    SymbolLayerProperties(
      iconImage: ['get', 'arrow'],
      iconAllowOverlap: true,
      textField: [
        'concat',
        [
          'to-string',
          ['get', 'wind'],
        ],
        ' km/h',
      ],
      textFont: ['Noto Sans Regular'],
      textSize: 11,
      textOffset: [0, 1.4],
      textAllowOverlap: true,
      textColor: hexColor(p.label),
      textHaloColor: hexColor(p.labelHalo),
      textHaloWidth: 1.5,
    ),
    enableInteraction: false,
  );
}
