import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/calc/tide/observation.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/config/cache_ttl.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/stations/data/ioc_parser.dart';
import 'package:rivertide/features/stations/data/observation_codec.dart';
import 'package:rivertide/features/stations/data/remote_sources.dart';
import 'package:rivertide/features/stations/domain/station.dart';

/// Keeps up to 30 days of 10-minute IOC means per station on the device and only
/// downloads what is new (IOC sends every sensor at 1-minute resolution: ~0.5 MB/day).
class ObservationStore {
  ObservationStore({required this._remote, required this._db, required this._clock});

  final RemoteSources _remote;
  final AppDatabase _db;
  final Clock _clock;

  static const Duration keep = Duration(days: 30);
  static const Duration firstFetch = Duration(days: 3);
  static const Duration overlap = Duration(hours: 1);

  Future<Cached<List<WaterObservation>>> load(
    Station station, {
    required double datumOffsetCm,
    bool forceRefresh = false,
  }) async {
    final code = station.iocCode;
    final sensor = station.iocSensor;
    if (code == null || sensor == null) {
      return Cached(data: const [], fetchedAtUtc: _clock(), isStale: false);
    }
    final key = 'ioc:$code:$sensor';
    final now = _clock();
    final hit = await _db.readCache(key);
    final old = hit == null ? <WaterObservation>[] : decodeObservations(hit.payload);
    final isFresh = hit != null && now.difference(hit.fetchedAtUtc) < CacheTtl.observations;
    if (isFresh && !forceRefresh) {
      return Cached(data: old, fetchedAtUtc: hit.fetchedAtUtc, isStale: false);
    }
    final from = old.isEmpty ? now.subtract(firstFetch) : old.last.timeUtc.subtract(overlap);
    try {
      final body = await _remote.fetchIoc(code, from, now);
      final fresh = parseIocObservations(body, sensor: sensor, datumOffsetCm: datumOffsetCm);
      final merged = mergeObservations(old, fresh, now.subtract(keep));
      await _db.writeCache(key, encodeObservations(merged), now);
      return Cached(data: merged, fetchedAtUtc: now, isStale: false);
    } on AppException catch (e) {
      log.warn('ioc fetch failed', {'code': code, 'error': e.debugMessage});
      // Prediction still works offline, so an empty, stale observation list is acceptable.
      return Cached(data: old, fetchedAtUtc: hit?.fetchedAtUtc ?? now, isStale: true);
    }
  }
}
