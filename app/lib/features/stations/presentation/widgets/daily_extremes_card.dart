import 'package:flutter/material.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

/// Tidal-river stations where KTTV gives only highest/lowest values (no times).
class DailyExtremesCard extends StatelessWidget {
  const DailyExtremesCard({required this.extremes, super.key});

  final DailyExtremes extremes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final e = extremes;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.station_dailyTitle(e.windowHours), style: context.text.label),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.station_dailyFc(LevelFormat.meters(e.fcMaxCm), LevelFormat.meters(e.fcMinCm)),
              style: context.text.title,
            ),
            Text(
              l10n.station_dailyRangeNow(LevelFormat.meters(e.fcMaxCm - e.fcMinCm)),
              style: context.text.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.station_dailyObs(LevelFormat.meters(e.obsMaxCm), LevelFormat.meters(e.obsMinCm)),
              style: context.text.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.station_dailyNoCurve, style: context.text.caption),
          ],
        ),
      ),
    );
  }
}
