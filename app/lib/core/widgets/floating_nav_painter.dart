import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/appearance.dart';

/// Size of the round notch button.
const double notchButton = 52;

typedef NavPalette = ({Color bar, Color accent, Color accent2, Color shadow, Color edge});

/// Bar shape and the sliding indicator for every [NavStyle]. [position] is
/// the animated tab index (fractional while sliding).
class NavBarPainter extends CustomPainter {
  NavBarPainter({
    required this.style,
    required this.position,
    required this.count,
    required this.palette,
    required this.top,
  }) : super(repaint: position);

  final NavStyle style;
  final Animation<double> position;
  final int count;
  final NavPalette palette;

  /// Space above the bar (for the notch button).
  final double top;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = Rect.fromLTWH(0, top, size.width, size.height - top);
    final r = Radius.circular(bar.height / 2);
    final slot = size.width / count;
    final cx = slot * (position.value + 0.5);
    final shape = style == NavStyle.notch
        ? _notched(bar, r, cx)
        : (Path()..addRRect(RRect.fromRectAndRadius(bar, r)));
    canvas
      ..drawShadow(shape, palette.shadow, 12, false)
      ..drawPath(shape, Paint()..color = palette.bar);
    switch (style) {
      case NavStyle.arc:
        _arc(canvas, bar, cx, slot);
      case NavStyle.glass:
        _glass(canvas, bar, r, cx, slot);
      case NavStyle.dot:
        canvas.drawCircle(Offset(cx, bar.top + 7), 2.6, Paint()..color = palette.accent);
      case NavStyle.notch:
        canvas.drawPath(
          shape,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = palette.edge,
        );
    }
  }

  /// Bar with a round bite out of its top edge around the current tab.
  Path _notched(Rect bar, Radius r, double cx) {
    final body = Path()..addRRect(RRect.fromRectAndRadius(bar, r));
    final bite = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, top + 4), radius: notchButton / 2 + 6));
    return Path.combine(PathOperation.difference, body, bite);
  }

  /// A glowing line along the bottom that arcs over the current tab.
  void _arc(Canvas canvas, Rect bar, double cx, double slot) {
    final y = bar.bottom - 2;
    final peak = bar.top + 6;
    // The line stays inside the pill; near the ends the arc narrows so it
    // always lands back on the line instead of being cut off.
    final left = bar.left + bar.height * 0.42;
    final right = bar.right - bar.height * 0.42;
    final hw = math.max(AppSpacing.lg, math.min(slot * 0.6, math.min(cx - left, right - cx)));
    final from = cx - hw;
    final to = cx + hw;
    final path = Path()
      ..moveTo(left, y)
      ..lineTo(from, y)
      ..cubicTo(cx - hw * 0.45, y, cx - hw * 0.55, peak, cx, peak)
      ..cubicTo(cx + hw * 0.55, peak, cx + hw * 0.45, y, to, y)
      ..lineTo(right, y);
    final under = Path.from(path)
      ..lineTo(right, y)
      ..lineTo(left, y)
      ..close();
    canvas
      ..drawPath(
        under,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.accent.withValues(alpha: 0.16), palette.accent.withValues(alpha: 0)],
          ).createShader(Rect.fromLTRB(cx - hw, peak, cx + hw, y)),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = palette.accent.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(colors: [palette.accent, palette.accent2]).createShader(bar),
      );
  }

  /// Frosted look: a light top sheen, a bright edge and a soft pill behind
  /// the current tab.
  void _glass(Canvas canvas, Rect bar, Radius r, double cx, double slot) {
    final rr = RRect.fromRectAndRadius(bar, r);
    canvas
      ..drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.edge.withValues(alpha: 0.35), palette.edge.withValues(alpha: 0)],
          ).createShader(bar),
      )
      ..drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = palette.edge,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, bar.center.dy),
            width: slot - AppSpacing.sm,
            height: bar.height - AppSpacing.md,
          ),
          Radius.circular(bar.height / 2),
        ),
        Paint()..color = palette.accent.withValues(alpha: 0.14),
      );
  }

  @override
  bool shouldRepaint(NavBarPainter old) =>
      old.style != style || old.count != count || old.palette != palette || old.top != top;
}
