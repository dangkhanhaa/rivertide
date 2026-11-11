import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';

/// Upper bound so a long watch list does not hammer the free APIs at start.
const int maxPrefetchPlaces = 20;

/// Fills the on-device cache for every saved place (water level, 7-day
/// weather, river flow) when the app opens, so they still show — marked
/// "cập nhật lúc …" — out on the river without signal.
Future<void> prefetchSavedPlaces(WidgetRef ref) async {
  final List<String> ids;
  try {
    // Straight from the database: an auto-dispose provider read once may be
    // disposed before it emits.
    ids = await ref.read(appDatabaseProvider).watchFavoriteIds().first;
  } on Exception catch (e) {
    log.warn('prefetch: saved places unreadable', {'error': '$e'});
    return;
  }
  final repo = ref.read(stationRepositoryProvider);
  var done = 0;
  for (final id in ids.take(maxPrefetchPlaces)) {
    try {
      final station = await repo.getById(id);
      await repo.getTide(station);
      await repo.getWeather(station);
      await repo.getFlow(station);
      done++;
    } on AppException catch (e) {
      // No id in the log: a saved point's id holds its exact coordinates.
      log.info('prefetch: one place skipped', {'error': e.debugMessage});
    }
  }
  log.info('prefetch: saved places cached', {'count': done});
}
