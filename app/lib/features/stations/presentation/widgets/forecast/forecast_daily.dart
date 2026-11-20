import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/weather/wx_codes.dart';
import 'package:rivertide/core/calc/weather/wx_daily.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/weather_glyph.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/wx_text.dart';

/// Rain chance below this is left out of the day row.
const double _showRainPct = 10;

/// One row per day: name, sky, rain chance, low–high bar on the week's
/// scale, then rain total and strongest wind in words.
class DailyList extends StatelessWidget {
  const DailyList({required this.days, required this.nowUtc, this.nowTempC, super.key});

  final List<WxDay> days;
  final DateTime nowUtc;

  /// Marked on today's bar.
  final double? nowTempC;

  @override
  Widget build(BuildContext context) {
    final lows = days.map((d) => d.minC).nonNulls;
    final highs = days.map((d) => d.maxC).nonNulls;
    final weekMin = lows.isEmpty ? null : lows.reduce(math.min);
    final weekMax = highs.isEmpty ? null : highs.reduce(math.max);
    return Column(
      children: [
        for (final (i, d) in days.indexed) ...[
          if (i > 0) Divider(height: 1, color: context.colors.stale.withValues(alpha: 0.2)),
          _DayRow(
            day: d,
            nowUtc: nowUtc,
            weekMin: weekMin,
            weekMax: weekMax,
            nowTempC: i == 0 ? nowTempC : null,
          ),
        ],
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.nowUtc,
    this.weekMin,
    this.weekMax,
    this.nowTempC,
  });

  final WxDay day;
  final DateTime nowUtc;
  final double? weekMin;
  final double? weekMax;
  final double? nowTempC;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final scale = MediaQuery.textScalerOf(context);
    final d = day;
    final sky = skyOf(d.code);
    final prob = d.rainProbPct;
    final name = context.dayName(d.dayStartUtc, nowUtc);
    String deg(double? v) => v == null ? '—' : '${v.round()}°';
    final semantics = l10n.wx_daySemantics(
      name,
      context.skyText(sky),
      deg(d.minC),
      deg(d.maxC),
      prob == null ? '—' : l10n.wx_percent(prob.round()),
    );
    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            Row(
              spacing: AppSpacing.sm,
              children: [
                SizedBox(
                  width: scale.scale(64),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: context.text.bodyStrong, maxLines: 1),
                      Text(TimeFormat.dm(d.dayStartUtc), style: context.text.caption),
                    ],
                  ),
                ),
                SizedBox(
                  width: scale.scale(36),
                  child: Column(
                    children: [
                      WeatherGlyph(sky: sky),
                      if (prob != null && prob >= _showRainPct)
                        Text(
                          l10n.wx_percent(prob.round()),
                          style: context.text.caption.copyWith(color: c.water),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: scale.scale(30),
                  child: Text(deg(d.minC), textAlign: TextAlign.end, style: context.text.body),
                ),
                Expanded(
                  child: TempRangeBar(
                    low: d.minC,
                    high: d.maxC,
                    weekMin: weekMin,
                    weekMax: weekMax,
                    marker: nowTempC,
                  ),
                ),
                SizedBox(
                  width: scale.scale(30),
                  child: Text(deg(d.maxC), style: context.text.bodyStrong),
                ),
              ],
            ),
            if (_details(context) case final t?) Text(t, style: context.text.caption),
          ],
        ),
      ),
    );
  }

  /// "Mưa 12,4 mm · gió tới 30 km/h, giật 45"; null when nothing to say.
  String? _details(BuildContext context) {
    final l10n = context.l10n;
    final rain = day.rainMm;
    final wind = day.windMaxKmh;
    final gust = day.gustMaxKmh;
    final dir = day.windFromDeg;
    final parts = [
      if (rain != null && rain >= 0.1) l10n.wx_dayRain(LevelFormat.decimal1(rain)),
      if (wind != null && dir == null) l10n.wx_dayWind(wind.round()),
      if (wind != null && dir != null)
        l10n.wx_dayWindDir(context.compassText(compassOf(dir)), wind.round()),
      if (gust != null) l10n.wx_dayGust(gust.round()),
    ];
    return parts.isEmpty ? null : joinPhrases(parts);
  }
}

/// Low–high bar placed on the scale of the whole list (coolest low to
/// warmest high), shaded cool to warm, with an optional "now" dot.
class TempRangeBar extends StatelessWidget {
  const TempRangeBar({
    required this.low,
    required this.high,
    required this.weekMin,
    required this.weekMax,
    this.marker,
    super.key,
  });

  final double? low;
  final double? high;
  final double? weekMin;
  final double? weekMax;
  final double? marker;

  static const double _thickness = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lo = low;
    final hi = high;
    final min = weekMin;
    final max = weekMax;
    final track = c.stale.withValues(alpha: 0.2);
    if (lo == null || hi == null || min == null || max == null) {
      return Container(height: _thickness, color: track);
    }
    final span = math.max(max - min, 1);
    double at(double t) => ((t - min) / span).clamp(0.0, 1.0);
    final a = at(lo);
    final b = math.max(at(hi), a + 0.04).clamp(0.0, 1.0);
    final m = marker;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return SizedBox(
          height: _thickness * 2,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: _thickness,
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              Positioned(
                left: w * a,
                width: w * (b - a),
                child: Container(
                  height: _thickness,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(c.water, c.alarm2, a) ?? c.water,
                        Color.lerp(c.water, c.alarm2, b) ?? c.alarm2,
                      ],
                    ),
                  ),
                ),
              ),
              if (m != null)
                Positioned(
                  left: (w * at(m) - _thickness)
                      .clamp(0, math.max(0, w - _thickness * 2))
                      .toDouble(),
                  child: Container(
                    width: _thickness * 2,
                    height: _thickness * 2,
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.onSurface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
