import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Chỉ đường": hands the destination to Google Maps (official Maps URLs, no
/// key), which does the turn-by-turn route from wherever the user is. Free
/// routing services that allow commercial use without a key do not exist.
class DirectionsButton extends StatelessWidget {
  const DirectionsButton({required this.lat, required this.lon, super.key});

  final double lat;
  final double lon;

  /// https://developers.google.com/maps/documentation/urls/get-started
  static Uri directionsUri(double lat, double lon) => Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${lat.toStringAsFixed(6)},${lon.toStringAsFixed(6)}',
  });

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
    onPressed: () => unawaited(_open(context)),
    icon: const Icon(Icons.directions_rounded),
    label: Text(context.l10n.directions_action),
  );

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.directions_failed;
    final ok = await launchUrl(directionsUri(lat, lon), mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
}
