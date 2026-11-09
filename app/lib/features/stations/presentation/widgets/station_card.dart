import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/map_focus.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Summary row used by the station list and the watch list.
class StationCard extends ConsumerWidget {
  const StationCard({required this.station, super.key});

  final Station station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteIdsProvider).value?.contains(station.id) ?? false;
    final l10n = context.l10n;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        // Lists open the station on the map with its detail panel (zoomed in).
        onTap: () {
          ref.read(mapFocusProvider.notifier).stationId = station.id;
          context.go(mapRoute);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(station.name, style: context.text.title)),
                    Icon(
                      stationKindIcon(station.kind),
                      size: AppIconSize.sm,
                      color: context.colors.onSurfaceMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        context.stationKindLabel(station.kind),
                        style: context.text.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: isFavorite ? l10n.station_unfollow : l10n.station_follow,
                      icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                      onPressed: () => toggleFavorite(ref, station.id),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                _Summary(stationId: station.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({required this.stationId});

  final String stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(stationViewProvider(stationId));
    return switch (view) {
      AsyncData(:final value) => _content(context, value),
      AsyncError() => Text(context.l10n.error_network, style: context.text.caption),
      _ => const LinearProgressIndicator(minHeight: 2),
    };
  }

  Widget _content(BuildContext context, StationView view) {
    final now = view.now;
    final level = now.levelCm;
    final state = now.state;
    final next = now.nextExtreme;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(level == null ? '—' : LevelFormat.meters(level), style: context.text.bodyStrong),
        if (state != null) TrendLabel(state: state, compact: true),
        if (next != null)
          Text(
            '${context.extremeName(next.kind)} ${context.relativeTime(next.timeUtc, view.nowUtc)}',
            style: context.text.caption,
          ),
        DataKindBadge(kind: now.kind),
      ],
    );
  }
}
