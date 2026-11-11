import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fishing_advice.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/stations.dart';

/// "What to do now" for the chosen spot: near or far from the bank, wind,
/// storm, rain, light — from the spot's own level, weather and flow.
class AdviceCard extends ConsumerWidget {
  const AdviceCard({required this.spotId, super.key});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(stationViewProvider(spotId)).value;
    final fishing = ref.watch(stationFishingProvider(spotId)).value;
    if (view == null || fishing == null) return const SizedBox.shrink();
    final flow = ref.watch(stationFlowProvider(spotId)).value?.data;
    final kinds = adviceNow(view, fishing, flow);
    if (kinds.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates_outlined),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(l10n.advice_title, style: context.text.title)),
              ],
            ),
            for (final k in kinds) _line(context, k, view),
            Text(l10n.advice_note, style: context.text.caption),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, AdviceKind k, StationView view) {
    final (icon, text, color) = context.adviceLine(k, view);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: AppIconSize.sm),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: context.text.body)),
      ],
    );
  }
}
