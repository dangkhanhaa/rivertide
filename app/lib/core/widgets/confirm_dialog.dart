import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';

/// Yes/no question before something that cannot be undone; false when dismissed.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String ok,
  String? body,
  String? cancel,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: body == null ? null : Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancel ?? ctx.l10n.common_cancel),
          ),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(ok)),
        ],
      ),
    ) ??
    false;
