import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/fish_activity_style.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';

/// 24 hourly bars, minimal: no axis numbers, colour = "Cá ăn" band (legend
/// below), past hours faded, golden hours on a soft background, "Giờ này"
/// under the current hour. Tooltip gives the exact score and band word.
class ScoreBars extends ConsumerWidget {
  const ScoreBars({required this.hours, super.key});

  final List<FishingHourScore> hours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final nowIndex = hours.indexWhere(
      (h) => !now.isBefore(h.hourUtc) && now.isBefore(h.hourUtc.add(const Duration(hours: 1))),
    );
    final golden = goldenWindows(hours);
    bool isGolden(DateTime t) => golden.any((w) => !t.isBefore(w.startUtc) && t.isBefore(w.endUtc));
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Semantics(
          label: context.l10n.fishing_hourly,
          child: SizedBox(
            height: 112,
            child: BarChart(
              BarChartData(
                maxY: 10,
                minY: 0,
                alignment: BarChartAlignment.spaceBetween,
                barGroups: [
                  for (final (i, h) in hours.indexed)
                    _group(
                      context,
                      i,
                      h,
                      past: nowIndex >= 0 && i < nowIndex,
                      golden: isGolden(h.hourUtc),
                    ),
                ],
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      // Room for the descender of "Giờ này" in the bold label style.
                      reservedSize: 30,
                      getTitlesWidget: (v, meta) => _hourTitle(context, meta, v.toInt(), nowIndex),
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => c.surface,
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
        ),
        const _Legend(),
      ],
    );
  }

  BarChartGroupData _group(
    BuildContext context,
    int i,
    FishingHourScore h, {
    required bool past,
    required bool golden,
  }) {
    final color = context.scoreColor(h.score);
    return BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: h.score,
          color: past ? color.withValues(alpha: 0.35) : color,
          width: 9,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          backDrawRodData: BackgroundBarChartRodData(
            show: golden,
            toY: 10,
            color: context.colors.fishPeak.withValues(alpha: 0.14),
          ),
        ),
      ],
    );
  }

  Widget _hourTitle(BuildContext context, TitleMeta meta, int i, int nowIndex) {
    if (i < 0 || i >= hours.length) return const SizedBox.shrink();
    final isNow = i == nowIndex;
    // Every 6 hours, except where it would collide with the "Giờ này" mark.
    final show = isNow || (i % 6 == 0 && (nowIndex < 0 || (i - nowIndex).abs() > 2));
    if (!show) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        isNow
            ? context.l10n.fishing_nowMark
            : context.l10n.fishing_hourShort(TimeFormat.toVn(hours[i].hourUtc).hour),
        style: isNow
            ? context.text.label.copyWith(color: context.colors.primary)
            : context.text.caption,
      ),
    );
  }
}

/// Colour key; the words make the bars readable without colour.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.xs,
    children: [
      for (final a in FishActivity.values)
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: [
            Container(
              width: AppSpacing.sm,
              height: AppSpacing.sm,
              decoration: BoxDecoration(
                color: context.fishActivityColor(a),
                shape: BoxShape.circle,
              ),
            ),
            Text(context.fishActivityName(a), style: context.text.caption),
          ],
        ),
    ],
  );
}
