import 'dart:math' as math;

import 'package:rivertide/core/calc/tide/spring_neap.dart';

/// Component scores of the fishing index, fs-2 (PROJECT.md 9.6,
/// docs/fishing-score.md). Each returns a value in [0, 1] and changes
/// smoothly: a step at "60 minutes" made hours flip between good and poor for
/// no visible reason.

/// Linear ramp: 0 at [from], 1 at [to] (works for from > to too), clamped.
double ramp(double x, double from, double to) => ((x - from) / (to - from)).clamp(0.0, 1.0);

/// Bell curve: 1 at [center], ~0.37 at ±[width].
double bell(double x, double center, double width) =>
    math.exp(-math.pow((x - center) / width, 2).toDouble());

/// Piecewise-linear lookup through (x, y) knots sorted by x; flat outside.
double knots(double x, List<(double, double)> points) {
  if (x <= points.first.$1) return points.first.$2;
  for (var i = 1; i < points.length; i++) {
    final (x1, y1) = points[i];
    if (x <= x1) {
      final (x0, y0) = points[i - 1];
      return y0 + (y1 - y0) * (x - x0) / (x1 - x0);
    }
  }
  return points.last.$2;
}

double _unit(double v) => v.clamp(0.0, 1.0);

/// Multiplier for the day's tidal range; unknown range is treated as normal.
/// Milder than fs-1 because [tideScore] already sees how fast water moves.
double springNeapFactor(SpringNeap? springNeap) => switch (springNeap) {
  SpringNeap.spring => 1,
  SpringNeap.neap => 0.8,
  SpringNeap.normal || null => 0.92,
};

/// Tide component: fish feed when the water moves, not at slack.
///
/// [rateNorm] = |level change rate| / the fastest rate of that local day
/// (0 = slack, 1 = strongest current). [minutesSinceTurn] gives the bonus for
/// the first hours after a turn, when the current starts carrying food
/// ("nước bắt đầu chảy"); rising water gets a small extra (fish move into the
/// banks and flooded grass).
double tideScore({
  required double rateNorm,
  int? minutesSinceTurn,
  bool rising = false,
  SpringNeap? springNeap,
}) {
  final moving = 0.25 + 0.65 * ramp(rateNorm, 0.15, 0.85);
  final since = minutesSinceTurn;
  final onset = since == null ? 0.0 : 0.12 * bell(since.toDouble(), 90, 60);
  return _unit((moving + onset + (rising ? 0.05 : 0)) * springNeapFactor(springNeap));
}

/// Flow component for non-tidal stations; positive rate = rising.
/// Gentle change is best, a fast rise brings muddy flood water.
double flowScore(double rateCmPerH) {
  if (rateCmPerH > 20) return 0.3;
  final abs = rateCmPerH.abs();
  if (abs < 2) return 0.6;
  if (abs <= 10) return 0.9;
  return 0.6;
}

/// Solunar component from [strength] (0–1, see `solunarStrengthAt`) and how
/// close the day is to new/full moon ([daysFromNewOrFull], 0 = that day).
double solunarScore({required double strength, double? daysFromNewOrFull}) {
  final d = daysFromNewOrFull;
  final phase = d == null ? 0.0 : 0.12 * ramp(d, 4, 0);
  return _unit(0.3 + 0.7 * strength + phase);
}

/// Pressure trend over 24 hours (hPa; negative = falling).
///
/// fs-1 compared with 3 hours ago, but in the tropics the air pressure itself
/// swings ~2–3 hPa twice a day (falls 10h–16h, rises evening and morning), so
/// every afternoon looked like "falling pressure, fish bite" and every morning
/// like the opposite. Same hour yesterday cancels that daily cycle and leaves
/// the weather systems that actually matter.
double pressureScore(double delta24hHpa) => knots(delta24hHpa, const [
  (-8, 0.3), // deep low / storm coming
  (-5, 0.55),
  (-3.5, 1),
  (-1, 1), // slowly falling: best
  (1, 0.8), // stable
  (4, 0.55),
  (7, 0.4), // strong rise behind a cold front
]);

/// Light: dawn and dusk are best; the hot midday is worst unless overcast;
/// nights depend a little on moonlight.
double daytimeScore({
  required DateTime timeUtc,
  DateTime? sunriseUtc,
  DateTime? sunsetUtc,
  double? cloudPct,
  double moonFraction = 0,
}) {
  final rise = sunriseUtc;
  final set = sunsetUtc;
  if (rise == null || set == null) return 0.6;
  double minutesFrom(DateTime e) => timeUtc.difference(e).inSeconds / 60;
  final dawn = bell(minutesFrom(rise), 20, 75);
  final dusk = bell(minutesFrom(set), -10, 80);
  final double base;
  if (timeUtc.isBefore(rise) || timeUtc.isAfter(set)) {
    base = 0.5 + 0.12 * moonFraction;
  } else {
    // Fraction of the day 0 (sunrise) → 1 (sunset); solar noon ≈ 0.5.
    final f = minutesFrom(rise) / set.difference(rise).inMinutes;
    final heat = bell(f, 0.52, 0.17); // 1 around 10h30–14h
    final shade = (cloudPct ?? 0) / 100;
    base = 0.68 - heat * (0.3 - 0.18 * shade);
  }
  return _unit(math.max(base, math.max(dawn, dusk)));
}

/// Air temperature as a stand-in for water temperature. Tropical fish feed
/// best 24–30 °C; a heat wave sends them deep, a northern cold snap stops them.
/// [drop24h] = how much colder than the same hour yesterday (°C, ≥ 0).
double temperatureScore(double tempC, {double drop24h = 0}) {
  final base = knots(tempC, const [
    (10, 0.2),
    (15, 0.45),
    (20, 0.75),
    (24, 1),
    (30, 1),
    (33, 0.7),
    (36, 0.45),
  ]);
  return _unit(base * (1 - 0.25 * ramp(drop24h, 3, 7)));
}

/// Wind and rain. A light breeze ruffles the surface (fish less wary); glassy
/// calm is slightly worse; strong wind makes fishing hard. Light rain is fine.
double weatherScore({required double windKmh, double? rainMmPerH}) {
  final wind = knots(windKmh, const [(0, 0.8), (4, 1), (15, 1), (25, 0.6), (40, 0.2)]);
  final rain = knots(rainMmPerH ?? 0, const [(0, 1), (2, 1), (8, 0.7), (15, 0.45)]);
  return _unit(wind * rain);
}

double seasonScore({required bool isBestSeason}) => isBestSeason ? 1 : 0.4;

/// Rain runoff on running water without tide (fs-3), from the last 24 h of
/// rain (mm). A few mm to ~20 mm washes food in and tints the water (fish
/// feed more boldly); dry days are ordinary; 40 mm and more brings fast,
/// muddy flood water that puts fish off and makes banks unsafe.
double runoffScore(double rain24hMm) =>
    knots(rain24hMm, const [(0, 0.85), (3, 1), (20, 1), (40, 0.6), (80, 0.3)]);
