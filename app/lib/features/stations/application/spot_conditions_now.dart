import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/astro/sun.dart';
import 'package:rivertide/core/calc/fishing/spot_conditions.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';

/// Real conditions at a place now, for the species guide and "Cá không ăn?"
/// (P2-32): next 24 hourly scores with their part of the day, tide state and
/// the weather changes over the last 24 hours.
SpotConditions spotConditionsNow(StationView view, StationFishing fishing) {
  final now = view.nowUtc;
  final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
  final st = view.tide.data.station;
  final sunByDay = <DateTime, SunTimes>{};
  SunTimes sunOf(DateTime t) => sunByDay.putIfAbsent(TimeFormat.vnDayStartUtc(t), () {
    final vn = TimeFormat.toVn(t);
    return sunTimes(year: vn.year, month: vn.month, day: vn.day, lat: st.lat, lon: st.lon);
  });
  DayPart partOf(DateTime t) {
    final s = sunOf(t);
    return dayPartOf(t, s.sunrise, s.sunset);
  }

  final ahead = [
    for (final h in fishing.hours.where((h) => !h.hourUtc.isBefore(hour)).take(24))
      (
        hourUtc: h.hourUtc,
        score: h.score,
        part: partOf(h.hourUtc.add(const Duration(minutes: 30))),
      ),
  ];
  final byHour = {for (final w in fishing.weather) w.timeUtc: w};
  final w = byHour[hour];
  final yesterday = byHour[hour.subtract(const Duration(days: 1))];
  final rain = [
    for (var i = 1; i <= 24; i++) byHour[hour.subtract(Duration(hours: i))]?.precipitationMm,
  ].nonNulls;
  final temp = w?.temperatureC;
  final temp24 = yesterday?.temperatureC;
  final p = w?.pressureHpa;
  final p24 = yesterday?.pressureHpa;
  return SpotConditions(
    nowUtc: now,
    ahead: ahead,
    tide: view.now.state,
    nextTurnUtc: view.now.nextExtreme?.timeUtc,
    rain24hMm: rain.isEmpty ? null : rain.sum,
    tempC: temp,
    tempDrop24h: temp == null || temp24 == null ? null : temp24 - temp,
    pressureDelta24h: p == null || p24 == null ? null : p - p24,
    windKmh: w?.windKmh,
    cloudPct: w?.cloudPct,
    nowPart: partOf(now),
  );
}
