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

/// One-line licence credit kept visible on the map; tap for the full text.
class MapCredit extends StatelessWidget {
  const MapCredit({required this.satellite, required this.onTap, super.key});

  final bool satellite;
  final void Function(WidgetBuilder builder) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.map_credits,
      child: InkWell(
        onTap: () => onTap(
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.map_credits, style: ctx.text.title),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.map_baseMapCredit, style: ctx.text.body),
                  if (satellite) Text(l10n.map_satelliteCredit, style: ctx.text.body),
                ],
              ),
            ),
          ),
        ),
        // Touch target ≥ 48 dp while the visible text stays one small line.
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
            color: context.colors.surface.withValues(alpha: 0.7),
            child: Text(
              satellite ? l10n.map_creditShortSat : l10n.map_creditShort,
              style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted),
            ),
          ),
        ),
      ),
    );
  }
}
