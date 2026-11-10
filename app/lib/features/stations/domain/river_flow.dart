/// Discharge of the river's main stem near a point (GloFAS model, daily).
class RiverFlow {
  const RiverFlow({required this.days, required this.cellLat, required this.cellLon});

  /// (UTC day, m³/s) in time order.
  final List<(DateTime, double)> days;

  /// GloFAS cell chosen as the main stem (largest mean discharge nearby).
  final double cellLat;
  final double cellLon;

  /// Value for the UTC day containing [nowUtc], or null.
  double? on(DateTime nowUtc) {
    final day = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    for (final (d, q) in days) {
      if (d == day) return q;
    }
    return null;
  }
}

enum FlowTrend { rising, falling, steady }

/// Change from today to tomorrow beyond this share counts as rising/falling.
const double flowTrendThreshold = 0.05;

FlowTrend? flowTrend(double? today, double? tomorrow) {
  if (today == null || tomorrow == null || today <= 0) return null;
  final r = (tomorrow - today) / today;
  if (r > flowTrendThreshold) return FlowTrend.rising;
  if (r < -flowTrendThreshold) return FlowTrend.falling;
  return FlowTrend.steady;
}
