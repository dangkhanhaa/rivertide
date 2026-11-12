import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/features/map/domain/place.dart';

const _key = 'recent_places';

/// Places kept in "Tìm gần đây".
const int recentPlacesMax = 6;

/// Last searched places, newest first (stored on the device only).
class RecentPlaces extends AsyncNotifier<List<Place>> {
  @override
  Future<List<Place>> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_key);
    if (raw == null) return const [];
    try {
      return parsePlaces(raw);
    } on FormatException {
      return const [];
    }
  }

  Future<void> remember(Place p) async {
    final next = [
      p,
      for (final o in state.value ?? const <Place>[])
        if (o.name != p.name || o.lat != p.lat || o.lon != p.lon) o,
    ].take(recentPlacesMax).toList();
    state = AsyncData(next);
    await ref.read(appDatabaseProvider).writeSetting(_key, encodePlaces(next));
  }
}

final AsyncNotifierProvider<RecentPlaces, List<Place>> recentPlacesProvider = AsyncNotifierProvider(
  RecentPlaces.new,
);
