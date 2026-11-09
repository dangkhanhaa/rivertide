// Shared low-precision astronomy helpers.
//
// Port of SunCalc (c) Vladimir Agafonkin, BSD-2 (https://github.com/mourner/suncalc),
// itself based on formulas from https://aa.quae.nl/en/reken/hemelpositie.html
// and Jean Meeus, "Astronomical Algorithms". Accuracy is ~1 minute for the
// sun and a few minutes for the moon, which is enough for fishing guidance.

import 'dart:math' as math;

const double degToRad = math.pi / 180;
const double _dayMs = 86400000;
const double _j1970 = 2440588;
const double _j2000 = 2451545;

/// Mean obliquity of the ecliptic (J2000).
const double _obliquityRad = degToRad * 23.4397;

/// Julian date of a UTC instant.
double toJulian(DateTime utc) => utc.millisecondsSinceEpoch / _dayMs - 0.5 + _j1970;

/// UTC instant of a Julian date.
DateTime fromJulian(double julian) =>
    DateTime.fromMillisecondsSinceEpoch(((julian + 0.5 - _j1970) * _dayMs).round(), isUtc: true);

/// Days since J2000.0.
double toDays(DateTime utc) => toJulian(utc) - _j2000;

/// Julian date from days since J2000.0.
double daysToJulian(double days) => days + _j2000;

/// UTC instant of local midnight starting calendar day [year]-[month]-[day]
/// in a zone [tzOffsetHours] east of UTC.
DateTime localMidnightUtc(int year, int month, int day, double tzOffsetHours) =>
    DateTime.utc(year, month, day).subtract(hoursToDuration(tzOffsetHours));

/// Fractional hours to a [Duration] (microsecond precision).
Duration hoursToDuration(double hours) => Duration(microseconds: (hours * 3600e6).round());

/// Equatorial coordinates; [distanceKm] is 0 when not meaningful.
class Equatorial {
  const Equatorial({required this.raRad, required this.decRad, this.distanceKm = 0});

  final double raRad;
  final double decRad;
  final double distanceKm;
}

double rightAscension(double lRad, double bRad) => math.atan2(
  math.sin(lRad) * math.cos(_obliquityRad) - math.tan(bRad) * math.sin(_obliquityRad),
  math.cos(lRad),
);

double declination(double lRad, double bRad) => math.asin(
  math.sin(bRad) * math.cos(_obliquityRad) +
      math.cos(bRad) * math.sin(_obliquityRad) * math.sin(lRad),
);

/// SunCalc azimuth: measured from south, positive towards west.
double azimuthFromSouth(double hRad, double phiRad, double decRad) => math.atan2(
  math.sin(hRad),
  math.cos(hRad) * math.sin(phiRad) - math.tan(decRad) * math.cos(phiRad),
);

double altitude(double hRad, double phiRad, double decRad) => math.asin(
  math.sin(phiRad) * math.sin(decRad) + math.cos(phiRad) * math.cos(decRad) * math.cos(hRad),
);

/// Local sidereal time; [lwRad] is west longitude in radians (= -lon).
double siderealTime(double days, double lwRad) => degToRad * (280.16 + 360.9856235 * days) - lwRad;

/// Atmospheric refraction (radians) for apparent altitude near the horizon.
double astroRefraction(double hRad) {
  // The formula diverges below the horizon; clamp as SunCalc does.
  final h = hRad < 0 ? 0.0 : hRad;
  return 0.0002967 / math.tan(h + 0.00312536 / (h + 0.08901179));
}

double solarMeanAnomaly(double days) => degToRad * (357.5291 + 0.98560028 * days);

double eclipticLongitude(double meanAnomalyRad) {
  final m = meanAnomalyRad;
  final center =
      degToRad * (1.9148 * math.sin(m) + 0.02 * math.sin(2 * m) + 0.0003 * math.sin(3 * m));
  const perihelion = degToRad * 102.9372;
  return m + center + perihelion + math.pi;
}

Equatorial sunCoords(double days) {
  final l = eclipticLongitude(solarMeanAnomaly(days));
  return Equatorial(raRad: rightAscension(l, 0), decRad: declination(l, 0));
}

/// Geocentric ecliptic coordinates of the moon (low precision).
Equatorial moonCoords(double days) {
  final l = degToRad * (218.316 + 13.176396 * days);
  final m = degToRad * (134.963 + 13.064993 * days);
  final f = degToRad * (93.272 + 13.229350 * days);
  final lon = l + degToRad * 6.289 * math.sin(m);
  final lat = degToRad * 5.128 * math.sin(f);
  final distanceKm = 385001 - 20905 * math.cos(m);
  return Equatorial(
    raRad: rightAscension(lon, lat),
    decRad: declination(lon, lat),
    distanceKm: distanceKm,
  );
}
