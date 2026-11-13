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
import 'package:rivertide/core/widgets/confirm_dialog.dart';
import 'package:rivertide/core/widgets/detail_host.dart';
import 'package:rivertide/features/community/application/community_providers.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:rivertide/features/community/presentation/publish_spot_screen.dart';
import 'package:rivertide/features/community/presentation/spot_comments.dart';
import 'package:rivertide/features/community/presentation/spot_photos.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Details of one community spot: photos, what bites, tips, and the way there.
class SpotSheet extends ConsumerWidget {
  const SpotSheet({required this.spot, required this.onViewWater, super.key});

  final PublicSpot spot;

  /// Opens the water level / fishing details for the spot's position.
  final VoidCallback onViewWater;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final mine = spot.mine;
    final km = spot.distanceKm;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Row(
            children: [
              Icon(Icons.groups_rounded, size: AppIconSize.sm, color: c.spot),
              const SizedBox(width: AppSpacing.xs),
              Text(
                mine ? l10n.spot_ownedByYou : l10n.spot_publicTag,
                style: context.text.label.copyWith(color: c.spot),
              ),
            ],
          ),
          Text(spot.title, style: context.text.headline),
          if (spot.photoUrls.isNotEmpty) SpotPhotos(urls: spot.photoUrls),
          if (spot.species.isNotEmpty)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final s
                    in spot.species.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty))
                  Chip(
                    avatar: const Icon(Icons.set_meal_rounded, size: AppIconSize.sm),
                    label: Text(s),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          if (spot.note.isNotEmpty) Text(spot.note, style: context.text.body),
          Text(
            [
              l10n.spot_postedAgo(TimeFormat.dayShort(spot.createdAt)),
              if (spot.updatedAt case final u?) l10n.spot_edited(TimeFormat.dayShort(u)),
              if (km != null) l10n.spot_distance(LevelFormat.km(km)),
              ?adminLine(ref, spot.lat, spot.lon),
            ].join(' · '),
            style: context.text.caption,
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              DirectionsButton(lat: spot.lat, lon: spot.lon),
              OutlinedButton.icon(
                onPressed: onViewWater,
                icon: const Icon(Icons.water_rounded),
                label: Text(l10n.spot_viewWater),
              ),
            ],
          ),
          _OwnerActions(
            mine: mine,
            onEdit: () => unawaited(_edit(context)),
            onDelete: () => unawaited(_delete(context, ref)),
            onReport: () => unawaited(_report(context, ref)),
          ),
          const Divider(),
          SpotComments(spotId: spot.id),
        ],
      ),
    );
  }

  /// The sheet shows a snapshot: close it after a saved edit (pins refresh).
  Future<void> _edit(BuildContext context) async {
    final saved = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => PublishSpotScreen.edit(spot)));
    if (saved == true && context.mounted) DetailHost.closeOf(context);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await confirmDialog(context, title: l10n.spot_deleteTitle, ok: l10n.journal_delete)) {
      return;
    }
    try {
      await deleteSpot(ref, spot);
      if (nav.canPop()) nav.pop();
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_error)));
    }
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!await confirmDialog(
      context,
      title: l10n.spot_reportTitle,
      body: l10n.spot_reportHint,
      ok: l10n.spot_report,
    )) {
      return;
    }
    try {
      final counted = await reportSpot(ref, spot);
      messenger.showSnackBar(
        SnackBar(content: Text(counted ? l10n.spot_reportDone : l10n.spot_reportTwice)),
      );
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_error)));
    }
  }
}

/// Edit / delete for the owner; report for everyone else.
class _OwnerActions extends StatelessWidget {
  const _OwnerActions({
    required this.mine,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  final bool mine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: AppSpacing.xs,
      children: [
        if (mine) ...[
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.spot_edit),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: context.colors.alarm3),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.spot_delete),
          ),
        ] else
          TextButton.icon(
            onPressed: onReport,
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.spot_report),
          ),
      ],
    );
  }
}
