import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/widgets/confirm_dialog.dart';
import 'package:rivertide/features/more/application/erase_my_data.dart';

/// Thêm → Pháp lý → "Xoá dữ liệu của tôi" (P2-60), in two steps: what will be
/// erased, then typing the confirmation word. On success the app starts over
/// at the welcome flow and its terms gate.
Future<void> askEraseMyData(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final server = ref.read(socialClientProvider) != null;
  final first = await confirmDialog(
    context,
    title: l10n.erase_title,
    body: server ? l10n.erase_body : l10n.erase_bodyLocal,
    ok: l10n.erase_continue,
  );
  if (!first || !context.mounted) return;
  final sure =
      await showDialog<bool>(context: context, builder: (_) => const _TypeToConfirm()) ?? false;
  if (!sure || !context.mounted) return;
  final failure = await _withProgress(context, () => eraseMyData(ref));
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(failure == null ? ctx.l10n.erase_doneTitle : ctx.l10n.erase_failedTitle),
      content: Text(switch (failure) {
        null => ctx.l10n.erase_doneBody,
        EraseFailure.server => ctx.l10n.erase_failedServer,
        EraseFailure.device => ctx.l10n.erase_failedDevice,
      }),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
        ),
      ],
    ),
  );
  if (failure == null) restartAfterErase(ref);
}

/// Runs [work] behind a dialog that cannot be dismissed.
Future<T> _withProgress<T>(BuildContext context, Future<T> Function() work) async {
  // showDialog pushes on the root navigator; the tab's own navigator
  // (P2-58) must not be popped instead.
  final nav = Navigator.of(context, rootNavigator: true);
  final label = context.l10n.erase_working;
  final shown = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    ),
  );
  try {
    return await work();
  } finally {
    nav.pop();
    await shown;
  }
}

/// Second step: the action unlocks only once the word is typed.
class _TypeToConfirm extends StatefulWidget {
  const _TypeToConfirm();

  @override
  State<_TypeToConfirm> createState() => _TypeToConfirmState();
}

class _TypeToConfirmState extends State<_TypeToConfirm> {
  final TextEditingController _text = TextEditingController();
  bool _match = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// Case-insensitive; "XOA" also matches "XOÁ" (a keyboard without accents).
  static String _fold(String s) => s.trim().toUpperCase().replaceAll('Á', 'A');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final word = l10n.erase_word;
    return AlertDialog(
      title: Text(l10n.erase_title2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.erase_typeHint(word)),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _text,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(hintText: word),
            onChanged: (v) => setState(() => _match = _fold(v) == _fold(word)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: context.colors.alarm3),
          onPressed: _match ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.erase_confirm),
        ),
      ],
    );
  }
}
