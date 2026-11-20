import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/weather/wx_codes.dart';
import 'package:rivertide/core/calc/weather/wx_hour.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/weather_glyph.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/wx_text.dart';

/// Rain chance below this is left blank, so real chances stand out.
const double _showRainPct = 10;

/// Rain amount below this (mm in the hour) is left blank.
const double _showRainMm = 0.1;

/// Base width of one hour column; grows with the text size.
const double _cellWidth = 56;

/// Horizontally scrolling hours: time, sky, temperature, rain chance and
/// amount, wind with its direction. Midnight starts a new day, marked with
/// the day's name and a line.
class HourlyStrip extends StatelessWidget {
  const HourlyStrip({required this.hours, required this.nowUtc, super.key});

  final List<WxHour> hours;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.textScalerOf(context).scale(_cellWidth);
    // No rain amount anywhere in the strip: drop the line instead of a blank row.
    final showMm = hours.any((h) => (h.rainMm ?? 0) >= _showRainMm);
    return RepaintBoundary(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, h) in hours.indexed)
              _HourCell(
                hour: h,
                width: width,
                showMm: showMm,
                isFirst: i == 0,
                dayLabel: i > 0 && TimeFormat.toVn(h.timeUtc).hour == 0
                    ? context.dayName(h.timeUtc, nowUtc)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  const _HourCell({
    required this.hour,
    required this.width,
    required this.showMm,
    required this.isFirst,
    this.dayLabel,
  });

  final WxHour hour;
  final double width;
  final bool showMm;
  final bool isFirst;

  /// Set on the first hour of a new day.
  final String? dayLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final h = hour;
    final sky = skyOf(h.code);
    final prob = h.rainProbPct;
    final mm = h.rainMm;
    final wind = h.windKmh;
    final dir = h.windFromDeg;
    final time = isFirst ? l10n.wx_now : (dayLabel ?? TimeFormat.hm(h.timeUtc));
    final strong = isFirst || dayLabel != null;
    final temp = h.tempC == null ? '—' : '${h.tempC?.round()}°';
    final caption = context.text.caption;
    return Semantics(
      label: l10n.wx_hourSemantics(
        isFirst ? l10n.wx_now : TimeFormat.hm(h.timeUtc),
        context.skyText(sky, isDay: h.isDay ?? true),
        temp,
        prob == null ? '—' : l10n.wx_percent(prob.round()),
      ),
      excludeSemantics: true,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        // A one-sided border cannot be rounded: the two decorations never meet.
        decoration: isFirst
            ? BoxDecoration(
                color: c.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              )
            : dayLabel == null
            ? null
            : BoxDecoration(
                border: Border(left: BorderSide(color: c.stale.withValues(alpha: 0.5))),
              ),
        child: Column(
          spacing: AppSpacing.xs,
          children: [
            Text(
              time,
              maxLines: 1,
              style: strong ? context.text.label.copyWith(color: c.primary) : caption,
            ),
            WeatherGlyph(sky: sky, isDay: h.isDay ?? true),
            Text(temp, style: context.text.bodyStrong),
            Text(
              prob != null && prob >= _showRainPct ? l10n.wx_percent(prob.round()) : ' ',
              style: caption.copyWith(color: c.water, fontWeight: FontWeight.w600),
            ),
            if (showMm)
              Text(
                mm != null && mm >= _showRainMm ? LevelFormat.decimal1(mm) : ' ',
                style: caption.copyWith(color: c.water),
              ),
            if (wind != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dir != null)
                    Transform.rotate(
                      angle: (dir + 180) * math.pi / 180,
                      child: Icon(
                        Icons.north_rounded,
                        size: AppIconSize.sm * 0.75,
                        color: c.onSurfaceMuted,
                      ),
                    ),
                  Text('${wind.round()}', style: caption),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
