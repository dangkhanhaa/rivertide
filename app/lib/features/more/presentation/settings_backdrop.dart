import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/more/presentation/settings_pickers.dart';

/// Backdrops as tiny phone mock-ups: page colour, a card and an accent bar.
class BackdropPicker extends StatelessWidget {
  const BackdropPicker({
    required this.value,
    required this.accent,
    required this.dark,
    required this.onPick,
    super.key,
  });

  final AppBackdrop value;
  final Color accent;
  final bool dark;
  final ValueChanged<AppBackdrop> onPick;

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: AppSpacing.sm,
    crossAxisSpacing: AppSpacing.sm,
    childAspectRatio: 1.6,
    children: [
      for (final b in AppBackdrop.values)
        _BackdropTile(
          colors: backdropColors(b, accent, dark: dark),
          accent: accent,
          label: context.backdropName(b),
          selected: b == value,
          onTap: () => onPick(b),
        ),
    ],
  );
}

class _BackdropTile extends StatelessWidget {
  const _BackdropTile({
    required this.colors,
    required this.accent,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ({Color page, Color card}) colors;
  final Color accent;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Mock-ups show the other mode too, so take that palette's text colour.
    final ink = dark(colors.page) ? AppColors.dark.onSurface : AppColors.light.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.page,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? accent : c.stale.withValues(alpha: 0.35),
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: AppSpacing.md,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accent, accentPartner(accent)]),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: context.text.caption.copyWith(color: ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: accent, size: AppIconSize.sm),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool dark(Color c) => c.computeLuminance() < 0.2;
}
