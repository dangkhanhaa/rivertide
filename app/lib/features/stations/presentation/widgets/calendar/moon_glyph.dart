import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/theme/app_colors.dart';

/// The moon disc with its lit part, drawn from the computed illumination
/// (no emoji: web fonts do not always have them).
class MoonGlyph extends StatelessWidget {
  const MoonGlyph({required this.moon, required this.size, super.key});

  final MoonIllumination moon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomPaint(
      size: Size.square(size),
      painter: _MoonPainter(
        phase: moon.phase,
        lit: c.alarm1,
        dark: c.stale.withValues(alpha: 0.35),
        rim: c.onSurfaceMuted.withValues(alpha: 0.6),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  _MoonPainter({required this.phase, required this.lit, required this.dark, required this.rim});

  /// 0 new → 0.5 full → 1 new.
  final double phase;
  final Color lit;
  final Color dark;
  final Color rim;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final centre = size.center(Offset.zero);
    final disc = Rect.fromCircle(center: centre, radius: r);
    canvas.drawOval(disc, Paint()..color = dark);
    // Terminator ellipse half-width: r at new/full, 0 at the quarters.
    final k = math.cos(2 * math.pi * phase); // 1 new, -1 full
    final waxing = phase < 0.5; // lit on the right (as seen from the north)
    final half = Path()..addArc(disc, -math.pi / 2, waxing ? math.pi : -math.pi);
    final w = (r * k).abs();
    final ellipse = Rect.fromCenter(center: centre, width: 2 * w, height: 2 * r);
    final litPath = k > 0
        // Crescent: lit half minus the terminator ellipse.
        ? Path.combine(PathOperation.difference, half, Path()..addOval(ellipse))
        // Gibbous: lit half plus the terminator ellipse.
        : Path.combine(PathOperation.union, half, Path()..addOval(ellipse));
    canvas
      ..drawPath(litPath, Paint()..color = lit)
      ..drawOval(
        disc,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = rim,
      );
  }

  @override
  bool shouldRepaint(_MoonPainter old) =>
      old.phase != phase || old.lit != lit || old.dark != dark || old.rim != rim;
}
