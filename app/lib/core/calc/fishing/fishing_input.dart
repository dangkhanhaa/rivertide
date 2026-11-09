import 'package:rivertide/core/calc/astro/solunar_kind.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';

/// All per-hour inputs of the fishing score (PROJECT.md 9.6).
///
/// Every weather-derived field is nullable: a missing value drops the whole
/// component from the weighted mean instead of guessing a neutral value.
class FishingHourInput {
  const FishingHourInput({
    required this.hourUtc,
    required this.hasTide,
    this.minutesToTurn,
    this.springNeap,
    this.flowRateCmPerH,
    this.solunar = SolunarKind.none,
    this.isSolunarGoodDay = false,
    this.sunriseUtc,
    this.sunsetUtc,
    this.tzOffsetHours = 7,
    this.pressureDelta3hHpa,
    this.windKmh,
    this.gustKmh,
    this.rainMmPerH,
    this.cloudPct,
    this.weatherCode,
    this.capeJPerKg,
    this.precipProbPct,
    this.isBestSeason,
  });

  /// Start of the hour being scored (UTC).
  final DateTime hourUtc;

  /// Station is tidal → use the tide component, otherwise the flow component.
  final bool hasTide;

  /// Minutes to the nearest tide turn (high/low), before or after; sign ignored.
  final int? minutesToTurn;

  /// Range class of the day; null is treated as [SpringNeap.normal].
  final SpringNeap? springNeap;

  /// Water level change for non-tidal stations; positive = rising.
  final double? flowRateCmPerH;

  final SolunarKind solunar;

  /// Within ±2 days of new/full moon (PROJECT.md 9.5).
  final bool isSolunarGoodDay;

  /// Sunrise/sunset of the local day containing [hourUtc].
  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;

  /// Local offset used by the 11h–14h rule (Asia/Ho_Chi_Minh = +7).
  final double tzOffsetHours;

  /// Pressure change over the last 3 hours; negative = falling.
  final double? pressureDelta3hHpa;
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
