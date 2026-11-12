import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fish_time.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/fish_activity_style.dart';
import 'package:rivertide/core/widgets/fish_scene.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_fishing.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';

/// Looks ahead this far for the next golden window.
const Duration _windowLookahead = Duration(hours: 48);

/// "Cá ăn: CAO" card (P2-20): band, fish meter, a swimming-fish strip and the
/// next golden window, for the hour chosen on the map (default: now).
class FishActivityCard extends ConsumerWidget {
  const FishActivityCard({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tide = view.tide.data;
    final hour = fishHourUtc(view.nowUtc, ref.watch(fishTimeProvider));
    final fishing = ref.watch(stationFishingProvider(tide.station.id)).value;
    final full = fishing?.hours.firstWhereOrNull((h) => h.hourUtc == hour);
    final score = full ?? scoreStationHourQuick(tide, hour);
    final activity = fishActivity(score.score);
    final color = context.fishActivityColor(activity);
    final c = context.colors;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            activity: activity,
            score: score.score,
            when: context.fishTimeLabel(view.nowUtc, hour),
          ),
          _Meter(count: fishCount(score.score), color: color),
          FishScene(
            fishes: fishCount(score.score),
            energy: (score.score / 10).clamp(0, 1),
            water: c.deepWater,
            fish: color,
          ),
          _Footer(
            score: score,
            nowUtc: view.nowUtc,
            hourUtc: hour,
            hours: fishing?.hours,
            quick: full == null,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activity, required this.score, required this.when});

  final FishActivity activity;
  final double score;
  final String when;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = context.fishActivityColor(activity);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${l10n.fishAct_title}: ', style: context.text.title),
                  TextSpan(
                    text: context.fishActivityName(activity).toUpperCase(),
                    style: context.text.headline.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.fishAct_score(LevelFormat.decimal1(score)), style: context.text.bodyStrong),
              Text(when, style: context.text.caption),
            ],
          ),
        ],
      ),
    );
  }
}

/// Five fish, lit up to the score: the band in a glance (with words for a11y).
class _Meter extends StatelessWidget {
  const _Meter({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: context.l10n.fishAct_meter(count),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.06)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 5; i++)
              FishGlyph(
                size: AppIconSize.lg,
                color: i < count ? color : c.stale.withValues(alpha: 0.35),
                eye: c.surface,
              ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.score,
    required this.nowUtc,
    required this.hourUtc,
    required this.hours,
    required this.quick,
  });

  final FishingHourScore score;
  final DateTime nowUtc;
  final DateTime hourUtc;
  final List<FishingHourScore>? hours;
  final bool quick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final reasons = score.positiveFactors.map((f) => _factor(context, f)).join(', ');
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          if (score.safety != SafetyLevel.none)
            Text(l10n.fish_unsafe, style: context.text.bodyStrong.copyWith(color: c.alarm3)),
          if (hours case final h?) Text(_windowText(context, h), style: context.text.bodyStrong),
          if (reasons.isNotEmpty) Text(l10n.fishAct_because(reasons), style: context.text.body),
          if (quick) Text(l10n.fishAct_quick, style: context.text.caption),
          Text(l10n.fishAct_source, style: context.text.caption),
        ],
      ),
    );
  }

  String _windowText(BuildContext context, List<FishingHourScore> all) {
    final l10n = context.l10n;
    final end = hourUtc.add(_windowLookahead);
    final ahead = [
      for (final h in all)
        if (!h.hourUtc.isBefore(hourUtc) && h.hourUtc.isBefore(end)) h,
    ];
    final w = goldenWindows(ahead).firstOrNull;
    if (w == null) return l10n.fishAct_noWindow;
    if (!w.startUtc.isAfter(hourUtc)) return l10n.fishAct_inWindow(TimeFormat.hm(w.endUtc));
    final when = '${context.fishTimeLabel(nowUtc, w.startUtc)}–${TimeFormat.hm(w.endUtc)}';
    return l10n.fishAct_next(when);
  }

  static String _factor(BuildContext context, FishingFactor f) => switch (f) {
    FishingFactor.tide => context.l10n.fishing_factor_tide,
    FishingFactor.flow => context.l10n.fishing_factor_flow,
    FishingFactor.solunar => context.l10n.fishing_factor_solunar,
    FishingFactor.pressure => context.l10n.fishing_factor_pressure,
    FishingFactor.daytime => context.l10n.fishing_factor_daytime,
    FishingFactor.weather => context.l10n.fishing_factor_weather,
    FishingFactor.season => context.l10n.fishing_factor_season,
  };
}
