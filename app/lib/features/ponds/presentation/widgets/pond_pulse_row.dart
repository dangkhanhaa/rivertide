import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/ponds/application/ponds_providers.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';

/// "Lúc này ở hồ": one tap to say busy / quiet / biting / just released,
/// with how many said so in the last 6 hours.
class PondPulseRow extends ConsumerWidget {
  const PondPulseRow({required this.pondId, super.key});

  final String pondId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final counts = ref.watch(pondPulseProvider(pondId)).value ?? const {};
    String label(PulseKind k) => switch (k) {
      PulseKind.busy => l10n.pond_pulseBusy,
      PulseKind.quiet => l10n.pond_pulseQuiet,
      PulseKind.biting => l10n.pond_pulseBiting,
      PulseKind.released => l10n.pond_pulseReleased,
    };
    IconData icon(PulseKind k) => switch (k) {
      PulseKind.busy => Icons.groups_rounded,
      PulseKind.quiet => Icons.self_improvement_rounded,
      PulseKind.biting => Icons.phishing_rounded,
      PulseKind.released => Icons.water_drop_rounded,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text(l10n.pond_pulseTitle, style: context.text.label),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final k in PulseKind.values)
              ActionChip(
                avatar: Icon(icon(k), size: AppIconSize.sm),
                label: Text(
                  (counts[k] ?? 0) > 0 ? l10n.pond_pulseCount(label(k), counts[k] ?? 0) : label(k),
                ),
                onPressed: () => unawaited(_send(context, ref, k)),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _send(BuildContext context, WidgetRef ref, PulseKind kind) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sendPulse(ref, pondId, kind);
      messenger.showSnackBar(SnackBar(content: Text(l10n.pond_pulseSent)));
    } on AppException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e is RateLimitedException ? l10n.pond_pulseWait : l10n.pond_error)),
      );
    }
  }
}
