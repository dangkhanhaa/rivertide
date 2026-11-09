// Sun rise/set/noon and civil twilight (PROJECT.md 9.4).
//
// Port of SunCalc.getTimes (c) Vladimir Agafonkin, BSD-2
// (https://github.com/mourner/suncalc); formulas from aa.quae.nl / Meeus.

import 'dart:math' as math;

import 'package:rivertide/core/calc/astro/astro_math.dart';

/// Sun events for one local calendar day; all instants are UTC.
///
/// Rise/set/dawn/dusk are null when the event does not happen (polar
/// day/night).
class SunTimes {
  const SunTimes({required this.solarNoon, this.sunrise, this.sunset, this.dawn, this.dusk});

  final DateTime solarNoon;
  final DateTime? sunrise;
  final DateTime? sunset;

  /// Civil dawn: sun 6° below the horizon, morning.
  final DateTime? dawn;

  /// Civil dusk: sun 6° below the horizon, evening.
  final DateTime? dusk;
}

const double _j0 = 0.0009;
const double _sunriseAngleDeg = -0.833;
const double _civilAngleDeg = -6;

/// Sun times for calendar day [year]-[month]-[day] at UTC+[tzOffsetHours].
SunTimes sunTimes({
  required int year,
  required int month,
  required int day,
  required double lat,
  required double lon,
  double tzOffsetHours = 7,
}) {
  // Local noon picks the solar transit belonging to this local day.
  final localNoon = localMidnightUtc(
    year,
    month,
    day,
    tzOffsetHours,
  ).add(const Duration(hours: 12));
  final lwRad = degToRad * -lon;
  final phiRad = degToRad * lat;
  final d = toDays(localNoon);
  final n = (d - _j0 - lwRad / (2 * math.pi)).roundToDouble();
  final ds = _approxTransit(0, lwRad, n);
  final m = solarMeanAnomaly(ds);
  final l = eclipticLongitude(m);
  final dec = declination(l, 0);
  final jNoon = _solarTransitJ(ds, m, l);

  ({DateTime? rise, DateTime? set}) pair(double angleDeg) {
    final w = _hourAngle(angleDeg * degToRad, phiRad, dec);
    if (w.isNaN) return (rise: null, set: null);
    final jSet = _solarTransitJ(_approxTransit(w, lwRad, n), m, l);
    final jRise = jNoon - (jSet - jNoon);
    return (rise: fromJulian(jRise), set: fromJulian(jSet));
  }

  final main = pair(_sunriseAngleDeg);
  final civil = pair(_civilAngleDeg);
  return SunTimes(
    solarNoon: fromJulian(jNoon),
    sunrise: main.rise,
    sunset: main.set,
    dawn: civil.rise,
    dusk: civil.set,
  );
}

double _approxTransit(double ht, double lwRad, double n) => _j0 + (ht + lwRad) / (2 * math.pi) + n;

double _solarTransitJ(double ds, double m, double l) =>
    daysToJulian(ds) + 0.0053 * math.sin(m) - 0.0069 * math.sin(2 * l);

/// NaN when the sun never reaches [hRad] that day.
double _hourAngle(double hRad, double phiRad, double decRad) => math.acos(
  (math.sin(hRad) - math.sin(phiRad) * math.sin(decRad)) / (math.cos(phiRad) * math.cos(decRad)),
);
