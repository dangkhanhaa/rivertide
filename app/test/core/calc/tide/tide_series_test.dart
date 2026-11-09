import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';

import 'tide_test_utils.dart';

void main() {
  final start = DateTime.utc(2026, 11);
  final series = syntheticM2(start: start);

  group('TideSeries interpolation', () {
    test('levelAt matches the analytic curve between samples within 1 cm', () {
      for (var m = 0; m < 24 * 60; m += 7) {
        final t = start.add(Duration(hours: 30, minutes: m));
        expect(series.levelAt(t), closeTo(m2LevelCm(start, t), 1.0));
      }
    });

    test('levelAt returns null outside coverage', () {
      expect(series.levelAt(start.subtract(const Duration(minutes: 1))), isNull);
      expect(series.levelAt(series.endUtc.add(const Duration(minutes: 1))), isNull);
    });

    test('rate is about 0 at high water and about -50 cm/h at mid-falling', () {
      final high = series.extremes[2].timeUtc;
      expect(series.rateCmPerHAt(high)!.abs(), lessThan(2));
      final midFall = high.add(Duration(seconds: (m2Hours / 4 * 3600).round()));
      // d/dt of 100 cos(2πt/T) at quarter period = -100·2π/T ≈ -50.6 cm/h.
      expect(series.rateCmPerHAt(midFall), closeTo(-50.6, 1.5));
    });

    test('rejects non-UTC start and non-positive step', () {
      expect(
        () => TideSeries(
          startUtc: DateTime(2026),
          stepMinutes: 10,
          levelsCm: const [1, 2],
          extremes: const [],
        ),
        throwsArgumentError,
      );
      expect(
        () =>
            TideSeries(startUtc: start, stepMinutes: 0, levelsCm: const [1, 2], extremes: const []),
        throwsArgumentError,
      );
    });

    test('append joins contiguous series and rejects gaps', () {
      final a = TideSeries(
        startUtc: start,
        stepMinutes: 10,
        levelsCm: const [1, 2],
        extremes: const [],
      );
      final b = TideSeries(
        startUtc: start.add(const Duration(minutes: 20)),
        stepMinutes: 10,
        levelsCm: const [3, 4],
        extremes: const [],
      );
      expect(a.append(b).levelsCm, [1, 2, 3, 4]);
      expect(() => a.append(a), throwsArgumentError);
    });
  });

  group('TideQueries', () {
    test('countdown to next high (AC-TIDE02-1 style)', () {
      final high = series.extremes[4];
      final now = high.timeUtc.subtract(const Duration(hours: 2, minutes: 15));
      expect(series.nextExtreme(now), high);
      expect(series.countdownToNext(now), const Duration(hours: 2, minutes: 15));
    });

    test('next extreme switches right after passing (AC-TIDE02-2)', () {
      final high = series.extremes[4];
      expect(series.nextExtreme(high.timeUtc.add(const Duration(seconds: 1))), series.extremes[5]);
    });

    test('isTurning within 10 minutes of an extreme (AC-TIDE02-4)', () {
      final t = series.extremes[4].timeUtc;
      expect(series.isTurning(t.subtract(const Duration(minutes: 10))), isTrue);
      expect(series.isTurning(t.add(const Duration(minutes: 11))), isFalse);
    });

    test('stateAt reports slack at high water and falling after', () {
      final t = series.extremes[4].timeUtc;
      expect(series.stateAt(t), TideState.slack);
      expect(isFalling(series.stateAt(t.add(const Duration(hours: 3)))!), isTrue);
    });

    test('daily range and normal spring/neap on a constant-range tide', () {
      final day = localDayStartUtc(2026, 11, 15);
      expect(series.dailyRangeCm(day), 200);
      expect(series.springNeapAt(day), SpringNeap.normal);
    });

    test('correction fades linearly to zero over 12 h (F-TIDE-07)', () {
      final obsTime = start.add(const Duration(days: 3));
      final pred = series.levelAt(obsTime)!;
      final atObs = series.correctedLevelAt(obsTime, obsTimeUtc: obsTime, obsLevelCm: pred + 30);
      expect(atObs, closeTo(pred + 30, 1e-6));
      final t6 = obsTime.add(const Duration(hours: 6));
      expect(
        series.correctedLevelAt(t6, obsTimeUtc: obsTime, obsLevelCm: pred + 30),
        closeTo(series.levelAt(t6)! + 15, 1e-6),
      );
      final t13 = obsTime.add(const Duration(hours: 13));
      expect(
        series.correctedLevelAt(t13, obsTimeUtc: obsTime, obsLevelCm: pred + 30),
        series.levelAt(t13),
      );
    });

    test('localDayStartUtc gives 17:00 UTC of previous day for Vietnam', () {
      expect(localDayStartUtc(2026, 11, 9), DateTime.utc(2026, 11, 8, 17));
    });
  });

  group('classifyRate', () {
    test('thresholds 3 and 20 cm/h', () {
      expect(classifyRate(2.9), TideState.slack);
      expect(classifyRate(-2.9), TideState.slack);
      expect(classifyRate(3), TideState.rising);
      expect(classifyRate(20), TideState.rising);
      expect(classifyRate(20.1), TideState.risingFast);
      expect(classifyRate(-3), TideState.falling);
      expect(classifyRate(-20.1), TideState.fallingFast);
    });
  });
}
