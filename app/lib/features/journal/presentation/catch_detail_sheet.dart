import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/journal/application/journal_providers.dart';
import 'package:rivertide/features/journal/presentation/journal_screen.dart';
import 'package:rivertide/features/stations/stations.dart';

/// One catch with the conditions saved with it, and delete.
class CatchDetailSheet extends ConsumerWidget {
  const CatchDetailSheet({required this.entry, super.key});

  final CatchEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final photo = entry.photo;
    final state = TideState.values.firstWhereOrNull((s) => s.name == entry.waterState);
    final moon = entry.moonPhase;
    final lines = [
      '${TimeFormat.dayShort(entry.caughtAtUtc)} ${TimeFormat.hm(entry.caughtAtUtc)} · ${entry.placeName}',
      if (entry.weightKg case final w?) l10n.journal_weightValue(LevelFormat.decimal1(w)),
      if (entry.lengthCm case final l?) l10n.journal_lengthValue(l.round()),
      if (entry.bait case final b?) l10n.journal_baitValue(b),
      ?entry.note,
    ];
    final conditions = [
      if (entry.levelCm case final lv?) l10n.journal_levelValue(LevelFormat.meters(lv)),
      if (state != null) l10n.journal_water(context.waterStateName(state).toLowerCase()),
      if (entry.temperatureC case final t?) '${t.round()} °C',
      if (entry.windKmh case final w?) l10n.summary_wind(w.round()),
      if (moon != null) context.moonPhaseName(phaseNameOf(moon)),
      if (entry.fishingScore case final s?) l10n.journal_scoreValue(LevelFormat.decimal1(s)),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Text(entry.species, style: context.text.headline),
            if (photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.memory(photo, width: double.infinity, fit: BoxFit.cover),
              ),
            for (final l in lines) Text(l, style: context.text.body),
            if (conditions.isNotEmpty) ...[
              Text(l10n.journal_conditions, style: context.text.label),
              Text(conditions.join(' · '), style: context.text.body),
            ],
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: context.colors.alarm3),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.journal_deleteTitle),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(l10n.common_cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(l10n.journal_delete),
                      ),
                    ],
                  ),
                );
                if (ok != true) return;
                await deleteCatch(ref, entry.id);
                navigator.pop();
              },
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.journal_delete),
            ),
          ],
        ),
      ),
    );
  }
}
