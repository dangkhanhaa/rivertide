import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/features/community/application/community_providers.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';

/// "Điểm câu gần đây": community spots around the area, nearest first.
class NearbySpotsSheet extends ConsumerWidget {
  const NearbySpotsSheet({required this.areaKey, required this.onOpen, super.key});

  /// From [nearbyKey] of the map centre or the user's position.
  final String areaKey;
  final ValueChanged<PublicSpot> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      child: AsyncValueView(
        value: ref.watch(nearbySpotsProvider(areaKey)),
        onRetry: () => ref.invalidate(nearbySpotsProvider(areaKey)),
        isEmpty: (s) => s.isEmpty,
        emptyMessage: l10n.spot_nearbyEmpty,
        data: (spots) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          children: [
            Text(l10n.spot_nearbyTitle, style: context.text.title),
            const SizedBox(height: AppSpacing.sm),
            for (final s in spots) _SpotTile(spot: s, onTap: () => onOpen(s)),
          ],
        ),
      ),
    );
  }
}

class _SpotTile extends StatelessWidget {
  const _SpotTile({required this.spot, required this.onTap});

  final PublicSpot spot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final km = spot.distanceKm;
    const thumb = AppSpacing.xxl * 2;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            spacing: AppSpacing.md,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox.square(
                  dimension: thumb,
                  child: spot.photoUrls.isEmpty
                      ? ColoredBox(
                          color: c.fishHigh.withValues(alpha: 0.15),
                          child: Icon(Icons.phishing_rounded, color: c.fishHigh),
                        )
                      : Image.network(
                          spot.photoUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Icon(Icons.phishing_rounded, color: c.fishHigh),
                        ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spot.title, style: context.text.bodyStrong, maxLines: 2),
                    if (spot.species.isNotEmpty)
                      Text(spot.species, style: context.text.body, maxLines: 1),
                    if (km != null)
                      Text(
                        context.l10n.spot_distance(LevelFormat.km(km)),
                        style: context.text.caption,
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.stale),
            ],
          ),
        ),
      ),
    );
  }
}
