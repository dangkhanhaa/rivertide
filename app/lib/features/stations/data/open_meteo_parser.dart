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

const weatherFields = [
  'temperature_2m',
  'precipitation',
  'precipitation_probability',
  'weather_code',
  'cloud_cover',
  'pressure_msl',
  'wind_speed_10m',
  'wind_gusts_10m',
  'wind_direction_10m',
  'cape',
];

List<WeatherHour> parseWeather(String body) {
  final table = parseOpenMeteoHourly(body, weatherFields);
  double? col(String f, int i) => table.columns[f]?[i];
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
