import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// Red: thunderstorm / strong gusts. Yellow: possible storm or heavy rain (PROJECT.md 9.6).
/// States the affected hours so it never reads as contradicting a good day score.
class SafetyBanner extends StatelessWidget {
  const SafetyBanner({required this.hours, super.key});

  /// The hours to inspect (one Vietnam day).
  final List<FishingHourScore> hours;

  /// Worst level among [hours].
  static SafetyLevel worstOf(List<FishingHourScore> hours) =>
      hours.fold(SafetyLevel.none, (acc, h) => h.safety.index > acc.index ? h.safety : acc);

  @override
  Widget build(BuildContext context) {
    final level = worstOf(hours);
    if (level == SafetyLevel.none) return const SizedBox.shrink();
    final flagged = hours.where((h) => h.safety == level).toList();
    final from = TimeFormat.hm(flagged.first.hourUtc);
    final to = TimeFormat.hm(flagged.last.hourUtc.add(const Duration(hours: 1)));
    final isRed = level == SafetyLevel.red;
    final color = isRed ? context.colors.alarm3 : context.colors.alarm1;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(isRed ? Icons.thunderstorm_rounded : Icons.warning_amber_rounded, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isRed
                  ? context.l10n.fishing_warnRed(from, to)
                  : context.l10n.fishing_warnYellow(from, to),
              style: context.text.bodyStrong,
            ),
          ),
        ],
      ),
    );
  }
}
