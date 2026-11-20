import 'dart:math' as math;

import 'package:rivertide/core/calc/fishing/fishing_components.dart';
import 'package:rivertide/core/calc/fishing/fishing_input.dart';

/// Bump on any weight/threshold change and log it in docs/fishing-score.md.
const String fishingScoreVersion = 'fs-3';

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

enum FishingFactor {
  tide,
  flow,
  solunar,
  pressure,
  daytime,
  temperature,
  weather,
  season,

  /// Rain of the last 24 h on running water without tide (fs-3).
  runoff,
}

/// fs-2 splits the factors in two (PROJECT.md 9.6):
/// - timing decides WHICH hours fish feed (moving water, moon, light);
/// - conditions scale the whole day up or down (pressure, temperature,
///   wind/rain, season).
/// A single weighted mean (fs-1) let good weather lift every hour to ≥ 7, so
/// the golden hours did not stand out.
const Map<FishingFactor, double> timingWeights = {
  FishingFactor.tide: 0.40,
  FishingFactor.flow: 0.40,
  FishingFactor.solunar: 0.33,
  FishingFactor.daytime: 0.27,
};

/// fs-3: [FishingFactor.runoff] only exists for running water without tide;
/// elsewhere it drops out and the other four keep their fs-2 balance.
/// Still water (lake, pond, reservoir) has neither tide nor flow, so its
/// timing is solunar + light alone.
const Map<FishingFactor, double> conditionWeights = {
  FishingFactor.pressure: 0.35,
  FishingFactor.temperature: 0.30,
  FishingFactor.weather: 0.25,
  FishingFactor.season: 0.10,
  FishingFactor.runoff: 0.20,
};

/// Combined view of both maps, used to rank reasons (heaviest first).
const Map<FishingFactor, double> fishingWeights = {...timingWeights, ...conditionWeights};

/// Conditions value assumed when no weather is loaded (quick map scores), so
/// those pins land near the full score on an ordinary day.
const double neutralConditions = 0.85;

/// Conditions multiplier = floor + (1 − floor) × conditions: the worst weather
/// roughly halves a score, the best leaves it whole.
const double conditionFloor = 0.5;

/// Extra points when moving water or dawn/dusk falls inside a strong solunar
/// period: anglers and Knight's tables both rate that overlap highest.
const double coincidenceBonus = 0.8;

const Set<FishingFactor> _reasonFactors = {
  FishingFactor.tide,
  FishingFactor.flow,
  FishingFactor.solunar,
  FishingFactor.daytime,
  FishingFactor.pressure,
};

/// Component threshold counted as a "reason" in golden-window text (0.85 in
/// fs-2: hour averages of smooth curves rarely reach 0.9 even at a peak).
const double positiveFactorThreshold = 0.85;

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

  /// Timing components and pressure ≥ [positiveFactorThreshold], heaviest first.
  final List<FishingFactor> positiveFactors;
}

/// Scores one hour from instants inside it (fs-2 uses :00, :15, :30, :45):
/// each component is averaged over the samples that have it, so an event at
/// 10:40 lifts the 10h and 11h scores by how much of the hour it covers.
/// Components without data are dropped from Σw; safety takes the worst sample.
FishingHourScore scoreHour(DateTime hourUtc, List<FishingHourInput> samples) {
  final sums = <FishingFactor, double>{};
  final counts = <FishingFactor, int>{};
  final reasons = <SafetyReason>{};
  for (final s in samples) {
    for (final e in _components(s).entries) {
      sums[e.key] = (sums[e.key] ?? 0) + e.value;
      counts[e.key] = (counts[e.key] ?? 0) + 1;
    }
    reasons.addAll(_safetyReasons(s));
  }
  final components = {for (final e in sums.entries) e.key: e.value / (counts[e.key] ?? 1)};
  final timing = _mean(components, timingWeights);
  final conditions = _mean(components, conditionWeights) ?? neutralConditions;
  var score = timing == null
      ? 0.0
      : 10 * timing * (conditionFloor + (1 - conditionFloor) * conditions) +
            _coincidence(components);
  score = math.min(score, 10);
  if (reasons.contains(SafetyReason.thunderstorm) || reasons.contains(SafetyReason.strongGust)) {
    score = math.min(score, 2);
  }
  if (reasons.contains(SafetyReason.heavyRain)) score = math.min(score, 3);
  // Reasons are what makes THIS hour stand out; temperature, wind and season
  // are the same all day, so listing them under every golden hour is noise.
  final positives =
      components.entries
          .where((e) => e.value >= positiveFactorThreshold && _reasonFactors.contains(e.key))
          .map((e) => e.key)
          .toList()
        ..sort((a, b) => (fishingWeights[b] ?? 0).compareTo(fishingWeights[a] ?? 0));
  final reasonList = SafetyReason.values.where(reasons.contains).toList();
  return FishingHourScore(
    hourUtc: hourUtc,
    score: roundTo1(score),
    components: Map.unmodifiable(components),
    safety: _safetyLevel(reasonList),
    safetyReasons: List.unmodifiable(reasonList),
    positiveFactors: List.unmodifiable(positives),
  );
}

/// Weighted mean of the components present in [weights]; null when none are.
double? _mean(Map<FishingFactor, double> components, Map<FishingFactor, double> weights) {
  var weightSum = 0.0;
  var weighted = 0.0;
  for (final e in components.entries) {
    final w = weights[e.key];
    if (w == null) continue;
    weightSum += w;
    weighted += w * e.value;
  }
  return weightSum == 0 ? null : weighted / weightSum;
}

double _coincidence(Map<FishingFactor, double> c) {
  final solunar = c[FishingFactor.solunar] ?? 0;
  final other = math.max(
    math.max(c[FishingFactor.tide] ?? 0, c[FishingFactor.flow] ?? 0),
    c[FishingFactor.daytime] ?? 0,
  );
  // Both must be strong; scales from 0 (either ≤ 0.75) to full (both ≥ 0.95).
  return coincidenceBonus * math.min(1, math.max(0, (math.min(solunar, other) - 0.75) / 0.2));
}

/// Rounds half away from zero to 1 decimal.
double roundTo1(double value) => (value * 10).round() / 10;

Map<FishingFactor, double> _components(FishingHourInput input) {
  final result = <FishingFactor, double>{};
  final rate = input.tideRateNorm;
  final flow = input.flowRateCmPerH;
  if (input.hasTide && rate != null) {
    result[FishingFactor.tide] = tideScore(
      rateNorm: rate,
      minutesSinceTurn: input.minutesSinceTurn,
      rising: input.tideRising,
      springNeap: input.springNeap,
    );
  } else if (!input.hasTide && flow != null) {
    result[FishingFactor.flow] = flowScore(flow);
  }
  result[FishingFactor.solunar] = solunarScore(
    strength: input.solunarStrength,
    daysFromNewOrFull: input.daysFromNewOrFull,
  );
  final pressure = input.pressureDelta24hHpa;
  if (pressure != null) result[FishingFactor.pressure] = pressureScore(pressure);
  result[FishingFactor.daytime] = daytimeScore(
    timeUtc: input.timeUtc,
    sunriseUtc: input.sunriseUtc,
    sunsetUtc: input.sunsetUtc,
    cloudPct: input.cloudPct,
    moonFraction: input.moonFraction,
  );
  final temp = input.temperatureC;
  if (temp != null) {
    result[FishingFactor.temperature] = temperatureScore(temp, drop24h: input.temperatureDrop24h);
  }
  final wind = input.windKmh;
  if (wind != null) {
    result[FishingFactor.weather] = weatherScore(windKmh: wind, rainMmPerH: input.rainMmPerH);
  }
  final season = input.isBestSeason;
  if (season != null) result[FishingFactor.season] = seasonScore(isBestSeason: season);
  final rain24 = input.rain24hMm;
  if (rain24 != null) result[FishingFactor.runoff] = runoffScore(rain24);
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
