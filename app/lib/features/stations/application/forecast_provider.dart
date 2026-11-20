import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/calc/weather/wx_advice.dart';
import 'package:rivertide/core/calc/weather/wx_daily.dart';
import 'package:rivertide/core/calc/weather/wx_hour.dart';
import 'package:rivertide/core/calc/weather/wx_now.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

part 'forecast_provider.g.dart';

/// Everything the weather section shows for one place (P2-55).
typedef StationForecast = ({
  WxNow? now,

  /// From the current hour slot, [forecastHours] long at most.
  List<WxHour> hours,
  List<WxDay> days,
  List<WxAdvice> advice,
  DateTime nowUtc,
  DateTime fetchedAtUtc,
  bool isStale,
});

const int forecastHours = 48;

/// Local days asked of the summary; the API covers 7 full Vietnam days.
const int _forecastDays = 8;

WxHour toWxHour(WeatherHour w) => WxHour(
  timeUtc: w.timeUtc,
  tempC: w.temperatureC,
  feelsC: w.apparentC,
  humidityPct: w.humidityPct,
  rainMm: w.precipitationMm,
  rainProbPct: w.precipProbPct,
  code: w.weatherCode,
  pressureHpa: w.pressureHpa,
  windKmh: w.windKmh,
  gustKmh: w.gustKmh,
  windFromDeg: w.windDirDeg,
  uv: w.uvIndex,
  visibilityM: w.visibilityM,
  isDay: w.isDay,
);

/// Recomputed when the weather is refreshed or the clock enters a new hour —
/// not every minute, so the hourly strip does not rebuild needlessly.
@riverpod
Future<StationForecast> stationForecast(Ref ref, String id) async {
  DateTime floor(DateTime v) => DateTime.utc(v.year, v.month, v.day, v.hour);
  final hourUtc = ref.watch(
    minuteTickerProvider.select(
      (t) => switch (t.value) {
        final v? => floor(v),
        null => null,
      },
    ),
  );
  final nowUtc = hourUtc ?? floor(ref.read(clockProvider)());
  final cached = await ref.watch(stationWeatherProvider(id).future);
  final all = [for (final w in cached.data) toWxHour(w)]
    ..sort((a, b) => a.timeUtc.compareTo(b.timeUtc));
  final from = hourIndexAt(all, nowUtc);
  final today = TimeFormat.vnDayStartUtc(nowUtc);
  return (
    now: weatherNow(all, nowUtc),
    hours: from < 0
        ? const <WxHour>[]
        : all.sublist(from, (from + forecastHours).clamp(0, all.length)),
    days: dailyWeather(all, [for (var d = 0; d < _forecastDays; d++) today.add(Duration(days: d))]),
    advice: weatherAdvice(all, nowUtc, vnOffset),
    nowUtc: nowUtc,
    fetchedAtUtc: cached.fetchedAtUtc,
    isStale: cached.isStale,
  );
}
