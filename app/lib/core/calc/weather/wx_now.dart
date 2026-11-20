import 'package:rivertide/core/calc/weather/wx_hour.dart';

/// Pressure change over 24 h. Compared with the same hour yesterday, not 3 h
/// back: in the tropics the daily air-pressure tide swings ±1.5 hPa every
/// few hours, which would read as a "trend" on a 3 h window and mean nothing.
enum PressureTrend { fallingFast, falling, steady, rising, risingFast }

/// |Δ24h| below this is steady (normal day-to-day noise).
const double pressureSteadyHpa = 2;

/// |Δ24h| at or above this is a fast change (same bar as P2-34's "áp suất
/// giảm nhanh" warning: ≥ 5 hPa within 24 h means weather is changing).
const double pressureFastHpa = 5;

PressureTrend pressureTrend(double delta24h) => switch (delta24h) {
  <= -pressureFastHpa => PressureTrend.fallingFast,
  <= -pressureSteadyHpa => PressureTrend.falling,
  >= pressureFastHpa => PressureTrend.risingFast,
  >= pressureSteadyHpa => PressureTrend.rising,
  _ => PressureTrend.steady,
};

/// Hours ahead the "chance of rain soon" looks at.
const int rainSoonHours = 3;

/// The forecast hour now plus what the "Bây giờ" header adds to it.
class WxNow {
  const WxNow({required this.hour, this.pressureDelta24h, this.rainProbSoonPct});

  /// Forecast for the current hour slot.
  final WxHour hour;

  /// Pressure now minus pressure 24 h ago (hPa); null when either is missing.
  final double? pressureDelta24h;

  /// Highest chance of rain over this hour and the next [rainSoonHours].
  final double? rainProbSoonPct;

  PressureTrend? get trend => switch (pressureDelta24h) {
    final d? => pressureTrend(d),
    null => null,
  };
}

/// Current conditions; null when [hours] does not cover [nowUtc].
WxNow? weatherNow(List<WxHour> hours, DateTime nowUtc) {
  final i = hourIndexAt(hours, nowUtc);
  if (i < 0) return null;
  final h = hours[i];
  final dayAgo = h.timeUtc.subtract(const Duration(days: 1));
  final before = hours.where((x) => x.timeUtc == dayAgo).firstOrNull?.pressureHpa;
  final p = h.pressureHpa;
  final soon = [
    for (var k = i; k < hours.length && k <= i + rainSoonHours; k++) ?hours[k].rainProbPct,
  ];
  return WxNow(
    hour: h,
    pressureDelta24h: p == null || before == null ? null : p - before,
    rainProbSoonPct: soon.isEmpty ? null : soon.reduce((a, b) => a > b ? a : b),
  );
}
