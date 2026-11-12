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
import 'package:rivertide/features/community/application/community_providers.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
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
              Icon(Icons.groups_rounded, size: AppIconSize.sm, color: c.fishHigh),
              const SizedBox(width: AppSpacing.xs),
              Text(
                mine ? l10n.spot_ownedByYou : l10n.spot_publicTag,
                style: context.text.label.copyWith(color: c.fishHigh),
              ),
            ],
          ),
          Text(spot.title, style: context.text.headline),
          if (spot.photoUrls.isNotEmpty) _Photos(urls: spot.photoUrls),
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
          Align(
            alignment: Alignment.centerRight,
            child: mine
                ? TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: c.alarm3),
                    onPressed: () => unawaited(_delete(context, ref)),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.spot_delete),
                  )
                : TextButton.icon(
                    onPressed: () => unawaited(_report(context, ref)),
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(l10n.spot_report),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _confirm(context, l10n.spot_deleteTitle, null, l10n.journal_delete)) return;
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
    if (!await _confirm(context, l10n.spot_reportTitle, l10n.spot_reportHint, l10n.spot_report)) {
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

  static Future<bool> _confirm(BuildContext context, String title, String? body, String ok) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: body == null ? null : Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(ctx.l10n.common_cancel),
            ),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(ok)),
          ],
        ),
      ) ??
      false;
}

/// Swipeable photos with page dots.
class _Photos extends StatefulWidget {
  const _Photos({required this.urls});

  final List<String> urls;

  @override
  State<_Photos> createState() => _PhotosState();
}

class _PhotosState extends State<_Photos> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      spacing: AppSpacing.xs,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: PageView(
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                for (final u in widget.urls)
                  Image.network(
                    u,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: c.surfaceAlt,
                      child: Icon(Icons.broken_image_outlined, color: c.stale),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.urls.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacing.xs,
            children: [
              for (var i = 0; i < widget.urls.length; i++)
                Container(
                  width: AppSpacing.sm,
                  height: AppSpacing.sm,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page ? c.primary : c.stale.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
