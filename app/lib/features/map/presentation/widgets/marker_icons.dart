import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';

/// Logical size of the trend glyph drawn on top of a station dot.
const double _size = 14;

/// PNG of the trend arrow (▲ rising, ▼ falling, – slack, nothing when unknown),
/// so trend is not shown by colour alone (CLAUDE.md 3.4).
Future<Uint8List> arrowPng(MarkerTrend trend, Color color, double pixelRatio) async {
  final px = (_size * pixelRatio).round();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(px / _size);
  final paint = Paint()
    ..color = color
    ..isAntiAlias = true;
  const s = _size;
  switch (trend) {
    case MarkerTrend.rising:
      canvas.drawPath(
        Path()
          ..moveTo(s / 2, s * 0.18)
          ..lineTo(s * 0.86, s * 0.78)
          ..lineTo(s * 0.14, s * 0.78)
          ..close(),
        paint,
      );
    case MarkerTrend.falling:
      canvas.drawPath(
        Path()
          ..moveTo(s * 0.14, s * 0.22)
          ..lineTo(s * 0.86, s * 0.22)
          ..lineTo(s / 2, s * 0.82)
          ..close(),
        paint,
      );
    case MarkerTrend.slack:
      canvas.drawRRect(
        RRect.fromLTRBR(s * 0.18, s * 0.42, s * 0.82, s * 0.58, const Radius.circular(1)),
        paint,
      );
    case MarkerTrend.unknown:
      break;
  }
  final image = await recorder.endRecording().toImage(px, px);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('png encode failed');
    return data.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
