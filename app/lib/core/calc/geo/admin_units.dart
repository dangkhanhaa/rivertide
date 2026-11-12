import 'dart:convert';
import 'dart:math' as math;

/// One administrative unit with its simplified outer boundary rings, each a
/// flat [lat, lon, lat, lon, …] list (tools/places/fetch_admin.py).
class AdminArea {
  AdminArea({
    required this.name,
    required this.rings,
    this.provinceIndex = -1,
    double? lat,
    double? lon,
  }) : _box = _bbox(rings),
       lat = lat ?? 0,
       lon = lon ?? 0;

  final String name;
  final List<List<double>> rings;

  /// Province of a ward/commune (index into [AdminIndex.provinces]).
  final int provinceIndex;

  /// Label point (commune centre) used for search results.
  final double lat;
  final double lon;
  final ({double minLat, double maxLat, double minLon, double maxLon}) _box;

  bool contains(double lat, double lon) {
    final b = _box;
    if (lat < b.minLat || lat > b.maxLat || lon < b.minLon || lon > b.maxLon) return false;
    var inside = false;
    for (final r in rings) {
      final n = r.length ~/ 2;
      for (var i = 0, j = n - 1; i < n; j = i++) {
        final (yi, xi, yj, xj) = (r[2 * i], r[2 * i + 1], r[2 * j], r[2 * j + 1]);
        if ((yi > lat) != (yj > lat) && lon < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
          inside = !inside;
        }
      }
    }
    return inside;
  }

  static ({double minLat, double maxLat, double minLon, double maxLon}) _bbox(
    List<List<double>> rings,
  ) {
    var (minLat, maxLat, minLon, maxLon) = (90.0, -90.0, 180.0, -180.0);
    for (final r in rings) {
      for (var i = 0; i + 1 < r.length; i += 2) {
        minLat = math.min(minLat, r[i]);
        maxLat = math.max(maxLat, r[i]);
        minLon = math.min(minLon, r[i + 1]);
        maxLon = math.max(maxLon, r[i + 1]);
      }
    }
    return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon);
  }
}

/// Vietnam's provinces and wards/communes (2025 units, OpenStreetMap).
class AdminIndex {
  AdminIndex({required this.provinces, required this.communes});

  final List<AdminArea> provinces;
  final List<AdminArea> communes;

  String? provinceOf(AdminArea commune) =>
      commune.provinceIndex >= 0 && commune.provinceIndex < provinces.length
      ? provinces[commune.provinceIndex].name
      : null;

  /// Ward/commune and province containing the point; either may be null
  /// (at sea, or across the border).
  ({String? commune, String? province}) lookup(double lat, double lon) {
    final c = communes.where((a) => a.contains(lat, lon)).firstOrNull;
    if (c != null) return (commune: c.name, province: provinceOf(c));
    return (
      commune: null,
      province: provinces.where((p) => p.contains(lat, lon)).firstOrNull?.name,
    );
  }
}

/// Parses admin.json; malformed entries are skipped (checked: types, ranges).
AdminIndex parseAdminIndex(String body) {
  final root = jsonDecode(body);
  if (root is! Map<String, Object?>) return AdminIndex(provinces: const [], communes: const []);
  List<List<double>>? rings(Object? v) {
    if (v is! List) return null;
    final out = <List<double>>[];
    for (final r in v) {
      if (r is! List || r.length < 8 || r.length.isOdd) continue;
      final ring = [
        for (final x in r)
          if (x is num) x.toDouble(),
      ];
      if (ring.length != r.length) continue;
      out.add(ring);
    }
    return out.isEmpty ? null : out;
  }

  final provinces = <AdminArea>[];
  for (final p in (root['p'] as List?) ?? const []) {
    if (p case [final String name, final Object? r] when name.length <= 80) {
      if (rings(r) case final rs?) provinces.add(AdminArea(name: name, rings: rs));
    }
  }
  final communes = <AdminArea>[];
  for (final c in (root['c'] as List?) ?? const []) {
    if (c case [final String name, final int pi, final num lat, final num lon, final Object? r]
        when name.length <= 80 && lat.abs() <= 90 && lon.abs() <= 180) {
      if (rings(r) case final rs?) {
        communes.add(
          AdminArea(
            name: name,
            rings: rs,
            provinceIndex: pi,
            lat: lat.toDouble(),
            lon: lon.toDouble(),
          ),
        );
      }
    }
  }
  return AdminIndex(provinces: provinces, communes: communes);
}
