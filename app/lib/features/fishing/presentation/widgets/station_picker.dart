import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/features/fishing/application/fishing_selection.dart';
import 'package:rivertide/features/stations/stations.dart';

class StationPicker extends ConsumerWidget {
  const StationPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(fishingStationProvider);
    final stations = ref.watch(stationListProvider).value ?? const <Station>[];
    if (stations.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: DropdownButtonFormField<String>(
        initialValue: selected,
        isExpanded: true,
        decoration: InputDecoration(labelText: context.l10n.fishing_pickStation),
        items: [for (final s in stations) DropdownMenuItem(value: s.id, child: Text(s.name))],
        onChanged: (id) {
          if (id != null) ref.read(fishingStationProvider.notifier).stationId = id;
        },
      ),
    );
  }
}
