import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/features/stations/application/station_fishing.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

part 'hour_extras_provider.g.dart';

typedef StationFishing = ({
  List<FishingHourScore> hours,
  List<WeatherHour> weather,
  DateTime fetchedAtUtc,
  bool isStale,
});

/// 7 days of hourly fishing scores from today (Vietnam day) for one station.
@riverpod
Future<StationFishing> stationFishing(Ref ref, String id) async {
  final today = TimeFormat.vnDayStartUtc(ref.watch(clockProvider)());
  final tide = await ref.watch(stationTideProvider(id).future);
  final weather = await ref.watch(stationWeatherProvider(id).future);
  return (
    hours: scoreStationHours(tide: tide.data, weather: weather.data, fromDayUtc: today),
    weather: weather.data,
    fetchedAtUtc: weather.fetchedAtUtc,
    isStale: weather.isStale || tide.isStale,
  );
}

typedef HourExtras = ({WeatherHour? weather, double? fishingScore});

/// Weather + fishing score for one hour, for the F-TIDE-09 detail panel.
@riverpod
Future<HourExtras> hourExtras(Ref ref, String id, DateTime hourUtc) async {
  final fishing = await ref.watch(stationFishingProvider(id).future);
  return (
    weather: fishing.weather.firstWhereOrNull((w) => w.timeUtc == hourUtc),
    fishingScore: fishing.hours.firstWhereOrNull((h) => h.hourUtc == hourUtc)?.score,
  );
}
