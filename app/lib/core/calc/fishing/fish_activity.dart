/// "Cá ăn" bands of the hourly fishing score (P2-20), shown on map pins and
/// the activity card. The score is an estimate (PROJECT.md 9.6); these bands
/// only make it readable at a glance.
enum FishActivity { low, fair, high, peak }

/// Lower bounds of [FishActivity.fair], [FishActivity.high], [FishActivity.peak].
/// 7.0 matches the golden-window threshold, so "Cao" hours are golden hours.
const double fishFairFrom = 5;
const double fishHighFrom = 7;
const double fishPeakFrom = 8.5;

FishActivity fishActivity(double score) => score >= fishPeakFrom
    ? FishActivity.peak
    : (score >= fishHighFrom
          ? FishActivity.high
          : (score >= fishFairFrom ? FishActivity.fair : FishActivity.low));

/// 1–5 fish for the meter: one fish per 2 points, at least one.
int fishCount(double score) => (score / 2).round().clamp(1, 5);
