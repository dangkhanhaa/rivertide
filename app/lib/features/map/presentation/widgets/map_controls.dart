import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/map/application/map_providers.dart';

/// Legend, filter and "my location" buttons stacked on the map's right edge.
class MapControls extends ConsumerWidget {
  const MapControls({required this.onLocate, super.key});

  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filterActive = ref.watch(mapFilterStateProvider).isActive;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'map-legend',
          tooltip: l10n.map_legend,
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (_) => const _Legend(),
          ),
          child: const Icon(Icons.info_outline_rounded),
        ),
        const SizedBox(height: AppSpacing.sm),
        FloatingActionButton.small(
          heroTag: 'map-filter',
          tooltip: l10n.map_filter,
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (_) => const _FilterSheet(),
          ),
          child: Badge(isLabelVisible: filterActive, child: const Icon(Icons.filter_alt_outlined)),
        ),
        const SizedBox(height: AppSpacing.sm),
        FloatingActionButton(
          heroTag: 'map-locate',
          tooltip: l10n.map_locate,
          onPressed: onLocate,
          child: const Icon(Icons.my_location_rounded),
        ),
      ],
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final f = ref.watch(mapFilterStateProvider);
    final notifier = ref.read(mapFilterStateProvider.notifier);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            value: f.onlyTide,
            title: Text(l10n.map_filterOnlyTide),
            onChanged: (v) => notifier.filter = f.copyWith(onlyTide: v ?? false),
          ),
          CheckboxListTile(
            value: f.onlyAlarm,
            title: Text(l10n.map_filterOnlyAlarm),
            onChanged: (v) => notifier.filter = f.copyWith(onlyAlarm: v ?? false),
          ),
          CheckboxListTile(
            value: f.hideStale,
            title: Text(l10n.map_filterHideStale),
            onChanged: (v) => notifier.filter = f.copyWith(hideStale: v ?? false),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    Widget dot(Color color, String text, [IconData? icon]) => ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: AppSpacing.md,
        backgroundColor: color,
        child: icon == null ? null : Icon(icon, size: AppIconSize.sm, color: c.surface),
      ),
      title: Text(text),
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dot(c.ok, l10n.map_legendNormal),
            dot(c.alarm1, l10n.map_legendAlarm1),
            dot(c.alarm2, l10n.map_legendAlarm2),
            dot(c.alarm3, l10n.map_legendAlarm3),
            dot(c.stale, l10n.map_legendStale),
            dot(c.ok, l10n.tide_rising, Icons.arrow_drop_up_rounded),
            dot(c.ok, l10n.tide_falling, Icons.arrow_drop_down_rounded),
            dot(c.ok, l10n.tide_slack, Icons.remove_rounded),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.map_legendCluster, style: context.text.body),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.map_legendNote, style: context.text.caption),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.map_baseMapCredit, style: context.text.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
