import 'dart:math' as math;

import 'package:rivertide/core/calc/weather/wx_hour.dart';

/// One local day of forecast, aggregated from its 24 hourly values (00:00–
/// 23:00 local). Checked against Open-Meteo's own daily fields on 19/11/2026
/// (HCMC, Hà Nội, Đà Lạt): rain sum, max rain chance, max wind and gust, UV,
/// dominant direction and weather code (highest = most severe) match
/// exactly. Its daily max/min temperature come from the model's sub-hourly
/// extremes and can differ by up to ~1 °C; here they are the extremes of the
/// hourly values, so the daily rows agree with the hourly strip.
class WxDay {
  const WxDay({
    required this.dayStartUtc,
    this.minC,
    this.maxC,
    this.rainMm,
    this.rainProbPct,
    this.windMaxKmh,
    this.gustMaxKmh,
    this.windFromDeg,
    this.uvMax,
    this.code,
  });

  final DateTime dayStartUtc;
  final double? minC;
  final double? maxC;

  /// Total of the hourly values stamped inside the day.
  final double? rainMm;

  /// Highest hourly chance of rain.
  final double? rainProbPct;
  final double? windMaxKmh;
  final double? gustMaxKmh;

  /// Dominant direction (speed-weighted vector mean), degrees from north.
  final double? windFromDeg;
  final double? uvMax;
  final int? code;
}

/// Hours a day must have to be summarised; the forecast's last local day is
/// cut short (the request ends at a UTC midnight) and would show wrong
/// highs/lows, so it is left out.
const int hoursPerDay = 24;

/// Days of [dayStartsUtc] (local midnights as UTC instants) fully covered by
/// [hours], in order.
List<WxDay> dailyWeather(List<WxHour> hours, List<DateTime> dayStartsUtc) {
  final out = <WxDay>[];
  for (final start in dayStartsUtc) {
    final end = start.add(const Duration(days: 1));
    final day = [
      for (final h in hours)
        if (!h.timeUtc.isBefore(start) && h.timeUtc.isBefore(end)) h,
    ];
    if (day.length < hoursPerDay) continue;
    out.add(_summarise(start, day));
  }
  return out;
}

WxDay _summarise(DateTime start, List<WxHour> day) {
  double? maxOf(Iterable<double?> v) =>
      v.nonNulls.fold<double?>(null, (a, b) => math.max(a ?? b, b));
  double? minOf(Iterable<double?> v) =>
      v.nonNulls.fold<double?>(null, (a, b) => math.min(a ?? b, b));
  final rain = day.map((h) => h.rainMm).nonNulls;
  final codes = day.map((h) => h.code).nonNulls;
  return WxDay(
    dayStartUtc: start,
    minC: minOf(day.map((h) => h.tempC)),
    maxC: maxOf(day.map((h) => h.tempC)),
    rainMm: rain.isEmpty ? null : rain.fold<double>(0, (a, b) => a + b),
    rainProbPct: maxOf(day.map((h) => h.rainProbPct)),
    windMaxKmh: maxOf(day.map((h) => h.windKmh)),
    gustMaxKmh: maxOf(day.map((h) => h.gustKmh)),
    windFromDeg: dominantDirection(day),
    uvMax: maxOf(day.map((h) => h.uv)),
    code: codes.isEmpty ? null : codes.reduce(math.max),
  );
}

/// Speed-weighted mean of wind directions; null when calm or unknown.
double? dominantDirection(Iterable<WxHour> hours) {
  var x = 0.0;
  var y = 0.0;
  for (final h in hours) {
    final deg = h.windFromDeg;
    final kmh = h.windKmh;
    if (deg == null || kmh == null) continue;
    final rad = deg * math.pi / 180;
    x += kmh * math.sin(rad);
    y += kmh * math.cos(rad);
  }
  if (x.abs() < 1e-9 && y.abs() < 1e-9) return null;
  return (math.atan2(x, y) * 180 / math.pi + 360) % 360;
}
