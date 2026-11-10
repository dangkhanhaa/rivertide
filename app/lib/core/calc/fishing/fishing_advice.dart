import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';

/// What the angler should know right now, most important first. Rules are
/// common angling practice (water movement, wind, storm, light), applied to
/// the place's computed level and weather — shown as suggestions.
enum AdviceKind {
  /// Thunderstorm or strong gusts: do not fish.
  unsafe,

  /// Rising water: fish move to banks and flooded shallows to feed → fish close in.
  risingNearBank,

  /// Falling water: fish drop back to deeper channels and creek mouths → fish farther out.
  fallingDeeper,

  /// Slack / turning: little feeding until the water moves again.
  slackWait,

  /// Strong wind: casting far is hard; stay near a sheltered bank, no boats.
  windStrong,

  /// Moderate wind on the water: fish the downwind side where food gathers.
  windDownwind,

  /// Rain likely in the next hours.
  rainLikely,

  /// River discharge rising fast: murky water, fish slack water behind obstacles.
  floodRising,

  /// Sunrise or sunset within the next hour: a strong feeding time.
  lightChange,

  /// Good score now.
  goodNow,
}

class AdviceInput {
  const AdviceInput({
    required this.nowUtc,
    required this.score,
    this.state,
    this.isTurning = false,
    this.nextTurnUtc,
    this.windKmh,
    this.gustKmh,
    this.rainProbPct,
    this.flowRisingFast = false,
    this.sunriseUtc,
    this.sunsetUtc,
  });

  final DateTime nowUtc;

  /// Current hour's fishing score (null when unknown).
  final FishingHourScore? score;
  final TideState? state;
  final bool isTurning;
  final DateTime? nextTurnUtc;
  final double? windKmh;
  final double? gustKmh;
  final double? rainProbPct;
  final bool flowRisingFast;
  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;
}

/// Thresholds (km/h, %) — Beaufort 5 "fresh breeze" ≈ 30 km/h makes casting hard.
const double strongWindKmh = 30;
const double moderateWindKmh = 15;
const double rainLikelyPct = 60;
const Duration lightChangeWindow = Duration(hours: 1);

List<AdviceKind> fishingAdvice(AdviceInput i) {
  final out = <AdviceKind>[];
  final safety = i.score?.safety ?? SafetyLevel.none;
  if (safety == SafetyLevel.red) return const [AdviceKind.unsafe];
  final state = i.state;
  if (i.isTurning || state == TideState.slack) {
    out.add(AdviceKind.slackWait);
  } else if (state != null && isRising(state)) {
    out.add(AdviceKind.risingNearBank);
  } else if (state != null && isFalling(state)) {
    out.add(AdviceKind.fallingDeeper);
  }
  final wind = [i.windKmh, i.gustKmh].whereType<double>().fold<double>(0, (a, b) => a > b ? a : b);
  if (wind >= strongWindKmh) {
    out.add(AdviceKind.windStrong);
  } else if ((i.windKmh ?? 0) >= moderateWindKmh) {
    out.add(AdviceKind.windDownwind);
  }
  if ((i.rainProbPct ?? 0) >= rainLikelyPct) out.add(AdviceKind.rainLikely);
  if (i.flowRisingFast) out.add(AdviceKind.floodRising);
  for (final t in [i.sunriseUtc, i.sunsetUtc]) {
    if (t == null) continue;
    final d = t.difference(i.nowUtc);
    if (!d.isNegative && d <= lightChangeWindow) {
      out.add(AdviceKind.lightChange);
      break;
    }
  }
  if ((i.score?.score ?? 0) >= 7 && safety == SafetyLevel.none) out.add(AdviceKind.goodNow);
  return out;
}
