import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/widgets/map_pill.dart';
import 'package:rivertide/features/community/application/community_providers.dart';
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

/// "5 điểm cộng đồng" beside "Hôm nay đi đâu?" under the search bar; nothing when none.
class NearbySpotsChip extends ConsumerWidget {
  const NearbySpotsChip({required this.areaKey, required this.onTap, super.key});

  final String? areaKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = areaKey;
    if (!Env.communityEnabled || key == null) return const SizedBox.shrink();
    final count = ref.watch(nearbySpotsProvider(key)).value?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();
    return MapPill(
      icon: Icons.groups_rounded,
      color: context.colors.spot,
      label: context.l10n.spot_nearbyChip(count),
      onTap: onTap,
    );
  }
}
