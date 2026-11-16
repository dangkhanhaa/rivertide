import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';

/// Up to 3 golden windows as cards side by side (swipe on narrow screens).
class GoldenList extends StatelessWidget {
  const GoldenList({required this.windows, required this.nowUtc, super.key});

  final List<GoldenWindow> windows;

  /// Decides the "Hôm nay" / "Mai" tag on each card.
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    if (windows.isEmpty) {
      return Text(context.l10n.fishing_noGolden, style: context.text.body);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          for (final w in windows)
            _GoldenCard(
              window: w,
              tomorrow: TimeFormat.vnDayStartUtc(w.startUtc)
                  .isAfter(TimeFormat.vnDayStartUtc(nowUtc)),
            ),
        ],
      ),
    );
  }
}

class _GoldenCard extends StatelessWidget {
  const _GoldenCard({required this.window, required this.tomorrow});

  final GoldenWindow window;
  final bool tomorrow;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final w = window;
    return SizedBox(
      width: 172,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              Row(
                children: [
                  Icon(Icons.star_rounded, color: c.alarm1),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      tomorrow ? context.l10n.common_tomorrow : context.l10n.common_today,
                      style: context.text.label.copyWith(color: c.onSurfaceMuted),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.fishGood.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      LevelFormat.decimal1(w.peakScore),
                      style: context.text.bodyStrong.copyWith(color: c.fishGood),
                    ),
                  ),
                ],
              ),
              Text(
                '${TimeFormat.hm(w.startUtc)} – ${TimeFormat.hm(w.endUtc)}',
                style: context.text.title,
              ),
              Text(
                w.reasons.map(context.factorName).join(' · '),
                style: context.text.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
