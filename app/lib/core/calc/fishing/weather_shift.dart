/// "Sắp đổi thời tiết" (P2-34): changes in the next three days that matter
/// to anglers, from the hourly forecast. Common knowledge: fish feed hard
/// before a cold front and poorly for a day or two after; heavy rain clouds
/// the water; a fast pressure drop means worsening weather.
enum ShiftKind {
  /// Daily mean temperature drops ≥ 3 °C (northeast monsoon / cold front).
  coldFront,

  /// ≥ 30 mm of rain within a day.
  heavyRain,

  /// Pressure falls ≥ 5 hPa within 24 h.
  pressureDrop,

  /// Afternoon highs ≥ 36 °C.
  heatWave,
}

typedef WeatherShift = ({ShiftKind kind, DateTime atUtc});

/// One forecast hour (UTC); any value may be missing.
typedef ShiftHour = ({DateTime timeUtc, double? tempC, double? pressureHpa, double? rainMm});

const double coldFrontDropC = 3;
const double heavyRainMm = 30;
const double pressureDropHpa = 5;
const double heatWaveC = 36;

/// Shifts starting after [nowUtc] within [horizon], earliest first; at most
/// one per kind. [dayStartsUtc] = local-midnight boundaries covering the
/// hours (today first), used for daily means and rain totals.
List<WeatherShift> weatherShifts(
  List<ShiftHour> hours,
  DateTime nowUtc,
  List<DateTime> dayStartsUtc, {
  Duration horizon = const Duration(days: 3),
}) {
  final end = nowUtc.add(horizon);
  final out = <WeatherShift>[];
  List<ShiftHour> dayOf(int i) {
    final from = dayStartsUtc[i];
    final to = from.add(const Duration(days: 1));
    return [
      for (final h in hours)
        if (!h.timeUtc.isBefore(from) && h.timeUtc.isBefore(to)) h,
    ];
  }

  double? mean(Iterable<double?> v) {
    final x = v.nonNulls.toList();
    return x.isEmpty ? null : x.reduce((a, b) => a + b) / x.length;
  }

  final today = mean(dayOf(0).map((h) => h.tempC));
  for (var i = 1; i < dayStartsUtc.length; i++) {
    final start = dayStartsUtc[i];
    if (start.isAfter(end)) break;
    final day = dayOf(i);
    final t = mean(day.map((h) => h.tempC));
    final prev = i == 1 ? today : mean(dayOf(i - 1).map((h) => h.tempC));
    if (t != null && prev != null && prev - t >= coldFrontDropC) {
      out.add((kind: ShiftKind.coldFront, atUtc: start));
      break;
    }
  }
  for (var i = 0; i < dayStartsUtc.length; i++) {
    final day = dayOf(i).where((h) => h.timeUtc.isAfter(nowUtc) && h.timeUtc.isBefore(end));
    final rain = day.map((h) => h.rainMm ?? 0).fold<double>(0, (a, b) => a + b);
    if (rain >= heavyRainMm) {
      final wettest = day.reduce((a, b) => (b.rainMm ?? 0) > (a.rainMm ?? 0) ? b : a);
      out.add((kind: ShiftKind.heavyRain, atUtc: wettest.timeUtc));
      break;
    }
  }
  final future = [
    for (final h in hours)
      if (h.timeUtc.isAfter(nowUtc) && h.timeUtc.isBefore(end) && h.pressureHpa != null) h,
  ];
  for (final (i, h) in future.indexed) {
    final later = future.skip(i).where((x) => x.timeUtc.difference(h.timeUtc).inHours <= 24);
    final low = later.reduce((a, b) => (b.pressureHpa ?? 0) < (a.pressureHpa ?? 0) ? b : a);
    if ((h.pressureHpa ?? 0) - (low.pressureHpa ?? 0) >= pressureDropHpa) {
      out.add((kind: ShiftKind.pressureDrop, atUtc: h.timeUtc));
      break;
    }
  }
  final hot = hours.where(
    (h) => h.timeUtc.isAfter(nowUtc) && h.timeUtc.isBefore(end) && (h.tempC ?? 0) >= heatWaveC,
  );
  if (hot.isNotEmpty) out.add((kind: ShiftKind.heatWave, atUtc: hot.first.timeUtc));
  return out..sort((a, b) => a.atUtc.compareTo(b.atUtc));
}
