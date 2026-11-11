import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Paints [child] at [size] outside the visible screen and returns it as PNG
/// (share cards). Null when the frame could not be captured.
Future<Uint8List?> captureWidget(
  BuildContext context,
  Widget child, {
  required Size size,
  double pixelRatio = 3,
}) async {
  final key = GlobalKey();
  final theme = Theme.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      // Left of the screen: painted (so it can be captured) but never seen.
      left: -size.width - 100,
      top: 0,
      child: RepaintBoundary(
        key: key,
        child: Theme(
          data: theme,
          child: Material(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: SizedBox.fromSize(size: size, child: child),
            ),
          ),
        ),
      ),
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
  try {
    // Two frames: layout/paint, then any image/async content settles.
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    final boundary = key.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  } finally {
    entry.remove();
  }
}
