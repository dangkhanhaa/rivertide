import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/astro/moon_times.dart';
import 'package:rivertide/core/calc/astro/solunar.dart';
import 'package:rivertide/core/calc/astro/solunar_kind.dart';

const double canThoLat = 10.03;
const double canThoLon = 105.78;

void main() {
  group('SolunarPeriod', () {
    test('around() builds a symmetric window', () {
      final c = DateTime.utc(2026, 3, 1, 12);
      final p = SolunarPeriod.around(SolunarKind.major, c, majorHalfWidth);
      expect(p.startUtc, DateTime.utc(2026, 3, 1, 11));
      expect(p.endUtc, DateTime.utc(2026, 3, 1, 13));
      expect(p.contains(p.startUtc), isTrue);
      expect(p.contains(p.endUtc), isFalse);
    });
  });

  group('solunarAt', () {
    final center = DateTime.utc(2026, 3, 1, 12);
    final day = SolunarDay(
      periods: [
        SolunarPeriod.around(SolunarKind.major, center, majorHalfWidth),
        SolunarPeriod.around(
          SolunarKind.minor,
          center.add(const Duration(minutes: 70)),
          minorHalfWidth,
        ),
      ],
      isGoodDay: false,
    );

    test('returns major inside a major period', () {
      expect(solunarAt(center, day), SolunarKind.major);
    });

    test('major wins where major and minor overlap', () {
      expect(solunarAt(center.add(const Duration(minutes: 50)), day), SolunarKind.major);
    });

    test('returns minor inside a minor-only window', () {
      expect(solunarAt(center.add(const Duration(minutes: 65)), day), SolunarKind.minor);
    });

    test('returns none outside every period', () {
      expect(solunarAt(center.add(const Duration(hours: 3)), day), SolunarKind.none);
      expect(solunarAt(center.subtract(const Duration(hours: 2)), day), SolunarKind.none);
    });
  });

  group('solunarForDay', () {
    final result = solunarForDay(year: 2026, month: 3, day: 10, lat: canThoLat, lon: canThoLon);
    final dayStart = DateTime.utc(2026, 3, 9, 17);
    final dayEnd = DateTime.utc(2026, 3, 10, 17);

    test('builds majors around transits and minors around rise/set', () {
      final transits = moonTransits(year: 2026, month: 3, day: 10, lat: canThoLat, lon: canThoLon);
      final times = moonTimes(year: 2026, month: 3, day: 10, lat: canThoLat, lon: canThoLon);
      final centers = result.periods.map((p) => (p.kind, p.centerUtc)).toList();
      for (final t in [transits.upper, transits.lower]) {
        if (t != null) expect(centers, contains((SolunarKind.major, t)));
      }
      for (final t in [times.rise, times.set]) {
        if (t != null) expect(centers, contains((SolunarKind.minor, t)));
      }
      for (final p in result.periods) {
        final width = p.endUtc.difference(p.startUtc);
        expect(width, p.kind == SolunarKind.major ? majorHalfWidth * 2 : minorHalfWidth * 2);
      }
    });

    test('periods overlap the local day and are sorted by start', () {
      expect(result.periods, isNotEmpty);
      for (final p in result.periods) {
        expect(p.endUtc.isAfter(dayStart) && p.startUtc.isBefore(dayEnd), isTrue);
      }
      for (var i = 1; i < result.periods.length; i++) {
        expect(result.periods[i].startUtc.isBefore(result.periods[i - 1].startUtc), isFalse);
      }
    });

    test('period list is unmodifiable', () {
      expect(result.periods.clear, throwsUnsupportedError);
    });

    test('isGoodDay near the 2026-02-17 new moon, not a week later', () {
      bool good(int day) =>
          solunarForDay(year: 2026, month: 2, day: day, lat: canThoLat, lon: canThoLon).isGoodDay;
      expect(good(17), isTrue);
      expect(good(15), isTrue);
      expect(good(19), isTrue);
      expect(good(22), isFalse);
      expect(good(24), isFalse);
    });
  });
}
