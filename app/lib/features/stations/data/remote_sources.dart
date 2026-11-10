import 'package:dio/dio.dart';
import 'package:rivertide/core/network/dio_client.dart';

/// URL builders + fetchers for the free, key-less sources used in V0 (PROJECT.md 3.0).
class RemoteSources {
  RemoteSources(this._dio);

  final Dio _dio;

  static String _iocTime(DateTime utc) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${utc.year}-${two(utc.month)}-${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}';
  }

  static Uri iocUri(String code, DateTime fromUtc, DateTime toUtc) =>
      Uri.https('www.ioc-sealevelmonitoring.org', '/service.php', {
        'query': 'data',
        'code': code,
        'timestart': _iocTime(fromUtc),
        'timestop': _iocTime(toUtc),
        'format': 'json',
      });

  static Uri marineUri(double lat, double lon) =>
      Uri.https('marine-api.open-meteo.com', '/v1/marine', {
        'latitude': lat.toStringAsFixed(3),
        'longitude': lon.toStringAsFixed(3),
        'hourly': 'sea_level_height_msl',
        'past_days': '3', // river fit needs the sea tide over the last 48 h + lag
        'forecast_days': '7',
        'timezone': 'GMT',
      });

  static Uri weatherUri(double lat, double lon, List<String> fields) =>
      Uri.https('api.open-meteo.com', '/v1/forecast', {
        // Rounded to ~1 km: enough for weather, avoids sending precise positions.
        'latitude': lat.toStringAsFixed(2),
        'longitude': lon.toStringAsFixed(2),
        'hourly': fields.join(','),
        'past_days': '1',
        'forecast_days': '7',
        'timezone': 'GMT',
        'wind_speed_unit': 'kmh',
      });

  /// GloFAS cells are ~5 km; the main stem is found by trying a 3×3 block.
  static const double floodGridStep = 0.05;

  static Uri floodUri(double lat, double lon) {
    final lats = <String>[];
    final lons = <String>[];
    for (final dy in [-1, 0, 1]) {
      for (final dx in [-1, 0, 1]) {
        lats.add((lat + dy * floodGridStep).toStringAsFixed(3));
        lons.add((lon + dx * floodGridStep).toStringAsFixed(3));
      }
    }
    return Uri.https('flood-api.open-meteo.com', '/v1/flood', {
      'latitude': lats.join(','),
      'longitude': lons.join(','),
      'daily': 'river_discharge',
      'past_days': '3',
      'forecast_days': '7',
    });
  }

  Future<String> fetchFlood(double lat, double lon) => getText(_dio, floodUri(lat, lon));

  Future<String> fetchIoc(String code, DateTime fromUtc, DateTime toUtc) =>
      getText(_dio, iocUri(code, fromUtc, toUtc));

  Future<String> fetchMarine(double lat, double lon) => getText(_dio, marineUri(lat, lon));

  /// Parsed KTTV bulletin published daily by the GitHub Actions job (V0-09).
  static final Uri kttvUri = Uri.https('dangkhanhaa.github.io', '/rivertide/data/kttv_tvhn.json');

  Future<String> fetchKttv() => getText(_dio, kttvUri);

  Future<String> fetchWeather(double lat, double lon, List<String> fields) =>
      getText(_dio, weatherUri(lat, lon, fields));
}
