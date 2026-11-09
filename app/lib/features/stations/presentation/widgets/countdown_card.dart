import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/station_now.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// F-TIDE-02 card: countdown to the next high/low, then the one after.
class CountdownCard extends StatelessWidget {
  const CountdownCard({required this.now, required this.nowUtc, super.key});

  final StationNow now;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = now.nextExtreme;
    if (next == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(l10n.tide_noPrediction, style: context.text.body),
        ),
      );
    }
    final isHigh = next.kind == TideExtremeKind.high;
    final wait = context.durationText(next.timeUtc.difference(nowUtc));
    final following = now.followingExtreme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHigh ? Icons.vertical_align_top_rounded : Icons.vertical_align_bottom_rounded,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    now.isTurning
                        ? l10n.tide_turning
                        : (isHigh ? l10n.tide_countdownHigh(wait) : l10n.tide_countdownLow(wait)),
                    style: context.text.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${l10n.tide_extremeAt(context.relativeTime(next.timeUtc, nowUtc), LevelFormat.meters(next.levelCm))} (${l10n.common_reference})',
              style: context.text.body,
            ),
            if (context.changeToNext(now.levelCm, next) case final change?)
              Text(change, style: context.text.bodyStrong),
            if (following != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.tide_nextOther(
                  context.extremeName(following.kind),
                  context.relativeTime(following.timeUtc, nowUtc),
                  LevelFormat.meters(following.levelCm),
                ),
                style: context.text.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
