import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/journal/application/journal_providers.dart';
import 'package:rivertide/features/journal/presentation/catch_detail_sheet.dart';
import 'package:rivertide/features/journal/presentation/catch_form_screen.dart';

/// S07 fishing log: what was caught, where, and in which conditions — with
/// what the log says about when the user catches most.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catches = ref.watch(catchesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.journal_title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const CatchFormScreen())),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.journal_add),
      ),
      body: switch (catches) {
        AsyncData(:final value) when value.isEmpty => EmptyView(message: l10n.journal_empty),
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl * 3,
          ),
          children: [
            _Stats(catches: value),
            const SizedBox(height: AppSpacing.md),
            for (final c in value) _CatchTile(entry: c),
          ],
        ),
        AsyncError(:final error) => ErrorView(error: error),
        _ => const LoadingView(),
      },
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.catches});

  final List<CatchEntry> catches;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kg = catches.map((c) => c.weightKg ?? 0).sum;
    final topSpecies = groupBy(
      catches,
      (c) => c.species,
    ).entries.sortedBy<num>((e) => -e.value.length).firstOrNull;
    final withState = catches.where((c) => c.waterState != null).toList();
    final rising = withState.where((c) => c.waterState?.startsWith('rising') ?? false).length;
    final falling = withState.where((c) => c.waterState?.startsWith('falling') ?? false).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            Text(l10n.journal_statsTitle, style: context.text.title),
            Text(
              l10n.journal_statsCount(catches.length, LevelFormat.decimal1(kg)),
              style: context.text.body,
            ),
            if (topSpecies != null)
              Text(
                l10n.journal_statsTop(topSpecies.key, topSpecies.value.length),
                style: context.text.body,
              ),
            if (withState.length >= 3)
              Text(
                rising >= falling
                    ? l10n.journal_statsRising((100 * rising / withState.length).round())
                    : l10n.journal_statsFalling((100 * falling / withState.length).round()),
                style: context.text.bodyStrong,
              ),
          ],
        ),
      ),
    );
  }
}

class _CatchTile extends StatelessWidget {
  const _CatchTile({required this.entry});

  final CatchEntry entry;

  @override
  Widget build(BuildContext context) {
    final photo = entry.photo;
    final state = TideState.values.firstWhereOrNull((s) => s.name == entry.waterState);
    final details = [
      if (entry.weightKg case final w?) '${LevelFormat.decimal1(w)} kg',
      if (entry.lengthCm case final l?) '${l.round()} cm',
      if (state != null) context.l10n.journal_water(context.waterStateName(state).toLowerCase()),
    ].join(' · ');
    return Card(
      child: ListTile(
        leading: photo == null
            ? const CircleAvatar(child: Icon(Icons.set_meal_rounded))
            : ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.memory(
                  photo,
                  width: AppSpacing.minTouch,
                  height: AppSpacing.minTouch,
                  fit: BoxFit.cover,
                ),
              ),
        title: Text(entry.species, style: context.text.bodyStrong),
        subtitle: Text(
          [
            '${TimeFormat.dayShort(entry.caughtAtUtc)} ${TimeFormat.hm(entry.caughtAtUtc)} · ${entry.placeName}',
            if (details.isNotEmpty) details,
          ].join('\n'),
          style: context.text.body,
        ),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => CatchDetailSheet(entry: entry),
        ),
      ),
    );
  }
}

extension WaterStateName on BuildContext {
  String waterStateName(TideState s) => switch (s) {
    TideState.rising || TideState.risingFast => l10n.tide_rising,
    TideState.falling || TideState.fallingFast => l10n.tide_falling,
    TideState.slack => l10n.tide_slack,
  };
}
