import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/core/widgets/floating_nav_painter.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';

typedef NavItem = ({IconData icon, IconData selectedIcon, String label});

/// Floating bottom bar (P2-41/P2-42). One painter draws the bar and its
/// indicator, which slides between tabs on a single animation, so switching
/// costs one repaint of a small layer. Every item keeps its label and a
/// 48 dp target; colour and position are never the only cue.
class FloatingNavBar extends StatefulWidget {
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

  /// Bar height, plus room above it for the notch button.
  static const double barHeight = 64;
  static const double rise = 22;

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _pos = AnimationController(
    vsync: this,
    upperBound: (widget.items.length - 1).toDouble(),
    value: widget.index.toDouble(),
  );

  @override
  void didUpdateWidget(FloatingNavBar old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    final reduce = MediaQuery.disableAnimationsOf(context);
    _pos.animateTo(
      widget.index.toDouble(),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final palette = (
      bar: widget.style == NavStyle.glass
          ? c.surface.withValues(alpha: dark ? 0.55 : 0.68)
          : c.surface,
      accent: c.primary,
      accent2: accentPartner(c.primary),
      shadow: c.onSurface.withValues(alpha: dark ? 0.5 : 0.18),
      edge: dark ? c.onSurface.withValues(alpha: 0.12) : c.surface.withValues(alpha: 0.9),
    );
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: SizedBox(
          height: FloatingNavBar.barHeight + FloatingNavBar.rise,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: NavBarPainter(
                style: widget.style,
                position: _pos,
                count: widget.items.length,
                palette: palette,
                top: FloatingNavBar.rise,
              ),
              child: Stack(
                children: [
                  if (widget.style == NavStyle.notch) _floatingButton(context, palette),
                  Positioned.fill(
                    top: FloatingNavBar.rise,
                    child: Row(
                      children: [
                        for (final (i, item) in widget.items.indexed)
                          Expanded(
                            child: _NavButton(
                              item: item,
                              selected: i == widget.index,
                              hideIcon: widget.style == NavStyle.notch && i == widget.index,
                              onTap: () => widget.onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The round button riding in the notch, sliding with the indicator.
  Widget _floatingButton(BuildContext context, NavPalette p) => AnimatedBuilder(
    animation: _pos,
    builder: (context, _) => LayoutBuilder(
      builder: (context, box) {
        final slot = box.maxWidth / widget.items.length;
        final cx = slot * (_pos.value + 0.5);
        final item = widget.items[widget.index];
        return Stack(
          children: [
            Positioned(
              left: cx - notchButton / 2,
              top: 0,
              width: notchButton,
              height: notchButton,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [p.accent, p.accent2],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: p.accent.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(item.selectedIcon, color: context.colors.surface),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.hideIcon,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;

  /// Notch style: the floating button shows the icon instead.
  final bool hideIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.primary : c.onSurfaceMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            Opacity(
              opacity: hideIcon ? 0 : 1,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: AppIconSize.md,
                color: color,
              ),
            ),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
