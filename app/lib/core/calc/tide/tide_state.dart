/// Water movement classes shown with text + icon (FEATURES.md F-TIDE-02, F-TIDE-09).
enum TideState { risingFast, rising, slack, falling, fallingFast }

/// Default thresholds; PROJECT.md 9.1 marks them tunable per station.
const double slackThresholdCmPerH = 3;
const double fastThresholdCmPerH = 20;

/// Window around an extreme where the UI says "Đang đổi con nước" (AC-TIDE02-4).
const Duration turningWindow = Duration(minutes: 10);

TideState classifyRate(
  double rateCmPerH, {
  double slackCmPerH = slackThresholdCmPerH,
  double fastCmPerH = fastThresholdCmPerH,
}) {
  if (rateCmPerH.abs() < slackCmPerH) return TideState.slack;
  if (rateCmPerH > fastCmPerH) return TideState.risingFast;
  if (rateCmPerH > 0) return TideState.rising;
  if (rateCmPerH < -fastCmPerH) return TideState.fallingFast;
  return TideState.falling;
}

bool isRising(TideState s) => s == TideState.rising || s == TideState.risingFast;

bool isFalling(TideState s) => s == TideState.falling || s == TideState.fallingFast;
