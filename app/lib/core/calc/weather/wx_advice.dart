import 'package:rivertide/core/calc/weather/wx_codes.dart';
import 'package:rivertide/core/calc/weather/wx_hour.dart';
import 'package:rivertide/core/calc/weather/wx_now.dart';

/// Short weather advice for anglers, from the hourly forecast only. Every
/// line is a rule of thumb with a fixed, documented threshold, so the app
/// never claims more than the forecast says. Order = priority (safety first).
enum WxAdviceKind {
  /// WMO 95/96/99 within [stormHours]: lightning over open water.
  storm,

  /// Mean wind ≥ Beaufort [windStrongForce] within [stormHours].
  wind,

  /// Gusts ≥ Beaufort [gustStrongForce] (mean wind lower) within [stormHours].
  gust,

  /// ≥ [heavyRainDayMm] in one local day, today (rest of it) to [rainDays] ahead.
  heavyRain,

  /// Chance ≥ [rainSoonPct] and ≥ [rainSoonMm] in an hour within [rainSoonHours].
  rainSoon,

  /// Fog code or visibility < [fogVisibilityM] within the next [dayHours].
  fog,

  /// Temperature ≤ [coldC] within [stormHours].
  cold,

  /// Feels-like ≥ [heatFeelsC] within the next [dayHours].
  heat,

  /// UV ≥ [uvHigh] within the next [dayHours].
  uv,

  /// No warning above, calm and dry for [calmHours], and pressure falling
  /// gently over 24 h (anglers' lore: fish feed before weather turns).
  pressureGood,

  /// No warning above, light wind and little rain chance for [calmHours].
  calm,
}

/// Look-ahead for dangers worth planning a trip around (two days).
const int stormHours = 48;
const int dayHours = 24;
const int calmHours = 6;

/// KTTV calls force 6 and above "gió mạnh"; small boats should stay in.
const int windStrongForce = 6;

/// Force 7 gusts (≥ 50 km/h) capsize small boats and snap rods.
const int gustStrongForce = 7;

/// KTTV: "mưa to" is more than 50 mm in 24 h.
const double heavyRainDayMm = 50;
const int rainDays = 2;
const double rainSoonPct = 60;
const double rainSoonMm = 0.5;
const double fogVisibilityM = 1000;

/// KTTV: "rét đậm" when the daily mean is ≤ 15 °C; a low this cold already
/// calls for warm clothes on a night session.
const double coldC = 15;

/// Heat index "danger" band starts at 39 °C (US NWS).
const double heatFeelsC = 39;

/// WHO "very high" UV starts at 8.
const double uvHigh = 8;

/// "Calm": mean wind under force 4 (< 20 km/h) and rain chance < 30 %.
const double calmWindKmh = 20;
const double calmRainPct = 30;

enum WxDayPart { morning, noon, afternoon, evening, night }

/// When something happens, in the words people use: "chiều mai", "đêm nay".
class WxWhen {
  const WxWhen({required this.timeUtc, required this.dayOffset, required this.part});

  final DateTime timeUtc;

  /// 0 = today (tonight included), 1 = tomorrow, …
  final int dayOffset;
  final WxDayPart part;
}

/// Hours 00–04 belong to the night that started the evening before, so
/// 02:00 tomorrow reads "đêm nay", not "đêm mai".
WxWhen whenOf(DateTime timeUtc, DateTime nowUtc, Duration localOffset) {
  final t = timeUtc.add(localOffset);
  final n = nowUtc.add(localOffset);
  final part = switch (t.hour) {
    >= 5 && < 11 => WxDayPart.morning,
    >= 11 && < 13 => WxDayPart.noon,
    >= 13 && < 18 => WxDayPart.afternoon,
    >= 18 && < 22 => WxDayPart.evening,
    _ => WxDayPart.night,
  };
  var day = DateTime.utc(t.year, t.month, t.day);
  if (t.hour < 5) day = day.subtract(const Duration(days: 1));
  final today = DateTime.utc(n.year, n.month, n.day);
  final offset = (day.difference(today).inHours / 24).round();
  return WxWhen(timeUtc: timeUtc, dayOffset: offset < 0 ? 0 : offset, part: part);
}

class WxAdvice {
  const WxAdvice(this.kind, {this.when, this.value, this.percent});

  final WxAdviceKind kind;
  final WxWhen? when;

  /// Force, mm, °C or UV, depending on [kind].
  final int? value;
  final int? percent;
}

/// Advice from now on, highest priority first.
List<WxAdvice> weatherAdvice(List<WxHour> hours, DateTime nowUtc, Duration localOffset) {
  final i = hourIndexAt(hours, nowUtc);
  if (i < 0) return const [];
  List<WxHour> next(int n) => hours.sublist(i, (i + n + 1).clamp(i, hours.length));
  WxWhen at(WxHour h) => whenOf(h.timeUtc, nowUtc, localOffset);
  final ahead = next(stormHours);
  final day = next(dayHours);
  final warnings = <WxAdvice>[
    ?_storm(ahead, at),
    ?_wind(ahead, at),
    ?_heavyRain(hours, i, nowUtc, localOffset, at),
    ?_rainSoon(next(rainSoonHours), at),
    ?_fog(day, at),
    ?_peak(ahead, (h) => -(h.tempC ?? 99), -coldC, WxAdviceKind.cold, at, negate: true),
  ];
  final out = [
    ...warnings,
    ?_peak(day, (h) => h.feelsC ?? -99, heatFeelsC, WxAdviceKind.heat, at),
    ?_peak(day, (h) => h.uv ?? -1, uvHigh, WxAdviceKind.uv, at),
  ];
  final calm = next(calmHours);
  final dry = calm.every((h) => (h.rainProbPct ?? 0) < calmRainPct && !isStormCode(h.code));
  final light = calm.every((h) => (h.windKmh ?? 0) < calmWindKmh);
  final known = calm.any((h) => h.windKmh != null);
  if (warnings.isEmpty && dry && light && known) {
    final falling = weatherNow(hours, nowUtc)?.trend == PressureTrend.falling;
    out.add(WxAdvice(falling ? WxAdviceKind.pressureGood : WxAdviceKind.calm));
  }
  return out..sort((a, b) => a.kind.index.compareTo(b.kind.index));
}

WxAdvice? _storm(List<WxHour> hours, WxWhen Function(WxHour) at) {
  final h = hours.where((h) => isStormCode(h.code)).firstOrNull;
  return h == null ? null : WxAdvice(WxAdviceKind.storm, when: at(h));
}

WxAdvice? _wind(List<WxHour> hours, WxWhen Function(WxHour) at) {
  WxHour? strongest(double? Function(WxHour) v) => hours
      .where((h) => v(h) != null)
      .fold<WxHour?>(null, (a, b) => a == null || (v(b) ?? 0) > (v(a) ?? 0) ? b : a);
  final mean = strongest((h) => h.windKmh);
  final meanForce = beaufort(mean?.windKmh ?? 0);
  if (mean != null && meanForce >= windStrongForce) {
    final first = hours.firstWhere((h) => beaufort(h.windKmh ?? 0) >= windStrongForce);
    return WxAdvice(WxAdviceKind.wind, when: at(first), value: meanForce);
  }
  final gust = strongest((h) => h.gustKmh);
  final gustForce = beaufort(gust?.gustKmh ?? 0);
  if (gust == null || gustForce < gustStrongForce) return null;
  final first = hours.firstWhere((h) => beaufort(h.gustKmh ?? 0) >= gustStrongForce);
  return WxAdvice(WxAdviceKind.gust, when: at(first), value: gustForce);
}

WxAdvice? _heavyRain(
  List<WxHour> hours,
  int nowIndex,
  DateTime nowUtc,
  Duration localOffset,
  WxWhen Function(WxHour) at,
) {
  final local = nowUtc.add(localOffset);
  final todayStart = DateTime.utc(local.year, local.month, local.day).subtract(localOffset);
  for (var d = 0; d <= rainDays; d++) {
    final from = todayStart.add(Duration(days: d));
    final to = from.add(const Duration(days: 1));
    final day = [
      for (final h in hours.skip(nowIndex))
        if (!h.timeUtc.isBefore(from) && h.timeUtc.isBefore(to)) h,
    ];
    final total = day.fold<double>(0, (a, h) => a + (h.rainMm ?? 0));
    if (day.isEmpty || total < heavyRainDayMm) continue;
    final wettest = day.reduce((a, b) => (b.rainMm ?? 0) > (a.rainMm ?? 0) ? b : a);
    return WxAdvice(WxAdviceKind.heavyRain, when: at(wettest), value: total.round());
  }
  return null;
}

WxAdvice? _rainSoon(List<WxHour> hours, WxWhen Function(WxHour) at) {
  final h = hours
      .where((h) => (h.rainProbPct ?? 0) >= rainSoonPct && (h.rainMm ?? 0) >= rainSoonMm)
      .firstOrNull;
  final p = h?.rainProbPct;
  return h == null || p == null
      ? null
      : WxAdvice(WxAdviceKind.rainSoon, when: at(h), percent: p.round());
}

WxAdvice? _fog(List<WxHour> hours, WxWhen Function(WxHour) at) {
  final h = hours
      .where((h) => isFogCode(h.code) || (h.visibilityM ?? fogVisibilityM) < fogVisibilityM)
      .firstOrNull;
  return h == null ? null : WxAdvice(WxAdviceKind.fog, when: at(h));
}

/// The hour where [score] peaks, if it reaches [threshold]. [negate] flips
/// the reported value back for "lowest temperature" checks.
WxAdvice? _peak(
  List<WxHour> hours,
  double Function(WxHour) score,
  double threshold,
  WxAdviceKind kind,
  WxWhen Function(WxHour) at, {
  bool negate = false,
}) {
  if (hours.isEmpty) return null;
  final best = hours.reduce((a, b) => score(b) > score(a) ? b : a);
  final v = score(best);
  if (v < threshold) return null;
  return WxAdvice(kind, when: at(best), value: (negate ? -v : v).round());
}
