import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// Big "Hôm nay đi đâu?" button at the top of the fishing tab (P2-21).
class WhereEntryCard extends StatelessWidget {
  const WhereEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ink = c.surface;
    return Material(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [c.primary, c.fishGood])),
        child: InkWell(
          onTap: () => unawaited(context.push(whereRoute)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.explore_rounded, color: ink, size: AppIconSize.lg),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.where_title,
                        style: context.text.title.copyWith(color: ink),
                      ),
                      Text(
                        context.l10n.where_entryHint,
                        style: context.text.body.copyWith(color: ink),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
