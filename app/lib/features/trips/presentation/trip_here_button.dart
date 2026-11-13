import 'package:flutter/material.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/trips/presentation/trip_form_screen.dart';

/// "Rủ đi câu ở đây" on a place sheet; hidden until Supabase is configured.
class TripHereButton extends StatelessWidget {
  const TripHereButton({required this.lat, required this.lon, this.name, super.key});

  final double lat;
  final double lon;
  final String? name;

  @override
  Widget build(BuildContext context) {
    if (!Env.communityEnabled) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TripFormScreen(lat: lat, lon: lon, placeName: name),
        ),
      ),
      icon: const Icon(Icons.groups_2_outlined),
      label: Text(context.l10n.trip_createHere),
    );
  }
}
