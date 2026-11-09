import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';

/// 24 hourly score bars; tooltip gives the exact score and band word.
class ScoreBars extends StatelessWidget {
  const ScoreBars({required this.hours, super.key});

  final List<FishingHourScore> hours;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.fishing_title,
    child: SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: 10,
          minY: 0,
          barGroups: [
            for (var i = 0; i < hours.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: hours[i].score,
                    color: context.scoreColor(hours[i].score),
                    width: 8,
                  ),
                ],
              ),
          ],
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 5, reservedSize: 32),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, meta) => v.toInt() % 6 == 0 && v.toInt() < hours.length
                    ? SideTitleWidget(
                        meta: meta,
                        child: Text(
                          TimeFormat.hm(hours[v.toInt()].hourUtc),
                          style: context.text.caption,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${TimeFormat.hm(hours[group.x].hourUtc)} · ${LevelFormat.decimal1(rod.toY)} '
                '${context.scoreLabel(rod.toY)}',
                context.text.caption,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
