import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/map_pill.dart';

/// Wide enough to show every shortcut as a pill.
const double _allPillsFrom = 600;

/// One compact row at the top of the map. On phones: search, "Đi đâu?", the
/// one shortcut where something is happening (if any) and "⋯" for the rest.
/// The row is measured so it always stays on one line, without sideways
/// dragging (on the web that would also pan the map underneath): when space
/// is short "Đi đâu?" shrinks to its icon, then the hot shortcut moves into "⋯".
class MapShortcuts extends StatelessWidget {
  const MapShortcuts({
    required this.search,
    required this.actions,
    required this.onMore,
    super.key,
  });

  final Widget search;

  /// Most relevant first.
  final List<MapAction> actions;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final l10n = context.l10n;
      final wide = box.maxWidth >= _allPillsFrom;
      final hot = wide ? actions : actions.where((a) => a.hot).take(1).toList();
      final where = wide ? l10n.where_title : l10n.where_short;
      double pill(String label) => _pillWidth(context, label);
      const round = AppSpacing.minTouch + AppSpacing.sm;
      final more = hot.length < actions.length ? round : 0.0;
      final room = box.maxWidth - round - more;
      final hotWidth = hot.fold<double>(0, (w, a) => w + pill(a.label) + AppSpacing.sm);
      // Full "Đi đâu?" if it fits, else its icon; drop the hot pill if even that is too wide.
      final whereFull = wide || pill(where) + AppSpacing.sm + hotWidth <= room;
      final keepHot = wide || whereFull || round + hotWidth <= room;
      final shown = keepHot ? hot : const <MapAction>[];
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          search,
          if (whereFull)
            MapPill(
              icon: Icons.explore_rounded,
              color: context.colors.fishGood,
              label: where,
              onTap: () => unawaited(context.push(whereRoute)),
            )
          else
            MapRoundButton(
              icon: Icons.explore_rounded,
              tooltip: l10n.where_title,
              onTap: () => unawaited(context.push(whereRoute)),
            ),
          for (final a in shown) MapPill.of(a),
          if (shown.length < actions.length)
            MapRoundButton(
              icon: Icons.more_horiz_rounded,
              tooltip: l10n.more_shortcuts,
              onTap: onMore,
            ),
        ],
      );
    },
  );

  /// Same sizes as [MapPill]: padding + icon circle + gap + label.
  static double _pillWidth(BuildContext context, String label) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: context.text.label),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final w = painter.width;
    painter.dispose();
    return AppSpacing.xs + AppIconSize.sm + AppSpacing.sm + AppSpacing.sm + w + AppSpacing.md;
  }
}
