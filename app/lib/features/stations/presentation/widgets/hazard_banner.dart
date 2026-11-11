import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/hazards.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';

/// Red/amber card at the top of a place when something is dangerous in the
/// next 12 hours (storm, gusts, heavy rain, water rising fast, flood coming).
/// Nothing is shown when all is calm.
class HazardBanner extends ConsumerWidget {
  const HazardBanner({required this.view, this.bottomGap = 0, super.key});

  final StationView view;

  /// Space below the card when it is shown (lists without `spacing`).
  final double bottomGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = view.tide.data.station.id;
    final fishing = ref.watch(stationFishingProvider(id)).value;
    final flow = ref.watch(stationFlowProvider(id)).value?.data;
    final now = view.nowUtc;
    final hazards = hazardsAhead(
      nowUtc: now,
      hours: fishing?.hours ?? const [],
      waterRisingFast: switch (view.tide.data.prediction) {
        final p? => risingAbnormally(p, now),
        null => false,
      },
      flowTodayM3s: flow?.on(now),
      flowTomorrowM3s: flow?.on(now.add(const Duration(days: 1))),
    );
    if (hazards.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    final severe = hazards.any((h) => h.isSevere);
    final tone = severe ? c.alarm3 : c.alarm2;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            border: Border.all(color: tone, width: 2),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              Row(
                spacing: AppSpacing.sm,
                children: [
                  Icon(Icons.warning_amber_rounded, color: tone),
                  Expanded(
                    child: Text(
                      severe ? context.l10n.hazard_titleSevere : context.l10n.hazard_title,
                      style: context.text.bodyStrong.copyWith(color: tone),
                    ),
                  ),
                ],
              ),
              for (final h in hazards) Text(_text(context, h), style: context.text.body),
            ],
          ),
        ),
      ),
    );
  }

  String _text(BuildContext context, Hazard h) {
    final l10n = context.l10n;
    final (from, to) = (h.fromUtc, h.toUtc);
    final when = from == null
        ? ''
        : (to == null || to == from
              ? l10n.hazard_at(TimeFormat.hm(from))
              : l10n.hazard_between(
                  TimeFormat.hm(from),
                  TimeFormat.hm(to.add(const Duration(hours: 1))),
                ));
    final what = switch (h.kind) {
      HazardKind.thunderstorm => l10n.hazard_thunderstorm,
      HazardKind.strongGust => l10n.hazard_gust,
      HazardKind.heavyRain => l10n.hazard_heavyRain,
      HazardKind.possibleThunderstorm => l10n.hazard_possibleStorm,
      HazardKind.waterRisingFast => l10n.hazard_risingFast,
      HazardKind.floodComing => l10n.hazard_flood,
    };
    return when.isEmpty ? what : '$what $when';
  }
}
