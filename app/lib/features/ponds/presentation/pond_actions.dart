import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/confirm_dialog.dart';
import 'package:rivertide/features/ponds/application/ponds_providers.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';
import 'package:rivertide/features/ponds/presentation/pond_form_screen.dart';

/// "Hồ có thật" / Sửa / Tôi là chủ hồ / Báo cáo under a pond.
class PondFooterActions extends ConsumerWidget {
  const PondFooterActions({required this.pond, super.key});

  final Pond pond;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = pond;
    final canEdit = !p.hasOwner || p.mineOwner;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        if (!p.hasOwner)
          OutlinedButton.icon(
            onPressed: p.confirmedByMe ? null : () => unawaited(_confirm(context, ref)),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(p.confirmedByMe ? l10n.pond_confirmed : l10n.pond_confirm),
          ),
        if (canEdit)
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => PondFormScreen.edit(p))),
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.pond_edit),
          ),
        if (!p.hasOwner || p.mineOwner)
          OutlinedButton.icon(
            onPressed: () => unawaited(_claim(context, ref)),
            icon: const Icon(Icons.storefront_outlined),
            label: Text(l10n.pond_claim),
          ),
        if (!p.mineOwner)
          TextButton.icon(
            onPressed: () => unawaited(_report(context, ref)),
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.pond_report),
          ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await confirmPond(ref, pond.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.pond_confirmDone)));
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pond_error)));
    }
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.pond_reportTitle,
      body: l10n.pond_reportHint,
      ok: l10n.pond_report,
    );
    if (!ok) return;
    try {
      final counted = await reportPond(ref, pond.id);
      messenger.showSnackBar(
        SnackBar(content: Text(counted ? l10n.spot_reportDone : l10n.spot_reportTwice)),
      );
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pond_error)));
    }
  }

  Future<void> _claim(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final input = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _ClaimDialog(),
    );
    if (input == null) return;
    try {
      final r = await claimPond(ref, pond.id, input.$1, input.$2);
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (r) {
            ClaimResult.sent => l10n.pond_claimSent,
            ClaimResult.pending => l10n.pond_claimPending,
            ClaimResult.owned => l10n.pond_claimOwned,
            ClaimResult.yours => l10n.pond_claimYours,
          }),
        ),
      );
    } on AppException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e is RateLimitedException ? l10n.pond_tooMany : l10n.pond_error)),
      );
    }
  }
}

class _ClaimDialog extends StatefulWidget {
  const _ClaimDialog();

  @override
  State<_ClaimDialog> createState() => _ClaimDialogState();
}

class _ClaimDialogState extends State<_ClaimDialog> {
  final _contact = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _contact.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.pond_claimTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Text(l10n.pond_claimBody, style: context.text.body),
            TextField(
              controller: _contact,
              keyboardType: TextInputType.phone,
              maxLength: 60,
              decoration: InputDecoration(labelText: l10n.pond_claimContact),
            ),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: InputDecoration(labelText: l10n.pond_claimNote),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.common_cancel)),
        FilledButton(
          onPressed: () {
            if (_contact.text.trim().length < 6) return;
            Navigator.of(context).pop((_contact.text.trim(), _note.text.trim()));
          },
          child: Text(l10n.pond_claimSend),
        ),
      ],
    );
  }
}
