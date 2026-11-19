import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

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

/// Licence line in the map corner (P2-46: tiny, bottom right, OSM only).
/// Not a button: the full credits are in More → Nguồn dữ liệu.
class MapCredit extends StatelessWidget {
  const MapCredit({required this.satellite, super.key});

  final bool satellite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        color: context.colors.surface.withValues(alpha: 0.6),
        child: Text(
          satellite ? l10n.map_creditShortSat : l10n.map_creditShort,
          // Fixed size: a licence line, not reading text.
          textScaler: TextScaler.noScaling,
          style: context.text.caption.copyWith(
            fontSize: creditFontSize,
            height: 1.2,
            color: context.colors.onSurfaceMuted,
          ),
        ),
      ),
    );
  }
}
