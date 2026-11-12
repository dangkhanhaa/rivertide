import 'package:collection/collection.dart';
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

/// Per-day astronomy reused for all 24 hours of that day.
class _DayAstro {
  _DayAstro(this.solunar, this.sunriseUtc, this.sunsetUtc, this.springNeap);

  final SolunarDay solunar;
  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;
  final SpringNeap? springNeap;
}

/// Hourly fishing scores (fs-1, PROJECT.md 9.6) for [days] Vietnam days from [fromDayUtc].
List<FishingHourScore> scoreStationHours({
  required StationTide tide,
  required List<WeatherHour> weather,
  required DateTime fromDayUtc,
  int days = 7,
}) {
  final byHour = {for (final w in weather) w.timeUtc: w};
  final station = tide.station;
  final scores = <FishingHourScore>[];
  for (var d = 0; d < days; d++) {
    final dayStart = fromDayUtc.add(Duration(days: d));
    final astro = _astroFor(dayStart, station.lat, station.lon, tide.prediction);
    for (var h = 0; h < 24; h++) {
      final hourUtc = dayStart.add(Duration(hours: h));
      scores.add(scoreHour(_input(hourUtc, tide.prediction, astro, byHour)));
    }
  }
  return scores;
}

/// One hour's score from tide and astronomy only (no weather): the quick
/// estimate behind map pins whose weather is not loaded yet.
FishingHourScore scoreStationHourQuick(StationTide tide, DateTime hourUtc) {
  final station = tide.station;
  final dayStart = TimeFormat.vnDayStartUtc(hourUtc);
  final astro = _astroFor(dayStart, station.lat, station.lon, tide.prediction);
  return scoreHour(_input(hourUtc, tide.prediction, astro, const {}));
}

_DayAstro _astroFor(DateTime dayStartUtc, double lat, double lon, TideSeries? prediction) {
  final vn = TimeFormat.toVn(dayStartUtc);
  final sun = sunTimes(year: vn.year, month: vn.month, day: vn.day, lat: lat, lon: lon);
  final solunar = solunarForDay(year: vn.year, month: vn.month, day: vn.day, lat: lat, lon: lon);
  return _DayAstro(solunar, sun.sunrise, sun.sunset, prediction?.springNeapAt(dayStartUtc));
}

FishingHourInput _input(
  DateTime hourUtc,
  TideSeries? prediction,
  _DayAstro astro,
  Map<DateTime, WeatherHour> weather,
) {
  // Score the middle of the hour: that is when someone fishing "at 6h" is there.
  final mid = hourUtc.add(const Duration(minutes: 30));
  final w = weather[hourUtc];
  final pressure3hAgo = weather[hourUtc.subtract(const Duration(hours: 3))]?.pressureHpa;
  final pressureNow = w?.pressureHpa;
  return FishingHourInput(
    hourUtc: hourUtc,
    hasTide: prediction != null,
    minutesToTurn: prediction == null ? null : _minutesToTurn(prediction, mid),
    springNeap: astro.springNeap,
    solunar: solunarAt(mid, astro.solunar),
    isSolunarGoodDay: astro.solunar.isGoodDay,
    sunriseUtc: astro.sunriseUtc,
    sunsetUtc: astro.sunsetUtc,
    pressureDelta3hHpa: pressureNow == null || pressure3hAgo == null
        ? null
        : pressureNow - pressure3hAgo,
    windKmh: w?.windKmh,
    gustKmh: w?.gustKmh,
    rainMmPerH: w?.precipitationMm,
    cloudPct: w?.cloudPct,
    weatherCode: w?.weatherCode,
    capeJPerKg: w?.capeJPerKg,
    precipProbPct: w?.precipProbPct,
  );
}

int? _minutesToTurn(TideSeries prediction, DateTime t) {
  final candidates = [prediction.previousExtreme(t), prediction.nextExtreme(t)].nonNulls;
  if (candidates.isEmpty) return null;
  return candidates.map((e) => e.timeUtc.difference(t).inMinutes.abs()).min;
}
