// Solunar periods (PROJECT.md 9.5), after John Alden Knight's solunar theory:
// major = ±60 min around moon upper/lower transit, minor = ±30 min around
// moonrise/moonset; "good day" = within ±2 calendar days of new/full moon.

import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/astro/astro_math.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/astro/moon_times.dart';
import 'package:rivertide/core/calc/astro/solunar_kind.dart';

class SolunarPeriod {
  const SolunarPeriod({
    required this.kind,
    required this.startUtc,
    required this.endUtc,
    required this.centerUtc,
  });

  /// Builds a period of ±[halfWidth] around [centerUtc].
  SolunarPeriod.around(this.kind, this.centerUtc, Duration halfWidth)
    : startUtc = centerUtc.subtract(halfWidth),
      endUtc = centerUtc.add(halfWidth);

  final SolunarKind kind;
  final DateTime startUtc;
  final DateTime endUtc;
  final DateTime centerUtc;

  /// Half-open containment [startUtc, endUtc).
  bool contains(DateTime utc) => !utc.isBefore(startUtc) && utc.isBefore(endUtc);
}

class SolunarDay {
  const SolunarDay({required this.periods, required this.isGoodDay});

  /// Periods overlapping the local day, sorted by start.
  final List<SolunarPeriod> periods;

  /// Within ±2 calendar days of a new or full moon.
  final bool isGoodDay;
}

const Duration majorHalfWidth = Duration(minutes: 60);
const Duration minorHalfWidth = Duration(minutes: 30);
const int goodDayWindowDays = 2;

/// Solunar periods for local calendar day [year]-[month]-[day].
///
/// Events of the previous/next day are included when their period spills
/// over local midnight, so lookups near midnight are correct.
SolunarDay solunarForDay({
  required int year,
  required int month,
  required int day,
  required double lat,
  required double lon,
  double tzOffsetHours = 7,
}) {
  final dayStart = localMidnightUtc(year, month, day, tzOffsetHours);
  final dayEnd = localMidnightUtc(year, month, day + 1, tzOffsetHours);
  final all = <SolunarPeriod>[];
  for (var offset = -1; offset <= 1; offset++) {
    // DateTime.utc normalises day overflow (e.g. day 0 / day 32).
    final date = DateTime.utc(year, month, day + offset);
    all.addAll(_periodsOf(date, lat, lon, tzOffsetHours));
  }
  final periods = all
      .where((p) => p.endUtc.isAfter(dayStart) && p.startUtc.isBefore(dayEnd))
      .sortedBy((p) => p.startUtc);
  return SolunarDay(
    periods: List.unmodifiable(periods),
    isGoodDay: _isGoodDay(year, month, day, tzOffsetHours),
  );
}

/// Solunar kind at [utc]; major wins over minor where they overlap.
SolunarKind solunarAt(DateTime utc, SolunarDay day) {
  final hits = day.periods.where((p) => p.contains(utc));
  if (hits.any((p) => p.kind == SolunarKind.major)) return SolunarKind.major;
  if (hits.any((p) => p.kind == SolunarKind.minor)) return SolunarKind.minor;
  return SolunarKind.none;
}

List<SolunarPeriod> _periodsOf(DateTime date, double lat, double lon, double tzOffsetHours) {
  final transits = moonTransits(
    year: date.year,
    month: date.month,
    day: date.day,
    lat: lat,
    lon: lon,
    tzOffsetHours: tzOffsetHours,
  );
  final times = moonTimes(
    year: date.year,
    month: date.month,
    day: date.day,
    lat: lat,
    lon: lon,
    tzOffsetHours: tzOffsetHours,
  );
  return [
    for (final t in [transits.upper, transits.lower])
      if (t != null) SolunarPeriod.around(SolunarKind.major, t, majorHalfWidth),
    for (final t in [times.rise, times.set])
      if (t != null) SolunarPeriod.around(SolunarKind.minor, t, minorHalfWidth),
  ];
}

bool _isGoodDay(int year, int month, int day, double tzOffsetHours) {
  final localNoon = localMidnightUtc(
    year,
    month,
    day,
    tzOffsetHours,
  ).add(const Duration(hours: 12));
  final event = nearestNewOrFullMoon(localNoon);
  final eventLocal = event.utc.add(hoursToDuration(tzOffsetHours));
  final eventDate = DateTime.utc(eventLocal.year, eventLocal.month, eventLocal.day);
  final diffDays = DateTime.utc(year, month, day).difference(eventDate).inDays.abs();
  return diffDays <= goodDayWindowDays;
}
