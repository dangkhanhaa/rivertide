import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/features/watch/presentation/place_meta_dialog.dart';

/// S05: followed stations and saved places (stored on the device), grouped by
/// the user's own groups, each with its own name and note (F-UX-07).
class WatchScreen extends ConsumerWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);
    final stations = ref.watch(stationListProvider);
    final body = switch ((favs, stations)) {
      (AsyncData(value: final list), AsyncData(value: final all)) => _list(context, ref, list, all),
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) => ErrorView(error: error),
      _ => const LoadingView(),
    };
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.nav_watch)),
      body: body,
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, List<SavedPlace> favs, List<Station> all) {
    // Saved map points are not in the catalogue: rebuild them from their id.
    final rows = [
      for (final f in favs)
        if (all.firstWhereOrNull((s) => s.id == f.stationId) ?? PointId.toStation(f.stationId)
            case final station?)
          (fav: f, station: station),
    ];
    if (rows.isEmpty) return EmptyView(message: context.l10n.watch_empty);
    final groups = groupBy(rows, (r) => r.fav.group);
    // Named groups A→Z, ungrouped last.
    final names = groups.keys.whereType<String>().sorted();
    final ordered = [...names, if (groups.containsKey(null)) null];
    final existing = names;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (final g in ordered) ...[
          if (ordered.length > 1 || g != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
              child: Text(g ?? context.l10n.watch_noGroup, style: context.text.label),
            ),
          for (final r in groups[g] ?? const <({SavedPlace fav, Station station})>[])
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: StationCard(
                station: r.station,
                label: r.fav.label,
                note: r.fav.note,
                onEdit: () => editPlaceMeta(context, ref, r.fav, r.station.name, existing),
              ),
            ),
        ],
      ],
    );
  }
}
