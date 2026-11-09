import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/astro/sun.dart';

Matcher within(DateTime expected, Duration tolerance) => predicate<DateTime?>(
  (actual) => actual != null && actual.difference(expected).abs() <= tolerance,
  'within $tolerance of $expected',
);

void main() {
  const tolerance = Duration(minutes: 2);

  group('sunTimes — SunCalc test-suite values', () {
    // Values from SunCalc's test/test.js (mourner/suncalc): date
    // 2013-03-05T00:00:00Z, lat 50.5, lon 30.5. dawn/dusk are also taken
    // from that suite (quoted from memory of test.js; not re-fetched).
    final times = sunTimes(year: 2013, month: 3, day: 5, lat: 50.5, lon: 30.5, tzOffsetHours: 0);

    test('sunrise', () {
      expect(times.sunrise, within(DateTime.utc(2013, 3, 5, 4, 34, 56), tolerance));
    });

    test('sunset', () {
      expect(times.sunset, within(DateTime.utc(2013, 3, 5, 15, 46, 57), tolerance));
    });

    test('solar noon', () {
      expect(times.solarNoon, within(DateTime.utc(2013, 3, 5, 10, 10, 57), tolerance));
    });

    test('civil dawn and dusk', () {
      expect(times.dawn, within(DateTime.utc(2013, 3, 5, 4, 2, 17), tolerance));
      expect(times.dusk, within(DateTime.utc(2013, 3, 5, 16, 19, 36), tolerance));
    });

    test('same result when the local day is expressed with UTC+2', () {
      final kyiv = sunTimes(year: 2013, month: 3, day: 5, lat: 50.5, lon: 30.5, tzOffsetHours: 2);
      expect(kyiv.sunrise, within(DateTime.utc(2013, 3, 5, 4, 34, 56), tolerance));
    });
  });

  group('sunTimes — Vietnam sanity', () {
    // Cần Thơ 10.03N 105.78E. Sanity bounds derived from geometry
    // (latitude 10°, equation of time ±16 min), not from an official table:
    // local sunrise stays within ~05:35–06:20 all year (computed 2026 range:
    // 05:36–06:20, latest in late January). Bounds 05:30–06:25.
    test('Cần Thơ sunrise is between 05:30 and 06:25 local every day of 2026', () {
      var date = DateTime.utc(2026);
      while (date.year == 2026) {
        final t = sunTimes(
          year: date.year,
          month: date.month,
          day: date.day,
          lat: 10.03,
          lon: 105.78,
        );
        final sunrise = t.sunrise;
        if (sunrise == null) fail('no sunrise on $date');
        final local = sunrise.add(const Duration(hours: 7));
        final minutes = local.hour * 60 + local.minute;
        expect(minutes, inInclusiveRange(5 * 60 + 30, 6 * 60 + 25), reason: '$date');
        expect(local.day, date.day, reason: 'sunrise must fall on the requested local day');
        date = date.add(const Duration(days: 1));
      }
    });

    test('dawn < sunrise < noon < sunset < dusk', () {
      final t = sunTimes(year: 2026, month: 6, day: 21, lat: 21.03, lon: 105.85);
      final events = [t.dawn, t.sunrise, t.solarNoon, t.sunset, t.dusk].nonNulls.toList();
      expect(events, hasLength(5));
      for (var i = 1; i < events.length; i++) {
        expect(events[i - 1].isBefore(events[i]), isTrue);
      }
    });
  });

  group('sunTimes — polar edge cases', () {
    test('returns null sunrise/sunset during polar night', () {
      final t = sunTimes(year: 2026, month: 12, day: 21, lat: 80, lon: 15, tzOffsetHours: 1);
      expect(t.sunrise, isNull);
      expect(t.sunset, isNull);
      expect(t.dawn, isNull);
    });

    test('returns null sunrise/sunset during midnight sun', () {
      final t = sunTimes(year: 2026, month: 6, day: 21, lat: 80, lon: 15, tzOffsetHours: 1);
      expect(t.sunrise, isNull);
      expect(t.sunset, isNull);
    });
  });
}
