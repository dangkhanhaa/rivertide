import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/species_guide.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/fishing/application/species_providers.dart';
import 'package:rivertide/features/fishing/presentation/widgets/no_bite_sheet.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';
import 'package:rivertide/features/fishing/presentation/widgets/species_style.dart';

/// One species (P2-32): today's outlook at the chosen spot, season, where,
/// bait, groundbait, how — and "Cá không ăn?" at the bottom.
class SpeciesDetailScreen extends ConsumerWidget {
  const SpeciesDetailScreen({required this.spotId, required this.species, super.key});

  final String spotId;
  final FishSpecies species;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.species(species);
    final c = ref.watch(spotConditionsProvider(spotId)).value;
    final outlook = c == null ? null : speciesOutlook(species, c, localMonth(c.nowUtc));
    return Scaffold(
      appBar: AppBar(title: Text(t.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
        children: [
          _Header(species: species, outlook: outlook, nowUtc: c?.nowUtc),
          if (outlook != null) ...[
            SectionTitle(title: l10n.sp_todayTips, icon: Icons.tips_and_updates_rounded),
            _Tips(outlook: outlook),
          ],
          SectionTitle(title: l10n.sp_season, icon: Icons.calendar_month_rounded),
          _SeasonStrip(species: species, month: c == null ? null : localMonth(c.nowUtc)),
          for (final (icon, title, body) in [
            (Icons.place_rounded, l10n.sp_where, t.where),
            (Icons.restaurant_rounded, l10n.sp_bait, t.bait),
            (Icons.grain_rounded, l10n.sp_chum, t.chum),
            (Icons.phishing_rounded, l10n.sp_how, t.how),
          ]) ...[SectionTitle(title: title, icon: icon), Text(body, style: context.text.body)],
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => showNoBiteSheet(context, spotId),
            icon: const Icon(Icons.help_outline_rounded),
            label: Text(l10n.nb_button),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.sp_note, style: context.text.caption),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.species, required this.outlook, required this.nowUtc});

  final FishSpecies species;
  final SpeciesOutlook? outlook;
  final DateTime? nowUtc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final o = outlook;
    final now = nowUtc;
    final base = context.speciesColor(species);
    final facts = [
      ...species.habitats.map(context.habitatName),
      context.depthName(species.depth),
    ].join(' · ');
    return HeroPanel(
      colors: [base, accentPartner(base)],
      child: Row(
        spacing: AppSpacing.md,
        children: [
          CircleAvatar(
            radius: AppSpacing.xxl,
            backgroundColor: c.surface.withValues(alpha: 0.22),
            child: Icon(Icons.set_meal_rounded, color: c.surface, size: AppIconSize.lg),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                if (o != null)
                  Text(
                    '${l10n.sp_today}: ${context.scoreLabel(o.score).toUpperCase()}',
                    style: context.text.title.copyWith(color: c.surface),
                  ),
                Text(
                  o == null || now == null
                      ? l10n.sp_noTime
                      : o.bestStartUtc == null
                      ? context.speciesSpan(o, now)
                      : l10n.sp_bestTime(context.speciesSpan(o, now)),
                  style: context.text.bodyStrong.copyWith(color: c.surface),
                ),
                Text(facts, style: context.text.caption.copyWith(color: c.surface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips({required this.outlook});

  final SpeciesOutlook outlook;

  @override
  Widget build(BuildContext context) {
    if (outlook.tips.isEmpty) return Text(context.l10n.sp_noTips, style: context.text.body);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        for (final t in outlook.tips)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              Icon(Icons.check_circle_rounded, size: AppIconSize.sm, color: context.colors.primary),
              Expanded(child: Text(context.speciesTip(t), style: context.text.body)),
            ],
          ),
      ],
    );
  }
}

/// Twelve month pills; main-season months filled, this month outlined.
class _SeasonStrip extends StatelessWidget {
  const _SeasonStrip({required this.species, required this.month});

  final FishSpecies species;
  final int? month;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = context.speciesColor(species);
    return Row(
      spacing: 3,
      children: [
        for (var m = 1; m <= 12; m++)
          Expanded(
            child: Column(
              spacing: 2,
              children: [
                Container(
                  height: AppSpacing.lg,
                  decoration: BoxDecoration(
                    color: species.peakMonths.contains(m) ? color : c.stale.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: m == month ? Border.all(color: c.onSurface, width: 2) : null,
                  ),
                ),
                Text('$m', style: context.text.caption),
              ],
            ),
          ),
      ],
    );
  }
}
