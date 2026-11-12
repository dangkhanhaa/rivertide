import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// "Hôm nay đi đâu?" chip under the search bar (P2-21).
class WhereChip extends StatelessWidget {
  const WhereChip({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ActionChip(
          avatar: Icon(Icons.explore_rounded, color: c.fishGood, size: AppIconSize.sm),
          label: Text(context.l10n.where_title, style: context.text.label),
          backgroundColor: c.surface,
          elevation: 3,
          shadowColor: c.onSurface.withValues(alpha: 0.3),
          side: BorderSide.none,
          onPressed: () => unawaited(context.push(whereRoute)),
        ),
      ),
    );
  }
}
