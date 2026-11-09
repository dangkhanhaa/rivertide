import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';

class MapInlineError extends StatelessWidget {
  const MapInlineError({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.error_outline_rounded),
      title: Text(context.l10n.map_stationsError),
      trailing: TextButton(onPressed: onRetry, child: Text(context.l10n.common_retry)),
    ),
  );
}

class MapNote extends StatelessWidget {
  const MapNote({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: Text(text)),
  );
}
