import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/species_guide.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/push_page.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/fishing/application/species_providers.dart';
import 'package:rivertide/features/fishing/presentation/species_detail_screen.dart';
import 'package:rivertide/features/fishing/presentation/widgets/species_strip.dart';
import 'package:rivertide/features/fishing/presentation/widgets/species_style.dart';

/// Species handbook (P2-32): every species, best for today first, with a
/// habitat filter. Works offline for the texts; the ranking needs the spot's
/// tide and weather.
class SpeciesScreen extends ConsumerStatefulWidget {
  const SpeciesScreen({required this.spotId, super.key});

  final String spotId;

  @override
  ConsumerState<SpeciesScreen> createState() => _SpeciesScreenState();
}

class _SpeciesScreenState extends ConsumerState<SpeciesScreen> {
  Habitat? _habitat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final conditions = ref.watch(spotConditionsProvider(widget.spotId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sp_guideTitle)),
      body: switch (conditions) {
        AsyncData(:final value?) => _list(
          context,
          rankSpecies(value, localMonth(value.nowUtc)),
          value.nowUtc,
        ),
        AsyncData() => EmptyView(message: l10n.common_empty),
        AsyncError(:final error) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(spotConditionsProvider(widget.spotId)),
        ),
        _ => const LoadingView(),
      },
    );
  }

  Widget _list(BuildContext context, List<SpeciesOutlook> ranked, DateTime nowUtc) {
    final shown = ranked.where((o) => _habitat == null || o.species.habitats.contains(_habitat));
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final h in Habitat.values)
              FilterChip(
                label: Text(context.habitatName(h)),
                selected: _habitat == h,
                onSelected: (on) => setState(() => _habitat = on ? h : null),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final o in shown) _Row(outlook: o, spotId: widget.spotId, nowUtc: nowUtc),
        const SizedBox(height: AppSpacing.md),
        Text(context.l10n.sp_note, style: context.text.caption),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.outlook, required this.spotId, required this.nowUtc});

  final SpeciesOutlook outlook;
  final String spotId;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final o = outlook;
    final l10n = context.l10n;
    final span = context.speciesSpan(o, nowUtc);
    final time = o.bestStartUtc == null ? span : l10n.sp_bestTime(span);
    final habitats = o.species.habitats.map(context.habitatName).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
          leading: SpeciesAvatar(species: o.species, size: 44),
          title: Text(context.species(o.species).name, style: context.text.bodyStrong),
          subtitle: Text(
            '$time\n$habitats · ${o.inSeason ? l10n.sp_inSeason : l10n.sp_offSeason}',
            style: context.text.caption,
          ),
          isThreeLine: true,
          trailing: ScorePill(score: o.score),
          onTap: () =>
              pushPage<void>(context, SpeciesDetailScreen(spotId: spotId, species: o.species)),
        ),
      ),
    );
  }
}
