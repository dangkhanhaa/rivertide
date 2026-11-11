import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fishing_advice.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/advice_now.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Icon, text and colour of one piece of advice (fishing tab + summary).
extension AdviceText on BuildContext {
  (IconData, String, Color) adviceLine(AdviceKind k, StationView view) {
    final c = colors;
    final next = view.now.nextExtreme;
    return switch (k) {
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
  }
}

/// "Lúc này ở đây": water, fishing and wind in one glance, plus the most
/// important advice — the answer to "should I fish here now?".
class QuickSummary extends ConsumerWidget {
  const QuickSummary({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = view.tide.data.station.id;
    final fishing = ref.watch(stationFishingProvider(id)).value;
    if (fishing == null) return const SizedBox.shrink();
    final flow = ref.watch(stationFlowProvider(id)).value?.data;
    final now = view.nowUtc;
    final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
    final score = fishing.hours.firstWhereOrNull((h) => h.hourUtc == hour)?.score;
    final wind = fishing.weather.firstWhereOrNull((w) => w.timeUtc == hour)?.windKmh;
    final advice = adviceNow(view, fishing, flow).firstOrNull;
    final l10n = context.l10n;
    final c = context.colors;
    final parts = [
      ?_water(context),
      if (score != null) l10n.summary_fishing(LevelFormat.decimal1(score), _label(context, score)),
      if (wind != null) l10n.summary_wind(wind.round()),
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    final line = advice == null ? null : context.adviceLine(advice, view);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.fishHigh.withValues(alpha: 0.1),
        border: Border.all(color: c.fishHigh.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Text(l10n.summary_title, style: context.text.label),
          Text(parts.join(' · '), style: context.text.bodyStrong),
          if (line case (final icon, final text, final color))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.sm,
              children: [
                Icon(icon, color: color, size: AppIconSize.sm),
                Expanded(child: Text(text, style: context.text.body)),
              ],
            ),
        ],
      ),
    );
  }

  String? _water(BuildContext context) {
    final l10n = context.l10n;
    final state = view.now.state;
    if (state == null) return null;
    final s = switch (state) {
      TideState.rising || TideState.risingFast => l10n.tide_rising,
      TideState.falling || TideState.fallingFast => l10n.tide_falling,
      TideState.slack => l10n.tide_slack,
    };
    final next = view.now.nextExtreme;
    if (next == null) return s;
    final wait = context.durationText(next.timeUtc.difference(view.nowUtc));
    return l10n.summary_water(
      s,
      context.extremeName(next.kind).toLowerCase(),
      TimeFormat.hm(next.timeUtc),
      wait,
    );
  }

  String _label(BuildContext context, double s) => s >= 7
      ? context.l10n.fishing_levelGood
      : (s >= 5 ? context.l10n.fishing_levelFair : context.l10n.fishing_levelPoor);
}
