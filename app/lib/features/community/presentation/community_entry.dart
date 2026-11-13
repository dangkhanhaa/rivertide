import 'package:flutter/material.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/community/presentation/publish_spot_screen.dart';

/// "Ghim công khai" on a place sheet; hidden until Supabase is configured.
class PinPublicButton extends StatelessWidget {
  const PinPublicButton({required this.lat, required this.lon, this.name, super.key});

  final double lat;
  final double lon;
  final String? name;

  @override
  Widget build(BuildContext context) {
    if (!Env.communityEnabled) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PublishSpotScreen(lat: lat, lon: lon, suggestedName: name),
        ),
      ),
      icon: const Icon(Icons.push_pin_outlined),
      label: Text(context.l10n.spot_pinAction),
    );
  }
}
