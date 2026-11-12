import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/astro/solunar_kind.dart';
import 'package:rivertide/core/calc/fishing/catch_patterns.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/journal/application/catch_patterns_provider.dart';

/// Words for one pattern value ("Lúc bình minh", "Khi nước đang rút", …).
String patternValueText(BuildContext context, Enum value) {
  final l = context.l10n;
  return switch (value) {
    DayPart.dawn => l.habit_dawn,
    DayPart.morning => l.habit_morning,
    DayPart.midday => l.habit_midday,
    DayPart.afternoon => l.habit_afternoon,
    DayPart.dusk => l.habit_dusk,
    DayPart.night => l.habit_night,
    WaterMove.rising => l.habit_rising,
    WaterMove.falling => l.habit_falling,
    WaterMove.slack => l.habit_slack,
    MoonBand.newMoon => l.habit_newMoon,
    MoonBand.fullMoon => l.habit_fullMoon,
    MoonBand.quarter => l.habit_quarter,
    SolunarKind.major => l.habit_major,
    SolunarKind.minor => l.habit_minor,
    SolunarKind.none => l.habit_noSolunar,
    WindBand.calm => l.habit_calm,
    WindBand.light => l.habit_light,
    WindBand.strong => l.habit_strong,
    _ => value.name,
  };
}

IconData _icon(PatternFactor f) => switch (f) {
  PatternFactor.dayPart => Icons.wb_twilight_rounded,
  PatternFactor.water => Icons.waves_rounded,
  PatternFactor.moon => Icons.nightlight_round,
  PatternFactor.solunar => Icons.schedule_rounded,
  PatternFactor.wind => Icons.air_rounded,
};

/// "Thói quen câu của bạn" (P2-23): progress until enough catches, then the
/// conditions that come up most in the log, each with "6/9 mẻ".
class PatternsCard extends ConsumerWidget {
  const PatternsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(catchPatternsProvider).value;
    if (report == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final c = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, color: c.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(l10n.habit_title, style: context.text.title)),
              ],
            ),
            if (!report.ready) ...[
              Text(l10n.habit_needMore(report.missing), style: context.text.body),
              LinearProgressIndicator(
                value: report.total / minCatchesForPatterns,
                minHeight: AppSpacing.sm,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              Text(
                l10n.habit_progress(report.total, minCatchesForPatterns),
                style: context.text.caption,
              ),
            ] else if (report.patterns.isEmpty)
              Text(l10n.habit_none(report.total), style: context.text.body)
            else
              for (final p in report.patterns) _PatternRow(pattern: p),
            if (report.ready) Text(l10n.habit_note, style: context.text.caption),
          ],
        ),
      ),
    );
  }
}

class _PatternRow extends StatelessWidget {
  const _PatternRow({required this.pattern});

  final CatchPattern pattern;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Row(
          children: [
            Icon(_icon(pattern.factor), size: AppIconSize.sm, color: c.fishGood),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(patternValueText(context, pattern.value), style: context.text.bodyStrong),
            ),
            Text(context.l10n.habit_hits(pattern.hits, pattern.known), style: context.text.label),
          ],
        ),
        LinearProgressIndicator(
          value: pattern.share,
          color: c.fishGood,
          backgroundColor: c.fishGood.withValues(alpha: 0.15),
          minHeight: AppSpacing.sm,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ],
    );
  }
}
