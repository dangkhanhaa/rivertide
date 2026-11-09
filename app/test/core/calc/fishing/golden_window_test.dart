import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';

final _day = DateTime.utc(2026, 11, 9);

FishingHourScore _h(int hour, double score, [List<FishingFactor> pos = const []]) =>
    FishingHourScore(
      hourUtc: _day.add(Duration(hours: hour)),
      score: score,
      components: const {},
      safety: SafetyLevel.none,
      positiveFactors: pos,
    );

void main() {
  group('goldenWindows', () {
    test('returns nothing when no hour reaches 7.0', () {
      expect(goldenWindows([_h(0, 6.9), _h(1, 5)]), isEmpty);
    });

    test('merges adjacent hours ≥ 7.0 into one window (7.0 inclusive)', () {
      final w = goldenWindows([_h(5, 7), _h(6, 8.5), _h(7, 7.2), _h(8, 6)]);
      expect(w, hasLength(1));
      expect(w.single.startUtc, _day.add(const Duration(hours: 5)));
      expect(w.single.endUtc, _day.add(const Duration(hours: 8)));
      expect(w.single.peakScore, 8.5);
    });

    test('hourly gap of one bad hour (60 min) is not merged', () {
      final w = goldenWindows([_h(5, 8), _h(6, 5), _h(7, 8)]);
      expect(w, hasLength(2));
    });

    test('gaps < 30 min are merged, 30 min is not', () {
      const slot = Duration(minutes: 30);
      FishingHourScore at(int minutes, double s) => FishingHourScore(
        hourUtc: _day.add(Duration(minutes: minutes)),
        score: s,
        components: const {},
        safety: SafetyLevel.none,
        positiveFactors: const [],
      );
      // 0–30 good, 30–50 gap (20 min) → merged with 50–80.
      final merged = goldenWindows([at(0, 8), at(50, 8)], slot: slot);
      expect(merged, hasLength(1));
      expect(merged.single.endUtc, _day.add(const Duration(minutes: 80)));
      // 0–30 good, 30–60 gap (30 min) → separate.
      final split = goldenWindows([at(0, 8), at(60, 8)], slot: slot);
      expect(split, hasLength(2));
    });

    test('keeps at most 3 windows with the highest peaks, sorted by start', () {
      final w = goldenWindows([_h(1, 7.1), _h(4, 9), _h(7, 7.5), _h(10, 8), _h(13, 7.2)]);
      expect(w.map((e) => e.peakScore), [9, 7.5, 8]);
      expect(w.map((e) => e.startUtc.hour), [4, 7, 10]);
    });

    test('accepts unsorted input', () {
      final w = goldenWindows([_h(7, 8), _h(5, 8), _h(6, 9)]);
      expect(w.single.startUtc.hour, 5);
      expect(w.single.peakScore, 9);
    });

    test('reasons come from the peak hour', () {
      final w = goldenWindows([
        _h(5, 7.5, [FishingFactor.daytime]),
        _h(6, 8.8, [FishingFactor.tide, FishingFactor.solunar]),
      ]);
      expect(w.single.reasons, [FishingFactor.tide, FishingFactor.solunar]);
    });
  });

  group('dayScore', () {
    test('averages the top 4 hour scores, 1 decimal', () {
      final s = dayScore([_h(0, 2), _h(1, 9), _h(2, 8), _h(3, 7), _h(4, 6.5), _h(5, 1)]);
      expect(s, 7.6); // (9+8+7+6.5)/4 = 7.625
    });

    test('uses all hours when fewer than 4', () {
      expect(dayScore([_h(0, 6), _h(1, 8)]), 7);
    });

    test('empty day scores 0', () {
      expect(dayScore(const []), 0);
    });
  });
}
