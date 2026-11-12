import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/geo/admin_provider.dart';
import 'package:rivertide/features/map/domain/place.dart';

/// Everything the search box looks through, loaded on the first search and
/// kept (works with no network): the 34 provinces and ~3 300 wards/communes
/// of 2025, then bridges, wharves, ferries, towns and villages (OSM).
final FutureProvider<List<Place>> placeIndexProvider = FutureProvider((ref) async {
  final admin = await ref.watch(adminIndexProvider.future);
  final named = parsePlaces(await rootBundle.loadString('assets/data/places.json', cache: false));
  return [
    for (final p in admin.provinces)
      if (p.rings.isNotEmpty)
        Place(
          name: p.name,
          kind: PlaceKind.province,
          lat: _mean(p.rings.first, 0),
          lon: _mean(p.rings.first, 1),
        ),
    for (final c in admin.communes)
      Place(
        name: c.name,
        kind: PlaceKind.commune,
        lat: c.lat,
        lon: c.lon,
        area: admin.provinceOf(c),
      ),
    ...named,
  ];
});

/// Average of every other value of a flat [lat, lon, …] ring.
double _mean(List<double> ring, int offset) {
  var sum = 0.0;
  var n = 0;
  for (var i = offset; i < ring.length; i += 2) {
    sum += ring[i];
    n++;
  }
  return n == 0 ? 0 : sum / n;
}
