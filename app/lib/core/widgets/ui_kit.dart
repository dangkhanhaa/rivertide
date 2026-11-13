import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// Shared building blocks of the app's look: hero headers, section titles,
/// coloured icon badges, quick-action tiles and list rows. Screens use these
/// instead of styling by hand, so every tab feels like one app.

/// Coloured round icon (soft tint background).
class IconBadge extends StatelessWidget {
  const IconBadge({required this.icon, required this.color, this.size = 40, super.key});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(size * 0.32),
    ),
    alignment: Alignment.center,
    child: Icon(icon, color: color, size: size * 0.55),
  );
}

/// Big gradient card at the top of a tab: title, subtitle and any content.
class HeroPanel extends StatelessWidget {
  const HeroPanel({required this.child, this.colors, super.key});

  final Widget child;

  /// Gradient stops; defaults to primary → fish green.
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [c.primary, c.fishGood],
        ),
        boxShadow: [
          BoxShadow(
            color: (colors?.first ?? c.primary).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: c.surface),
        child: IconTheme.merge(
          data: IconThemeData(color: c.surface),
          child: child,
        ),
      ),
    );
  }
}

/// Section title with an optional action on the right.
class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.icon, this.action, super.key});

  final String title;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
    child: Row(
      children: [
        if (icon case final i?) ...[
          Icon(i, size: AppIconSize.sm, color: context.colors.primary),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(child: Text(title, style: context.text.title)),
        ?action,
      ],
    ),
  );
}

/// One square-ish shortcut in a grid: coloured icon over a short label.
class QuickAction extends StatelessWidget {
  const QuickAction({
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
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm,
          children: [
            IconBadge(icon: icon, color: color, size: 44),
            Text(
              label,
              style: context.text.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Row of [QuickAction]s that share the width evenly.
class QuickActionRow extends StatelessWidget {
  const QuickActionRow({required this.actions, super.key});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [for (final a in actions) Expanded(child: a)],
    ),
  );
}

/// Settings-style row: icon badge, title, subtitle, chevron or trailing.
class ActionRow extends StatelessWidget {
  const ActionRow({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadius.md),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouch + AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            IconBadge(icon: icon, color: color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: context.text.bodyStrong),
                  if (subtitle case final s?) Text(s, style: context.text.caption),
                ],
              ),
            ),
            trailing ??
                (onTap == null
                    ? const SizedBox.shrink()
                    : Icon(Icons.chevron_right_rounded, color: context.colors.stale)),
          ],
        ),
      ),
    ),
  );
}

/// A card holding [ActionRow]s separated by thin lines.
class ActionGroup extends StatelessWidget {
  const ActionGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0)
            Divider(
              height: 1,
              indent: AppSpacing.xxl * 2,
              color: context.colors.stale.withValues(alpha: 0.2),
            ),
          c,
        ],
      ],
    ),
  );
}
