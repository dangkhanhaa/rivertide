import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/no_bite.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/fishing/application/species_providers.dart';
import 'package:rivertide/features/fishing/presentation/widgets/species_style.dart';

/// "Cá không ăn? Thử…" (P2-32) for [spotId].
void showNoBiteSheet(BuildContext context, String spotId) => unawaited(
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _NoBiteSheet(spotId: spotId),
  ),
);

/// Situation-specific tips first (with times), then the classic checks.
class _NoBiteSheet extends ConsumerWidget {
  const _NoBiteSheet({required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = ref.watch(spotConditionsProvider(spotId));
    final tips = switch (c.value) {
      final v? => noBiteTips(v),
      null => const <NoBiteTip>[],
    };
    final now = tips.where((t) => t.kind.index < NoBiteKind.changeDepth.index).toList();
    final always = tips.where((t) => t.kind.index >= NoBiteKind.changeDepth.index).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
        children: [
          Text(l10n.nb_title, style: context.text.title),
          if (c.isLoading)
            const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
          if (now.isNotEmpty) ...[
            _Heading(l10n.nb_now),
            for (final t in now) _TipRow(tip: t, strong: true),
          ],
          if (always.isNotEmpty) ...[
            _Heading(l10n.nb_always),
            for (final t in always) _TipRow(tip: t, strong: false),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(l10n.sp_note, style: context.text.caption),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
    child: Text(text, style: context.text.label.copyWith(color: context.colors.onSurfaceMuted)),
  );
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip, required this.strong});

  final NoBiteTip tip;

  /// Situation tips get a filled accent badge; the checklist a quiet one.
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (icon, text) = context.noBite(tip);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          Container(
            width: AppSpacing.xxl,
            height: AppSpacing.xxl,
            decoration: BoxDecoration(
              color: strong ? c.primary : c.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppIconSize.sm, color: strong ? c.surface : c.primary),
          ),
          Expanded(child: Text(text, style: context.text.body)),
        ],
      ),
    );
  }
}
