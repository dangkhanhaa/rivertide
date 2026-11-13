import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';

/// Logical size of a pin image; the tip sits at the bottom centre.
const double _w = 46;
const double _h = 56;
const double _r = 15;

/// Head centre of the drop; the tip is at (_w / 2, _h - 3).
const Offset _head = Offset(_w / 2, 20);

typedef FishPinStyle = ({Color fill, Color ink, Color shadow, bool glow});

/// What is drawn inside the drop.
enum PinGlyph { fish, people }

/// Drop-shaped pin with two fish (one when [fishes] is 1), an optional glow
/// and a trend badge, drawn once per style so the map only swaps images.
Future<Uint8List> fishPinPng(
  FishPinStyle style,
  MarkerTrend trend,
  double pixelRatio, {
  int fishes = 2,
  bool star = false,
  PinGlyph glyph = PinGlyph.fish,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  final drop = _dropPath();
  if (style.glow) {
    canvas.drawPath(
      drop,
      Paint()
        ..color = style.fill.withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }
  canvas
    ..drawPath(
      drop.shift(const Offset(0, 1.5)),
      Paint()
        ..color = style.shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    )
    ..drawPath(
      drop,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, _head.dy - _r), const Offset(0, _h), [
          Color.lerp(style.fill, style.ink, 0.25) ?? style.fill,
          style.fill,
        ]),
    )
    ..drawPath(
      drop,
      Paint()
        ..color = style.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  _inside(canvas, style, glyph, fishes: fishes, strong: star);
  if (star) _starBadge(canvas, style);
  _trendBadge(canvas, trend, style);
  return await _encode(recorder, pixelRatio);
}

void _inside(
  Canvas canvas,
  FishPinStyle style,
  PinGlyph glyph, {
  required int fishes,
  required bool strong,
}) {
  if (glyph == PinGlyph.people) return _people(canvas, style.ink);
  if (fishes >= 2) {
    _fish(canvas, _head + const Offset(-1, -5), 0.9, style.ink, style.fill);
    _fish(canvas, _head + const Offset(1, 5), 0.9, style.ink, style.fill);
  } else {
    _fish(canvas, _head, 1.15, style.ink.withValues(alpha: strong ? 1 : 0.7), style.fill);
  }
}

/// Two people side by side: a group trip ("kèo câu").
void _people(Canvas canvas, Color ink) {
  final p = Paint()..color = ink;
  for (final (dx, scale) in [(-4.5, 0.85), (4.5, 1.0)]) {
    final c = _head + Offset(dx, 0);
    canvas
      ..drawCircle(c + Offset(0, -4.5 * scale), 3.2 * scale, p)
      ..drawPath(
        Path()
          ..addArc(
            Rect.fromCenter(
              center: c + Offset(0, 6 * scale),
              width: 11 * scale,
              height: 10 * scale,
            ),
            math.pi,
            math.pi,
          )
          ..close(),
        p,
      );
  }
}

Path _dropPath() {
  const tip = Offset(_w / 2, _h - 3);
  // Tangent points where the sides leave the circle towards the tip.
  final d = tip.dy - _head.dy;
  final a = math.acos(_r / d);
  final left = Offset(_head.dx - _r * math.sin(a), _head.dy + _r * math.cos(a));
  final start = math.pi / 2 + a;
  return Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(left.dx, left.dy)
    ..arcTo(Rect.fromCircle(center: _head, radius: _r), start, 2 * math.pi - 2 * a, false)
    ..close();
}

/// A fish facing right: body, tail and an eye punched in the pin colour.
void _fish(Canvas canvas, Offset c, double scale, Color ink, Color eye) {
  final s = scale;
  final paint = Paint()..color = ink;
  final body = Rect.fromCenter(center: c + Offset(2 * s, 0), width: 15 * s, height: 8 * s);
  final tail = Path()
    ..moveTo(c.dx - 4 * s, c.dy)
    ..lineTo(c.dx - 9.5 * s, c.dy - 4 * s)
    ..lineTo(c.dx - 9.5 * s, c.dy + 4 * s)
    ..close();
  canvas
    ..drawOval(body, paint)
    ..drawPath(tail, paint)
    ..drawCircle(c + Offset(6.2 * s, -1 * s), 1.1 * s, Paint()..color = eye);
}

void _trendBadge(Canvas canvas, MarkerTrend trend, FishPinStyle style) {
  if (trend == MarkerTrend.unknown) return;
  const c = Offset(_w - 9, 9);
  canvas
    ..drawCircle(c, 7.5, Paint()..color = style.ink)
    ..drawCircle(
      c,
      7.5,
      Paint()
        ..color = style.fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  final p = Paint()..color = style.fill;
  switch (trend) {
    case MarkerTrend.rising:
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - 4)
          ..lineTo(c.dx + 4, c.dy + 3)
          ..lineTo(c.dx - 4, c.dy + 3)
          ..close(),
        p,
      );
    case MarkerTrend.falling:
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - 4, c.dy - 3)
          ..lineTo(c.dx + 4, c.dy - 3)
          ..lineTo(c.dx, c.dy + 4)
          ..close(),
        p,
      );
    case MarkerTrend.slack:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: 8, height: 2.5),
          const Radius.circular(1),
        ),
        p,
      );
    case MarkerTrend.unknown:
      break;
  }
}

/// Five-point star: marks a spot shared by the community.
void _starBadge(Canvas canvas, FishPinStyle style) {
  const c = Offset(_w - 9, 9);
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? 6.5 : 2.8;
    final a = -math.pi / 2 + i * math.pi / 5;
    final p = c + Offset(r * math.cos(a), r * math.sin(a));
    if (i == 0) {
      star.moveTo(p.dx, p.dy);
    } else {
      star.lineTo(p.dx, p.dy);
    }
  }
  star.close();
  canvas
    ..drawCircle(c, 8, Paint()..color = style.ink)
    ..drawPath(star, Paint()..color = style.fill);
}

Future<Uint8List> _encode(ui.PictureRecorder recorder, double ratio) async {
  final image = await recorder.endRecording().toImage((_w * ratio).round(), (_h * ratio).round());
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('png encode failed');
    return data.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
