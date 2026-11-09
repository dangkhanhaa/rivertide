// Moonrise/moonset and moon transits for a local calendar day (PROJECT.md 9.4).
//
// moonTimes ports SunCalc.getMoonTimes (c) Vladimir Agafonkin, BSD-2
// (https://github.com/mourner/suncalc): hourly quadratic interpolation of
// altitude, after https://www.stargazing.net/kepler/moonrise.html.
// moonTransits finds altitude extremes: 5-minute scan + ternary search.

import 'dart:math' as math;

import 'package:rivertide/core/calc/astro/astro_math.dart';
import 'package:rivertide/core/calc/astro/moon.dart';

/// Moonrise/moonset inside [local midnight, next local midnight); UTC.
class MoonTimes {
  const MoonTimes({this.rise, this.set, this.isAlwaysUp = false, this.isAlwaysDown = false});

  final DateTime? rise;
  final DateTime? set;

  /// No rise/set and the moon stays above the horizon all day.
  final bool isAlwaysUp;

  /// No rise/set and the moon stays below the horizon all day.
  final bool isAlwaysDown;
}

/// Upper (highest altitude) and lower (lowest altitude) transits; UTC.
/// Null when the extreme falls outside the local day (the moon transits
/// every ~24h50m, so one day in ~29 misses each kind).
class MoonTransits {
  const MoonTransits({this.upper, this.lower});

  final DateTime? upper;
  final DateTime? lower;
}

/// Altitude offset SunCalc uses for the moon's apparent upper limb.
const double _horizonOffsetRad = 0.133 * degToRad;

MoonTimes moonTimes({
  required int year,
  required int month,
  required int day,
  required double lat,
  required double lon,
  double tzOffsetHours = 7,
}) {
  final start = localMidnightUtc(year, month, day, tzOffsetHours);
  double alt(double hours) =>
      moonPosition(start.add(hoursToDuration(hours)), lat, lon).altitudeRad - _horizonOffsetRad;

  double? riseH;
  double? setH;
  var ye = 0.0;
  var h0 = alt(0);
  for (var i = 1; i <= 24; i += 2) {
    final h2 = alt(i + 1.0);
    final hit = _crossings(h0, alt(i.toDouble()), h2);
    ye = hit.ye;
    if (hit.rise != null) riseH = i + (hit.rise ?? 0);
    if (hit.set != null) setH = i + (hit.set ?? 0);
    if (riseH != null && setH != null) break;
    h0 = h2;
  }
  final none = riseH == null && setH == null;
  return MoonTimes(
    rise: riseH == null ? null : start.add(hoursToDuration(riseH)),
    set: setH == null ? null : start.add(hoursToDuration(setH)),
    isAlwaysUp: none && ye > 0,
    isAlwaysDown: none && ye <= 0,
  );
}

/// Horizon crossings of the parabola through (-1,h0), (0,h1), (1,h2):
/// offsets in [-1, 1] relative to the middle sample, plus the vertex value.
({double? rise, double? set, double ye}) _crossings(double h0, double h1, double h2) {
  final a = (h0 + h2) / 2 - h1;
  final b = (h2 - h0) / 2;
  final xe = -b / (2 * a);
  final ye = (a * xe + b) * xe + h1;
  final disc = b * b - 4 * a * h1;
  if (disc < 0) return (rise: null, set: null, ye: ye);
  final dx = math.sqrt(disc) / (a.abs() * 2);
  var x1 = xe - dx;
  final x2 = xe + dx;
  var roots = 0;
  if (x1.abs() <= 1) roots++;
  if (x2.abs() <= 1) roots++;
  if (x1 < -1) x1 = x2;
  if (roots == 1) {
    return h0 < 0 ? (rise: x1, set: null, ye: ye) : (rise: null, set: x1, ye: ye);
  }
  if (roots == 2) {
    return ye < 0 ? (rise: x2, set: x1, ye: ye) : (rise: x1, set: x2, ye: ye);
  }
  return (rise: null, set: null, ye: ye);
}

const int _scanStepMin = 5;

MoonTransits moonTransits({
  required int year,
  required int month,
  required int day,
  required double lat,
  required double lon,
  double tzOffsetHours = 7,
}) {
  final start = localMidnightUtc(year, month, day, tzOffsetHours);
  double alt(double minutes) => moonGeometricAltitudeRad(
    start.add(Duration(microseconds: (minutes * 6e7).round())),
    lat,
    lon,
  );

  const steps = 24 * 60 ~/ _scanStepMin;
  final samples = List<double>.generate(steps + 1, (i) => alt(i * _scanStepMin.toDouble()));
  DateTime? upper;
  DateTime? lower;
  // Interior samples only: an extreme at the window edge belongs to the
  // neighbouring day.
  for (var i = 1; i < steps; i++) {
    final prev = samples[i - 1];
    final cur = samples[i];
    final next = samples[i + 1];
    final centerMin = i * _scanStepMin.toDouble();
    if (upper == null && cur > prev && cur >= next) {
      upper = _instant(start, _ternary(alt, centerMin, maximize: true));
    } else if (lower == null && cur < prev && cur <= next) {
      lower = _instant(start, _ternary(alt, centerMin, maximize: false));
    }
  }
  return MoonTransits(upper: upper, lower: lower);
}

DateTime _instant(DateTime start, double minutes) =>
    start.add(Duration(seconds: (minutes * 60).round()));

/// Ternary search on [center ± step] to < 6 seconds.
double _ternary(double Function(double) f, double centerMin, {required bool maximize}) {
  var lo = centerMin - _scanStepMin;
  var hi = centerMin + _scanStepMin;
  while (hi - lo > 0.1) {
    final m1 = lo + (hi - lo) / 3;
    final m2 = hi - (hi - lo) / 3;
    final better = maximize ? f(m1) < f(m2) : f(m1) > f(m2);
    if (better) {
      lo = m1;
    } else {
      hi = m2;
    }
  }
  return (lo + hi) / 2;
}
