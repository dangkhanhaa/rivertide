import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/widgets/map_pill.dart';

/// One row of shortcuts under the search bar: "Hôm nay đi đâu?" (P2-21) and
/// [trailing] (community spots nearby, when any). Scrolls sideways on narrow
/// screens or with large text instead of wrapping.
class MapShortcuts extends StatelessWidget {
  const MapShortcuts({required this.trailing, super.key});

  final Widget trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xs),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          MapPill(
            icon: Icons.explore_rounded,
            color: context.colors.fishGood,
            label: context.l10n.where_title,
            onTap: () => unawaited(context.push(whereRoute)),
          ),
          trailing,
        ],
      ),
    ),
  );
}
