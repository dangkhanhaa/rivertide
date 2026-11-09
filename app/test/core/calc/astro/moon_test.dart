import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/lunar/lunar_calendar.dart';

void main() {
  group('SunCalc test-suite values', () {
    // From SunCalc's test/test.js (mourner/suncalc):
    // date 2013-03-05T00:00:00Z, lat 50.5, lon 30.5.
    final date = DateTime.utc(2013, 3, 5);

    test('moonPosition altitude, azimuth, distance', () {
      final p = moonPosition(date, 50.5, 30.5);
      expect(p.altitudeRad, closeTo(0.014551482243892251, 1e-3));
      // SunCalc azimuth -0.9783999522438226 (from south) → from north: +π.
      expect(p.azimuthRad, closeTo(-0.9783999522438226 + math.pi, 1e-3));
      expect(p.distanceKm, closeTo(364121.37256256194, 1));
    });

    test('moonIllumination fraction and phase', () {
      final i = moonIllumination(date);
      expect(i.fraction, closeTo(0.4848068202456373, 1e-6));
      expect(i.phase, closeTo(0.7548368838538762, 1e-6));
      expect(i.phaseName, MoonPhaseName.lastQuarter);
    });
  });

  group('phaseNameOf', () {
    test('buckets phases into eight names centred on the principal phases', () {
      expect(phaseNameOf(0), MoonPhaseName.newMoon);
      expect(phaseNameOf(0.97), MoonPhaseName.newMoon);
      expect(phaseNameOf(0.125), MoonPhaseName.waxingCrescent);
      expect(phaseNameOf(0.25), MoonPhaseName.firstQuarter);
      expect(phaseNameOf(0.375), MoonPhaseName.waxingGibbous);
      expect(phaseNameOf(0.5), MoonPhaseName.fullMoon);
      expect(phaseNameOf(0.625), MoonPhaseName.waningGibbous);
      expect(phaseNameOf(0.75), MoonPhaseName.lastQuarter);
      expect(phaseNameOf(0.875), MoonPhaseName.waningCrescent);
    });
  });

  group('nearestNewOrFullMoon', () {
    test('lands on a nearly dark or nearly full disc', () {
      for (var day = 0; day < 60; day += 3) {
        final t = DateTime.utc(2026).add(Duration(days: day));
        final event = nearestNewOrFullMoon(t);
        final fraction = moonIllumination(event.utc).fraction;
        if (event.isFullMoon) {
          expect(fraction, greaterThan(0.99), reason: '$t');
        } else {
          expect(fraction, lessThan(0.01), reason: '$t');
        }
        expect(event.utc.difference(t).inHours.abs(), lessThanOrEqualTo(8 * 24));
      }
    });

    test('new moon falls on lunar day 1 (Tết 2026, 2026-02-17)', () {
      // Both use the same Meeus lunation series; this guards the k ↔ date
      // bookkeeping and the UTC+7 day boundary.
      final event = nearestNewOrFullMoon(DateTime.utc(2026, 2, 17, 5));
      expect(event.isFullMoon, isFalse);
      final local = event.utc.add(const Duration(hours: 7));
      expect(solarToLunar(local.year, local.month, local.day).day, 1);
    });

    // The task brief said 14–16, but a full moon can astronomically fall on
    // lunar day 17: lunar month 9/2026 starts 2026-10-10 (new moon ~22:50
    // UTC+7) and the next full moon is 2026-10-26 ~11:1x UTC+7 = day 17.
    test('full moons of 2026 fall on lunar day 14–17 (Vietnam, UTC+7)', () {
      final lunarDays = <int>[];
      var t = DateTime.utc(2026, 1, 3);
      while (t.year == 2026) {
        final event = nearestNewOrFullMoon(t);
        if (event.isFullMoon) {
          final local = event.utc.add(const Duration(hours: 7));
          lunarDays.add(solarToLunar(local.year, local.month, local.day).day);
          t = event.utc.add(const Duration(days: 25));
        } else {
          t = t.add(const Duration(days: 5));
        }
      }
      expect(lunarDays.length, greaterThanOrEqualTo(12));
      expect(lunarDays, everyElement(inInclusiveRange(14, 17)));
      expect(lunarDays.where((d) => d == 17).length, lessThanOrEqualTo(1));
    });
  });
}
