import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/presentation/widgets/station_card.dart';

/// Station list grouped by region (the map tab shows the same stations).
class StationsScreen extends ConsumerWidget {
  const StationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(stationListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.stations_title)),
      body: AsyncValueView(
        value: stations,
        onRetry: () => ref.invalidate(stationListProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: context.l10n.common_empty,
        data: (list) => _StationList(stations: list),
      ),
    );
  }
}

class _StationList extends StatelessWidget {
  const _StationList({required this.stations});

  final List<Station> stations;

  @override
  Widget build(BuildContext context) {
    // Gauges first: they have real measurements.
    final groups = groupBy(
      stations.sortedBy<num>((s) => s.kind == StationKind.gauge ? 0 : 1),
      (s) => s.region,
    );
    final rows = <Widget>[
      for (final entry in groups.entries) ...[
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
          child: Text(entry.key, style: context.text.label),
        ),
        for (final s in entry.value)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: StationCard(station: s),
          ),
      ],
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: rows.length,
      itemBuilder: (_, i) => rows[i],
    );
  }
}
