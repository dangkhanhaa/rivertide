import 'dart:convert';

import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/calc/geo/vietnam_bounds.dart';
import 'package:rivertide/core/format/text_fold.dart';

enum PlaceKind { city, ward, bridge, ferry, wharf }

/// A named place from the bundled OpenStreetMap extract (tools/places).
class Place {
  Place({required this.name, required this.kind, required this.lat, required this.lon})
    : folded = TextFold.fold(name);

  final String name;
  final PlaceKind kind;
  final double lat;
  final double lon;

  /// Accent-free lower-case name, precomputed for fast search.
  final String folded;
}

/// Parses `[[name, kind, lat, lon], ...]`; malformed rows are skipped
/// (the file is ours but still checked: type, range, size).
List<Place> parsePlaces(String body) {
  final rows = jsonDecode(body);
  if (rows is! List) return const [];
  final out = <Place>[];
  for (final r in rows) {
    if (r case [final String name, final String kind, final num lat, final num lon]
        when name.isNotEmpty &&
            name.length <= 80 &&
            isInVietnamBounds(lat.toDouble(), lon.toDouble())) {
      final k = PlaceKind.values.where((v) => v.name == kind).firstOrNull;
      if (k != null) out.add(Place(name: name, kind: k, lat: lat.toDouble(), lon: lon.toDouble()));
    }
  }
  return out;
}

/// Most results listed under the stations.
const int placeSearchMax = 8;

/// Places whose name contains every word of [query] (accent-insensitive);
/// names starting with the query first; then, like a map app, the nearest to
/// [near] (the area being viewed) or, without it, cities/bridges before wards.
/// The same name within ~3 km is listed once (a bridge has two carriageways).
List<Place> searchPlaces(
  List<Place> places,
  String query, {
  int max = placeSearchMax,
  ({double lat, double lon})? near,
}) {
  final q = TextFold.fold(query);
  if (q.length < 2) return const [];
  final words = q.split(' ');
  final hits = places.where((p) => words.every(p.folded.contains)).toList()
    ..sort((a, b) {
      final ap = a.folded.startsWith(q) || a.folded.contains(' $q') ? 0 : 1;
      final bp = b.folded.startsWith(q) || b.folded.contains(' $q') ? 0 : 1;
      if (ap != bp) return ap - bp;
      if (near != null) return distanceKm(a, near).compareTo(distanceKm(b, near));
      final byKind = a.kind.index.compareTo(b.kind.index);
      return byKind != 0 ? byKind : a.name.length.compareTo(b.name.length);
    });
  final out = <Place>[];
  for (final p in hits) {
    final dup = out.any(
      (o) => o.name == p.name && (o.lat - p.lat).abs() < 0.03 && (o.lon - p.lon).abs() < 0.03,
    );
    if (!dup) out.add(p);
    if (out.length >= max) break;
  }
  return out;
}

/// Nearest city/town to [p] (itself excluded), so same-named bridges or
/// wards can be told apart in the list ("gần Hà Nội").
Place? nearestTown(List<Place> places, Place p) {
  Place? best;
  var bestD = double.infinity;
  for (final c in places) {
    if (c.kind != PlaceKind.city || identical(c, p)) continue;
    // Equirectangular distance is enough to rank neighbours.
    final dLat = c.lat - p.lat;
    final dLon = (c.lon - p.lon) * 0.95; // cos(18°), mid-Vietnam
    final d = dLat * dLat + dLon * dLon;
    if (d < bestD) {
      bestD = d;
      best = c;
    }
  }
  return best;
}

double distanceKm(Place p, ({double lat, double lon}) from) =>
    haversineKm(from.lat, from.lon, p.lat, p.lon);

/// Same row format as the bundled file, for the "recent searches" setting.
String encodePlaces(List<Place> places) => jsonEncode([
  for (final p in places) [p.name, p.kind.name, p.lat, p.lon],
]);
