import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/astro/sun.dart';
import 'package:rivertide/core/calc/fishing/fishing_advice.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Discharge rising more than this from today to tomorrow counts as "fast".
const double _floodRiseShare = 0.15;

/// "What to do now" for the chosen spot: near or far from the bank, wind,
/// storm, rain, light — from the spot's own level, weather and flow.
class AdviceCard extends ConsumerWidget {
  const AdviceCard({required this.spotId, super.key});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(stationViewProvider(spotId)).value;
    final fishing = ref.watch(stationFishingProvider(spotId)).value;
    if (view == null || fishing == null) return const SizedBox.shrink();
    final now = view.nowUtc;
    final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
    final weather = fishing.weather.firstWhereOrNull((w) => w.timeUtc == hour);
    final flow = ref.watch(stationFlowProvider(spotId)).value?.data;
    final today = flow?.on(now);
    final tomorrow = flow?.on(now.add(const Duration(days: 1)));
    final st = view.tide.data.station;
    final vn = TimeFormat.toVn(now);
    final sun = sunTimes(year: vn.year, month: vn.month, day: vn.day, lat: st.lat, lon: st.lon);
    final kinds = fishingAdvice(
      AdviceInput(
        nowUtc: now,
        score: fishing.hours.firstWhereOrNull((h) => h.hourUtc == hour),
        state: view.now.state,
        isTurning: view.now.isTurning,
        nextTurnUtc: view.now.nextExtreme?.timeUtc,
        windKmh: weather?.windKmh,
        gustKmh: weather?.gustKmh,
        rainProbPct: weather?.precipProbPct,
        flowRisingFast:
            today != null &&
            tomorrow != null &&
            today > 0 &&
            (tomorrow - today) / today > _floodRiseShare,
        sunriseUtc: sun.sunrise,
        sunsetUtc: sun.sunset,
      ),
    );
    if (kinds.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates_outlined),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(l10n.advice_title, style: context.text.title)),
              ],
            ),
            for (final k in kinds) _line(context, k, view),
            Text(l10n.advice_note, style: context.text.caption),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, AdviceKind k, StationView view) {
    final l10n = context.l10n;
    final c = context.colors;
    final next = view.now.nextExtreme;
    final (icon, text, color) = switch (k) {
      AdviceKind.unsafe => (Icons.thunderstorm_rounded, l10n.advice_unsafe, c.alarm3),
      AdviceKind.risingNearBank => (Icons.north_east_rounded, l10n.advice_rising, c.primary),
      AdviceKind.fallingDeeper => (Icons.south_west_rounded, l10n.advice_falling, c.primary),
      AdviceKind.slackWait => (
        Icons.pause_circle_outline_rounded,
        next == null
            ? l10n.advice_slack
            : l10n.advice_slackAt(TimeFormat.hm(next.timeUtc.add(const Duration(minutes: 30)))),
        c.onSurfaceMuted,
      ),
      AdviceKind.windStrong => (Icons.air_rounded, l10n.advice_windStrong, c.alarm2),
      AdviceKind.windDownwind => (Icons.air_rounded, l10n.advice_windDown, c.onSurface),
      AdviceKind.rainLikely => (Icons.umbrella_rounded, l10n.advice_rain, c.onSurface),
      AdviceKind.floodRising => (Icons.waves_rounded, l10n.advice_flood, c.alarm1),
      AdviceKind.lightChange => (Icons.wb_twilight_rounded, l10n.advice_light, c.fishHigh),
      AdviceKind.goodNow => (Icons.check_circle_outline_rounded, l10n.advice_good, c.fishHigh),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: AppIconSize.sm),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: context.text.body)),
      ],
    );
  }
}
