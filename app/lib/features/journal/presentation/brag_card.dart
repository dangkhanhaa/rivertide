import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/journal/presentation/journal_screen.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Picture size of the shared card (4:5, what social feeds show uncropped).
const Size bragCardSize = Size(360, 450);

/// "Khoe cá" card (P2-36): the catch photo full-bleed with species, size and
/// the conditions it was caught in. The place is only shown when asked.
class BragCard extends StatelessWidget {
  const BragCard({required this.entry, required this.showPlace, super.key});

  final CatchEntry entry;
  final bool showPlace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final white = c.surface;
    final size = [
      if (entry.weightKg case final w?) l10n.journal_weightValue(LevelFormat.decimal1(w)),
      if (entry.lengthCm case final l?) l10n.journal_lengthValue(l.round()),
    ].join(' · ');
    return SizedBox.fromSize(
      size: bragCardSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Backdrop(photo: entry.photo),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.35, 1],
                  colors: [c.deepWater.withValues(alpha: 0), c.deepWater.withValues(alpha: 0.92)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Brand(color: white),
                  const Spacer(),
                  Text(
                    entry.species,
                    style: context.text.headline.copyWith(color: white),
                    // Poster-sized title from the theme's headline, not a new size.
                    textScaler: const TextScaler.linear(1.35),
                    maxLines: 2,
                  ),
                  if (size.isNotEmpty) Text(size, style: context.text.title.copyWith(color: white)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [for (final t in _chips(context)) _Chip(text: t)],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _chips(BuildContext context) {
    final l10n = context.l10n;
    final state = TideState.values.firstWhereOrNull((s) => s.name == entry.waterState);
    final moon = entry.moonPhase;
    return [
      '${TimeFormat.hm(entry.caughtAtUtc)} · ${TimeFormat.dayShort(entry.caughtAtUtc)}',
      if (state != null) context.waterStateName(state),
      if (moon != null) context.moonPhaseName(phaseNameOf(moon)),
      if (entry.fishingScore case final s?) l10n.brag_score(LevelFormat.decimal1(s)),
      if (showPlace) entry.placeName,
    ];
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.photo});

  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    final p = photo;
    if (p != null) return Image.memory(p, fit: BoxFit.cover);
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.primary, accentPartner(c.primary)],
        ),
      ),
      child: Align(
        alignment: const Alignment(0, -0.3),
        child: Icon(Icons.set_meal_rounded, size: 140, color: c.surface.withValues(alpha: 0.35)),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
    decoration: BoxDecoration(
      color: context.colors.deepWater.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        Icon(Icons.waves_rounded, color: color, size: AppIconSize.sm),
        Text(context.l10n.appTitle, style: context.text.label.copyWith(color: color)),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
    decoration: BoxDecoration(
      color: context.colors.surface.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      border: Border.all(color: context.colors.surface.withValues(alpha: 0.35)),
    ),
    child: Text(text, style: context.text.caption.copyWith(color: context.colors.surface)),
  );
}
