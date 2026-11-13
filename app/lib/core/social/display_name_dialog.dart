import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// Asks for the name shown on comments, trips and chat; saves it on the device.
Future<void> editDisplayName(BuildContext context, WidgetRef ref) async {
  final current = await ref.read(displayNameProvider.future);
  if (!context.mounted) return;
  final controller = TextEditingController(text: current);
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.l10n.name_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: displayNameMax,
            decoration: InputDecoration(hintText: ctx.l10n.name_hint),
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          Text(ctx.l10n.name_note, style: ctx.text.caption),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(ctx.l10n.common_cancel)),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text),
          child: Text(ctx.l10n.social_save),
        ),
      ],
    ),
  );
  controller.dispose();
  if (name != null) await ref.read(displayNameProvider.notifier).save(name);
}
