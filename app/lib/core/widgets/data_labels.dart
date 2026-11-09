import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// Small source line under every data block (CLAUDE.md 3.3).
class SourceAttribution extends StatelessWidget {
  const SourceAttribution({required this.source, super.key});

  final String source;

  @override
  Widget build(BuildContext context) =>
      Text(context.l10n.common_source(source), style: context.text.caption);
}

/// "Thực đo" / "Dự báo · tham khảo" / "Ước tính" chip with a distinct look per kind.
class DataKindBadge extends StatelessWidget {
  const DataKindBadge({required this.kind, super.key});

  final LevelDataKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final (label, color) = switch (kind) {
      LevelDataKind.observed => (l10n.dataKind_observed, c.water),
      LevelDataKind.forecast => (l10n.dataKind_forecast, c.tidePred),
      LevelDataKind.estimate => (l10n.dataKind_estimate, c.alarm2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: kind == LevelDataKind.estimate ? c.estimateHatch : null,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(label, style: context.text.caption.copyWith(color: color)),
    );
  }
}

/// Trend icon + words; never colour alone (docs/rules/06 §3).
class TrendLabel extends StatelessWidget {
  const TrendLabel({required this.state, this.compact = false, super.key});

  final TideState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final (icon, text, color) = switch (state) {
      TideState.risingFast => (
        Icons.keyboard_double_arrow_up_rounded,
        l10n.tide_risingFast,
        c.alarm2,
      ),
      TideState.rising => (Icons.arrow_upward_rounded, l10n.tide_rising, c.water),
      TideState.slack => (Icons.pause_rounded, l10n.tide_slack, c.onSurfaceMuted),
      TideState.falling => (Icons.arrow_downward_rounded, l10n.tide_falling, c.tidePred),
      TideState.fallingFast => (
        Icons.keyboard_double_arrow_down_rounded,
        l10n.tide_fallingFast,
        c.alarm2,
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: compact ? AppIconSize.sm : AppIconSize.md),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            text,
            style: compact ? context.text.label : context.text.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
