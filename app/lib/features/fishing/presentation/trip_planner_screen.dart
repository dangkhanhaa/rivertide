import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/trip_plan.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Places scored at once, so the free weather API is not flooded.
const int _maxPlaces = 10;

/// "Lên kế hoạch chuyến câu": the best windows of the next 7 days across the
/// saved places, with why each is good. Tapping one makes it the fishing spot.
class TripPlannerScreen extends ConsumerWidget {
  const TripPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final places = ref.watch(favoritesProvider);
    final stations = ref.watch(stationListProvider).value ?? const <Station>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trip_title)),
      body: switch (places) {
        AsyncData(:final value) when value.isEmpty => EmptyView(message: l10n.trip_noPlaces),
        AsyncData(:final value) => _Plan(
          places: value.take(_maxPlaces).toList(),
          stations: stations,
        ),
        AsyncError(:final error) => ErrorView(error: error),
        _ => const LoadingView(),
      },
    );
  }
}

class _Plan extends ConsumerWidget {
  const _Plan({required this.places, required this.stations});

  final List<SavedPlace> places;
  final List<Station> stations;

  String _name(SavedPlace p) =>
      p.label ??
      stations.firstWhereOrNull((s) => s.id == p.stationId)?.name ??
      PointId.toStation(p.stationId)?.name ??
      p.stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final byPlace = <String, List<FishingHourScore>>{};
    var loading = 0;
    for (final p in places) {
      final f = ref.watch(stationFishingProvider(p.stationId));
      if (f.value case final v?) {
        byPlace[p.stationId] = v.hours;
      } else if (f.isLoading) {
        loading++;
      }
    }
    final options = bestTrips(byPlace, now);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.trip_intro(places.length), style: context.text.body),
        if (loading > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(minHeight: 2),
        ],
        const SizedBox(height: AppSpacing.md),
        if (options.isEmpty && loading == 0)
          Text(l10n.trip_none, style: context.text.body)
        else
          for (final (i, o) in options.indexed)
            _OptionCard(
              option: o,
              rank: i + 1,
              placeName: _name(places.firstWhere((p) => p.stationId == o.placeId)),
            ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.trip_note, style: context.text.caption),
      ],
    );
  }
}

class _OptionCard extends ConsumerWidget {
  const _OptionCard({required this.option, required this.rank, required this.placeName});

  final TripOption option;
  final int rank;
  final String placeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = option.window;
    final c = context.colors;
    final reasons = w.reasons.map(context.factorName).join(', ');
    return Card(
      child: ListTile(
        minVerticalPadding: AppSpacing.sm,
        leading: CircleAvatar(
          backgroundColor: rank == 1 ? c.fishHigh : c.surfaceAlt,
          foregroundColor: rank == 1 ? c.surface : c.onSurface,
          child: Text('$rank'),
        ),
        title: Text(
          '${TimeFormat.dayShort(w.startUtc)} · '
          '${TimeFormat.hm(w.startUtc)}–${TimeFormat.hm(w.endUtc)}',
          style: context.text.bodyStrong,
        ),
        subtitle: Text(
          [
            placeName,
            context.l10n.trip_score(LevelFormat.decimal1(w.peakScore)),
            if (reasons.isNotEmpty) context.l10n.trip_because(reasons),
          ].join('\n'),
          style: context.text.body,
        ),
        isThreeLine: true,
        onTap: () {
          ref.read(fishingSpotProvider.notifier).choose(option.placeId);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
