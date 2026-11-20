import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/stations/application/forecast_provider.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/forecast_compact.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/forecast_daily.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/forecast_hourly.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/forecast_now.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/forecast_parts.dart';

/// Days from which the forecast is "far" (AC-FISH05-2: day 4 onwards).
const int _farFromDay = 3;

/// Weather for one place (P2-55): now, advice, hour by hour, day by day.
/// [compact] is the short version for map sheets. Handles loading (skeleton),
/// error (retry), empty and old data (offline, "lưu lúc …").
class ForecastSection extends ConsumerWidget {
  const ForecastSection({required this.stationId, this.compact = false, super.key});

  final String stationId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(stationForecastProvider(stationId));
    final f = value.value;
    if (f != null) {
      final empty = f.now == null && f.hours.isEmpty && f.days.isEmpty;
      if (empty) return _Message(text: context.l10n.wx_empty);
      return compact ? ForecastCompact(forecast: f) : _Full(forecast: f);
    }
    if (value.hasError) {
      return _Message(
        text: context.l10n.wx_error,
        onRetry: () => ref.invalidate(stationWeatherProvider(stationId)),
      );
    }
    return _Skeleton(compact: compact);
  }
}

class _Full extends StatelessWidget {
  const _Full({required this.forecast});

  final StationForecast forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final f = forecast;
    final now = f.now;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        SectionTitle(title: l10n.wx_title, icon: Icons.wb_sunny_rounded),
        if (now != null) ForecastNow(now: now),
        if (f.advice.isNotEmpty) WxAdviceCard(advice: f.advice),
        if (f.hours.isNotEmpty)
          _Block(
            title: l10n.wx_hourlyTitle,
            note: l10n.wx_hourlyLegend,
            child: HourlyStrip(hours: f.hours, nowUtc: f.nowUtc),
          ),
        if (f.days.isNotEmpty)
          _Block(
            title: l10n.wx_dailyTitle(f.days.length),
            note: f.days.length > _farFromDay ? l10n.wx_farNote : null,
            child: DailyList(days: f.days, nowUtc: f.nowUtc, nowTempC: now?.hour.tempC),
          ),
        WxSourceLine(forecast: f),
      ],
    );
  }
}

/// Titled card around one forecast block.
class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child, this.note});

  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Text(title, style: context.text.title),
          child,
          if (note case final n?) Text(n, style: context.text.caption),
        ],
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Icon(
            onRetry == null ? Icons.cloud_queue_rounded : Icons.cloud_off_rounded,
            color: onRetry == null ? context.colors.stale : context.colors.alarm2,
            size: AppIconSize.sm,
          ),
          Expanded(child: Text(text, style: context.text.body)),
          if (onRetry case final r?)
            TextButton(onPressed: r, child: Text(context.l10n.common_retry)),
        ],
      ),
    ),
  );
}

/// Grey placeholders shaped like the section while it loads.
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final grey = context.colors.stale.withValues(alpha: 0.15);
    Widget box(double h) => Container(
      height: h,
      decoration: BoxDecoration(color: grey, borderRadius: BorderRadius.circular(AppRadius.lg)),
    );
    return Semantics(
      label: context.l10n.common_loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: compact
            ? [box(AppSpacing.xxl * 3)]
            : [box(AppSpacing.xxl * 6), box(AppSpacing.xxl * 4), box(AppSpacing.xxl * 6)],
      ),
    );
  }
}
