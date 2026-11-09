import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';

/// Reads a bundled asset; null when it is not in the bundle.
typedef AssetLoader = Future<String?> Function(String path);

/// Stale-while-revalidate on raw bodies: fresh cache → use; else fetch; on
/// failure fall back to old cache flagged stale; no cache → rethrow.
class CachedFetcher {
  CachedFetcher({required this._db, required this._clock});

  final AppDatabase _db;
  final Clock _clock;

  Future<Cached<String>> get(
    String key,
    Duration ttl,
    Future<String> Function() fetch, {
    bool forceRefresh = false,
  }) async {
    final now = _clock();
    final hit = await _db.readCache(key);
    if (hit != null && !forceRefresh && now.difference(hit.fetchedAtUtc) < ttl) {
      return Cached(data: hit.payload, fetchedAtUtc: hit.fetchedAtUtc, isStale: false);
    }
    try {
      final body = await fetch();
      await _db.writeCache(key, body, now);
      return Cached(data: body, fetchedAtUtc: now, isStale: false);
    } on AppException catch (e) {
      log.warn('fetch failed, using cache', {'key': key, 'error': e.debugMessage});
      if (hit == null) rethrow;
      return Cached(data: hit.payload, fetchedAtUtc: hit.fetchedAtUtc, isStale: true);
    }
  }
}
