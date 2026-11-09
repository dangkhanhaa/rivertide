import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

abstract interface class StationRepository {
  Future<List<Station>> getAll();

  Future<Station> getById(String id);

  /// Observations (last 30 days, gauge stations) + prediction for the station.
  Future<Cached<StationTide>> getTide(Station station, {bool forceRefresh = false});

  Future<Cached<List<WeatherHour>>> getWeather(Station station, {bool forceRefresh = false});
}
