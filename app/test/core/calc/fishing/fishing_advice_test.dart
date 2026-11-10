import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/fishing/fishing_advice.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';

final _now = DateTime.utc(2026, 11, 10, 3);

FishingHourScore _score(double s, [SafetyLevel safety = SafetyLevel.none]) => FishingHourScore(
  hourUtc: _now,
  score: s,
  components: const {},
  safety: safety,
  positiveFactors: const [],
);

void main() {
  test('storm overrides everything', () {
    final a = fishingAdvice(
      AdviceInput(nowUtc: _now, score: _score(2, SafetyLevel.red), state: TideState.rising),
    );
    expect(a, [AdviceKind.unsafe]);
  });

  test('rising water → near the bank; falling → deeper; slack/turning → wait', () {
    expect(
      fishingAdvice(AdviceInput(nowUtc: _now, score: _score(5), state: TideState.risingFast)),
      contains(AdviceKind.risingNearBank),
    );
    expect(
      fishingAdvice(AdviceInput(nowUtc: _now, score: _score(5), state: TideState.falling)),
      contains(AdviceKind.fallingDeeper),
    );
    expect(
      fishingAdvice(AdviceInput(nowUtc: _now, score: _score(5), state: TideState.slack)),
      contains(AdviceKind.slackWait),
    );
    expect(
      fishingAdvice(
        AdviceInput(nowUtc: _now, score: _score(5), state: TideState.rising, isTurning: true),
      ),
      allOf(contains(AdviceKind.slackWait), isNot(contains(AdviceKind.risingNearBank))),
    );
  });

  test('wind thresholds use the stronger of wind and gust', () {
    expect(
      fishingAdvice(AdviceInput(nowUtc: _now, score: _score(5), windKmh: 12, gustKmh: 35)),
      contains(AdviceKind.windStrong),
    );
    expect(
      fishingAdvice(AdviceInput(nowUtc: _now, score: _score(5), windKmh: 18, gustKmh: 25)),
      contains(AdviceKind.windDownwind),
    );
    expect(
      fishingAdvice(AdviceInput(nowUtc: _now, score: _score(5), windKmh: 8)),
      isNot(anyOf(contains(AdviceKind.windStrong), contains(AdviceKind.windDownwind))),
    );
  });

  test('rain, flood, sunset within the hour, good score', () {
    final a = fishingAdvice(
      AdviceInput(
        nowUtc: _now,
        score: _score(7.5),
        rainProbPct: 70,
        flowRisingFast: true,
        sunsetUtc: _now.add(const Duration(minutes: 40)),
      ),
    );
    expect(
      a,
      containsAll([
        AdviceKind.rainLikely,
        AdviceKind.floodRising,
        AdviceKind.lightChange,
        AdviceKind.goodNow,
      ]),
    );
    final past = fishingAdvice(
      AdviceInput(
        nowUtc: _now,
        score: _score(5),
        sunsetUtc: _now.subtract(const Duration(minutes: 5)),
      ),
    );
    expect(past, isNot(contains(AdviceKind.lightChange)));
  });
}
