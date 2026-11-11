import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/presentation/widgets/calendar/calendar_month.dart';
import 'package:rivertide/features/stations/presentation/widgets/calendar/moon_glyph.dart';
import 'package:rivertide/features/stations/presentation/widgets/moon_text.dart';
import 'package:rivertide/features/stations/presentation/widgets/sun_moon_lines.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_chart.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Panel under the grid for the tapped day: highs/lows and that day's curve.
class DayDetail extends StatelessWidget {
  const DayDetail({
    required this.day,
    required this.prediction,
    required this.nowUtc,
    required this.lat,
    required this.lon,
    super.key,
  });

  final CalendarDay day;
  final double lat;
  final double lon;
  final TideSeries? prediction;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = prediction;
    final springNeap = day.springNeap;
    final range = day.rangeCm;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            Text(
              '${TimeFormat.dayShort(day.dayStartUtc)} · '
              '${l10n.station_lunarDay(day.lunar.day, day.lunar.month)}',
              style: context.text.title,
            ),
            Row(
              spacing: AppSpacing.sm,
              children: [
                MoonGlyph(moon: day.moon, size: AppSpacing.lg),
                Flexible(
                  child: Text(
                    [
                      context.moonPhaseName(day.moon.phaseName),
                      if (springNeap != null) context.springNeapName(springNeap),
                    ].join(' · '),
                    style: context.text.body,
                  ),
                ),
              ],
            ),
            if (!day.hasTide || p == null)
              Text(l10n.calendar_noTideDay, style: context.text.caption)
            else ...[
              for (final e in day.extremes) _ExtremeLine(extreme: e, nowUtc: nowUtc),
              if (range != null)
                Text(
                  l10n.station_dailyRange(LevelFormat.meters(range)),
                  style: context.text.caption,
                ),
              const SizedBox(height: AppSpacing.xs),
              TideChart(
                height: 140,
                fromUtc: day.dayStartUtc,
                toUtc: day.dayStartUtc.add(const Duration(days: 1)),
                nowUtc: nowUtc,
                observed: const {},
                prediction: p,
              ),
            ],
            const Divider(),
            SunMoonLines(
              lat: lat,
              lon: lon,
              dayStartUtc: day.dayStartUtc,
              nowUtc: nowUtc,
              showPhase: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtremeLine extends StatelessWidget {
  const _ExtremeLine({required this.extreme, required this.nowUtc});

  final TideExtreme extreme;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final isHigh = extreme.kind == TideExtremeKind.high;
    final past = extreme.timeUtc.isBefore(nowUtc);
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Icon(
          isHigh ? Icons.vertical_align_top_rounded : Icons.vertical_align_bottom_rounded,
          size: AppIconSize.sm,
          color: past ? context.colors.stale : context.colors.primary,
        ),
        Expanded(
          child: Text(
            '${context.extremeName(extreme.kind)} ${TimeFormat.hm(extreme.timeUtc)} · '
            '${LevelFormat.meters(extreme.levelCm)}',
            style: context.text.body.copyWith(color: past ? context.colors.onSurfaceMuted : null),
          ),
        ),
      ],
    );
  }
}
