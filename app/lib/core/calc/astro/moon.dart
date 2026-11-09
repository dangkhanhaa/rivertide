// Moon position, illumination and principal phases (PROJECT.md 9.4).
//
// Port of SunCalc.getMoonPosition / getMoonIllumination (c) Vladimir
// Agafonkin, BSD-2 (https://github.com/mourner/suncalc); formulas from
// aa.quae.nl and Jean Meeus, "Astronomical Algorithms" ch. 47–48.

import 'dart:math' as math;

import 'package:rivertide/core/calc/astro/astro_math.dart';
import 'package:rivertide/core/calc/lunar/lunar_math.dart';

/// Topocentric-ish moon position (SunCalc precision).
class MoonPosition {
  const MoonPosition({
    required this.altitudeRad,
    required this.azimuthRad,
    required this.distanceKm,
  });

  /// Altitude above the horizon, corrected for refraction.
  final double altitudeRad;

  /// Azimuth measured from NORTH, clockwise (east = π/2), in [0, 2π).
  /// SunCalc's own azimuth (from south, towards west) = this − π.
  final double azimuthRad;

  /// Earth–moon distance.
  final double distanceKm;
}

enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

class MoonIllumination {
  const MoonIllumination({required this.fraction, required this.phase, required this.phaseName});

  /// Illuminated fraction of the disc, 0..1.
  final double fraction;

  /// 0 new → 0.25 first quarter → 0.5 full → 0.75 last quarter → 1.
  final double phase;

  /// [phase] bucketed into eight equal arcs centred on 0, 1/8, 2/8, …
  final MoonPhaseName phaseName;
}

/// A new or full moon instant.
class MoonPhaseEvent {
  const MoonPhaseEvent({required this.utc, required this.isFullMoon});

  final DateTime utc;

  /// True for full moon, false for new moon.
  final bool isFullMoon;
}

const double _sunDistanceKm = 149598000;

/// Moon position at [utc] seen from [lat], [lon] (degrees).
MoonPosition moonPosition(DateTime utc, double lat, double lon) {
  final h = moonGeometricAltitudeRad(utc, lat, lon);
  final d = toDays(utc);
  final c = moonCoords(d);
  final hourAngle = siderealTime(d, degToRad * -lon) - c.raRad;
  final azSouth = azimuthFromSouth(hourAngle, degToRad * lat, c.decRad);
  return MoonPosition(
    altitudeRad: h + astroRefraction(h),
    azimuthRad: _normalizeRad(azSouth + math.pi),
    distanceKm: c.distanceKm,
  );
}

/// Moon altitude without refraction (used for transit search).
double moonGeometricAltitudeRad(DateTime utc, double lat, double lon) {
  final d = toDays(utc);
  final c = moonCoords(d);
  final hourAngle = siderealTime(d, degToRad * -lon) - c.raRad;
  return altitude(hourAngle, degToRad * lat, c.decRad);
}

/// Moon illumination at [utc] (geocentric, independent of observer).
MoonIllumination moonIllumination(DateTime utc) {
  final d = toDays(utc);
  final s = sunCoords(d);
  final m = moonCoords(d);
  final dRa = s.raRad - m.raRad;
  final elongation = math.acos(
    math.sin(s.decRad) * math.sin(m.decRad) +
        math.cos(s.decRad) * math.cos(m.decRad) * math.cos(dRa),
  );
  final inc = math.atan2(
    _sunDistanceKm * math.sin(elongation),
    m.distanceKm - _sunDistanceKm * math.cos(elongation),
  );
  final angle = math.atan2(
    math.cos(s.decRad) * math.sin(dRa),
    math.sin(s.decRad) * math.cos(m.decRad) -
        math.cos(s.decRad) * math.sin(m.decRad) * math.cos(dRa),
  );
  final phase = 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / math.pi;
  return MoonIllumination(
    fraction: (1 + math.cos(inc)) / 2,
    phase: phase,
    phaseName: phaseNameOf(phase),
  );
}

/// Buckets a phase value (0..1) into one of eight names.
MoonPhaseName phaseNameOf(double phase) {
  final index = (phase * 8 + 0.5).floor() % 8;
  return MoonPhaseName.values[index];
}

/// The new or full moon closest in time to [utc].
///
/// Uses the Meeus lunation series shared with the lunar calendar (error of a
/// few minutes) rather than SunCalc's phase, which can be ~3 hours off.
MoonPhaseEvent nearestNewOrFullMoon(DateTime utc) {
  final jd = toJulian(utc);
  final halfLunations = (jd - newMoonEpochJd) / synodicMonthDays * 2;
  final base = halfLunations.floor();
  // The series deviates from the mean month by < 0.6 days, so the nearest
  // event is among the half-lunations around the mean estimate.
  final nearest = [for (var h = base - 1; h <= base + 2; h++) h]
      .reduce((a, b) => (moonPhaseJd(a / 2) - jd).abs() <= (moonPhaseJd(b / 2) - jd).abs() ? a : b);
  return MoonPhaseEvent(utc: fromJulian(moonPhaseJd(nearest / 2)), isFullMoon: nearest.isOdd);
}

double _normalizeRad(double x) => x - 2 * math.pi * (x / (2 * math.pi)).floorToDouble();
