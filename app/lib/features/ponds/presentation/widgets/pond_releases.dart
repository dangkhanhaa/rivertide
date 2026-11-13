import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/ponds/application/ponds_providers.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';
import 'package:rivertide/features/ponds/presentation/pond_format.dart';
import 'package:rivertide/features/ponds/presentation/release_form_screen.dart';

/// "Lịch xả cá": upcoming first, owner posts marked official, relayed ones
/// marked as such; anyone can relay a release they saw posted.
class PondReleases extends ConsumerWidget {
  const PondReleases({required this.pond, super.key});

  final Pond pond;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final releases = ref.watch(pondReleasesProvider(pond.id));
    final now = ref.watch(clockProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.pond_releases, style: context.text.title)),
            FilledButton.tonalIcon(
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => ReleaseFormScreen(pond: pond))),
              icon: const Icon(Icons.campaign_rounded),
              label: Text(l10n.pond_postRelease),
            ),
          ],
        ),
        switch (releases) {
          AsyncData(:final value) when value.isEmpty => Text(
            l10n.pond_noRelease,
            style: context.text.caption,
          ),
          AsyncData(:final value) => Column(
            spacing: AppSpacing.sm,
            children: [for (final r in value.take(6)) _ReleaseTile(release: r, nowUtc: now)],
          ),
          AsyncError() => Text(l10n.pond_loadError, style: context.text.caption),
          _ => const LinearProgressIndicator(),
        },
      ],
    );
  }
}

class _ReleaseTile extends ConsumerWidget {
  const _ReleaseTile({required this.release, required this.nowUtc});

  final PondRelease release;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final r = release;
    final past = r.startsAt.isBefore(nowUtc.subtract(const Duration(hours: 6)));
    final total = r.totalKg;
    final faded = past || r.cancelled;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (faded ? c.stale : c.alarm2).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: (faded ? c.stale : c.alarm2).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Row(
            children: [
              Icon(Icons.event_rounded, size: AppIconSize.sm, color: faded ? c.stale : c.alarm2),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(pondWhen(r.startsAt), style: context.text.bodyStrong)),
              if (total != null) Text(pondAmount(context, total), style: context.text.bodyStrong),
            ],
          ),
          if (r.fish.isNotEmpty) Text(pondFish(context, r), style: context.text.body),
          Text(
            [
              if (r.cancelled) l10n.pond_releaseCancelled else if (past) l10n.pond_releasePast,
              if (r.byOwner) l10n.pond_official else l10n.pond_relayed,
            ].join(' · '),
            style: context.text.caption.copyWith(color: r.byOwner ? c.fishGood : null),
          ),
          _ReleaseActions(release: r),
        ],
      ),
    );
  }
}

class _ReleaseActions extends ConsumerWidget {
  const _ReleaseActions({required this.release});

  final PondRelease release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = release;
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        if (r.sourceText.isNotEmpty)
          TextButton(
            onPressed: () => unawaited(
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(ctx.l10n.pond_showSource),
                  content: SingleChildScrollView(child: SelectableText(r.sourceText)),
                ),
              ),
            ),
            child: Text(l10n.pond_showSource),
          ),
        if (r.mine && !r.cancelled)
          TextButton(
            onPressed: () => unawaited(_run(context, () => cancelRelease(ref, r))),
            child: Text(l10n.pond_cancelRelease),
          ),
        if (!r.mine && !r.byOwner)
          TextButton(
            onPressed: () => unawaited(_run(context, () => reportRelease(ref, r))),
            child: Text(l10n.pond_reportRelease),
          ),
      ],
    );
  }

  static Future<void> _run(BuildContext context, Future<bool> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await action();
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pond_error)));
    }
  }
}
