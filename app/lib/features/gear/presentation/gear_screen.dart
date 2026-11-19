import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/gear/application/gear_checks.dart';
import 'package:rivertide/features/gear/domain/gear_data.dart';
import 'package:rivertide/features/gear/presentation/gear_texts.dart';
import 'package:rivertide/features/gear/presentation/knot_painter.dart';

/// "Đồ nghề & nút buộc" (P2-38): packing list by trip, and six knots with a
/// drawing and steps. Everything works offline.
class GearScreen extends StatelessWidget {
  const GearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.gear_title),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.gear_tabPack),
              Tab(text: l10n.gear_tabKnots),
            ],
          ),
        ),
        body: const TabBarView(children: [_PackTab(), _KnotsTab()]),
      ),
    );
  }
}

class _PackTab extends ConsumerStatefulWidget {
  const _PackTab();

  @override
  ConsumerState<_PackTab> createState() => _PackTabState();
}

class _PackTabState extends ConsumerState<_PackTab> {
  TripKind _kind = TripKind.pond;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final checked = ref.watch(gearChecksProvider).value ?? const <GearItem>{};
    final items = [...?gearLists[TripKind.common], ...?gearLists[_kind]];
    final done = items.where(checked.contains).length;
    final notifier = ref.read(gearChecksProvider.notifier);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final k in TripKind.values.skip(1))
              ChoiceChip(
                label: Text(context.tripName(k)),
                selected: _kind == k,
                onSelected: (_) => setState(() => _kind = k),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: items.isEmpty ? 0 : done / items.length,
                minHeight: AppSpacing.sm,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(l10n.gear_progress(done, items.length), style: context.text.label),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: [
              for (final g in items)
                CheckboxListTile(
                  value: checked.contains(g),
                  onChanged: (_) => unawaited(notifier.toggle(g)),
                  title: Text(context.gearName(g), style: context.text.body),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton.icon(
            onPressed: () => unawaited(notifier.clear()),
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(l10n.gear_clear),
          ),
        ),
      ],
    );
  }
}

class _KnotsTab extends StatelessWidget {
  const _KnotsTab();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
    children: [
      for (final k in Knot.values) _KnotCard(knot: k),
      Text(context.l10n.knot_note, style: context.text.caption),
    ],
  );
}

class _KnotCard extends StatelessWidget {
  const _KnotCard({required this.knot});

  final Knot knot;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.knotTexts(knot);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              Row(
                children: [
                  Expanded(child: Text(t.name, style: context.text.title)),
                  IconBadge(icon: Icons.link_rounded, color: c.primary, size: 32),
                ],
              ),
              Text(t.use, style: context.text.caption),
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: KnotPainter(
                    knot: knot,
                    line: c.primary,
                    metal: c.onSurfaceMuted,
                    accent: c.spot,
                  ),
                ),
              ),
              for (final (i, s) in t.steps.indexed) _Step(n: i + 1, text: s),
              Text(context.l10n.knot_strength(knot.strength), style: context.text.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.text});

  final int n;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        CircleAvatar(
          radius: AppSpacing.md,
          backgroundColor: c.primary.withValues(alpha: 0.12),
          child: Text('$n', style: context.text.label.copyWith(color: c.primary)),
        ),
        Expanded(child: Text(text, style: context.text.body)),
      ],
    );
  }
}
