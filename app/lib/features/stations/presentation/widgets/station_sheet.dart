import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/core/widgets/detail_host.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/presentation/widgets/daily_extremes_card.dart';
import 'package:rivertide/features/stations/presentation/widgets/source_line.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_chart.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Station summary shown when a map marker is tapped (FEATURES.md F-MAP-02).
/// Uses cached data first, so it opens without waiting for the network.
class StationSheet extends ConsumerWidget {
  const StationSheet({required this.station, super.key});

  final Station station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isFavorite = ref.watch(favoriteIdsProvider).value?.contains(station.id) ?? false;
    final view = ref.watch(stationViewProvider(station.id));
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(station.name, style: context.text.title),
                    Text(station.region, style: context.text.caption),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite ? l10n.station_unfollow : l10n.station_follow,
                icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                onPressed: () => toggleFavorite(ref, station.id),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AsyncValueView(
            value: view,
            onRetry: () => ref.invalidate(stationTideProvider(station.id)),
            data: (v) => StationSummaryBody(view: v),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppSpacing.minTouch)),
            onPressed: () {
              DetailHost.closeOf(context);
              unawaited(context.push('/station/${station.id}'));
            },
            child: Text(l10n.map_openDetail),
          ),
        ],
      ),
    );
  }
}

/// Level, trend, next turn, mini chart and sources — shared by station and point sheets.
class StationSummaryBody extends StatelessWidget {
  const StationSummaryBody({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = view.now;
    final level = now.levelCm;
    final state = now.state;
    final next = now.nextExtreme;
    final tide = view.tide.data;
    final daily = tide.dailyExtremes;
    if (tide.prediction == null && daily != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DailyExtremesCard(extremes: daily),
          SourceLine(view: view),
        ],
      );
    }
    final hour = DateTime.utc(
      view.nowUtc.year,
      view.nowUtc.month,
      view.nowUtc.day,
      view.nowUtc.hour,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(level == null ? '—' : LevelFormat.meters(level), style: context.text.headline),
            if (state != null) TrendLabel(state: state),
            DataKindBadge(kind: now.kind),
          ],
        ),
        if (next != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.map_nextExtreme(
              context.extremeName(next.kind),
              context.relativeTime(next.timeUtc, view.nowUtc),
              LevelFormat.meters(next.levelCm),
              context.durationText(next.timeUtc.difference(view.nowUtc)),
            ),
            style: context.text.bodyStrong,
          ),
          if (context.changeToNext(level, next) case final change?)
            Text(change, style: context.text.body),
        ] else if (tide.prediction == null)
          Text(l10n.tide_noPrediction, style: context.text.caption),
        const SizedBox(height: AppSpacing.sm),
        TideChart(
          height: 120,
          fromUtc: hour.subtract(const Duration(hours: 6)),
          toUtc: hour.add(const Duration(hours: 18)),
          nowUtc: view.nowUtc,
          observed: {for (final o in tide.observations) o.timeUtc: o.levelCm},
          prediction: tide.prediction,
          latestObservation: tide.anchor,
        ),
        const SizedBox(height: AppSpacing.sm),
        SourceLine(view: view),
      ],
    );
  }
}
