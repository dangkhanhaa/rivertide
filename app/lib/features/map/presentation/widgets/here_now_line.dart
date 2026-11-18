import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/fish_activity_style.dart';
import 'package:rivertide/features/stations/stations.dart';

/// First thing on the map (P2-32 feedback: "no useful info when the app
/// opens"): fish activity now and the next golden hour at the user's spot.
/// Tap → fishing tab. Hidden until the spot's scores are loaded.
class HereNowLine extends ConsumerWidget {
  const HereNowLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spot = ref.watch(fishingSpotProvider);
    // Only for the user's own position: "quanh bạn" must be true.
    if (!spot.mine) return const SizedBox.shrink();
    final fishing = ref.watch(stationFishingProvider(spot.id)).value;
    final view = ref.watch(stationViewProvider(spot.id)).value;
    if (fishing == null || view == null || fishing.hours.isEmpty) return const SizedBox.shrink();
    final now = view.nowUtc;
    final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
    final current = fishing.hours.firstWhereOrNull((h) => h.hourUtc == hour);
    if (current == null) return const SizedBox.shrink();
    final ahead = fishing.hours.where((h) => !h.hourUtc.isBefore(hour)).take(24).toList();
    final next = goldenWindows(ahead).where((w) => w.endUtc.isAfter(now)).firstOrNull;
    final l10n = context.l10n;
    final c = context.colors;
    final band = fishActivity(current.score);
    final color = context.fishActivityColor(band);
    final golden = next == null
        ? l10n.fishing_noGoldenShort
        : l10n.map_nextGolden(TimeFormat.hm(next.startUtc));
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => context.go(fishingRoute),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.04)],
            ),
          ),
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              Container(
                width: AppSpacing.sm + 2,
                height: AppSpacing.sm + 2,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.map_hereNow, style: context.text.caption),
                    Text(
                      '${context.fishActivityName(band)} · '
                      '${LevelFormat.decimal1(current.score)} · $golden',
                      style: context.text.bodyStrong,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }
}
