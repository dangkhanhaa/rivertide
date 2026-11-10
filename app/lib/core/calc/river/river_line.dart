import 'dart:math' as math;

/// One vertex of a river centre-line: position + km from the mouth.
typedef RiverVertex = ({double lat, double lon, double km});

/// Where a point falls on a river line.
typedef RiverProjection = ({double km, double offsetKm});

/// Main-stem centre-line (OpenStreetMap), mouth first, km increasing upstream
/// (tools/rivers/build_rivers.py). Pure Dart.
class RiverLine {
  RiverLine({
    required this.id,
    required this.name,
    required this.mouth,
    required List<RiverVertex> points,
    required Map<String, double> stationKm,
  }) : points = List.unmodifiable(points),
       stationKm = Map.unmodifiable(stationKm) {
    if (points.length < 2) throw ArgumentError('river $id needs ≥ 2 points');
    for (var i = 1; i < points.length; i++) {
      if (points[i].km < points[i - 1].km) throw ArgumentError('river $id km must not decrease');
    }
  }

  final String id;
  final String name;
  final String mouth;
  final List<RiverVertex> points;

  /// Station id → km from the mouth.
  final Map<String, double> stationKm;

  double get lengthKm => points.last.km;

  /// Closest point of the line to ([lat], [lon]): its km and the distance
  /// from the line. Local equirectangular projection per segment (segments
  /// are ≤ a few km, error ≪ 1 %).
  RiverProjection project(double lat, double lon) {
    var bestOff = double.infinity;
    var bestKm = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final kx = 111.32 * math.cos(a.lat * math.pi / 180);
      const ky = 110.574;
      final bx = (b.lon - a.lon) * kx;
      final by = (b.lat - a.lat) * ky;
      final px = (lon - a.lon) * kx;
      final py = (lat - a.lat) * ky;
      final l2 = bx * bx + by * by;
      final t = l2 == 0 ? 0.0 : ((px * bx + py * by) / l2).clamp(0.0, 1.0);
      final dx = px - t * bx;
      final dy = py - t * by;
      final off = math.sqrt(dx * dx + dy * dy);
      if (off < bestOff) {
        bestOff = off;
        bestKm = a.km + t * (b.km - a.km);
      }
    }
    return (km: bestKm, offsetKm: bestOff);
  }
}
