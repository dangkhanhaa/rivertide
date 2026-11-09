import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/geo/vietnam_bounds.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/map/domain/location_service.dart';

/// "◎" button flow (F-MAP-04): explain → ask → locate; every refusal ends in a
/// message, and a permanent refusal points to the system settings (AC-MAP04-3).
Future<({double lat, double lon})?> runLocateFlow(
  BuildContext context,
  LocationService source,
) async {
  if (!await source.hasPermission()) {
    if (!context.mounted) return null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.map_locRationaleTitle),
        content: Text(ctx.l10n.map_locRationaleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.map_later),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.l10n.map_locAllow),
          ),
        ],
      ),
    );
    if (ok != true) return null;
  }
  final result = await source.locate();
  if (!context.mounted) return null;
  final l10n = context.l10n;
  void snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  switch (result) {
    case Located(:final lat, :final lon):
      if (!isInVietnamBounds(lat, lon)) snack(l10n.map_outsideVn);
      return (lat: lat, lon: lon);
    case LocationServiceOff():
      snack(l10n.map_locServiceOff);
    case LocationDenied(forever: false):
      snack(l10n.map_locDenied);
    case LocationDenied(forever: true):
      await _showSettingsDialog(context, source);
    case LocationFailed():
      snack(l10n.map_locFailed);
  }
  return null;
}

Future<void> _showSettingsDialog(BuildContext context, LocationService source) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(ctx.l10n.map_locDeniedForeverTitle),
    content: Text(ctx.l10n.map_locDeniedForeverBody),
    actions: [
      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(ctx.l10n.map_close)),
      FilledButton(
        onPressed: () {
          Navigator.of(ctx).pop();
          unawaited(source.openSettings());
        },
        child: Text(ctx.l10n.map_openSettings),
      ),
    ],
  ),
);
