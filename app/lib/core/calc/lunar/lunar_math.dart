// Astronomical building blocks for the Vietnamese lunisolar calendar.
//
// Source: Hồ Ngọc Đức, "Computing the Vietnamese lunar calendar"
// (https://www.informatik.uni-leipzig.de/~duc/amlich/calrules.html), which
// uses simplified formulas from Jean Meeus, "Astronomical Algorithms".
// Valid roughly 1800–2199; the app needs 1900–2100.

import 'dart:math' as math;

const double _degToRad = math.pi / 180;

/// Mean synodic month length in days.
const double synodicMonthDays = 29.530588853;

/// Julian day of the first new moon after 1900-01-01 (k = 0 reference).
const double newMoonEpochJd = 2415021.076998695;

/// Julian day number (integer, noon-based) of a Gregorian/Julian date.
int jdFromDate(int day, int month, int year) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  var jd = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  if (jd < 2299161) {
    // Before the Gregorian reform the Julian calendar applies.
    jd = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
  }
  return jd;
}

/// Inverse of [jdFromDate].
({int year, int month, int day}) jdToDate(int jd) {
  int b;
  int c;
  if (jd > 2299160) {
    final a = jd + 32044;
    b = (4 * a + 3) ~/ 146097;
    c = a - (b * 146097) ~/ 4;
  } else {
    b = 0;
    c = jd + 32082;
  }
  final d = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * d) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  final day = e - (153 * m + 2) ~/ 5 + 1;
  final month = m + 3 - 12 * (m ~/ 10);
  final year = b * 100 + d - 4800 + m ~/ 10;
  return (year: year, month: month, day: day);
}

/// Julian day (fractional, UT) of the k-th new moon after 1900-01-01.
double newMoonJd(int k) => moonPhaseJd(k.toDouble());

/// Julian day (UT) of lunation [k]: integer k → new moon, k + 0.5 → full
/// moon. Meeus' full-moon series differs from the new-moon one only in the
/// 4th decimal of the coefficients, so this simplified series serves both.
double moonPhaseJd(double k) {
  final t = k / 1236.85;
  final t2 = t * t;
  final t3 = t2 * t;
  var jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
  jd1 += 0.00033 * math.sin((166.56 + 132.87 * t - 0.009173 * t2) * _degToRad);
  final m = (359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3) * _degToRad;
  final mpr = (306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3) * _degToRad;
  final f = (21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3) * _degToRad;
  final c1 =
      (0.1734 - 0.000393 * t) * math.sin(m) +
      0.0021 * math.sin(2 * m) -
      0.4068 * math.sin(mpr) +
      0.0161 * math.sin(2 * mpr) -
      0.0004 * math.sin(3 * mpr) +
      0.0104 * math.sin(2 * f) -
      0.0051 * math.sin(m + mpr) -
      0.0074 * math.sin(m - mpr) +
      0.0004 * math.sin(2 * f + m) -
      0.0004 * math.sin(2 * f - m) -
      0.0006 * math.sin(2 * f + mpr) +
      0.0010 * math.sin(2 * f - mpr) +
      0.0005 * math.sin(2 * mpr + m);
  // Delta T (TT - UT) approximation in days.
  final deltaT = t < -11
      ? 0.001 + 0.000839 * t + 0.0002261 * t2 - 0.00000845 * t3 - 0.000000081 * t * t3
      : -0.000278 + 0.000265 * t + 0.000262 * t2;
  return jd1 + c1 - deltaT;
}

/// Local Julian day number of the day containing the k-th new moon.
int newMoonDay(int k, double tzOffsetHours) => (newMoonJd(k) + 0.5 + tzOffsetHours / 24).floor();

/// Apparent sun longitude in radians [0, 2π) at Julian day [jd] (UT).
double sunLongitudeRad(double jd) {
  final t = (jd - 2451545.0) / 36525;
  final t2 = t * t;
  final m = (357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2) * _degToRad;
  final l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
  final dl =
      (1.914600 - 0.004817 * t - 0.000014 * t2) * math.sin(m) +
      (0.019993 - 0.000101 * t) * math.sin(2 * m) +
      0.000290 * math.sin(3 * m);
  final l = (l0 + dl) * _degToRad;
  return l - 2 * math.pi * (l / (2 * math.pi)).floorToDouble();
}

/// Index 0..11 of the 30° sun-longitude sector at the start of local day
/// [dayNumber]; sector changes mark the major solar terms (trung khí).
int sunLongitudeSector(int dayNumber, double tzOffsetHours) =>
    (sunLongitudeRad(dayNumber - 0.5 - tzOffsetHours / 24) / math.pi * 6).floor();

/// Local Julian day number of the start of lunar month 11 (the month
/// containing the winter solstice) of solar [year].
int lunarMonth11Start(int year, double tzOffsetHours) {
  final off = jdFromDate(31, 12, year) - 2415021;
  final k = (off / synodicMonthDays).floor();
  final nm = newMoonDay(k, tzOffsetHours);
  // Sector ≥ 9 means the solstice (270°) already passed → use previous moon.
  if (sunLongitudeSector(nm, tzOffsetHours) >= 9) {
    return newMoonDay(k - 1, tzOffsetHours);
  }
  return nm;
}

/// Offset (in months after month 11 starting at [a11]) of the leap month:
/// the first month that contains no major solar term.
int leapMonthOffset(int a11, double tzOffsetHours) {
  final k = ((a11 - newMoonEpochJd) / synodicMonthDays + 0.5).floor();
  var i = 1;
  var arc = sunLongitudeSector(newMoonDay(k + i, tzOffsetHours), tzOffsetHours);
  int last;
  do {
    last = arc;
    i++;
    arc = sunLongitudeSector(newMoonDay(k + i, tzOffsetHours), tzOffsetHours);
  } while (arc != last && i < 14);
  return i - 1;
}
