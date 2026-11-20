import 'package:rivertide/core/calc/astro/solunar_kind.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';

/// Inputs of the fishing score at one instant (PROJECT.md 9.6, fs-2). An hour
/// is scored from four of these (:00, :15, :30, :45).
///
/// Every weather-derived field is nullable: a missing value drops the whole
/// component from the weighted mean instead of guessing a neutral value.
class FishingHourInput {
  const FishingHourInput({
    required this.timeUtc,
    required this.hasTide,
    this.tideRateNorm,
    this.minutesSinceTurn,
    this.tideRising = false,
    this.springNeap,
    this.flowRateCmPerH,
    this.solunar = SolunarKind.none,
    this.solunarStrength = 0,
    this.daysFromNewOrFull,
    this.moonFraction = 0,
    this.sunriseUtc,
    this.sunsetUtc,
    this.pressureDelta24hHpa,
    this.temperatureC,
    this.temperatureDrop24h = 0,
    this.windKmh,
    this.gustKmh,
    this.rainMmPerH,
    this.cloudPct,
    this.weatherCode,
    this.capeJPerKg,
    this.precipProbPct,
    this.isBestSeason,
    this.rain24hMm,
  });

  /// Rain over the 24 hours before this hour (mm). Set only for running water
  /// without tide (streams, rivers far from the sea), where rain runoff drives
  /// the water (fs-3); null elsewhere.
  final double? rain24hMm;

  final DateTime timeUtc;

  /// Station is tidal → use the tide component, otherwise the flow component.
  final bool hasTide;

  /// |water level change rate| ÷ the fastest rate of that local day (0–1).
  final double? tideRateNorm;

  /// Minutes since the last high/low water.
  final int? minutesSinceTurn;
  final bool tideRising;

  /// Range class of the day; null is treated as [SpringNeap.normal].
  final SpringNeap? springNeap;

  /// Water level change for non-tidal stations; positive = rising.
  final double? flowRateCmPerH;

  /// Kind of solunar period covering this instant (for reasons/advice).
  final SolunarKind solunar;

  /// 0–1, peaking at moon transit (major) / rise-set (minor).
  final double solunarStrength;

  /// Days to the nearest new or full moon.
  final double? daysFromNewOrFull;

  /// Lit fraction of the moon, 0–1.
  final double moonFraction;

  /// Sunrise/sunset of the local day containing [timeUtc].
  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;

  /// Pressure now minus the same hour yesterday (hPa); negative = falling.
  final double? pressureDelta24hHpa;
  final double? temperatureC;

  /// Degrees colder than the same hour yesterday (0 when warmer/unknown).
  final double temperatureDrop24h;
  final double? windKmh;
  final double? gustKmh;
  final double? rainMmPerH;
  final double? cloudPct;

  /// WMO weather code (Open-Meteo).
  final int? weatherCode;
  final double? capeJPerKg;
  final double? precipProbPct;

  /// Current month is in the chosen species' best months; null = no species.
  final bool? isBestSeason;
}
