import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/config/cache_ttl.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/data/cached_fetcher.dart';
import 'package:rivertide/features/stations/data/flood_parser.dart';
import 'package:rivertide/features/stations/data/marine_series.dart';
import 'package:rivertide/features/stations/data/observation_store.dart';
import 'package:rivertide/features/stations/data/open_meteo_parser.dart';
import 'package:rivertide/features/stations/data/point_tide_source.dart';
import 'package:rivertide/features/stations/data/remote_sources.dart';
import 'package:rivertide/features/stations/data/river_tide_source.dart';
import 'package:rivertide/features/stations/data/rivers_parser.dart';
import 'package:rivertide/features/stations/data/tide_asset_parser.dart';
import 'package:rivertide/features/stations/domain/point_id.dart';
import 'package:rivertide/features/stations/domain/river_flow.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_repository.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

class StationRepositoryImpl implements StationRepository {
  StationRepositoryImpl({
    required RemoteSources remote,
    required AppDatabase db,
    required this._loadAsset,
    required Clock clock,
  }) : _remote = remote,
       _clock = clock,
       _observations = ObservationStore(remote: remote, db: db, clock: clock),
       _fetcher = CachedFetcher(db: db, clock: clock) {
    _river = RiverTideSource(
      remote: remote,
      fetcher: _fetcher,
      loadAsset: _loadAsset,
      clock: clock,
    );
    _points = PointTideSource(
      catalog: getAll,
      sea: _modelTide,
      river: _river.tide,
      rivers: getRivers,
      reach: _river.reachTide,
      clock: clock,
    );
  }

  final RemoteSources _remote;
  final AssetLoader _loadAsset;
  final Clock _clock;
  final ObservationStore _observations;
  final CachedFetcher _fetcher;
  late final RiverTideSource _river;
  late final PointTideSource _points;
  List<Station>? _catalog;

  @override
  Future<List<Station>> getAll() async => _catalog ??= await _readCatalog();

  List<RiverLine>? _riverLines;

  /// Mapped main-stem river lines with station km (assets/data/rivers.json).
  @override
  Future<List<RiverLine>> getRivers() async {
    final cached = _riverLines;
    if (cached != null) return cached;
    final body = await _loadAsset('assets/data/rivers.json');
    return _riverLines = body == null ? const [] : parseRivers(body);
  }

  Future<List<Station>> _readCatalog() async {
    final body = await _loadAsset('assets/data/stations.json');
    if (body == null) throw const NotFoundException('stations.json');
    final Object? decoded = jsonDecode(body);
    if (decoded case {'stations': final List<Object?> rows}) {
      return [
        for (final r in rows)
          if (r is Map<String, Object?>) Station.fromJson(r),
      ];
    }
    throw const ParseException('stations.json shape');
  }

  @override
  Future<Station> getById(String id) async {
    if (PointId.toStation(id) case final p?) return p;
    final station = (await getAll()).firstWhereOrNull((s) => s.id == id);
    if (station == null) throw NotFoundException('station $id');
    return station;
  }

  @override
  Future<Cached<StationTide>> getTide(Station station, {bool forceRefresh = false}) =>
      station.id.startsWith(PointId.prefix)
      ? _points.tide(station, forceRefresh: forceRefresh)
      : switch (station.kind) {
          StationKind.gauge => _gaugeTide(station, forceRefresh),
          StationKind.model => _modelTide(station, forceRefresh: forceRefresh),
          StationKind.river ||
          StationKind.riverDaily => _river.tide(station, forceRefresh: forceRefresh),
        };

  Future<Cached<StationTide>> _gaugeTide(Station station, bool forceRefresh) async {
    final asset = await _loadTideAssets(station);
    final obs = await _observations.load(
      station,
      datumOffsetCm: asset?.obsDatumOffsetCm ?? 0,
      forceRefresh: forceRefresh,
    );
    return Cached(
      data: StationTide(
        station: station,
        observations: obs.data,
        prediction: asset?.series,
        predictionKind: LevelDataKind.forecast,
        model: asset?.model,
      ),
      fetchedAtUtc: obs.fetchedAtUtc,
      isStale: obs.isStale,
    );
  }

  /// Current year + next year joined so countdowns work across New Year.
  Future<TideAsset?> _loadTideAssets(Station station) async {
    final prefix = station.tideAsset;
    if (prefix == null) return null;
    final year = _clock().year;
    TideAsset? current;
    for (final y in [year, year + 1]) {
      final body = await _loadAsset('assets/tide/${prefix}_$y.json');
      if (body == null) continue;
      final parsed = parseTideAsset(body);
      current = current == null
          ? parsed
          : (
              series: current.series.append(parsed.series),
              model: current.model,
              obsDatumOffsetCm: current.obsDatumOffsetCm,
            );
    }
    return current;
  }

  Future<Cached<StationTide>> _modelTide(Station station, {bool forceRefresh = false}) async {
    final cached = await _cachedFetch(
      'marine:${station.id}',
      CacheTtl.marine,
      forceRefresh,
      () => _remote.fetchMarine(station.lat, station.lon),
    );
    return Cached(
      data: StationTide(
        station: station,
        observations: const [],
        prediction: marineToSeries(parseMarineSeaLevel(cached.data)),
        predictionKind: LevelDataKind.forecast,
        model: openMeteoMarineModel,
      ),
      fetchedAtUtc: cached.fetchedAtUtc,
      isStale: cached.isStale,
    );
  }

  @override
  Future<Cached<RiverFlow?>> getFlow(Station station, {bool forceRefresh = false}) async {
    // Key on ~1 km so nearby taps share one request.
    final key = 'flood:${station.lat.toStringAsFixed(2)},${station.lon.toStringAsFixed(2)}';
    final cached = await _cachedFetch(
      key,
      CacheTtl.flood,
      forceRefresh,
      () => _remote.fetchFlood(station.lat, station.lon),
    );
    return Cached(
      data: parseMainStemFlow(cached.data),
      fetchedAtUtc: cached.fetchedAtUtc,
      isStale: cached.isStale,
    );
  }

  @override
  Future<Cached<List<WeatherHour>>> getWeather(Station station, {bool forceRefresh = false}) async {
    final cached = await _cachedFetch(
      'wx:${station.id}',
      CacheTtl.weather,
      forceRefresh,
      () => _remote.fetchWeather(station.lat, station.lon, weatherFields),
    );
    return Cached(
      data: parseWeather(cached.data),
      fetchedAtUtc: cached.fetchedAtUtc,
      isStale: cached.isStale,
    );
  }

  Future<Cached<String>> _cachedFetch(
    String key,
    Duration ttl,
    bool forceRefresh,
    Future<String> Function() fetch,
  ) => _fetcher.get(key, ttl, fetch, forceRefresh: forceRefresh);
}
