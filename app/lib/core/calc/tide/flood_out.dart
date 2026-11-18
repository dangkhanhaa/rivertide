import 'package:rivertide/core/calc/tide/tide_series.dart';

/// "Mấy giờ nước ngập lối về" (P2-33): when the predicted water rises by
/// `marginCm` above its level now — the angler's estimate of how far below
/// their standing spot / way back the water is — and when it drops again.
///
/// `windExtraCm` lowers the threshold: strong onshore wind pushes water above
/// the prediction, so warn earlier. Pure: time comes in as `nowUtc`.
class FloodOut {
  const FloodOut({
    required this.nowLevelCm,
    required this.thresholdCm,
    this.floodUtc,
    this.recedeUtc,
    this.peakUtc,
    this.peakCm,
  });

  final double nowLevelCm;
  final double thresholdCm;

  /// First time the level reaches the threshold within the horizon; null =
  /// it does not (safe for that long). Equals now when already reached.
  final DateTime? floodUtc;

  /// When it falls back below the threshold after [floodUtc].
  final DateTime? recedeUtc;

  /// Highest predicted level within the horizon.
  final DateTime? peakUtc;
  final double? peakCm;

  bool get floods => floodUtc != null;
}

/// Time step of the scan; tide curves change slowly, 5 min is plenty.
const Duration floodScanStep = Duration(minutes: 5);

/// Leave this long before the water arrives.
const Duration floodLeaveBefore = Duration(minutes: 30);

/// Wind (km/h) from which the threshold is lowered by [windSetupCm].
const double floodWindKmh = 30;
const int windSetupCm = 20;

/// Null when the series has no level for [nowUtc].
FloodOut? floodOut(
  TideSeries series,
  DateTime nowUtc, {
  required int marginCm,
  int windExtraCm = 0,
  Duration horizon = const Duration(hours: 24),
}) {
  final now = series.levelAt(nowUtc);
  if (now == null) return null;
  final threshold = now + marginCm - windExtraCm;
  DateTime? flood;
  DateTime? recede;
  DateTime? peakAt;
  double? peak;
  for (var t = nowUtc; !t.isAfter(nowUtc.add(horizon)); t = t.add(floodScanStep)) {
    final level = series.levelAt(t);
    if (level == null) break;
    if (peak == null || level > peak) {
      peak = level;
      peakAt = t;
    }
    if (flood == null && level >= threshold) flood = t;
    if (flood != null && recede == null && level < threshold) recede = t;
  }
  return FloodOut(
    nowLevelCm: now,
    thresholdCm: threshold,
    floodUtc: flood,
    recedeUtc: recede,
    peakUtc: peakAt,
    peakCm: peak,
  );
}
