import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/stations/stations.dart';

/// S05: followed stations (stored on the device).
class WatchScreen extends ConsumerWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoriteIdsProvider);
    final stations = ref.watch(stationListProvider);
    final body = switch ((ids, stations)) {
      (AsyncData(value: final idList), AsyncData(value: final all)) => _list(context, idList, all),
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) => ErrorView(error: error),
      _ => const LoadingView(),
    };
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.nav_watch)),
      body: body,
    );
  }

  Widget _list(BuildContext context, List<String> ids, List<Station> all) {
    // Saved map points are not in the catalogue: rebuild them from their id.
    final followed = [
      for (final id in ids) ?(all.firstWhereOrNull((s) => s.id == id) ?? PointId.toStation(id)),
    ];
    if (followed.isEmpty) return EmptyView(message: context.l10n.watch_empty);
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: followed.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => StationCard(station: followed[i]),
    );
  }
}
