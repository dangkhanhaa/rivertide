import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/checkin/application/checkin_providers.dart';
import 'package:rivertide/features/checkin/data/checkin_repository.dart';
import 'package:rivertide/features/stations/stations.dart';

typedef Locate = Future<({double lat, double lon})?> Function();

/// Start, update or end "đang câu ở đây" (P2-27). [locate] asks the map for
/// the current position (with its usual permission flow).
class CheckinSheet extends ConsumerStatefulWidget {
  const CheckinSheet({required this.locate, super.key});

  final Locate locate;

  @override
  ConsumerState<CheckinSheet> createState() => _CheckinSheetState();
}

class _CheckinSheetState extends ConsumerState<CheckinSheet> {
  late bool _biting = ref.read(myCheckinProvider).value?.biting ?? false;
  bool _busy = false;

  Future<void> _go({required bool stop}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      if (stop) {
        await ref.read(myCheckinProvider.notifier).stop();
      } else {
        final p = await widget.locate();
        if (p == null) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.checkin_needLocation)));
          if (mounted) setState(() => _busy = false);
          return;
        }
        await ref.read(myCheckinProvider.notifier).start(p.lat, p.lon, biting: _biting);
      }
      messenger.showSnackBar(SnackBar(content: Text(stop ? l10n.checkin_off : l10n.checkin_on)));
      nav.pop();
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.checkin_error)));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = ref.watch(myCheckinProvider).value != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.md,
          children: [
            Text(l10n.checkin_title, style: context.text.title),
            Text(l10n.checkin_body, style: context.text.body),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.checkin_noBite)),
                ButtonSegment(value: true, label: Text(l10n.checkin_biting)),
              ],
              selected: {_biting},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _biting = s.first),
            ),
            FilledButton.icon(
              onPressed: _busy ? null : () => unawaited(_go(stop: false)),
              icon: const Icon(Icons.place_rounded),
              label: Text(active ? l10n.checkin_update : l10n.checkin_start),
            ),
            if (active)
              OutlinedButton.icon(
                onPressed: _busy ? null : () => unawaited(_go(stop: true)),
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.checkin_stop),
              ),
          ],
        ),
      ),
    );
  }
}

/// What a "đang câu" bubble says: how many, how many biting, since when.
class CheckinCellSheet extends StatelessWidget {
  const CheckinCellSheet({required this.cell, required this.onViewWater, super.key});

  final CheckinCell cell;
  final VoidCallback onViewWater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: (cell.biting > 0 ? c.fishPeak : c.fishGood).withValues(alpha: 0.2),
                child: Text('${cell.people}', style: context.text.title),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(l10n.checkin_cellTitle(cell.people), style: context.text.title)),
            ],
          ),
          Text(
            cell.biting > 0 ? l10n.checkin_cellBiting(cell.biting) : l10n.checkin_cellNoBite,
            style: context.text.bodyStrong.copyWith(color: cell.biting > 0 ? c.fishGood : null),
          ),
          Text(l10n.checkin_cellLatest(TimeFormat.hm(cell.latest)), style: context.text.body),
          if (cell.mine) Text(l10n.checkin_cellYou, style: context.text.caption),
          Text(l10n.checkin_hint, style: context.text.caption),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              DirectionsButton(lat: cell.lat, lon: cell.lon),
              OutlinedButton.icon(
                onPressed: onViewWater,
                icon: const Icon(Icons.water_rounded),
                label: Text(l10n.spot_viewWater),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Busiest places first; tap one to see it on the map.
class CheckinListSheet extends StatelessWidget {
  const CheckinListSheet({
    required this.cells,
    required this.distanceKm,
    required this.onOpen,
    super.key,
  });

  final List<CheckinCell> cells;
  final double? Function(CheckinCell) distanceKm;
  final ValueChanged<CheckinCell> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        children: [
          Text(l10n.checkin_listTitle, style: context.text.title),
          for (final cell in cells)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('${cell.people}')),
              title: Text(l10n.checkin_cellTitle(cell.people)),
              subtitle: Text(
                [
                  if (cell.biting > 0) l10n.checkin_cellBiting(cell.biting),
                  if (distanceKm(cell) case final km?) l10n.spot_distance(LevelFormat.km(km)),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onOpen(cell),
            ),
          Text(l10n.checkin_hint, style: context.text.caption),
        ],
      ),
    );
  }
}
