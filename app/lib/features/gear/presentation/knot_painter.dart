import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rivertide/features/gear/domain/gear_data.dart';

/// Schematic of a finished knot (P2-38): what it is tied to (hook eye,
/// another line, a loop), the wraps around the standing line and the tag
/// end. A memory aid next to the written steps, not a photo.
class KnotPainter extends CustomPainter {
  KnotPainter({required this.knot, required this.line, required this.metal, required this.accent});

  final Knot knot;
  final Color line;
  final Color metal;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    switch (knot.target) {
      case KnotTarget.hookEye:
        _hookEye(canvas, size, cy, stroke);
      case KnotTarget.lineToLine:
        _lineToLine(canvas, size, cy, stroke);
      case KnotTarget.loop:
        _loop(canvas, size, cy, stroke);
    }
  }

  void _hookEye(Canvas canvas, Size size, double cy, Paint stroke) {
    final eye = Offset(size.width * 0.2, cy - 8);
    final metalPaint = Paint()
      ..color = metal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas
      // Hook shank going left from the eye, then the bend.
      ..drawCircle(eye, 10, metalPaint)
      ..drawLine(eye.translate(-10, 0), Offset(eye.dx - 40, cy), metalPaint)
      ..drawArc(
        Rect.fromCircle(center: Offset(eye.dx - 40, cy + 18), radius: 18),
        math.pi / 2,
        math.pi,
        false,
        metalPaint,
      );
    final start = eye.dx + 18;
    final end = size.width * 0.92;
    _standing(canvas, start, end, cy, stroke);
    _coils(canvas, start + 8, start + 8 + knot.turns * 11, cy, stroke);
    // Tag end tucked back through.
    final tag = Path()
      ..moveTo(eye.dx + 10, cy)
      ..quadraticBezierTo(start + 4, cy - 26, start + 8 + knot.turns * 11 + 10, cy - 18);
    canvas.drawPath(tag, stroke..color = accent);
  }

  void _lineToLine(Canvas canvas, Size size, double cy, Paint stroke) {
    final mid = size.width / 2;
    _standing(canvas, size.width * 0.06, mid + 30, cy - 5, stroke);
    _standing(canvas, mid - 30, size.width * 0.94, cy + 5, Paint.from(stroke)..color = accent);
    _coils(canvas, mid - 30 - knot.turns * 10, mid - 30, cy, stroke);
    _coils(canvas, mid + 30, mid + 30 + knot.turns * 10, cy, Paint.from(stroke)..color = accent);
  }

  void _loop(Canvas canvas, Size size, double cy, Paint stroke) {
    final left = size.width * 0.1;
    final loop = Path()
      ..moveTo(left + 70, cy - 4)
      ..cubicTo(left - 10, cy - 46, left - 10, cy + 46, left + 70, cy + 4);
    canvas.drawPath(loop, stroke);
    _standing(canvas, left + 70, size.width * 0.92, cy, stroke);
    _coils(canvas, left + 64, left + 92, cy, Paint.from(stroke)..color = accent);
  }

  void _standing(Canvas canvas, double from, double to, double y, Paint p) {
    canvas.drawLine(Offset(from, y), Offset(to, y), p);
    if (knot.doubled) canvas.drawLine(Offset(from, y + 6), Offset(to, y + 6), p);
  }

  /// Wraps drawn as narrow ellipses across the standing line.
  void _coils(Canvas canvas, double from, double to, double y, Paint p) {
    final n = knot.turns.clamp(1, 8);
    final step = (to - from) / n;
    for (var i = 0; i < n; i++) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(from + step * (i + 0.5), y), width: step * 0.8, height: 22),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(KnotPainter old) =>
      old.knot != knot || old.line != line || old.metal != metal || old.accent != accent;
}
