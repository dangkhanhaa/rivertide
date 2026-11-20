import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/features/stations/domain/point_water.dart';
import 'package:rivertide/features/stations/domain/river_flow.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

abstract interface class StationRepository {
  Future<List<Station>> getAll();

  Future<Station> getById(String id);

  /// Mapped main-stem river lines (with station km) used for along-river estimates.
  Future<List<RiverLine>> getRivers();

  /// Observations (last 30 days, gauge stations) + prediction for the station.
  Future<Cached<StationTide>> getTide(Station station, {bool forceRefresh = false});

  Future<Cached<List<WeatherHour>>> getWeather(Station station, {bool forceRefresh = false});

  /// Main-stem discharge near the station (GloFAS); data null where no river
  /// channel is found nearby.
  Future<Cached<RiverFlow?>> getFlow(Station station, {bool forceRefresh = false});

  /// Remembered water kind of a map point (P2-47).
  Future<WaterHint?> waterHint(String pointId);

  Future<void> saveWaterHint(String pointId, WaterHint hint);

  /// OpenStreetMap water and structures around a map point; null when the
  /// service cannot be reached (P2-52).
  Future<PointSurroundings?> surroundings(Station point);

  /// Level change (cm/h) now at points [pointKms] (km from the mouth) of the
  /// river through [station]; empty when the station has no tide model.
  Future<List<double?>> reachRates(
    Station station, {
    required double stationKm,
    required List<double> pointKms,
    required DateTime atUtc,
  });
}
