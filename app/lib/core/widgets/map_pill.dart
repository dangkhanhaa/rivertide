import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// One shortcut on the map: shown as a [MapPill] or as a row in the "⋯" list.
class MapAction {
  const MapAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.detail,
    required this.onTap,
    this.hot = false,
  });

  final IconData icon;
  final Color color;

  /// Short text for the pill.
  final String label;

  /// One line explaining it, in the "⋯" list.
  final String detail;
  final VoidCallback onTap;

  /// Worth a pill of its own on a phone (something is happening).
  final bool hot;
}

/// Small rounded shortcut floating on the map (one look for every shortcut):
/// coloured round icon + short label, 48 dp tall touch area.
class MapPill extends StatelessWidget {
  const MapPill({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    super.key,
  });

  MapPill.of(MapAction a, {super.key})
    : icon = a.icon,
      color = a.color,
      label = a.label,
      onTap = a.onTap;

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
      child: Center(
        widthFactor: 1,
        child: Material(
          color: c.surface,
          elevation: 3,
          shadowColor: c.onSurface.withValues(alpha: 0.3),
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: AppIconSize.sm / 2 + AppSpacing.xs,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, size: AppIconSize.sm - 2, color: color),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(label, style: context.text.label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round white map button (search, "⋯").
class MapRoundButton extends StatelessWidget {
  const MapRoundButton({required this.icon, required this.tooltip, required this.onTap, super.key});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surface,
        elevation: 3,
        shadowColor: c.onSurface.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: AppSpacing.minTouch,
            child: Icon(icon, color: c.primary),
          ),
        ),
      ),
    );
  }
}

/// All shortcuts with a line each (opened from "⋯" on phones).
class MapActionsSheet extends StatelessWidget {
  const MapActionsSheet({
    required this.title,
    required this.actions,
    required this.onPick,
    super.key,
  });

  final String title;
  final List<MapAction> actions;
  final ValueChanged<MapAction> onPick;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.text.title),
          const SizedBox(height: AppSpacing.sm),
          for (final a in actions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: a.color.withValues(alpha: 0.15),
                child: Icon(a.icon, color: a.color),
              ),
              title: Text(a.label, style: context.text.bodyStrong),
              subtitle: Text(a.detail, style: context.text.caption),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onPick(a),
            ),
        ],
      ),
    ),
  );
}
