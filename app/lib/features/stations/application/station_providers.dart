import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/network/dio_client.dart';
import 'package:rivertide/features/stations/data/remote_sources.dart';
import 'package:rivertide/features/stations/data/station_repository_impl.dart';
import 'package:rivertide/features/stations/domain/river_flow.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_repository.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

part 'station_providers.g.dart';

Set<String>? _assetNames;

/// Loads a bundled asset, or null when it is not in the manifest (e.g. next year's tide file).
Future<String?> _loadBundleAsset(String path) async {
  final names = _assetNames ??= (await AssetManifest.loadFromAssetBundle(rootBundle))
      .listAssets()
      .toSet();
  if (!names.contains(path)) return null;
  return await rootBundle.loadString(path);
}

@Riverpod(keepAlive: true)
StationRepository stationRepository(Ref ref) => StationRepositoryImpl(
  remote: RemoteSources(ref.watch(dioProvider)),
  db: ref.watch(appDatabaseProvider),
  loadAsset: _loadBundleAsset,
  clock: ref.watch(clockProvider),
);

@riverpod
Future<List<Station>> stationList(Ref ref) => ref.watch(stationRepositoryProvider).getAll();

@Riverpod(keepAlive: true)
Future<List<RiverLine>> riverLines(Ref ref) => ref.watch(stationRepositoryProvider).getRivers();

@riverpod
Future<Station> stationById(Ref ref, String id) => ref.watch(stationRepositoryProvider).getById(id);

@riverpod
Future<Cached<StationTide>> stationTide(Ref ref, String id) async {
  final station = await ref.watch(stationByIdProvider(id).future);
  return await ref.watch(stationRepositoryProvider).getTide(station);
}

@riverpod
Future<Cached<List<WeatherHour>>> stationWeather(Ref ref, String id) async {
  final station = await ref.watch(stationByIdProvider(id).future);
  return await ref.watch(stationRepositoryProvider).getWeather(station);
}

@riverpod
Future<Cached<RiverFlow?>> stationFlow(Ref ref, String id) async {
  final station = await ref.watch(stationByIdProvider(id).future);
  return await ref.watch(stationRepositoryProvider).getFlow(station);
}

/// Pull-to-refresh: bypass TTL then rebuild dependants.
Future<void> refreshStation(WidgetRef ref, String id) async {
  final repo = ref.read(stationRepositoryProvider);
  final station = await ref.read(stationByIdProvider(id).future);
  await Future.wait([
    repo.getTide(station, forceRefresh: true),
    repo.getWeather(station, forceRefresh: true),
  ]);
  ref
    ..invalidate(stationTideProvider(id))
    ..invalidate(stationWeatherProvider(id));
}

@riverpod
Stream<List<String>> favoriteIds(Ref ref) => ref.watch(appDatabaseProvider).watchFavoriteIds();

Future<void> toggleFavorite(WidgetRef ref, String stationId) =>
    ref.read(appDatabaseProvider).toggleFavorite(stationId);
