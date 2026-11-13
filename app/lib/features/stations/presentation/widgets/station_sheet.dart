import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/core/widgets/detail_host.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/presentation/widgets/daily_extremes_card.dart';
import 'package:rivertide/features/stations/presentation/widgets/directions_button.dart';
import 'package:rivertide/features/stations/presentation/widgets/fish_activity_card.dart';
import 'package:rivertide/features/stations/presentation/widgets/flow_card.dart';
import 'package:rivertide/features/stations/presentation/widgets/hazard_banner.dart';
import 'package:rivertide/features/stations/presentation/widgets/location_summary.dart';
import 'package:rivertide/features/stations/presentation/widgets/point_sheet.dart';
import 'package:rivertide/features/stations/presentation/widgets/share_place.dart';

/// Station summary shown when a map marker is tapped (FEATURES.md F-MAP-02).
/// Uses cached data first, so it opens without waiting for the network.
class StationSheet extends ConsumerWidget {
  const StationSheet({required this.station, super.key});

  final Station station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isFavorite = ref.watch(favoriteIdsProvider).value?.contains(station.id) ?? false;
    final view = ref.watch(stationViewProvider(station.id));
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(station.name, style: context.text.title),
                    Text(
                      adminLine(ref, station.lat, station.lon) ?? station.region,
                      style: context.text.caption,
                    ),
                  ],
                ),
              ),
              SharePlaceButton(stationId: station.id, title: station.name),
              IconButton(
                tooltip: isFavorite ? l10n.station_unfollow : l10n.station_follow,
                icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                onPressed: () => toggleFavorite(ref, station.id),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: DirectionsButton(lat: station.lat, lon: station.lon),
          ),
          const SizedBox(height: AppSpacing.sm),
          AsyncValueView(
            value: view,
            onRetry: () => ref.invalidate(stationTideProvider(station.id)),
            data: (v) => StationSummaryBody(
              view: v,
              place: station.river == null ? station.region : l10n.loc_river(station.river ?? ''),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.minTouch),
            ),
            icon: const Icon(Icons.phishing_rounded),
            label: Text(l10n.fish_here),
            onPressed: () {
              ref.read(fishingSpotProvider.notifier).choose(station.id);
              DetailHost.closeOf(context);
              context.go(fishingRoute);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppSpacing.minTouch)),
            onPressed: () {
              DetailHost.closeOf(context);
              unawaited(context.push('/station/${station.id}'));
            },
            child: Text(l10n.map_openDetail),
          ),
        ],
      ),
    );
  }
}

/// Everything known for one place, shared by station and point sheets:
/// level, next turns, chart, today's range, flow, fishing, weather.
/// The short version shown in map sheets (station and point): level and
/// direction, fish activity, next turns, warnings. Chart, day statistics and
/// weather are one tap away in "Xem chi tiết" (the full screen).
class StationSummaryBody extends StatelessWidget {
  const StationSummaryBody({required this.view, this.place, super.key});

  final StationView view;

  /// Short place context shown above the level ("Sông Hồng", "Vùng biển").
  final String? place;

  @override
  Widget build(BuildContext context) {
    final tide = view.tide.data;
    final daily = tide.dailyExtremes;
    if (levelUnknown(tide)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          if (place case final p?) Text(p, style: context.text.label),
          HazardBanner(view: view),
          FishActivityCard(view: view),
          FlowCard(stationId: tide.station.id, nowUtc: view.nowUtc, primary: true),
        ],
      );
    }
    if (tide.prediction == null && daily != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          if (place case final p?) Text(p, style: context.text.label),
          HazardBanner(view: view),
          DailyExtremesCard(extremes: daily),
          FishActivityCard(view: view),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        LocationHero(view: view, place: place),
        HazardBanner(view: view),
        if (tide.prediction != null) NextTurns(view: view),
        FishActivityCard(view: view),
      ],
    );
  }
}

/// A place no level source reaches (no curve, no readings, no bulletin):
/// shown by flow, fishing and weather instead of a level.
bool levelUnknown(StationTide t) =>
    t.prediction == null && t.observations.isEmpty && t.dailyExtremes == null;
