import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/astro/moon_times.dart';

Matcher within(DateTime expected, Duration tolerance) => predicate<DateTime?>(
  (actual) => actual != null && actual.difference(expected).abs() <= tolerance,
  'within $tolerance of $expected',
);

const double canThoLat = 10.03;
const double canThoLon = 105.78;

void main() {
  group('moonTimes', () {
    test('matches SunCalc test-suite rise/set for 2013-03-04 (UTC window)', () {
      // From SunCalc's test/test.js: getMoonTimes(2013-03-04 UTC, 50.5, 30.5,
      // inUTC=true) → rise 23:54:29Z, set 07:47:58Z.
      final t = moonTimes(year: 2013, month: 3, day: 4, lat: 50.5, lon: 30.5, tzOffsetHours: 0);
      const tolerance = Duration(minutes: 3);
      expect(t.rise, within(DateTime.utc(2013, 3, 4, 23, 54, 29), tolerance));
      expect(t.set, within(DateTime.utc(2013, 3, 4, 7, 47, 58), tolerance));
      expect(t.isAlwaysUp, isFalse);
      expect(t.isAlwaysDown, isFalse);
    });

    test('Cần Thơ has at least one day without moonrise in a month', () {
      var daysWithoutRise = 0;
      for (var day = 1; day <= 31; day++) {
        final t = moonTimes(year: 2026, month: 1, day: day, lat: canThoLat, lon: canThoLon);
        if (t.rise == null) daysWithoutRise++;
        final rise = t.rise;
        if (rise != null) {
          // Event must lie inside the local calendar day.
          final local = rise.add(const Duration(hours: 7));
          expect(local.day, day);
        }
      }
      expect(daysWithoutRise, greaterThanOrEqualTo(1));
    });

    test('flags a moon that never sets at high latitude', () {
      // Search a month at 78°N for an always-up or always-down day.
      var flagged = 0;
      for (var day = 1; day <= 28; day++) {
        final t = moonTimes(year: 2026, month: 2, day: day, lat: 78, lon: 15, tzOffsetHours: 1);
        if (t.isAlwaysUp || t.isAlwaysDown) {
          flagged++;
          expect(t.rise, isNull);
          expect(t.set, isNull);
        }
      }
      expect(flagged, greaterThan(0));
    });
  });

  group('moonTransits', () {
    test('upper transit is a local altitude maximum, lower a minimum', () {
      for (var day = 1; day <= 30; day++) {
        final t = moonTransits(year: 2026, month: 4, day: day, lat: canThoLat, lon: canThoLon);
        final upper = t.upper;
        if (upper != null) {
          final h = moonGeometricAltitudeRad(upper, canThoLat, canThoLon);
          for (final m in [-2, 2]) {
            final near = upper.add(Duration(minutes: m));
            expect(moonGeometricAltitudeRad(near, canThoLat, canThoLon), lessThan(h));
          }
        }
        final lower = t.lower;
        if (lower != null) {
          final h = moonGeometricAltitudeRad(lower, canThoLat, canThoLon);
          for (final m in [-2, 2]) {
            final near = lower.add(Duration(minutes: m));
            expect(moonGeometricAltitudeRad(near, canThoLat, canThoLon), greaterThan(h));
          }
        }
      }
    });

    test('transits drift ~50 min per day and skip roughly one day a month', () {
      var missingUpper = 0;
      DateTime? previous;
      for (var day = 1; day <= 31; day++) {
        final upper = moonTransits(
          year: 2026,
          month: 5,
          day: day,
          lat: canThoLat,
          lon: canThoLon,
        ).upper;
        if (upper == null) {
          missingUpper++;
          previous = null;
          continue;
        }
        final prev = previous;
        if (prev != null) {
          expect(upper.difference(prev).inMinutes, inInclusiveRange(24 * 60 + 30, 24 * 60 + 70));
        }
        previous = upper;
      }
      expect(missingUpper, inInclusiveRange(1, 2));
    });
  });
}
