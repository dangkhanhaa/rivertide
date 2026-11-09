import 'dart:math' as math;

import 'package:rivertide/core/calc/geo/haversine.dart';

/// Candidates tried before giving up on landing strictly inside the radius.
const int _maxAttempts = 64;

/// Shifts a point randomly within [radiusKm], then rounds to 2 decimals
/// (PROJECT.md 9.9). Same [seed] (e.g. record id) → same output.
///
/// Rounding moves a point by up to ~0.79 km, so candidates are redrawn until
/// the rounded point is still within the radius. For radii below ~0.8 km
/// that may be impossible; the closest rounded candidate is returned then.
/// A self-contained PRNG is used because `dart:math` `Random(seed)` is not
/// guaranteed identical across platforms (VM vs web).
({double lat, double lon}) fuzz(
  double lat,
  double lon, {
  required double radiusKm,
  required int seed,
}) {
  if (lat.isNaN || lat < -90 || lat > 90) {
    throw ArgumentError.value(lat, 'lat', 'must be within -90..90');
  }
  if (lon.isNaN || lon < -180 || lon > 180) {
    throw ArgumentError.value(lon, 'lon', 'must be within -180..180');
  }
  if (!radiusKm.isFinite || radiusKm <= 0) {
    throw ArgumentError.value(radiusKm, 'radiusKm', 'must be a finite value > 0');
  }
  final rng = Mulberry32(seed);
  ({double lat, double lon})? best;
  var bestKm = double.infinity;
  for (var i = 0; i < _maxAttempts; i++) {
    final candidate = _round2(_offset(lat, lon, radiusKm, rng));
    final km = haversineKm(lat, lon, candidate.lat, candidate.lon);
    if (km <= radiusKm) return candidate;
    if (km < bestKm) {
      bestKm = km;
      best = candidate;
    }
  }
  // Loop ran at least once, so best is set.
  return best ?? _round2((lat: lat, lon: lon));
}

/// Uniform point in a disc of [radiusKm] (sqrt for area-uniform distance).
({double lat, double lon}) _offset(double lat, double lon, double radiusKm, Mulberry32 rng) {
  final bearing = 2 * math.pi * rng.nextDouble();
  final distKm = radiusKm * math.sqrt(rng.nextDouble());
  final dLat = distKm * math.cos(bearing) / earthRadiusKm;
  // Avoid division by ~0 at the poles.
  final cosLat = math.max(math.cos(degToRad(lat)), 1e-6);
  final dLon = distKm * math.sin(bearing) / (earthRadiusKm * cosLat);
  final newLat = (lat + dLat * 180 / math.pi).clamp(-90.0, 90.0);
  var newLon = lon + dLon * 180 / math.pi;
  if (newLon > 180) newLon -= 360;
  if (newLon < -180) newLon += 360;
  return (lat: newLat, lon: newLon);
}

({double lat, double lon}) _round2(({double lat, double lon}) p) =>
    (lat: (p.lat * 100).round() / 100, lon: (p.lon * 100).round() / 100);

/// Mulberry32 PRNG using only 32-bit-safe arithmetic (identical on VM & web).
class Mulberry32 {
  Mulberry32(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  /// Next value in [0, 1).
  double nextDouble() => nextUint32() / 4294967296;

  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = _imul(t ^ (t >>> 15), t | 1);
    t ^= (t + _imul(t ^ (t >>> 7), t | 61)) & 0xFFFFFFFF;
    return (t ^ (t >>> 14)) & 0xFFFFFFFF;
  }

  /// 32-bit multiply split in 16-bit halves so it never exceeds 2^53.
  static int _imul(int a, int b) {
    final aHi = (a >>> 16) & 0xFFFF;
    final aLo = a & 0xFFFF;
    final bHi = (b >>> 16) & 0xFFFF;
    final bLo = b & 0xFFFF;
    final hi = ((aHi * bLo + aLo * bHi) & 0xFFFF) << 16;
    return (aLo * bLo + hi) & 0xFFFFFFFF;
  }
}
