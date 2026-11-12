import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a fish facing right centred on [c]; [size] is the body length.
void paintFish(Canvas canvas, Offset c, double size, Color color, {Color? eye}) {
  final s = size / 20;
  final paint = Paint()..color = color;
  final body = Rect.fromCenter(center: c + Offset(2.5 * s, 0), width: 15 * s, height: 8.5 * s);
  final tail = Path()
    ..moveTo(c.dx - 4 * s, c.dy)
    ..lineTo(c.dx - 10 * s, c.dy - 4.5 * s)
    ..lineTo(c.dx - 9 * s, c.dy)
    ..lineTo(c.dx - 10 * s, c.dy + 4.5 * s)
    ..close();
  final fin = Path()
    ..moveTo(c.dx, c.dy - 3.5 * s)
    ..quadraticBezierTo(c.dx + 2 * s, c.dy - 7.5 * s, c.dx + 5 * s, c.dy - 3.8 * s)
    ..close();
  canvas
    ..drawPath(fin, paint)
    ..drawOval(body, paint)
    ..drawPath(tail, paint);
  if (eye != null) canvas.drawCircle(c + Offset(7 * s, -1.2 * s), 1.1 * s, Paint()..color = eye);
}

/// One static fish icon (the activity meter).
class FishGlyph extends StatelessWidget {
  const FishGlyph({required this.color, this.size = 22, this.eye, super.key});

  final Color color;
  final Color? eye;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size * 0.6), painter: _GlyphPainter(color, eye));
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.color, this.eye);

  final Color color;
  final Color? eye;

  @override
  void paint(Canvas canvas, Size size) =>
      paintFish(canvas, size.center(Offset.zero), size.width, color, eye: eye);

  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color || old.eye != eye;
}

/// Decorative "underwater" strip: [fishes] silhouettes swim across, livelier
/// for higher [energy] (0–1). Still when the system asks for reduced motion.
/// Purely illustrative; the numbers are in the text around it.
class FishScene extends StatefulWidget {
  const FishScene({
    required this.fishes,
    required this.energy,
    required this.water,
    required this.fish,
    this.height = 92,
    super.key,
  });

  final int fishes;
  final double energy;
  final Color water;
  final Color fish;
  final double height;

  @override
  State<FishScene> createState() => _FishSceneState();
}

class _FishSceneState extends State<FishScene> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _t
        ..stop()
        ..value = 0.3;
    } else if (!_t.isAnimating) {
      _t.repeat();
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: CustomPaint(
        size: Size.fromHeight(widget.height),
        painter: _ScenePainter(_t, widget.fishes, widget.energy, widget.water, widget.fish),
      ),
    ),
  );
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.t, this.fishes, this.energy, this.water, this.fish) : super(repaint: t);

  final Animation<double> t;
  final int fishes;
  final double energy;
  final Color water;
  final Color fish;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(water, fish, 0.18) ?? water, water],
        ).createShader(rect),
    );
    _rays(canvas, size);
    final v = t.value;
    final speed = 1 + 2 * energy;
    for (var i = 0; i < fishes + 2; i++) {
      // Two faint far-away fish behind the counted ones.
      final far = i >= fishes;
      final seed = i * 0.618;
      final phase = (v * speed * (far ? 0.6 : 1) + seed) % 1;
      final x = -30 + phase * (size.width + 60);
      final lane = (0.22 + 0.62 * ((i * 0.37) % 1)) * size.height;
      final y = lane + math.sin((v * 6 + seed) * math.pi * 2) * 3;
      final len = far ? 12.0 : 16 + 6 * ((i * 0.53) % 1);
      final alpha = far ? 0.18 : 0.55 + 0.3 * energy;
      paintFish(canvas, Offset(x, y), len, fish.withValues(alpha: alpha));
    }
    _bubbles(canvas, size, v);
  }

  void _rays(Canvas canvas, Size size) {
    final p = Paint()..color = fish.withValues(alpha: 0.05);
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.2 + 0.3 * i);
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + 26, 0)
          ..lineTo(x + 60, size.height)
          ..lineTo(x + 20, size.height)
          ..close(),
        p,
      );
    }
  }

  void _bubbles(Canvas canvas, Size size, double v) {
    final p = Paint()
      ..color = fish.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final seed = i * 0.29;
      final rise = (v * 3 + seed) % 1;
      final x = size.width * ((0.13 + i * 0.21) % 1) + math.sin(rise * 8) * 3;
      canvas.drawCircle(Offset(x, size.height * (1 - rise)), 1.5 + i % 3, p);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.fishes != fishes || old.energy != energy || old.water != water || old.fish != fish;
}
