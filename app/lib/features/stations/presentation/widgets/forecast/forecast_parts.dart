import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/weather/wx_advice.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/forecast_provider.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/wx_text.dart';

/// Advice lines with icon and colour, plus the "for reference" note.
class WxAdviceCard extends StatelessWidget {
  const WxAdviceCard({required this.advice, this.max = 3, this.showTitle = true, super.key});

  final List<WxAdvice> advice;
  final int max;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final lines = advice.take(max).map(context.wxAdvice).toList();
    // Tinted by the most important line: red for a storm, green when calm.
    final tone = lines.isEmpty ? c.fishHigh : lines.first.$3;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          if (showTitle) Text(l10n.wx_adviceTitle, style: context.text.label),
          for (final (icon, text, color) in lines)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.sm,
              children: [
                Icon(icon, color: color, size: AppIconSize.sm),
                Expanded(child: Text(text, style: context.text.body)),
              ],
            ),
          Text(l10n.wx_adviceNote, style: context.text.caption),
        ],
      ),
    );
  }
}

/// "Dự báo · Open-Meteo · cập nhật 14:05", or the offline variant.
class WxSourceLine extends StatelessWidget {
  const WxSourceLine({required this.forecast, super.key});

  final StationForecast forecast;

  @override
  Widget build(BuildContext context) {
    final f = forecast;
    final at = TimeFormat.sameVnDay(f.fetchedAtUtc, f.nowUtc)
        ? TimeFormat.hm(f.fetchedAtUtc)
        : '${TimeFormat.dm(f.fetchedAtUtc)} ${TimeFormat.hm(f.fetchedAtUtc)}';
    final c = context.colors;
    return Row(
      spacing: AppSpacing.xs,
      children: [
        Icon(
          f.isStale ? Icons.wifi_off_rounded : Icons.cloud_done_outlined,
          size: AppIconSize.sm * 0.8,
          color: f.isStale ? c.alarm2 : c.onSurfaceMuted,
        ),
        Expanded(
          child: Text(
            f.isStale ? context.l10n.wx_staleSource(at) : context.l10n.wx_source(at),
            style: context.text.caption,
          ),
        ),
      ],
    );
  }
}
