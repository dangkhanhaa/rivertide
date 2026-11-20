import 'dart:convert';

import 'package:rivertide/core/calc/geo/coast_distance.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';
import 'package:rivertide/core/config/cache_ttl.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/stations/data/cached_fetcher.dart';
import 'package:rivertide/features/stations/data/osm_water_parser.dart';
import 'package:rivertide/features/stations/data/remote_sources.dart';
import 'package:rivertide/features/stations/data/water_hint_store.dart';
import 'package:rivertide/features/stations/domain/point_water.dart';
import 'package:rivertide/features/stations/domain/station.dart';

/// Overpass gets this long per call (connect included).
const Duration overpassTimeout = Duration(seconds: 8);

/// OSM finding no water within its radius means land only this far from the
/// coast: the sea itself is not an OSM area, so nearer it could be sea.
const double osmLandMinSeaKm = 2;

/// Everything the water verdict reads besides the map tap (P2-47/P2-52):
/// remembered hints, coast distance (bundled), ground height (Open-Meteo)
/// and OpenStreetMap around the point (Overpass).
class PointWaterData {
  PointWaterData({
    required this._remote,
    required this._fetcher,
    required this._hints,
    required this._loadAsset,
  });

  final RemoteSources _remote;
  final CachedFetcher _fetcher;
  final WaterHintStore _hints;
  final AssetLoader _loadAsset;
  CoastLines? _coast;

  Future<WaterHint?> hint(String pointId) => _hints.get(pointId);

  Future<void> saveHint(String pointId, WaterHint hint) => _hints.put(pointId, hint);

  /// Km to the coast; null when the bundled coast file is missing.
  Future<double?> seaKm(double lat, double lon) async {
    final coast = _coast ??= parseCoast(await _loadAsset('assets/data/coast.json') ?? '');
    return coast.isEmpty ? null : coast.distanceKm(lat, lon);
  }

  /// Ground height (m); null when the service fails or answers nonsense.
  Future<double?> elevationM(double lat, double lon) async {
    final key = 'elev:${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';
    try {
      final cached = await _fetcher.get(
        key,
        CacheTtl.elevation,
        () => _remote.fetchElevation(lat, lon),
      );
      return parseElevation(cached.data);
    } on AppException catch (e) {
      log.info('elevation unavailable', {'error': e.debugMessage});
      return null;
    }
  }

  /// OpenStreetMap water and structures at [point]; null when Overpass is
  /// unreachable or busy (the screens then simply go without).
  Future<PointSurroundings?> surroundings(Station point) async {
    try {
      final cached = await _fetcher.get('osm:${point.id}', CacheTtl.osmWater, () async {
        final body = await _remote.fetchOverpass(
          overpassWaterQuery(point.lat, point.lon),
          timeout: overpassTimeout,
        );
        // Throws before caching: a broken answer must not stick for 30 days.
        parseOverpassWater(body, point.lat, point.lon);
        return body;
      });
      final parsed = parseOverpassWater(cached.data, point.lat, point.lon);
      if (parsed.water != null) return parsed;
      final km = await seaKm(point.lat, point.lon);
      final land = km != null && km > osmLandMinSeaKm;
      return PointSurroundings(
        water: land ? const WaterHint(kind: WaterKind.land, source: WaterHintSource.osm) : null,
        structures: parsed.structures,
      );
    } on AppException catch (e) {
      log.info('overpass unavailable', {'error': e.debugMessage});
      return null;
    }
  }
}

/// `{"elevation":[12.0]}` → 12.0; null outside −100…9000 m or malformed.
double? parseElevation(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return null;
  }
  if (decoded case {'elevation': [final num v]} when v >= -100 && v <= 9000) {
    return v.toDouble();
  }
  return null;
}
