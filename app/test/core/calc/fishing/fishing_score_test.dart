import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/astro/solunar_kind.dart';
import 'package:rivertide/core/calc/fishing/fishing_input.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';

// 09:00 local (UTC+7): not twilight, not night, not midday → daytime 0.6.
final _hour = DateTime.utc(2026, 11, 9, 2);
final _sunrise = DateTime.utc(2026, 11, 8, 22, 55);
final _sunset = DateTime.utc(2026, 11, 9, 10, 20);

/// Ideal conditions: every component 1.0 except daytime (0.6).
FishingHourInput _ideal({
  bool hasTide = true,
  int? minutesToTurn = 60,
  double? flowRateCmPerH,
  int? weatherCode,
  double? gustKmh,
  double? rainMmPerH = 0,
  double? capeJPerKg,
  double? precipProbPct,
  double? pressureDelta3hHpa = -2,
  double? windKmh = 5,
  bool? isBestSeason = true,
}) => FishingHourInput(
  hourUtc: _hour,
  hasTide: hasTide,
  minutesToTurn: minutesToTurn,
  springNeap: SpringNeap.spring,
  flowRateCmPerH: flowRateCmPerH,
  solunar: SolunarKind.major,
  sunriseUtc: _sunrise,
  sunsetUtc: _sunset,
  pressureDelta3hHpa: pressureDelta3hHpa,
  windKmh: windKmh,
  gustKmh: gustKmh,
  rainMmPerH: rainMmPerH,
  weatherCode: weatherCode,
  capeJPerKg: capeJPerKg,
  precipProbPct: precipProbPct,
  isBestSeason: isBestSeason,
);

void main() {
  test('version constant is fs-1', () {
    expect(fishingScoreVersion, 'fs-1');
  });

  group('weighted mean', () {
    test('all components present: 10 × (1.0 − 0.1 × 0.4) = 9.6', () {
      final s = scoreHour(_ideal());
      expect(s.score, 9.6);
      expect(s.components.length, 6);
      expect(s.safety, SafetyLevel.none);
      expect(s.hourUtc, _hour);
    });

    test('positive factors are components ≥ 0.9, heaviest first', () {
      final s = scoreHour(_ideal());
      expect(s.positiveFactors, [
        FishingFactor.tide,
        FishingFactor.solunar,
        FishingFactor.pressure,
        FishingFactor.weather,
        FishingFactor.season,
      ]);
    });

    test('missing weather data is dropped and weights renormalised', () {
      final s = scoreHour(_ideal(pressureDelta3hHpa: null, windKmh: null));
      // tide 0.3 + solunar 0.25 + daytime 0.1×0.6 + season 0.05 over Σw 0.70.
      expect(s.components.keys, isNot(contains(FishingFactor.pressure)));
      expect(s.components.keys, isNot(contains(FishingFactor.weather)));
      expect(s.score, closeTo(10 * 0.66 / 0.70, 0.05));
      expect(s.score, 9.4);
    });

    test('score is rounded to 1 decimal', () {
      final s = scoreHour(_ideal(minutesToTurn: 10, pressureDelta3hHpa: 2));
      // tide 0.5, pressure 0.6 → (0.15+0.25+0.12+0.06+0.1+0.05)/1.0 = 0.73.
      expect(s.score, 7.3);
    });
  });

  group('không triều (non-tidal station)', () {
    test('uses flow instead of tide with the same weight', () {
      final s = scoreHour(_ideal(hasTide: false, minutesToTurn: null, flowRateCmPerH: 5));
      expect(s.components.keys, contains(FishingFactor.flow));
      expect(s.components.keys, isNot(contains(FishingFactor.tide)));
      expect(s.components[FishingFactor.flow], 0.9);
      // 0.27 + 0.25 + 0.2 + 0.06 + 0.1 + 0.05 = 0.93.
      expect(s.score, 9.3);
    });

    test('ignores minutesToTurn when hasTide is false', () {
      final s = scoreHour(_ideal(hasTide: false, flowRateCmPerH: 30));
      expect(s.components[FishingFactor.flow], 0.3);
      expect(s.components.keys, isNot(contains(FishingFactor.tide)));
    });

    test('drops the water component when flow is unknown', () {
      final s = scoreHour(_ideal(hasTide: false, minutesToTurn: null));
      expect(s.components.keys, isNot(contains(FishingFactor.flow)));
      // (0.25+0.2+0.06+0.1+0.05)/0.70 = 0.9429.
      expect(s.score, 9.4);
    });

    test('drops tide when a tidal station lacks minutesToTurn', () {
      final s = scoreHour(_ideal(minutesToTurn: null));
      expect(s.components.keys, isNot(contains(FishingFactor.tide)));
    });
  });

  group('không có loài (no species chosen)', () {
    test('drops the season component', () {
      final s = scoreHour(_ideal(isBestSeason: null));
      expect(s.components.keys, isNot(contains(FishingFactor.season)));
      // (0.3+0.25+0.2+0.06+0.1)/0.95 = 0.9579.
      expect(s.score, 9.6);
    });

    test('off-season species lowers the score', () {
      final s = scoreHour(_ideal(isBestSeason: false));
      expect(s.components[FishingFactor.season], 0.4);
      expect(s.score, 9.3); // 0.93
    });
  });

  group('safety overrides', () {
    for (final code in [95, 96, 99]) {
      test('dông (weather code $code) → ≤ 2.0 and red', () {
        final s = scoreHour(_ideal(weatherCode: code));
        expect(s.score, lessThanOrEqualTo(2.0));
        expect(s.score, 2.0);
        expect(s.safety, SafetyLevel.red);
        expect(s.safetyReasons, contains(SafetyReason.thunderstorm));
      });
    }

    test('non-thunderstorm code does not cap', () {
      final s = scoreHour(_ideal(weatherCode: 63));
      expect(s.score, 9.6);
      expect(s.safety, SafetyLevel.none);
    });

    test('gust > 50 km/h → ≤ 2.0 and red; exactly 50 is not', () {
      final strong = scoreHour(_ideal(gustKmh: 50.1));
      expect(strong.score, 2.0);
      expect(strong.safety, SafetyLevel.red);
      expect(strong.safetyReasons, [SafetyReason.strongGust]);
      final edge = scoreHour(_ideal(gustKmh: 50));
      expect(edge.score, 9.6);
      expect(edge.safety, SafetyLevel.none);
    });

    test('rain > 20 mm/h → ≤ 3.0; exactly 20 is not capped', () {
      final heavy = scoreHour(_ideal(rainMmPerH: 20.1));
      expect(heavy.score, lessThanOrEqualTo(3.0));
      expect(heavy.safetyReasons, [SafetyReason.heavyRain]);
      expect(heavy.safety, SafetyLevel.yellow);
      final edge = scoreHour(_ideal(rainMmPerH: 20));
      expect(edge.score, greaterThan(3.0));
      expect(edge.safetyReasons, isEmpty);
    });

    test('caps never raise a low score', () {
      final s = scoreHour(
        _ideal(weatherCode: 95, minutesToTurn: 0, pressureDelta3hHpa: -5, windKmh: 40),
      );
      expect(s.score, lessThanOrEqualTo(2.0));
    });

    test('CAPE ≥ 3000 & precip ≥ 50 → yellow only, score NOT capped', () {
      final s = scoreHour(_ideal(capeJPerKg: 3000, precipProbPct: 50));
      expect(s.safety, SafetyLevel.yellow);
      expect(s.safetyReasons, [SafetyReason.possibleThunderstorm]);
      expect(s.score, 9.6);
    });

    test('CAPE 2500 → no warning', () {
      final s = scoreHour(_ideal(capeJPerKg: 2500, precipProbPct: 90));
      expect(s.safety, SafetyLevel.none);
      expect(s.safetyReasons, isEmpty);
    });

    test('high CAPE with low precip probability → no warning', () {
      final s = scoreHour(_ideal(capeJPerKg: 3500, precipProbPct: 49));
      expect(s.safety, SafetyLevel.none);
    });

    test('red wins over yellow when both apply', () {
      final s = scoreHour(_ideal(weatherCode: 95, capeJPerKg: 3500, precipProbPct: 80));
      expect(s.safety, SafetyLevel.red);
      expect(
        s.safetyReasons,
        containsAll([SafetyReason.thunderstorm, SafetyReason.possibleThunderstorm]),
      );
    });
  });
}
