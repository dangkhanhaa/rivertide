import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/domain/river_flow.dart';

/// Main-stem discharge today/tomorrow (GloFAS). Hidden while loading, on
/// error, or when no river channel is found — it is extra context, never a
/// reason to block the water-level view.
class FlowCard extends ConsumerWidget {
  const FlowCard({required this.stationId, required this.nowUtc, super.key});

  final String stationId;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(stationFlowProvider(stationId)).value?.data;
    if (flow == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final today = flow.on(nowUtc);
    final tomorrow = flow.on(nowUtc.add(const Duration(days: 1)));
    if (today == null) return const SizedBox.shrink();
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
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
            Text(l10n.flow_today(LevelFormat.thousands(today)), style: context.text.bodyStrong),
            if (tomorrow != null)
              Text(
                l10n.flow_tomorrow(LevelFormat.thousands(tomorrow), trendText),
                style: context.text.body,
              ),
            Text(l10n.flow_note, style: context.text.caption),
          ],
        ),
      ),
    );
  }
}
