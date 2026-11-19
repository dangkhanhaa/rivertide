import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';

/// Shared pieces of the welcome flow (P2-53).

const Duration onbMotion = Duration(milliseconds: 260);

/// One step: title and lead text on top, then the step's content; scrolls
/// when the text is large or the keyboard is up.
class OnbStep extends StatelessWidget {
  const OnbStep({required this.title, required this.body, required this.children, super.key});

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
    children: [
      Semantics(header: true, child: Text(title, style: context.text.headline)),
      const SizedBox(height: AppSpacing.sm),
      Text(body, style: context.text.body.copyWith(color: context.colors.onSurfaceMuted)),
      const SizedBox(height: AppSpacing.xl),
      ...children,
    ],
  );
}

/// A selectable card row: icon, title, hint and a tick. Selection is shown
/// by the tick and the outline, never by colour alone.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
    this.subtitle,
    this.radio = false,
    this.leading,
    super.key,
  });

  final String title;

  /// Replaces the [icon] badge.
  final Widget? leading;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  /// One-of-many (language) instead of many-of-many.
  final bool radio;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = color ?? c.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: radio,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: AnimatedContainer(
              duration: onbMotion,
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: AppSpacing.minTouch + AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Color.alphaBlend(tint.withValues(alpha: 0.10), c.surface)
                    : c.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: selected ? tint : c.onSurface.withValues(alpha: 0.08),
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Row(
                spacing: AppSpacing.md,
                children: [
                  if (leading case final w?)
                    w
                  else if (icon case final i?)
                    IconBadge(icon: i, color: tint),
                  Expanded(
                    child: _Texts(title: title, subtitle: subtitle),
                  ),
                  _Tick(selected: selected, color: tint, radio: radio),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Texts extends StatelessWidget {
  const _Texts({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(title, style: context.text.bodyStrong),
      if (subtitle case final s?) Text(s, style: context.text.caption),
    ],
  );
}

class _Tick extends StatelessWidget {
  const _Tick({required this.selected, required this.color, required this.radio});

  final bool selected;
  final Color color;
  final bool radio;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: onbMotion,
      curve: Curves.easeOutBack,
      width: AppIconSize.md,
      height: AppIconSize.md,
      decoration: BoxDecoration(
        color: color.withValues(alpha: selected ? 1 : 0),
        shape: radio ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radio ? null : BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: selected ? color : c.stale, width: 1.6),
      ),
      child: AnimatedScale(
        duration: onbMotion,
        curve: Curves.easeOutBack,
        scale: selected ? 1 : 0,
        child: Icon(Icons.check_rounded, size: AppIconSize.sm - AppSpacing.xs, color: c.surface),
      ),
    );
  }
}

/// Step dots: the current one stretches into a pill.
class OnbProgress extends StatelessWidget {
  const OnbProgress({required this.step, required this.count, super.key});

  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: context.l10n.onb_progress(step + 1, count),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.sm,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: onbMotion,
              curve: Curves.easeOutCubic,
              width: i == step ? AppSpacing.xl : AppSpacing.sm,
              height: AppSpacing.sm,
              decoration: BoxDecoration(
                color: i <= step ? c.primary : c.primary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small rounded card holding one group on the preferences step.
class OnbCard extends StatelessWidget {
  const OnbCard({required this.icon, required this.title, required this.children, super.key});

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            Row(
              spacing: AppSpacing.sm,
              children: [
                Icon(icon, size: AppIconSize.sm, color: context.colors.primary),
                Expanded(child: Text(title, style: context.text.title)),
              ],
            ),
            ...children,
          ],
        ),
      ),
    ),
  );
}
