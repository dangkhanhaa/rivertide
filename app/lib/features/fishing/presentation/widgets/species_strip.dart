import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/species_guide.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/fishing/application/species_providers.dart';
import 'package:rivertide/features/fishing/presentation/species_detail_screen.dart';
import 'package:rivertide/features/fishing/presentation/species_screen.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';
import 'package:rivertide/features/fishing/presentation/widgets/species_style.dart';

/// "Câu cá gì hôm nay?" on the fishing tab (P2-32): the species that suit
/// today best at the chosen spot, swipe sideways, tap for the full guide.
class SpeciesStrip extends ConsumerWidget {
  const SpeciesStrip({super.key});

  static const int shown = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spot = ref.watch(fishingSpotProvider);
    final c = ref.watch(spotConditionsProvider(spot.id)).value;
    if (c == null) return const SizedBox.shrink();
    final ranked = rankSpecies(c, localMonth(c.nowUtc));
    void push(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: context.l10n.sp_title,
          icon: Icons.set_meal_rounded,
          action: TextButton(
            onPressed: () => push(SpeciesScreen(spotId: spot.id)),
            child: Text(context.l10n.sp_seeAll),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              for (final o in ranked.take(shown))
                _SpeciesCard(
                  outlook: o,
                  nowUtc: c.nowUtc,
                  onTap: () => push(SpeciesDetailScreen(spotId: spot.id, species: o.species)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  const _SpeciesCard({required this.outlook, required this.nowUtc, required this.onTap});

  final SpeciesOutlook outlook;
  final DateTime nowUtc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final o = outlook;
    return SizedBox(
      width: 148,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Row(
                  children: [
                    SpeciesAvatar(species: o.species),
                    const Spacer(),
                    ScorePill(score: o.score),
                  ],
                ),
                Text(
                  context.species(o.species).name,
                  style: context.text.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(context.speciesSpan(o, nowUtc), style: context.text.caption, maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round fish badge in the colour of the species' water.
class SpeciesAvatar extends StatelessWidget {
  const SpeciesAvatar({required this.species, this.size = 36, super.key});

  final FishSpecies species;
  final double size;

  @override
  Widget build(BuildContext context) =>
      IconBadge(icon: Icons.set_meal_rounded, color: context.speciesColor(species), size: size);
}

/// Score with its band word, coloured like the map's fish activity.
class ScorePill extends StatelessWidget {
  const ScorePill({required this.score, super.key});

  final double score;

  @override
  Widget build(BuildContext context) {
    final color = context.scoreColor(score);
    return Semantics(
      label: '${LevelFormat.decimal1(score)} ${context.scoreLabel(score)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          context.scoreLabel(score),
          style: context.text.label.copyWith(color: context.colors.onSurface),
        ),
      ),
    );
  }
}
