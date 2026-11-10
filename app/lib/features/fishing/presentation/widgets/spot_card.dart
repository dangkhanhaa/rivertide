import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/navigation/map_focus.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/map/map.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Which place the fishing tab is computed for, and how to change it.
class SpotCard extends ConsumerWidget {
  const SpotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spot = ref.watch(fishingSpotProvider);
    final station = ref.watch(stationByIdProvider(spot.id)).value;
    final isPoint = spot.id.startsWith(PointId.prefix);
    final title = !isPoint ? station?.name ?? '' : (spot.mine ? l10n.spot_mine : l10n.spot_point);
    final subtitle = isPoint
        ? station?.name ?? ''
        : (station?.river == null ? station?.region ?? '' : l10n.loc_river(station?.river ?? ''));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Text(l10n.spot_title, style: context.text.label),
            Text(title, style: context.text.title),
            if (subtitle.isNotEmpty) Text(subtitle, style: context.text.caption),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.my_location_rounded),
                  label: Text(l10n.spot_useMine),
                  onPressed: () async {
                    final p = await runLocateFlow(context, ref.read(locationServiceProvider));
                    if (p == null) return;
                    ref
                        .read(fishingSpotProvider.notifier)
                        .choose(PointId.encode(p.lat, p.lon), mine: true);
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.map_rounded),
                  label: Text(l10n.spot_pickMap),
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(l10n.spot_pickHint)));
                    context.go(mapRoute);
                  },
                ),
              ],
            ),
            const _SavedSpots(),
          ],
        ),
      ),
    );
  }
}

class _SavedSpots extends ConsumerWidget {
  const _SavedSpots();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoriteIdsProvider).value ?? const <String>[];
    if (ids.isEmpty) return const SizedBox.shrink();
    final stations = ref.watch(stationListProvider).value ?? const <Station>[];
    final spot = ref.watch(fishingSpotProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text(context.l10n.spot_saved, style: context.text.label),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final id in ids)
              if (stations.firstWhereOrNull((s) => s.id == id) ?? PointId.toStation(id)
                  case final s?)
                ChoiceChip(
                  label: Text(s.name),
                  selected: spot.id == id,
                  onSelected: (_) => ref.read(fishingSpotProvider.notifier).choose(id),
                ),
          ],
        ),
      ],
    );
  }
}

/// First open: fish where the user is, if location is already allowed (no prompt).
Future<void> autoLocateSpot(WidgetRef ref) async {
  final notifier = ref.read(fishingSpotProvider.notifier);
  if (notifier.userChose) return;
  final service = ref.read(locationServiceProvider);
  if (!await service.hasPermission()) return;
  if (await service.locate() case Located(:final lat, :final lon)) {
    if (notifier.userChose) return;
    notifier.choose(PointId.encode(lat, lon), mine: true, byUser: false);
  }
}

/// Fire-and-forget [autoLocateSpot] for initState.
void unawaitedLocate(WidgetRef ref) => unawaited(autoLocateSpot(ref));
