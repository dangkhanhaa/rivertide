import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Wind arrow pointing [toDeg] (0 = north, clockwise), drawn already rotated
/// so the map does not need icon rotation.
Future<Uint8List> windArrowPng(double toDeg, Color color, Color halo, double pixelRatio) async {
  const s = 22.0;
  final px = (s * pixelRatio).round();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..scale(px / s)
    ..translate(s / 2, s / 2)
    ..rotate(toDeg * math.pi / 180);
  // Shaft from the tail to the head, then a solid head: reads as "blowing
  // towards" at any size, unlike a notched dart.
  final head = Path()
    ..moveTo(0, -s * 0.46)
    ..lineTo(s * 0.24, -s * 0.06)
    ..lineTo(-s * 0.24, -s * 0.06)
    ..close();
  final shaft = Path()
    ..moveTo(0, s * 0.44)
    ..lineTo(0, -s * 0.1);
  final under = Paint()
    ..color = halo
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  canvas
    ..drawPath(shaft, under)
    ..drawPath(head, under)
    ..drawPath(
      shaft,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    )
    ..drawPath(
      head,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  final image = await recorder.endRecording().toImage(px, px);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('png encode failed');
    return data.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
