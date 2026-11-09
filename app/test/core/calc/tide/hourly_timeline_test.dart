import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/calc/tide/observation.dart';
import 'package:rivertide/core/calc/tide/skill.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';

import 'tide_test_utils.dart';

void main() {
  final start = DateTime.utc(2026, 11);
  final series = syntheticM2(start: start);

  List<WaterObservation> minuteObs(DateTime from, DateTime to, {double offsetCm = 0}) => [
    for (var t = from; t.isBefore(to); t = t.add(const Duration(minutes: 1)))
      WaterObservation(timeUtc: t, levelCm: m2LevelCm(start, t) + offsetCm),
  ];

  group('hourlyMeans', () {
    test('averages ±5 min around each hour and skips sparse hours', () {
      final from = DateTime.utc(2026, 11, 5, 3);
      final obs = [
        ...minuteObs(
          from.subtract(const Duration(minutes: 5)),
          from.add(const Duration(minutes: 5)),
        ),
        WaterObservation(timeUtc: from.add(const Duration(hours: 1)), levelCm: 1),
      ];
      final means = hourlyMeans(obs, from, from.add(const Duration(hours: 1)));
      expect(means.keys, [from]);
      expect(means[from], closeTo(m2LevelCm(start, from), 2));
    });
  });

  group('buildHourlyTimeline', () {
    final now = DateTime.utc(2026, 11, 5, 11, 5);
    final obs = minuteObs(now.subtract(const Duration(hours: 8)), now, offsetCm: 12);
    final observedHourly = hourlyMeans(obs, now.subtract(const Duration(hours: 8)), now);

    List<TimelineEntry> build() => buildHourlyTimeline(
      nowUtc: now,
      observedHourly: observedHourly,
      prediction: series,
      latestObservation: (timeUtc: obs.last.timeUtc, levelCm: obs.last.levelCm),
    );

    test('11:00 and before are observed, 12:00 onward forecast (AC-TIDE09-1)', () {
      final hours = build().whereType<HourEntry>().toList();
      final h11 = hours.firstWhere((h) => h.timeUtc == DateTime.utc(2026, 11, 5, 11));
      final h12 = hours.firstWhere((h) => h.timeUtc == DateTime.utc(2026, 11, 5, 12));
      expect(h11.kind, LevelDataKind.observed);
      expect(h12.kind, LevelDataKind.forecast);
      expect(h11.observedMinusPredictedCm, closeTo(12, 2));
    });

    test('covers -6 h to +18 h with extremes inserted at exact minute (AC-TIDE09-2)', () {
      final entries = build();
      final hours = entries.whereType<HourEntry>().toList();
      expect(hours.first.timeUtc, DateTime.utc(2026, 11, 5, 5));
      expect(hours.last.timeUtc, DateTime.utc(2026, 11, 6, 5));
      final extremes = entries.whereType<ExtremeEntry>().toList();
      expect(extremes, isNotEmpty);
      for (final e in extremes) {
        final i = entries.indexOf(e);
        if (i > 0) expect(entries[i - 1].timeUtc.isAfter(e.timeUtc), isFalse);
        if (i < entries.length - 1) expect(entries[i + 1].timeUtc.isBefore(e.timeUtc), isFalse);
      }
    });

    test('near-term forecast carries the observed bias, fading later', () {
      final hours = build().whereType<HourEntry>().toList();
      final h12 = hours.firstWhere((h) => h.timeUtc == DateTime.utc(2026, 11, 5, 12));
      expect(h12.levelCm - h12.predictedCm!, closeTo(12 * (1 - 55 / 720), 1));
      final far = hours.last;
      expect(far.levelCm, far.predictedCm);
    });

    test('without prediction and observations nothing is invented', () {
      final entries = buildHourlyTimeline(nowUtc: now, observedHourly: const {});
      expect(entries, isEmpty);
    });

    test('estimate kind is propagated for model-only stations', () {
      final entries = buildHourlyTimeline(
        nowUtc: now,
        observedHourly: const {},
        prediction: series,
        predictionKind: LevelDataKind.estimate,
      );
      expect(entries.whereType<HourEntry>().every((h) => h.kind == LevelDataKind.estimate), isTrue);
    });
  });

  group('computeSkill', () {
    test('constant 12 cm bias gives rmse 12 and ~0 min timing error', () {
      final from = DateTime.utc(2026, 11, 3);
      final to = DateTime.utc(2026, 11, 13);
      final hourly = hourlyMeans(minuteObs(from, to, offsetCm: 12), from, to);
      final skill = computeSkill(hourly, series)!;
      expect(skill.rmseCm, closeTo(12, 1));
      expect(skill.extremeCount, greaterThan(10));
      expect(skill.meanAbsExtremeTimeMin, lessThan(10));
      expect(skill.meanAbsExtremeHeightCm, closeTo(12, 3));
    });

    test('returns null with too little overlap', () {
      expect(computeSkill({DateTime.utc(2026, 11, 3): 1}, series), isNull);
    });

    test('series built from TideSeries has expected extreme kinds', () {
      expect(series.extremes.first.kind, TideExtremeKind.high);
    });
  });
}
