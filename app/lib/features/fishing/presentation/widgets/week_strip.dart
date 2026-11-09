import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';

/// One tile per day with the day score and its band word.
class WeekStrip extends StatelessWidget {
  const WeekStrip({required this.hours, super.key});

  final List<FishingHourScore> hours;

  @override
  Widget build(BuildContext context) {
    final days = <List<FishingHourScore>>[
      for (var i = 0; i + 24 <= hours.length; i += 24) hours.sublist(i, i + 24),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [for (final d in days) _DayTile(day: d.first.hourUtc, score: dayScore(d))],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.score});

  final DateTime day;
  final double score;

  @override
  Widget build(BuildContext context) {
    final color = context.scoreColor(score);
    return Container(
      width: 84,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(TimeFormat.dayShort(day), style: context.text.caption),
          Text(LevelFormat.decimal1(score), style: context.text.title),
          Text(context.scoreLabel(score), style: context.text.caption),
        ],
      ),
    );
  }
}
