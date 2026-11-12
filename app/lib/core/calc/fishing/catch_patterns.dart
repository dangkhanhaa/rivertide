import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/astro/solunar.dart';
import 'package:rivertide/core/calc/astro/solunar_kind.dart';
import 'package:rivertide/core/calc/astro/sun.dart';

/// "Thói quen câu của bạn" (P2-23): which conditions come up most in the
/// user's own fishing log. Descriptive only: it counts the log, it does not
/// claim why fish bit.

enum PatternFactor { dayPart, water, moon, solunar, wind }

enum DayPart { dawn, morning, midday, afternoon, dusk, night }

enum WaterMove { rising, falling, slack }

/// New/full = within ±[_moonBandHalfWidth] of the phase; the rest is "quarter".
enum MoonBand { newMoon, fullMoon, quarter }

/// Calm < 10 km/h, light 10–20, strong > 20.
enum WindBand { calm, light, strong }

const double _moonBandHalfWidth = 0.125;
const Duration _twilight = Duration(minutes: 90);
const int _tzHours = 7;

/// Below this many catches no pattern is shown.
const int minCatchesForPatterns = 8;

/// A factor needs this many catches where it is known…
const int _minKnown = 6;

/// …the top value at least this many of them…
const int _minHits = 4;

/// …at least this share of them…
const double _minShare = 0.4;

/// …and this many times its share of an ordinary day (so "night" or "no
/// solunar period", which fill most hours, do not count just by being common).
const double _minLift = 1.5;

/// Share of a day (or of the moon cycle) each value takes when nothing is
/// special: the yardstick for [_minLift].
const Map<Enum, double> _baseline = {
  DayPart.dawn: 3 / 24,
  DayPart.morning: 3.5 / 24,
  DayPart.midday: 3 / 24,
  DayPart.afternoon: 2.5 / 24,
  DayPart.dusk: 3 / 24,
  DayPart.night: 9 / 24,
  WaterMove.rising: 0.45,
  WaterMove.falling: 0.45,
  WaterMove.slack: 0.1,
  MoonBand.newMoon: 0.25,
  MoonBand.fullMoon: 0.25,
  MoonBand.quarter: 0.5,
  SolunarKind.major: 4 / 24,
  SolunarKind.minor: 2 / 24,
  SolunarKind.none: 18 / 24,
  WindBand.calm: 1 / 3,
  WindBand.light: 1 / 3,
  WindBand.strong: 1 / 3,
};

/// Conditions of one moment at one place; null = not known.
class CatchConditions {
  const CatchConditions({this.dayPart, this.water, this.moon, this.solunar, this.wind});

  final DayPart? dayPart;
  final WaterMove? water;
  final MoonBand? moon;
  final SolunarKind? solunar;
  final WindBand? wind;

  Enum? of(PatternFactor f) => switch (f) {
    PatternFactor.dayPart => dayPart,
    PatternFactor.water => water,
    PatternFactor.moon => moon,
    PatternFactor.solunar => solunar,
    PatternFactor.wind => wind,
  };
}

/// Conditions at [utc] and ([lat], [lon]); [tideState] is a `TideState` name
/// ("rising", "fallingFast", …) and [moonPhase] 0..1 when already known.
CatchConditions conditionsAt({
  required DateTime utc,
  required double lat,
  required double lon,
  String? tideState,
  double? windKmh,
  double? moonPhase,
}) {
  final local = utc.add(const Duration(hours: _tzHours));
  final sun = sunTimes(year: local.year, month: local.month, day: local.day, lat: lat, lon: lon);
  final day = solunarForDay(
    year: local.year,
    month: local.month,
    day: local.day,
    lat: lat,
    lon: lon,
  );
  return CatchConditions(
    dayPart: dayPartAt(utc, sun.sunrise, sun.sunset),
    water: waterMoveOf(tideState),
    moon: moonBand(moonPhase ?? moonIllumination(utc).phase),
    solunar: solunarAt(utc, day),
    wind: windBand(windKmh),
  );
}

DayPart dayPartAt(DateTime utc, DateTime? sunriseUtc, DateTime? sunsetUtc) {
  bool near(DateTime? t) => t != null && utc.difference(t).abs() <= _twilight;
  if (near(sunriseUtc)) return DayPart.dawn;
  if (near(sunsetUtc)) return DayPart.dusk;
  final hour = utc.add(const Duration(hours: _tzHours)).hour;
  final rise = sunriseUtc?.add(_twilight);
  final set = sunsetUtc?.subtract(_twilight);
  final isDay = rise != null && set != null
      ? utc.isAfter(rise) && utc.isBefore(set)
      : hour >= 7 && hour < 17;
  if (!isDay) return DayPart.night;
  if (hour >= 11 && hour < 14) return DayPart.midday;
  return hour < 11 ? DayPart.morning : DayPart.afternoon;
}

WaterMove? waterMoveOf(String? tideState) => switch (tideState) {
  'rising' || 'risingFast' => WaterMove.rising,
  'falling' || 'fallingFast' => WaterMove.falling,
  'slack' => WaterMove.slack,
  _ => null,
};

MoonBand moonBand(double phase) {
  final p = phase % 1;
  if (p <= _moonBandHalfWidth || p >= 1 - _moonBandHalfWidth) return MoonBand.newMoon;
  if ((p - 0.5).abs() <= _moonBandHalfWidth) return MoonBand.fullMoon;
  return MoonBand.quarter;
}

WindBand? windBand(double? kmh) => switch (kmh) {
  null => null,
  final k when k < 10 => WindBand.calm,
  final k when k <= 20 => WindBand.light,
  _ => WindBand.strong,
};

/// "[hits] of [known] catches were at [value]".
class CatchPattern {
  const CatchPattern({
    required this.factor,
    required this.value,
    required this.hits,
    required this.known,
  });

  final PatternFactor factor;
  final Enum value;
  final int hits;
  final int known;

  double get share => hits / known;
}

class PatternReport {
  const PatternReport({required this.total, required this.patterns});

  /// Catches in the log.
  final int total;

  /// At most one per factor, strongest first.
  final List<CatchPattern> patterns;

  bool get ready => total >= minCatchesForPatterns;

  /// Catches still needed before patterns are looked for.
  int get missing => ready ? 0 : minCatchesForPatterns - total;
}

PatternReport findPatterns(List<CatchConditions> catches) {
  if (catches.length < minCatchesForPatterns) {
    return PatternReport(total: catches.length, patterns: const []);
  }
  final out = <CatchPattern>[];
  for (final f in PatternFactor.values) {
    final values = catches.map((c) => c.of(f)).nonNulls.toList();
    if (values.length < _minKnown) continue;
    final counts = <Enum, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    CatchPattern? best;
    double bestLift = 0;
    for (final MapEntry(key: v, value: n) in counts.entries) {
      final share = n / values.length;
      final lift = share / (_baseline[v] ?? 1);
      if (n >= _minHits && share >= _minShare && lift >= _minLift && lift > bestLift) {
        best = CatchPattern(factor: f, value: v, hits: n, known: values.length);
        bestLift = lift;
      }
    }
    if (best != null) out.add(best);
  }
  out.sort((a, b) => b.share.compareTo(a.share));
  return PatternReport(total: catches.length, patterns: out);
}

/// True when [now] has (almost) all of the user's patterns: all of them when
/// there are 2, all but one when there are more. One pattern alone is too
/// thin to say "like your catches".
bool looksLikeYourCatches(PatternReport report, CatchConditions now) {
  final p = report.patterns;
  if (p.length < 2) return false;
  final matched = p.where((x) => now.of(x.factor) == x.value).length;
  return matched >= (p.length == 2 ? 2 : p.length - 1);
}
