import 'dart:math' as math;

import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/astro/solunar.dart';
import 'package:rivertide/core/calc/astro/sun.dart';
import 'package:rivertide/core/calc/fishing/fishing_input.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

/// Per-day astronomy and tide facts reused for every sample of that day.
class _Day {
  _Day(this.solunar, this.sunriseUtc, this.sunsetUtc, this.springNeap, this.maxRate);

  final SolunarDay solunar;
  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;
  final SpringNeap? springNeap;

  /// Fastest |level change| of the day (cm/h); the tide score is relative to it.
  final double? maxRate;
}

/// Each hour is scored from these instants (fs-2).
const List<int> _sampleMinutes = [0, 15, 30, 45];

/// Hourly fishing scores (fs-3, PROJECT.md 9.6) for [days] Vietnam days from [fromDayUtc].
List<FishingHourScore> scoreStationHours({
  required StationTide tide,
  required List<WeatherHour> weather,
  required DateTime fromDayUtc,
  int days = 7,
}) {
  final byHour = {for (final w in weather) w.timeUtc: w};
  final station = tide.station;
  final runoff = runsWithoutTide(tide);
  final scores = <FishingHourScore>[];
  for (var d = 0; d < days; d++) {
    final dayStart = fromDayUtc.add(Duration(days: d));
    final day = _dayFor(dayStart, station.lat, station.lon, tide.prediction);
    for (var h = 0; h < 24; h++) {
      final hour = dayStart.add(Duration(hours: h));
      scores.add(
        _scoreHour(
          hour,
          tide.prediction,
          day,
          byHour,
          rain24: runoff ? _rain24(byHour, hour) : null,
        ),
      );
    }
  }
  return scores;
}

/// A map point on running water (stream, river) without any tide curve:
/// rain runoff, not the tide, moves its water (fs-3).
bool runsWithoutTide(StationTide tide) =>
    tide.prediction == null && (tide.water?.kind.isFlowing ?? false);

/// Rain over the 24 hours before [hourUtc]; null when fewer than 18 of those
/// hours are known (the forecast starts one day back).
double? _rain24(Map<DateTime, WeatherHour> byHour, DateTime hourUtc) {
  var sum = 0.0;
  var known = 0;
  for (var k = 1; k <= 24; k++) {
    final mm = byHour[hourUtc.subtract(Duration(hours: k))]?.precipitationMm;
    if (mm == null) continue;
    sum += mm;
    known++;
  }
  return known >= 18 ? sum : null;
}

/// One hour's score from tide and astronomy only (no weather): the quick
/// estimate behind map pins whose weather is not loaded yet.
FishingHourScore scoreStationHourQuick(StationTide tide, DateTime hourUtc) {
  final station = tide.station;
  final dayStart = TimeFormat.vnDayStartUtc(hourUtc);
  final day = _dayFor(dayStart, station.lat, station.lon, tide.prediction);
  return _scoreHour(hourUtc, tide.prediction, day, const {});
}

FishingHourScore _scoreHour(
  DateTime hourUtc,
  TideSeries? prediction,
  _Day day,
  Map<DateTime, WeatherHour> weather, {
  double? rain24,
}) {
  // The moon's phase barely moves within an hour: compute it once, not per
  // 15-minute sample (it is the costliest part of a score on slow phones).
  final mid = hourUtc.add(const Duration(minutes: 30));
  final moon = (fraction: moonIllumination(mid).fraction, days: daysFromNewOrFullMoon(mid));
  return scoreHour(hourUtc, [
    for (final m in _sampleMinutes)
      _input(hourUtc.add(Duration(minutes: m)), hourUtc, prediction, day, weather, moon, rain24),
  ]);
}

/// Sun + solunar per (place, day). Pure functions of their key, so caching is
/// safe; it matters because the map re-scores every station after each pan
/// and the moon search costs far more than the score itself.
final Map<String, (SolunarDay, SunTimes)> _skyCache = {};
const int _skyCacheMax = 4000;

_Day _dayFor(DateTime dayStartUtc, double lat, double lon, TideSeries? prediction) {
  final vn = TimeFormat.toVn(dayStartUtc);
  final key = '$lat,$lon,${vn.year}-${vn.month}-${vn.day}';
  final (solunar, sun) = _skyCache[key] ??= () {
    if (_skyCache.length >= _skyCacheMax) _skyCache.clear();
    return (
      solunarForDay(year: vn.year, month: vn.month, day: vn.day, lat: lat, lon: lon),
      sunTimes(year: vn.year, month: vn.month, day: vn.day, lat: lat, lon: lon),
    );
  }();
  return _Day(
    solunar,
    sun.sunrise,
    sun.sunset,
    prediction?.springNeapAt(dayStartUtc),
    prediction == null ? null : _maxRate(prediction, dayStartUtc),
  );
}

double? _maxRate(TideSeries prediction, DateTime dayStartUtc) {
  double? best;
  for (var m = 0; m < 24 * 60; m += 20) {
    final r = prediction.rateCmPerHAt(dayStartUtc.add(Duration(minutes: m)))?.abs();
    if (r != null && (best == null || r > best)) best = r;
  }
  return best;
}

FishingHourInput _input(
  DateTime t,
  DateTime hourUtc,
  TideSeries? prediction,
  _Day day,
  Map<DateTime, WeatherHour> weather,
  ({double fraction, double days}) moon,
  double? rain24,
) {
  final w = weather[hourUtc];
  final yesterday = weather[hourUtc.subtract(const Duration(days: 1))];
  final p = w?.pressureHpa;
  final p24 = yesterday?.pressureHpa;
  final temp = w?.temperatureC;
  final temp24 = yesterday?.temperatureC;
  final tide = prediction == null ? null : _tideAt(prediction, t, day.maxRate);
  return FishingHourInput(
    timeUtc: t,
    hasTide: prediction != null,
    tideRateNorm: tide?.rateNorm,
    minutesSinceTurn: tide?.sinceTurn,
    tideRising: tide?.rising ?? false,
    springNeap: day.springNeap,
    solunar: solunarAt(t, day.solunar),
    solunarStrength: solunarStrengthAt(t, day.solunar),
    daysFromNewOrFull: moon.days,
    moonFraction: moon.fraction,
    sunriseUtc: day.sunriseUtc,
    sunsetUtc: day.sunsetUtc,
    pressureDelta24hHpa: p == null || p24 == null ? null : p - p24,
    temperatureC: temp,
    temperatureDrop24h: temp == null || temp24 == null ? 0 : math.max(0, temp24 - temp),
    windKmh: w?.windKmh,
    gustKmh: w?.gustKmh,
    rainMmPerH: w?.precipitationMm,
    cloudPct: w?.cloudPct,
    weatherCode: w?.weatherCode,
    capeJPerKg: w?.capeJPerKg,
    precipProbPct: w?.precipProbPct,
    rain24hMm: rain24,
  );
}

({double rateNorm, int? sinceTurn, bool rising})? _tideAt(
  TideSeries prediction,
  DateTime t,
  double? maxRate,
) {
  final rate = prediction.rateCmPerHAt(t);
  if (rate == null || maxRate == null || maxRate <= 0) return null;
  final last = prediction.previousExtreme(t);
  return (
    rateNorm: (rate.abs() / maxRate).clamp(0.0, 1.0),
    sinceTurn: last == null ? null : t.difference(last.timeUtc).inMinutes,
    rising: rate > 0,
  );
}
