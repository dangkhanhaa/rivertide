import 'dart:convert';
import 'dart:math' as math;

import 'package:rivertide/core/calc/geo/haversine.dart';

/// Km per degree of latitude on the mean sphere.
const double _kmPerDeg = earthRadiusKm * math.pi / 180;

/// Distance (km) from a point to the segment a–b on a local flat projection:
/// exact enough below a few hundred km, which is all the callers need.
double pointToSegmentKm(
  double lat,
  double lon,
  double aLat,
  double aLon,
  double bLat,
  double bLon,
) {
  final k = math.cos(degToRad(lat));
  final ax = (aLon - lon) * k;
  final ay = aLat - lat;
  final dx = (bLon - aLon) * k;
  final dy = bLat - aLat;
  final len2 = dx * dx + dy * dy;
  final t = len2 == 0 ? 0.0 : (-(ax * dx + ay * dy) / len2).clamp(0.0, 1.0);
  final x = ax + t * dx;
  final y = ay + t * dy;
  return math.sqrt(x * x + y * y) * _kmPerDeg;
}

/// Nearest point (lat, lon) of segment a–b to the given point, and its km.
({double lat, double lon, double km}) nearestOnSegment(
  double lat,
  double lon,
  double aLat,
  double aLon,
  double bLat,
  double bLon,
) {
  final k = math.cos(degToRad(lat));
  final dx = (bLon - aLon) * k;
  final dy = bLat - aLat;
  final len2 = dx * dx + dy * dy;
  final t = len2 == 0 ? 0.0 : (((lon - aLon) * k * dx + (lat - aLat) * dy) / len2).clamp(0.0, 1.0);
  final pLat = aLat + t * (bLat - aLat);
  final pLon = aLon + t * (bLon - aLon);
  final ex = (pLon - lon) * k;
  final ey = pLat - lat;
  return (lat: pLat, lon: pLon, km: math.sqrt(ex * ex + ey * ey) * _kmPerDeg);
}

/// Simplified sea coast (assets/data/coast.json, Natural Earth 1:10m, built
/// by tools/places/build_coast.py). Wide estuaries (Soài Rạp, Hậu, Cấm) count
/// as sea there, which suits a "how far up does the tide reach" proxy.
class CoastLines {
  CoastLines(this._lines) : _boxes = [for (final l in _lines) _box(l)];

  final List<List<double>> _lines;
  final List<({double minLat, double maxLat, double minLon, double maxLon})> _boxes;

  bool get isEmpty => _lines.isEmpty;

  /// Km to the nearest coast, or null when no line is loaded.
  double? distanceKm(double lat, double lon) {
    double? best;
    final k = math.cos(degToRad(lat));
    for (var i = 0; i < _lines.length; i++) {
      final b = _boxes[i];
      // Lower bound from the box: skip lines that cannot beat the best so far.
      final dLat = math.max(0, math.max(b.minLat - lat, lat - b.maxLat));
      final dLon = math.max(0, math.max(b.minLon - lon, lon - b.maxLon)) * k;
      final bound = math.sqrt(dLat * dLat + dLon * dLon) * _kmPerDeg;
      if (best != null && bound >= best) continue;
      final l = _lines[i];
      for (var j = 0; j + 3 < l.length; j += 2) {
        final d = pointToSegmentKm(lat, lon, l[j], l[j + 1], l[j + 2], l[j + 3]);
        if (best == null || d < best) best = d;
      }
    }
    return best;
  }

  static ({double minLat, double maxLat, double minLon, double maxLon}) _box(List<double> l) {
    var (minLat, maxLat, minLon, maxLon) = (90.0, -90.0, 180.0, -180.0);
    for (var i = 0; i + 1 < l.length; i += 2) {
      minLat = math.min(minLat, l[i]);
      maxLat = math.max(maxLat, l[i]);
      minLon = math.min(minLon, l[i + 1]);
      maxLon = math.max(maxLon, l[i + 1]);
    }
    return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon);
  }
}

/// Parses coast.json; lines with bad values are skipped (bundled, but still
/// checked: a broken file must not crash the tide screen).
CoastLines parseCoast(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return CoastLines(const []);
  }
  if (decoded case {'lines': final List<Object?> lines}) {
    return CoastLines([
      for (final l in lines)
        if (l is List<Object?> && l.length >= 4 && l.length.isEven && l.every((v) => v is num))
          [
            for (final v in l)
              if (v is num) v.toDouble(),
          ],
    ]);
  }
  return CoastLines(const []);
}
