import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

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
