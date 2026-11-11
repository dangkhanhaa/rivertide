import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/core/network/dio_client.dart';
import 'package:rivertide/features/map/domain/weather_grid.dart';

/// Map centre and zoom after the camera stops (set by the map widget).
typedef MapCamera = ({double lat, double lon, double zoom});

class MapCameraNotifier extends Notifier<MapCamera?> {
  @override
  MapCamera? build() => null;

  MapCamera? get camera => state;
  set camera(MapCamera? value) => state = value;
}

final NotifierProvider<MapCameraNotifier, MapCamera?> mapCameraProvider = NotifierProvider(
  MapCameraNotifier.new,
);

/// "Mưa & gió" layer switch (off by default: it costs API calls).
class WeatherLayerOn extends Notifier<bool> {
  @override
  bool build() => false;

  bool get on => state;
  set on(bool value) => state = value;
}

final NotifierProvider<WeatherLayerOn, bool> weatherLayerOnProvider = NotifierProvider(
  WeatherLayerOn.new,
);

/// A grid is reused for this long (weather changes slowly; free API quota).
const Duration weatherGridTtl = Duration(minutes: 30);

/// One request for all grid points; `key` is "lat,lon;lat,lon;…" (snapped).
final FutureProviderFamily<Map<String, Object?>, String> _gridProvider = FutureProvider.autoDispose
    .family<Map<String, Object?>, String>((ref, key) async {
      final link = ref.keepAlive();
      final timer = Timer(weatherGridTtl, link.close);
      ref.onDispose(timer.cancel);
      final pts = key.split(';').map((p) => p.split(',')).toList();
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': pts.map((p) => p[0]).join(','),
        'longitude': pts.map((p) => p[1]).join(','),
        'current': 'wind_speed_10m,wind_direction_10m',
        'hourly': 'precipitation,precipitation_probability',
        'forecast_hours': '2',
        'timezone': 'GMT',
        'wind_speed_unit': 'kmh',
      });
      try {
        return weatherGridGeoJson(parseWeatherGrid(await getText(ref.read(dioProvider), uri)));
      } on AppException catch (e) {
        link.close(); // retry on the next camera stop
        log.info('weather grid unavailable', {'error': e.debugMessage});
        rethrow;
      } on FormatException {
        link.close();
        throw const ParseException('weather grid not JSON');
      }
    });

const Map<String, Object?> _empty = {'type': 'FeatureCollection', 'features': <Object>[]};

/// Rain/wind points around the view, or nothing when the layer is off, the
/// map is zoomed out too far, or the request failed.
final Provider<Map<String, Object?>> weatherLayerGeoJsonProvider = Provider((ref) {
  final cam = ref.watch(mapCameraProvider);
  if (!ref.watch(weatherLayerOnProvider) || cam == null || cam.zoom < weatherGridMinZoom) {
    return _empty;
  }
  final grid = weatherGrid(cam.lat, cam.lon, cam.zoom);
  final key = grid.points.map((p) => '${p.lat},${p.lon}').join(';');
  return ref.watch(_gridProvider(key)).value ?? _empty;
});

/// Callback for the map's camera-idle event.
void Function(double lat, double lon, double zoom) reportCamera(WidgetRef ref) =>
    (lat, lon, zoom) =>
        ref.read(mapCameraProvider.notifier).camera = (lat: lat, lon: lon, zoom: zoom);
