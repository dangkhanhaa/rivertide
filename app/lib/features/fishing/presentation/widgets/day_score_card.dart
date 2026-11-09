import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';
import 'package:rivertide/features/stations/stations.dart';

class DayScoreCard extends StatelessWidget {
  const DayScoreCard({
    required this.score,
    required this.dayStartUtc,
    this.hasWarning = false,
    super.key,
  });

  final double score;
  final DateTime dayStartUtc;

  /// When some hours are unsafe, the label says the score applies outside them.
  final bool hasWarning;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final moon = moonIllumination(dayStartUtc.add(const Duration(hours: 12)));
    final color = context.scoreColor(score);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 6),
              ),
              child: Text(LevelFormat.decimal1(score), style: context.text.headline),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.fishing_dayScore, style: context.text.label),
                  Text(
                    hasWarning
                        ? l10n.fishing_levelOutsideWarning(
                            LevelFormat.decimal1(score),
                            context.scoreLabel(score),
                          )
                        : l10n.fishing_level(
                            LevelFormat.decimal1(score),
                            context.scoreLabel(score),
                          ),
                    style: context.text.title,
                  ),
                  Text(
                    l10n.fishing_moon(
                      context.moonPhaseName(moon.phaseName),
                      (moon.fraction * 100).round(),
                    ),
                    style: context.text.caption,
                  ),
                  Text('(${l10n.common_reference})', style: context.text.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
