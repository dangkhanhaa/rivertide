import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/domain/river_flow.dart';

/// Main-stem discharge today/tomorrow (GloFAS). As extra context under a level
/// curve it hides while loading, on error or when no river channel is found.
/// As the [primary] card of a place without a level curve it also shows the
/// week ahead, and says plainly when the place has no river flow either.
class FlowCard extends ConsumerWidget {
  const FlowCard({required this.stationId, required this.nowUtc, this.primary = false, super.key});

  final String stationId;
  final DateTime nowUtc;
  final bool primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stationFlowProvider(stationId));
    final flow = async.value?.data;
    final today = flow?.on(nowUtc);
    if (flow == null || today == null) {
      final settled = async.hasValue || async.hasError;
      if (!primary) return const SizedBox.shrink();
      if (!settled) return const LinearProgressIndicator(minHeight: 2);
      return Text(context.l10n.flow_unknown, style: context.text.body);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _FlowBody(flow: flow, today: today, nowUtc: nowUtc, primary: primary),
      ),
    );
  }
}

class _FlowBody extends StatelessWidget {
  const _FlowBody({
    required this.flow,
    required this.today,
    required this.nowUtc,
    required this.primary,
  });

  final RiverFlow flow;
  final double today;
  final DateTime nowUtc;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tomorrow = flow.on(nowUtc.add(const Duration(days: 1)));
    final trend = flowTrend(today, tomorrow);
    final trendText = switch (trend) {
      FlowTrend.rising => l10n.flow_rising,
      FlowTrend.falling => l10n.flow_falling,
      FlowTrend.steady || null => l10n.flow_steady,
    };
    final icon = switch (trend) {
      FlowTrend.rising => Icons.trending_up_rounded,
      FlowTrend.falling => Icons.trending_down_rounded,
      FlowTrend.steady || null => Icons.trending_flat_rounded,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(l10n.flow_title, style: context.text.label)),
            const DataKindBadge(kind: LevelDataKind.estimate),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (primary) Text(_headline(context, trend), style: context.text.title),
        Text(l10n.flow_today(LevelFormat.thousands(today)), style: context.text.bodyStrong),
        if (tomorrow != null)
          Text(
            l10n.flow_tomorrow(LevelFormat.thousands(tomorrow), trendText),
            style: context.text.body,
          ),
        if (primary) ...[
          const SizedBox(height: AppSpacing.sm),
          _WeekBars(flow: flow, nowUtc: nowUtc),
        ],
        Text(l10n.flow_note, style: context.text.caption),
      ],
    );
  }

  String _headline(BuildContext context, FlowTrend? trend) => switch (trend) {
    FlowTrend.rising => context.l10n.flow_headRising,
    FlowTrend.falling => context.l10n.flow_headFalling,
    FlowTrend.steady || null => context.l10n.flow_headSteady,
  };
}

/// Today and the following days as bars scaled to the week's largest flow.
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.flow, required this.nowUtc});

  final RiverFlow flow;
  final DateTime nowUtc;

  static const int _days = 7;
  static const double _barMax = AppSpacing.xxl * 2;

  @override
  Widget build(BuildContext context) {
    final start = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final week = [
      for (var i = 0; i < _days; i++)
        if (flow.on(start.add(Duration(days: i))) case final q?) (start.add(Duration(days: i)), q),
    ];
    final top = week.map((d) => d.$2).maxOrNull;
    if (top == null || top <= 0) return const SizedBox.shrink();
    final c = context.colors;
    return Semantics(
      label: week
          .map(
            (d) =>
                context.l10n.flow_dayValue(TimeFormat.weekday(d.$1), LevelFormat.thousands(d.$2)),
          )
          .join(', '),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: AppSpacing.xs,
        children: [
          for (final (i, (day, q)) in week.indexed)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: (_barMax * q / top).clamp(AppSpacing.xs, _barMax),
                    decoration: BoxDecoration(
                      color: i == 0 ? c.primary : c.water,
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    TimeFormat.weekday(day),
                    style: i == 0 ? context.text.label : context.text.caption,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
