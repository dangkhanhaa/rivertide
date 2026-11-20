import 'dart:convert';

import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

const int _maxHours = 24 * 120;

/// Hourly block of an Open-Meteo response: UTC times + numeric columns (nulls kept).
typedef HourlyTable = ({List<DateTime> timesUtc, Map<String, List<double?>> columns});

HourlyTable parseOpenMeteoHourly(String body, List<String> fields) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw ParseException('open-meteo json: ${e.message}');
  }
  if (decoded is! Map<String, Object?>) throw const ParseException('open-meteo: not an object');
  final offset = decoded['utc_offset_seconds'];
  final hourly = decoded['hourly'];
  if (offset is! int || hourly is! Map<String, Object?>) {
    throw const ParseException('open-meteo: missing hourly/utc_offset_seconds');
  }
  final rawTimes = hourly['time'];
  if (rawTimes is! List<Object?> || rawTimes.length > _maxHours) {
    throw const ParseException('open-meteo: bad time array');
  }
  final times = [
    for (final t in rawTimes)
      if (t is String && DateTime.tryParse('${t}Z') != null)
        DateTime.parse('${t}Z').subtract(Duration(seconds: offset))
      else
        throw const ParseException('open-meteo: bad time value'),
  ];
  final columns = <String, List<double?>>{};
  for (final f in fields) {
    final raw = hourly[f];
    if (raw is! List<Object?> || raw.length != times.length) continue; // field unavailable
    columns[f] = [
      for (final v in raw)
        switch (v) {
          final num n when n.isFinite => n.toDouble(),
          _ => null,
        },
    ];
  }
  return (timesUtc: times, columns: columns);
}

/// Hourly Open-Meteo variables asked for, with the physically possible range
/// of each. The answer is untrusted: a value outside its range is dropped
/// (shown as missing) rather than displayed or scored.
const Map<String, (double, double)> weatherFieldRanges = {
  'temperature_2m': (-60, 60),
  'apparent_temperature': (-80, 80),
  'relative_humidity_2m': (0, 100),
  'precipitation': (0, 500),
  'precipitation_probability': (0, 100),
  'weather_code': (0, 99),
  'cloud_cover': (0, 100),
  'pressure_msl': (850, 1100),
  'wind_speed_10m': (0, 400),
  'wind_gusts_10m': (0, 500),
  'wind_direction_10m': (0, 360),
  'cape': (0, 10000),
  'uv_index': (0, 25),
  'visibility': (0, 500000),
  'is_day': (0, 1),
};

final List<String> weatherFields = weatherFieldRanges.keys.toList(growable: false);

List<WeatherHour> parseWeather(String body) {
  final table = parseOpenMeteoHourly(body, weatherFields);
  double? col(String f, int i) {
    final v = table.columns[f]?[i];
    final range = weatherFieldRanges[f];
    if (v == null || range == null) return null;
    return v < range.$1 || v > range.$2 ? null : v;
  }

  return [
    for (var i = 0; i < table.timesUtc.length; i++)
      WeatherHour(
        timeUtc: table.timesUtc[i],
        temperatureC: col('temperature_2m', i),
        precipitationMm: col('precipitation', i),
        precipProbPct: col('precipitation_probability', i),
        weatherCode: col('weather_code', i)?.round(),
        cloudPct: col('cloud_cover', i),
        pressureHpa: col('pressure_msl', i),
        windKmh: col('wind_speed_10m', i),
        gustKmh: col('wind_gusts_10m', i),
        windDirDeg: col('wind_direction_10m', i),
        capeJPerKg: col('cape', i),
        apparentC: col('apparent_temperature', i),
        humidityPct: col('relative_humidity_2m', i),
        uvIndex: col('uv_index', i),
        visibilityM: col('visibility', i),
        isDay: switch (col('is_day', i)) {
          final double d => d >= 0.5,
          null => null,
        },
      ),
  ];
}

/// Sea level (cm, relative to model MSL) per hour; null where the model has no value.
List<(DateTime, double?)> parseMarineSeaLevel(String body) {
  final table = parseOpenMeteoHourly(body, const ['sea_level_height_msl']);
  final values = table.columns['sea_level_height_msl'];
  if (values == null) throw const ParseException('marine: no sea_level_height_msl');
  return [
    for (var i = 0; i < values.length; i++)
      (
        table.timesUtc[i],
        switch (values[i]) {
          final double m => m * 100,
          null => null,
        },
      ),
  ];
}

/// Grid cell Open-Meteo answered for, and the terrain height (90 m DEM) at
/// the requested point. The marine API gives sea level for land points too:
/// it snaps to a sea cell (Thanh Hóa city → 16 km away) or its coarse sea mask
/// covers delta land (Thái Bình city, 25 km inland, 11 m). Height > 0 is land.
({double lat, double lon, double? elevationM})? parseOpenMeteoCell(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw ParseException('open-meteo json: ${e.message}');
  }
  if (decoded case {'latitude': final num lat, 'longitude': final num lon}
      when decoded is Map<String, Object?> && lat.abs() <= 90 && lon.abs() <= 180) {
    final elevation = decoded['elevation'];
    return (
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      elevationM: elevation is num && elevation.abs() < 9000 ? elevation.toDouble() : null,
    );
  }
  return null;
}
