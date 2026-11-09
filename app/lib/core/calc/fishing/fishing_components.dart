import 'dart:math' as math;

import 'package:rivertide/core/calc/astro/solunar_kind.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';

/// Component scores of PROJECT.md 9.6; each returns a value in [0, 1].

/// Tide timing score from minutes to the nearest turn (before or after).
double tideTimingScore(int minutesToTurn) {
  final m = minutesToTurn.abs();
  if (m <= 20) return 0.5; // slack water
  if (m <= 120) return 1;
  if (m <= 180) return 0.75;
  return 0.5;
}

/// Multiplier for the day's tidal range; unknown range is treated as normal.
double springNeapFactor(SpringNeap? springNeap) {
  switch (springNeap) {
    case SpringNeap.spring:
      return 1;
    case SpringNeap.neap:
      return 0.7;
    case SpringNeap.normal:
    case null:
      return 0.85;
  }
}

/// Tide component: timing score × spring/neap factor.
double tideScore(int minutesToTurn, SpringNeap? springNeap) =>
    tideTimingScore(minutesToTurn) * springNeapFactor(springNeap);

/// Flow component for non-tidal stations; positive rate = rising.
///
/// Spec defines 2–10 cm/h (0.9), standing (0.6) and rising > 20 cm/h (0.3).
/// Gaps (10–20 cm/h either way, falling > 20 cm/h) get the neutral 0.6.
double flowScore(double rateCmPerH) {
  final abs = rateCmPerH.abs();
  if (rateCmPerH > 20) return 0.3; // muddy flood water
  if (abs < 2) return 0.6;
  if (abs <= 10) return 0.9;
  return 0.6;
}

double solunarScore(SolunarKind kind, {required bool isGoodDay}) {
  final base = switch (kind) {
    SolunarKind.major => 1.0,
    SolunarKind.minor => 0.75,
    SolunarKind.none => 0.35,
  };
  return math.min(1, base + (isGoodDay ? 0.1 : 0));
}

/// Pressure trend score; negative delta = falling pressure.
double pressureScore(double delta3hHpa) {
  if (delta3hHpa < -3) return 0.3;
  if (delta3hHpa <= -1) return 1;
  if (delta3hHpa < 1) return 0.8;
  if (delta3hHpa <= 3) return 0.6;
  return 0.4;
}

/// Daytime score. Twilight (±90 min around sunrise/sunset) wins, then night,
/// then local 11:00–14:00 (exclusive end, i.e. hours 11, 12, 13).
double daytimeScore({
  required DateTime timeUtc,
  DateTime? sunriseUtc,
  DateTime? sunsetUtc,
  double tzOffsetHours = 7,
}) {
  const twilight = Duration(minutes: 90);
  bool near(DateTime? event) => event != null && timeUtc.difference(event).abs() <= twilight;
  if (near(sunriseUtc) || near(sunsetUtc)) return 1;
  final isNight =
      (sunriseUtc != null && timeUtc.isBefore(sunriseUtc)) ||
      (sunsetUtc != null && timeUtc.isAfter(sunsetUtc));
  if (isNight) return 0.6;
  final offset = Duration(minutes: (tzOffsetHours * 60).round());
  final localHour = timeUtc.toUtc().add(offset).hour;
  if (localHour >= 11 && localHour < 14) return 0.4;
  return 0.6;
}

/// Weather score: wind base × rain multiplier, +0.1 for 30–80 % cloud.
/// Missing rain/cloud are treated as no rain / no bonus.
double weatherScore({required double windKmh, double? rainMmPerH, double? cloudPct}) {
  final wind = windKmh < 15 ? 1.0 : (windKmh <= 25 ? 0.6 : 0.2);
  final rain = rainMmPerH ?? 0;
  final rainFactor = rain < 1 ? 1.0 : (rain <= 5 ? 0.8 : 0.4);
  final cloud = cloudPct;
  final bonus = cloud != null && cloud >= 30 && cloud <= 80 ? 0.1 : 0.0;
  return math.min(1, wind * rainFactor + bonus);
}

double seasonScore({required bool isBestSeason}) => isBestSeason ? 1 : 0.4;
