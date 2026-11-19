import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';

typedef NavItem = ({IconData icon, IconData selectedIcon, String label});

/// Floating, rounded bottom bar (P2-41) in three looks the user picks in
/// Settings. Every item keeps a 48 dp target and its label, so colour and
/// position are never the only cue.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    required this.items,
    required this.index,
    required this.onTap,
    required this.style,
    super.key,
  });

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onTap;
  final NavStyle style;

  static const double barHeight = 66;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final glow = style == NavStyle.glow;
    final bg = glow ? c.deepWater : c.surface;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.xl + AppSpacing.xs),
            boxShadow: [
              BoxShadow(
                color: (glow ? c.primary : c.onSurface).withValues(alpha: glow ? 0.25 : 0.10),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              for (final (i, item) in items.indexed)
                Expanded(
                  child: _NavButton(
                    item: item,
                    selected: i == index,
                    style: style,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final NavStyle style;
  final VoidCallback onTap;

  static const Duration _anim = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final glow = style == NavStyle.glow;
    final idle = glow ? c.surface.withValues(alpha: 0.6) : c.onSurfaceMuted;
    final active = glow ? c.primary : c.primary;
    final bubble = style == NavStyle.bubble && selected;
    final duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : _anim;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutBack,
              width: bubble ? 50 : 40,
              height: bubble ? 50 : 32,
              transform: Matrix4.translationValues(0, bubble ? -20 : 0, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: bubble
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [c.primary, accentPartner(c.primary)],
                      )
                    : null,
                boxShadow: bubble || (glow && selected)
                    ? [
                        BoxShadow(
                          color: c.primary.withValues(alpha: 0.45),
                          blurRadius: glow ? 18 : 14,
                          offset: Offset(0, glow ? 0 : 6),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: AppIconSize.md,
                color: bubble ? c.surface : (selected ? active : idle),
              ),
            ),
            if (style == NavStyle.dot)
              AnimatedOpacity(
                duration: duration,
                opacity: selected ? 1 : 0,
                child: Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(color: active, shape: BoxShape.circle),
                ),
              ),
            AnimatedDefaultTextStyle(
              duration: duration,
              style: context.text.caption.copyWith(
                color: selected ? (bubble ? c.primary : active) : idle,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Transform.translate(
                offset: Offset(0, bubble ? -12 : 0),
                child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
