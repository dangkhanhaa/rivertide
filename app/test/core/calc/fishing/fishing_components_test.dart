import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/astro/solunar_kind.dart';
import 'package:rivertide/core/calc/fishing/fishing_components.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';

void main() {
  group('tideTimingScore', () {
    test('scores slack water (m ≤ 20) as 0.5', () {
      expect(tideTimingScore(0), 0.5);
      expect(tideTimingScore(20), 0.5);
      expect(tideTimingScore(-20), 0.5);
    });
    test('scores 20 < m ≤ 120 as 1.0', () {
      expect(tideTimingScore(21), 1.0);
      expect(tideTimingScore(120), 1.0);
      expect(tideTimingScore(-75), 1.0);
    });
    test('scores 120 < m ≤ 180 as 0.75', () {
      expect(tideTimingScore(121), 0.75);
      expect(tideTimingScore(180), 0.75);
    });
    test('scores m > 180 as 0.5', () {
      expect(tideTimingScore(181), 0.5);
      expect(tideTimingScore(400), 0.5);
    });
  });

  group('tideScore with spring/neap factor', () {
    test('applies spring 1.0, normal 0.85, neap 0.7', () {
      expect(tideScore(60, SpringNeap.spring), closeTo(1.0, 1e-9));
      expect(tideScore(60, SpringNeap.normal), closeTo(0.85, 1e-9));
      expect(tideScore(60, SpringNeap.neap), closeTo(0.7, 1e-9));
    });
    test('treats unknown spring/neap as normal', () {
      expect(tideScore(60, null), closeTo(0.85, 1e-9));
    });
  });

  group('flowScore (non-tidal stations)', () {
    test('gentle change 2–10 cm/h → 0.9', () {
      expect(flowScore(2), 0.9);
      expect(flowScore(10), 0.9);
      expect(flowScore(-5), 0.9);
    });
    test('standing water (< 2 cm/h) → 0.6', () {
      expect(flowScore(0), 0.6);
      expect(flowScore(1.9), 0.6);
    });
    test('rising very fast (> 20 cm/h) → 0.3', () {
      expect(flowScore(20.1), 0.3);
      expect(flowScore(50), 0.3);
    });
    test('unspecified gaps fall back to 0.6', () {
      expect(flowScore(15), 0.6);
      expect(flowScore(20), 0.6);
      expect(flowScore(-30), 0.6);
    });
  });

  group('solunarScore', () {
    test('major 1.0, minor 0.75, none 0.35', () {
      expect(solunarScore(SolunarKind.major, isGoodDay: false), 1.0);
      expect(solunarScore(SolunarKind.minor, isGoodDay: false), 0.75);
      expect(solunarScore(SolunarKind.none, isGoodDay: false), 0.35);
    });
    test('good day adds 0.1, capped at 1.0', () {
      expect(solunarScore(SolunarKind.minor, isGoodDay: true), closeTo(0.85, 1e-9));
      expect(solunarScore(SolunarKind.none, isGoodDay: true), closeTo(0.45, 1e-9));
      expect(solunarScore(SolunarKind.major, isGoodDay: true), 1.0);
    });
  });

  group('pressureScore', () {
    test('falling 1–3 hPa → 1.0 (inclusive)', () {
      expect(pressureScore(-1), 1.0);
      expect(pressureScore(-2), 1.0);
      expect(pressureScore(-3), 1.0);
    });
    test('|Δp| < 1 → 0.8', () {
      expect(pressureScore(-0.99), 0.8);
      expect(pressureScore(0), 0.8);
      expect(pressureScore(0.99), 0.8);
    });
    test('rising 1–3 hPa → 0.6 (inclusive)', () {
      expect(pressureScore(1), 0.6);
      expect(pressureScore(3), 0.6);
    });
    test('falling > 3 → 0.3, rising > 3 → 0.4', () {
      expect(pressureScore(-3.01), 0.3);
      expect(pressureScore(3.01), 0.4);
    });
  });

  group('daytimeScore', () {
    // Local day 2026-11-09 (UTC+7): sunrise 05:55 = 22:55Z prev day, sunset 17:20 = 10:20Z.
    final sunrise = DateTime.utc(2026, 11, 8, 22, 55);
    final sunset = DateTime.utc(2026, 11, 9, 10, 20);
    double at(DateTime t) => daytimeScore(timeUtc: t, sunriseUtc: sunrise, sunsetUtc: sunset);

    test('within ±90 min of sunrise/sunset → 1.0 (inclusive)', () {
      expect(at(sunrise.subtract(const Duration(minutes: 90))), 1.0);
      expect(at(sunrise.add(const Duration(minutes: 90))), 1.0);
      expect(at(sunset.subtract(const Duration(minutes: 90))), 1.0);
      expect(at(sunset.add(const Duration(minutes: 90))), 1.0);
    });
    test('just outside ±90 min at night → 0.6', () {
      expect(at(sunrise.subtract(const Duration(minutes: 91))), 0.6);
      expect(at(sunset.add(const Duration(minutes: 91))), 0.6);
    });
    test('local 11:00–13:59 → 0.4', () {
      expect(at(DateTime.utc(2026, 11, 9, 4)), 0.4); // 11:00 local
      expect(at(DateTime.utc(2026, 11, 9, 6, 59)), 0.4); // 13:59 local
    });
    test('local 14:00 and mid-morning → 0.6', () {
      expect(at(DateTime.utc(2026, 11, 9, 7)), 0.6); // 14:00 local
      expect(at(DateTime.utc(2026, 11, 9, 2)), 0.6); // 09:00 local
      expect(at(DateTime.utc(2026, 11, 9, 3, 59)), 0.6); // 10:59 local
    });
    test('without sun times only the local-hour rule applies', () {
      expect(daytimeScore(timeUtc: DateTime.utc(2026, 11, 9, 5)), 0.4);
      expect(daytimeScore(timeUtc: DateTime.utc(2026, 11, 9, 20)), 0.6);
    });
    test('honours a custom tz offset', () {
      final t = DateTime.utc(2026, 11, 9, 11); // 11:00 at UTC+0
      expect(daytimeScore(timeUtc: t, tzOffsetHours: 0), 0.4);
      expect(daytimeScore(timeUtc: t), 0.6); // 18:00 at UTC+7
    });
  });

  group('weatherScore', () {
    test('wind < 15 → 1.0, 15–25 → 0.6, > 25 → 0.2', () {
      expect(weatherScore(windKmh: 14.9), 1.0);
      expect(weatherScore(windKmh: 15), 0.6);
      expect(weatherScore(windKmh: 25), 0.6);
      expect(weatherScore(windKmh: 25.1), 0.2);
    });
    test('rain < 1 ×1.0, 1–5 ×0.8, > 5 ×0.4', () {
      expect(weatherScore(windKmh: 5, rainMmPerH: 0.9), 1.0);
      expect(weatherScore(windKmh: 5, rainMmPerH: 1), closeTo(0.8, 1e-9));
      expect(weatherScore(windKmh: 5, rainMmPerH: 5), closeTo(0.8, 1e-9));
      expect(weatherScore(windKmh: 5, rainMmPerH: 5.1), closeTo(0.4, 1e-9));
    });
    test('cloud 30–80 % adds 0.1, capped at 1.0', () {
      expect(weatherScore(windKmh: 20, cloudPct: 30), closeTo(0.7, 1e-9));
      expect(weatherScore(windKmh: 20, cloudPct: 80), closeTo(0.7, 1e-9));
      expect(weatherScore(windKmh: 20, cloudPct: 29), closeTo(0.6, 1e-9));
      expect(weatherScore(windKmh: 20, cloudPct: 81), closeTo(0.6, 1e-9));
      expect(weatherScore(windKmh: 5, cloudPct: 50), 1.0);
    });
  });

  test('seasonScore: best month 1.0, otherwise 0.4', () {
    expect(seasonScore(isBestSeason: true), 1.0);
    expect(seasonScore(isBestSeason: false), 0.4);
  });
}
