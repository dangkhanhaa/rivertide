import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/geo/fuzz.dart';
import 'package:rivertide/core/calc/geo/geohash.dart';
import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/calc/geo/vietnam_bounds.dart';

void main() {
  group('haversineKm', () {
    test('Hồ Hoàn Kiếm ↔ Nhà thờ Đức Bà ≈ 1143 km ± 3 km', () {
      expect(haversineKm(21.0287, 105.8524, 10.7798, 106.6990), closeTo(1143, 3));
    });
    test('is symmetric and zero for the same point', () {
      final a = haversineKm(21.0287, 105.8524, 10.0341, 105.7880);
      final b = haversineKm(10.0341, 105.7880, 21.0287, 105.8524);
      expect(a, closeTo(b, 1e-9));
      expect(haversineKm(10, 106, 10, 106), 0);
    });
    test('one degree of latitude ≈ 111.2 km', () {
      expect(haversineKm(10, 106, 11, 106), closeTo(111.2, 0.1));
    });
  });

  group('geohashEncode', () {
    test('matches the Wikipedia vector', () {
      expect(geohashEncode(57.64911, 10.40744, precision: 11), 'u4pruydqqvj');
    });
    test('defaults to precision 5 (prefix of the full hash)', () {
      expect(geohashEncode(57.64911, 10.40744), 'u4pru');
    });
    test('rejects invalid input', () {
      expect(() => geohashEncode(91, 0), throwsArgumentError);
      expect(() => geohashEncode(0, 181), throwsArgumentError);
      expect(() => geohashEncode(0, 0, precision: 0), throwsArgumentError);
      expect(() => geohashEncode(0, 0, precision: 13), throwsArgumentError);
    });
  });

  group('isInVietnamBounds', () {
    test('accepts mainland and offshore islands', () {
      expect(isInVietnamBounds(21.0287, 105.8524), isTrue); // Hà Nội
      expect(isInVietnamBounds(10.0341, 105.7880), isTrue); // Cần Thơ
      expect(isInVietnamBounds(16.5, 112), isTrue); // Hoàng Sa
      expect(isInVietnamBounds(8.65, 111.92), isTrue); // Trường Sa
    });
    test('rejects points outside the bbox, edges inclusive', () {
      expect(isInVietnamBounds(1.35, 103.8), isFalse); // Singapore
      expect(isInVietnamBounds(35.7, 139.7), isFalse); // Tokyo
      expect(isInVietnamBounds(8, 102), isTrue);
      expect(isInVietnamBounds(23.51, 105), isFalse);
    });
  });

  group('fuzz', () {
    test('is deterministic for the same seed', () {
      final a = fuzz(10.0341, 105.7880, radiusKm: 2, seed: 42);
      final b = fuzz(10.0341, 105.7880, radiusKm: 2, seed: 42);
      expect(a.lat, b.lat);
      expect(a.lon, b.lon);
    });

    test('different seeds usually give different points', () {
      final points = {
        for (var seed = 0; seed < 20; seed++) fuzz(10.0341, 105.7880, radiusKm: 5, seed: seed),
      };
      expect(points.length, greaterThan(1));
    });

    test('stays within the radius and is rounded to 2 decimals', () {
      for (final radius in [1.0, 2.0, 5.0]) {
        for (var seed = 0; seed < 200; seed++) {
          final p = fuzz(21.0287, 105.8524, radiusKm: radius, seed: seed);
          expect(haversineKm(21.0287, 105.8524, p.lat, p.lon), lessThanOrEqualTo(radius));
          expect((p.lat * 100).roundToDouble() / 100, p.lat);
          expect((p.lon * 100).roundToDouble() / 100, p.lon);
        }
      }
    });

    test('rejects invalid input', () {
      expect(() => fuzz(10, 106, radiusKm: 0, seed: 1), throwsArgumentError);
      expect(() => fuzz(10, 106, radiusKm: double.nan, seed: 1), throwsArgumentError);
      expect(() => fuzz(100, 106, radiusKm: 1, seed: 1), throwsArgumentError);
      expect(() => fuzz(10, 200, radiusKm: 1, seed: 1), throwsArgumentError);
    });
  });

  group('Mulberry32', () {
    test('produces the reference sequence for seed 1', () {
      // Canonical JS mulberry32(1) first output is 0.6270739405881613.
      final rng = Mulberry32(1);
      expect(rng.nextUint32(), 2693262067);
      expect(rng.nextUint32(), 11749833);
      expect(rng.nextUint32(), 2265367787);
    });

    test('outputs stay in [0, 1)', () {
      final rng = Mulberry32(123);
      for (var i = 0; i < 1000; i++) {
        final v = rng.nextDouble();
        expect(v, greaterThanOrEqualTo(0));
        expect(v, lessThan(1));
      }
    });
  });
}
