import 'dart:math' as math;

/// Mean Earth radius (IUGG); spherical model error ≤ ~0.5 %, fine for UI.
const double earthRadiusKm = 6371.0088;

double degToRad(double deg) => deg * math.pi / 180;

/// Great-circle distance between two WGS84 points (lat before lon).
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  final dLat = degToRad(lat2 - lat1);
  final dLon = degToRad(lon2 - lon1);
  final a =
      _sq(math.sin(dLat / 2)) +
      math.cos(degToRad(lat1)) * math.cos(degToRad(lat2)) * _sq(math.sin(dLon / 2));
  // Clamp guards against a > 1 from float error on antipodal points.
  final c = 2 * math.asin(math.sqrt(math.min(1, a)));
  return earthRadiusKm * c;
}

double _sq(double x) => x * x;
