import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';
import 'package:rivertide/features/fishing/presentation/widgets/spot_card.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Top of the fishing tab: where, today's score in big, the next golden window.
class FishingHero extends ConsumerWidget {
  const FishingHero({required this.today, required this.hasWarning, super.key});

  /// The 24 hours of today at the chosen spot (empty while loading).
  final List<FishingHourScore> today;
  final bool hasWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final spot = ref.watch(fishingSpotProvider);
    final station = ref.watch(stationByIdProvider(spot.id)).value;
    final isPoint = spot.id.startsWith(PointId.prefix);
    final name = !isPoint ? station?.name ?? '' : (spot.mine ? l10n.spot_mine : l10n.spot_point);
    final where = station == null ? null : adminLine(ref, station.lat, station.lon);
    final now = ref.watch(clockProvider)();
    final next = goldenWindows(today).where((w) => w.endUtc.isAfter(now)).firstOrNull;
    final score = today.isEmpty ? null : dayScore(today);
    final moon = moonIllumination(now);
    final white = c.surface;
    final accent = score == null
        ? c.primary
        : Color.lerp(c.primary, context.scoreColor(score), 0.7) ?? c.primary;
    return HeroPanel(
      colors: [c.primary, accent],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          Row(
            children: [
              Icon(Icons.place_rounded, color: white, size: AppIconSize.sm),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.text.title.copyWith(color: white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (where != null)
                      Text(
                        where,
                        style: context.text.caption.copyWith(color: white.withValues(alpha: 0.85)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: white.withValues(alpha: 0.2),
                  foregroundColor: white,
                ),
                onPressed: () => unawaited(
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const Padding(
                      padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                      child: SpotCard(),
                    ),
                  ),
                ),
                child: Text(l10n.fishing_changeSpot),
              ),
            ],
          ),
          Row(
            children: [
              _ScoreRing(score: score),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      l10n.fishing_dayScore,
                      style: context.text.label.copyWith(color: white.withValues(alpha: 0.85)),
                    ),
                    Text(
                      score == null ? '—' : context.scoreLabel(score).toUpperCase(),
                      style: context.text.headline.copyWith(color: white),
                    ),
                    Text(
                      next == null
                          ? l10n.fishing_noGolden
                          : l10n.fishing_nextGolden(
                              '${TimeFormat.hm(next.startUtc)}–${TimeFormat.hm(next.endUtc)}',
                            ),
                      style: context.text.bodyStrong.copyWith(color: white),
                    ),
                    Text(
                      l10n.fishing_moon(
                        context.moonPhaseName(moon.phaseName),
                        (moon.fraction * 100).round(),
                      ),
                      style: context.text.caption.copyWith(color: white.withValues(alpha: 0.85)),
                    ),
                    if (hasWarning)
                      Text(l10n.fish_unsafe, style: context.text.caption.copyWith(color: white)),
                  ],
                ),
              ),
            ],
          ),
          Text(
            l10n.common_reference,
            style: context.text.caption.copyWith(color: white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final double? score;

  @override
  Widget build(BuildContext context) {
    final white = context.colors.surface;
    final s = score;
    return SizedBox.square(
      dimension: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: s == null ? null : s / 10,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: white,
              backgroundColor: white.withValues(alpha: 0.25),
            ),
          ),
          Text(
            s == null ? '' : LevelFormat.decimal1(s),
            style: context.text.headline.copyWith(color: white),
          ),
        ],
      ),
    );
  }
}
