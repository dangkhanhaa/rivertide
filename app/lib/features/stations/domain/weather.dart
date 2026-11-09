import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';

/// One forecast hour from Open-Meteo; every field may be missing.
@freezed
abstract class WeatherHour with _$WeatherHour {
  const factory WeatherHour({
    required DateTime timeUtc,
    double? temperatureC,
    double? precipitationMm,
    double? precipProbPct,
    int? weatherCode,
    double? cloudPct,
    double? pressureHpa,
    double? windKmh,
    double? gustKmh,
    double? windDirDeg,
    double? capeJPerKg,
  }) = _WeatherHour;
}
