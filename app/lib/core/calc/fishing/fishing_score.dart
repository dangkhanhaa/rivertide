import 'dart:math' as math;

import 'package:rivertide/core/calc/fishing/fishing_components.dart';
import 'package:rivertide/core/calc/fishing/fishing_input.dart';

/// Bump on any weight/threshold change and log it in docs/fishing-score.md.
const String fishingScoreVersion = 'fs-1';

enum SafetyLevel { none, yellow, red }

/// Why a safety level was raised, so the UI can show the right message.
enum SafetyReason {
  /// WMO code 95/96/99 → red, score ≤ 2.0.
  thunderstorm,

  /// Gust > 50 km/h → red, score ≤ 2.0.
  strongGust,

  /// Rain > 20 mm/h → score ≤ 3.0 (shown as yellow).
  heavyRain,

  /// CAPE ≥ 3000 and precip probability ≥ 50 % → yellow, score NOT capped.
  possibleThunderstorm,
}

enum FishingFactor { tide, flow, solunar, pressure, daytime, weather, season }

/// Weights of PROJECT.md 9.6; flow replaces tide for non-tidal stations.
const Map<FishingFactor, double> fishingWeights = {
  FishingFactor.tide: 0.30,
  FishingFactor.flow: 0.30,
  FishingFactor.solunar: 0.25,
  FishingFactor.pressure: 0.20,
  FishingFactor.daytime: 0.10,
  FishingFactor.weather: 0.10,
  FishingFactor.season: 0.05,
};

/// Component threshold counted as a "reason" in golden-window text.
const double positiveFactorThreshold = 0.9;

const Set<int> _thunderstormCodes = {95, 96, 99};

class FishingHourScore {
  const FishingHourScore({
    required this.hourUtc,
    required this.score,
    required this.components,
    required this.safety,
    required this.positiveFactors,
    this.safetyReasons = const [],
  });

  final DateTime hourUtc;

  /// 0–10, rounded to 1 decimal, safety caps applied.
  final double score;

  /// Only components that had data.
  final Map<FishingFactor, double> components;
  final SafetyLevel safety;
  final List<SafetyReason> safetyReasons;

  /// Components ≥ 0.9, heaviest weight first.
  final List<FishingFactor> positiveFactors;
}

/// Scores one hour; components without data are dropped from Σw.
FishingHourScore scoreHour(FishingHourInput input) {
  final components = _components(input);
  var weightSum = 0.0;
  var weighted = 0.0;
  for (final entry in components.entries) {
    final w = fishingWeights[entry.key] ?? 0;
    weightSum += w;
    weighted += w * entry.value;
  }
  // Solunar and daytime always have data, so weightSum > 0.
  var score = 10 * weighted / weightSum;
  final reasons = _safetyReasons(input);
  if (reasons.contains(SafetyReason.thunderstorm) || reasons.contains(SafetyReason.strongGust)) {
    score = math.min(score, 2);
  }
  if (reasons.contains(SafetyReason.heavyRain)) score = math.min(score, 3);
  final positives =
      components.entries.where((e) => e.value >= positiveFactorThreshold).map((e) => e.key).toList()
        ..sort((a, b) => (fishingWeights[b] ?? 0).compareTo(fishingWeights[a] ?? 0));
  return FishingHourScore(
    hourUtc: input.hourUtc,
    score: roundTo1(score),
    components: Map.unmodifiable(components),
    safety: _safetyLevel(reasons),
    safetyReasons: List.unmodifiable(reasons),
    positiveFactors: List.unmodifiable(positives),
  );
}

/// Rounds half away from zero to 1 decimal.
double roundTo1(double value) => (value * 10).round() / 10;

Map<FishingFactor, double> _components(FishingHourInput input) {
  final result = <FishingFactor, double>{};
  final minutes = input.minutesToTurn;
  final flow = input.flowRateCmPerH;
  if (input.hasTide && minutes != null) {
    result[FishingFactor.tide] = tideScore(minutes, input.springNeap);
  } else if (!input.hasTide && flow != null) {
    result[FishingFactor.flow] = flowScore(flow);
  }
  result[FishingFactor.solunar] = solunarScore(input.solunar, isGoodDay: input.isSolunarGoodDay);
  final pressure = input.pressureDelta3hHpa;
  if (pressure != null) result[FishingFactor.pressure] = pressureScore(pressure);
  result[FishingFactor.daytime] = daytimeScore(
    timeUtc: input.hourUtc,
    sunriseUtc: input.sunriseUtc,
    sunsetUtc: input.sunsetUtc,
    tzOffsetHours: input.tzOffsetHours,
  );
  final wind = input.windKmh;
  if (wind != null) {
    result[FishingFactor.weather] = weatherScore(
      windKmh: wind,
      rainMmPerH: input.rainMmPerH,
      cloudPct: input.cloudPct,
    );
  }
  final season = input.isBestSeason;
  if (season != null) result[FishingFactor.season] = seasonScore(isBestSeason: season);
  return result;
}

List<SafetyReason> _safetyReasons(FishingHourInput input) {
  final reasons = <SafetyReason>[];
  if (_thunderstormCodes.contains(input.weatherCode)) {
    reasons.add(SafetyReason.thunderstorm);
  }
  final gust = input.gustKmh;
  if (gust != null && gust > 50) reasons.add(SafetyReason.strongGust);
  final rain = input.rainMmPerH;
  if (rain != null && rain > 20) reasons.add(SafetyReason.heavyRain);
  final cape = input.capeJPerKg;
  final prob = input.precipProbPct;
  // CAPE > 2000 is routine in Vietnam even on clear days; only warn, never cap.
  if (cape != null && prob != null && cape >= 3000 && prob >= 50) {
    reasons.add(SafetyReason.possibleThunderstorm);
  }
  return reasons;
}

SafetyLevel _safetyLevel(List<SafetyReason> reasons) {
  if (reasons.contains(SafetyReason.thunderstorm) || reasons.contains(SafetyReason.strongGust)) {
    return SafetyLevel.red;
  }
  if (reasons.isNotEmpty) return SafetyLevel.yellow;
  return SafetyLevel.none;
}
