import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';

/// Seven days on one line: weekday, a bar whose height is the day score
/// (colour = band), the score. Today is highlighted. The band word is in the
/// semantics label so the colour is never the only cue.
class WeekStrip extends StatelessWidget {
  const WeekStrip({required this.hours, super.key});

  final List<FishingHourScore> hours;

  @override
  Widget build(BuildContext context) {
    final days = <List<FishingHourScore>>[
      for (var i = 0; i + 24 <= hours.length; i += 24) hours.sublist(i, i + 24),
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (i, d) in days.indexed)
              Expanded(
                child: _DayColumn(day: d.first.hourUtc, score: dayScore(d), today: i == 0),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.day, required this.score, required this.today});

  final DateTime day;
  final double score;
  final bool today;

  static const double _barMax = 40;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = context.scoreColor(score);
    final ink = today ? c.primary : c.onSurfaceMuted;
    return Semantics(
      label:
          '${TimeFormat.dayShort(day)}: ${LevelFormat.decimal1(score)} ${context.scoreLabel(score)}',
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: today ? c.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          spacing: AppSpacing.xs,
          children: [
            Text(
              LevelFormat.decimal1(score),
              style: context.text.label.copyWith(color: color),
              maxLines: 1,
            ),
            SizedBox(
              height: _barMax,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: AppSpacing.md,
                  // Days rarely leave 4–9, so a 0–10 scale made all bars look alike.
                  height: ((score - 3) / 6.5).clamp(0.1, 1.0) * _barMax,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
            Text(
              TimeFormat.weekday(day),
              style: context.text.caption.copyWith(color: ink),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            Text(TimeFormat.dm(day), style: context.text.caption.copyWith(color: ink), maxLines: 1),
          ],
        ),
      ),
    );
  }
}
