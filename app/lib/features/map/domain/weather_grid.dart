import 'dart:convert';
import 'dart:math' as math;

/// Rain in the next hour and wind now at one grid point (map layer).
class WeatherCell {
  const WeatherCell({
    required this.lat,
    required this.lon,
    required this.rainMm,
    required this.rainProbPct,
    required this.windKmh,
    required this.windFromDeg,
  });

  final double lat;
  final double lon;
  final double rainMm;
  final int rainProbPct;
  final double windKmh;

  /// Meteorological direction the wind blows FROM (0 = north).
  final double windFromDeg;
}

/// Points per side of the grid around the map centre.
const int weatherGridSide = 5;

/// Below this zoom the grid would be too coarse to mean anything.
const double weatherGridMinZoom = 6;

/// Grid around the view centre spanning about one phone screen width at
/// [zoom]; snapped to its own spacing so small pans reuse the same request.
({List<({double lat, double lon})> points, double step}) weatherGrid(
  double lat,
  double lon,
  double zoom,
) {
  // Width of ~400 px in degrees at this zoom (256 px tiles).
  final viewDeg = 400 * 360 / (256 * math.pow(2, zoom));
  final step = double.parse((viewDeg / weatherGridSide).clamp(0.02, 1.0).toStringAsFixed(2));
  final cLat = (lat / step).round() * step;
  final cLon = (lon / step).round() * step;
  const half = weatherGridSide ~/ 2;
  return (
    step: step,
    points: [
      for (var i = -half; i <= half; i++)
        for (var j = -half; j <= half; j++)
          (
            lat: double.parse((cLat + i * step).toStringAsFixed(3)),
            lon: double.parse((cLon + j * step).toStringAsFixed(3)),
          ),
    ],
  );
}

/// Parses an Open-Meteo multi-location response (a JSON list, or one object
/// for a single point) with `current` wind and `hourly` rain. Values outside
/// physical ranges drop the point (external data is untrusted).
List<WeatherCell> parseWeatherGrid(String body) {
  final decoded = jsonDecode(body);
  final items = decoded is List ? decoded : [decoded];
  final out = <WeatherCell>[];
  for (final item in items) {
    if (item case {
      'latitude': final num lat,
      'longitude': final num lon,
      'current': {'wind_speed_10m': final num wind, 'wind_direction_10m': final num dir},
      'hourly': {
        'precipitation': final List<Object?> rain,
        'precipitation_probability': final List<Object?> prob,
      },
    }) {
      final r = rain.whereType<num>().take(2).fold<double>(0, (a, b) => math.max(a, b.toDouble()));
      final p = prob.whereType<num>().take(2).fold<num>(0, math.max).round();
      if (wind < 0 || wind > 400 || dir < 0 || dir > 360 || r < 0 || r > 500 || p < 0 || p > 100) {
        continue;
      }
      out.add(
        WeatherCell(
          lat: lat.toDouble(),
          lon: lon.toDouble(),
          rainMm: r,
          rainProbPct: p,
          windKmh: wind.toDouble(),
          windFromDeg: dir.toDouble(),
        ),
      );
    }
  }
  return out;
}

/// Arrow images drawn for the wind layer (every 45°).
const int windArrowDirections = 8;

String windArrowName(int i) => 'wind-$i';

/// Points with `rain` (mm), `wind` (km/h, rounded) and `arrow` (the image
/// of the nearest of 8 directions the wind blows to).
Map<String, Object?> weatherGridGeoJson(List<WeatherCell> cells) => {
  'type': 'FeatureCollection',
  'features': [
    for (final c in cells)
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [c.lon, c.lat],
        },
        'properties': {
          'rain': c.rainMm,
          'wind': c.windKmh.round(),
          'arrow': windArrowName(
            (((c.windFromDeg + 180) % 360) / (360 / windArrowDirections)).round() %
                windArrowDirections,
          ),
        },
      },
  ],
};
