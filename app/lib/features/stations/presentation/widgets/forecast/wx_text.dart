import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/weather/wx_advice.dart';
import 'package:rivertide/core/calc/weather/wx_codes.dart';
import 'package:rivertide/core/calc/weather/wx_now.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';

/// Words, icons and colours for forecast values (P2-55).
extension WxText on BuildContext {
  String skyText(WxSky? sky, {bool isDay = true}) {
    final l = l10n;
    return switch (sky) {
      null => '—',
      WxSky.clear => isDay ? l.wx_skyClear : l.wx_skyClearNight,
      WxSky.mainlyClear => l.wx_skyMainlyClear,
      WxSky.partlyCloudy => l.wx_skyPartlyCloudy,
      WxSky.overcast => l.wx_skyOvercast,
      WxSky.fog => l.wx_skyFog,
      WxSky.drizzle => l.wx_skyDrizzle,
      WxSky.rainLight => l.wx_skyRainLight,
      WxSky.rainModerate => l.wx_skyRainModerate,
      WxSky.rainHeavy => l.wx_skyRainHeavy,
      WxSky.showersLight => l.wx_skyShowersLight,
      WxSky.showers => l.wx_skyShowers,
      WxSky.showersHeavy => l.wx_skyShowersHeavy,
      WxSky.snow => l.wx_skySnow,
      WxSky.thunderstorm => l.wx_skyThunderstorm,
      WxSky.thunderstormHail => l.wx_skyThunderstormHail,
    };
  }

  String compassText(Compass c) => switch (c) {
    Compass.n => l10n.wx_dirN,
    Compass.ne => l10n.wx_dirNe,
    Compass.e => l10n.wx_dirE,
    Compass.se => l10n.wx_dirSe,
    Compass.s => l10n.wx_dirS,
    Compass.sw => l10n.wx_dirSw,
    Compass.w => l10n.wx_dirW,
    Compass.nw => l10n.wx_dirNw,
  };

  String uvText(double uv) => switch (uvLevel(uv)) {
    UvLevel.low => l10n.wx_uvLow,
    UvLevel.moderate => l10n.wx_uvModerate,
    UvLevel.high => l10n.wx_uvHigh,
    UvLevel.veryHigh => l10n.wx_uvVeryHigh,
    UvLevel.extreme => l10n.wx_uvExtreme,
  };

  String trendText(PressureTrend t) => switch (t) {
    PressureTrend.fallingFast => l10n.wx_trendFallingFast,
    PressureTrend.falling => l10n.wx_trendFalling,
    PressureTrend.steady => l10n.wx_trendSteady,
    PressureTrend.rising => l10n.wx_trendRising,
    PressureTrend.risingFast => l10n.wx_trendRisingFast,
  };

  String weekdayText(DateTime utc) => switch (TimeFormat.toVn(utc).weekday) {
    DateTime.monday => l10n.wx_wdMon,
    DateTime.tuesday => l10n.wx_wdTue,
    DateTime.wednesday => l10n.wx_wdWed,
    DateTime.thursday => l10n.wx_wdThu,
    DateTime.friday => l10n.wx_wdFri,
    DateTime.saturday => l10n.wx_wdSat,
    _ => l10n.wx_wdSun,
  };

  /// "Hôm nay", "Mai", "Th 5" for a local day start.
  String dayName(DateTime dayStartUtc, DateTime nowUtc) {
    final days = dayStartUtc.difference(TimeFormat.vnDayStartUtc(nowUtc)).inHours ~/ 24;
    return switch (days) {
      0 => l10n.common_today,
      1 => l10n.common_tomorrow,
      _ => weekdayText(dayStartUtc),
    };
  }

  /// "chiều mai", "đêm nay", "sáng Th 5".
  String whenText(WxWhen w) {
    final part = switch (w.part) {
      WxDayPart.morning => l10n.wx_partMorning,
      WxDayPart.noon => l10n.wx_partNoon,
      WxDayPart.afternoon => l10n.wx_partAfternoon,
      WxDayPart.evening => l10n.wx_partEvening,
      WxDayPart.night => l10n.wx_partNight,
    };
    final day = switch (w.dayOffset) {
      0 => l10n.wx_dayToday,
      1 => l10n.wx_dayTomorrow,
      _ => weekdayText(w.timeUtc.subtract(Duration(hours: w.part == WxDayPart.night ? 5 : 0))),
    };
    return l10n.wx_when(part, day);
  }

  /// Icon, sentence and colour of one advice line.
  (IconData, String, Color) wxAdvice(WxAdvice a) {
    final c = colors;
    final l = l10n;
    final when = switch (a.when) {
      final w? => whenText(w),
      null => '',
    };
    final v = a.value ?? 0;
    return switch (a.kind) {
      WxAdviceKind.storm => (Icons.thunderstorm_rounded, l.wx_adv_storm(when), c.alarm3),
      WxAdviceKind.wind => (Icons.air_rounded, l.wx_adv_wind(when, v), c.alarm2),
      WxAdviceKind.gust => (Icons.air_rounded, l.wx_adv_gust(when, v), c.alarm2),
      WxAdviceKind.heavyRain => (Icons.umbrella_rounded, l.wx_adv_heavyRain(when, v), c.alarm2),
      WxAdviceKind.rainSoon => (
        Icons.water_drop_rounded,
        l.wx_adv_rainSoon(TimeFormat.hm(a.when?.timeUtc ?? DateTime.utc(0)), a.percent ?? 0),
        c.water,
      ),
      WxAdviceKind.fog => (Icons.foggy, l.wx_adv_fog(when), c.onSurfaceMuted),
      WxAdviceKind.cold => (Icons.ac_unit_rounded, l.wx_adv_cold(when, v), c.water),
      WxAdviceKind.heat => (Icons.thermostat_rounded, l.wx_adv_heat(when, v), c.alarm2),
      WxAdviceKind.uv => (Icons.wb_sunny_rounded, l.wx_adv_uv(when, v), c.alarm2),
      WxAdviceKind.pressureGood => (Icons.trending_down_rounded, l.wx_adv_pressure, c.fishHigh),
      WxAdviceKind.calm => (Icons.check_circle_outline_rounded, l.wx_adv_calm, c.ok),
    };
  }
}

/// Joins short phrases with " · " so a line wraps only between phrases, never
/// inside "24 km/h" (spaces become no-break, "/" gets a word joiner).
String joinPhrases(Iterable<String> parts) =>
    parts.map((p) => p.replaceAll(' ', '\u00A0').replaceAll('/', '/\u2060')).join(' · ');
