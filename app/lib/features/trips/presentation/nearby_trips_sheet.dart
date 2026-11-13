import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/trips/application/trips_providers.dart';
import 'package:rivertide/features/trips/domain/trip.dart';
import 'package:rivertide/features/trips/presentation/trip_widgets.dart';

/// "Kèo câu quanh đây": soonest first, with a button to start one.
class NearbyTripsSheet extends ConsumerWidget {
  const NearbyTripsSheet({
    required this.areaKey,
    required this.onOpen,
    required this.onCreate,
    super.key,
  });

  final String areaKey;
  final ValueChanged<Trip> onOpen;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trips = ref.watch(nearbyTripsProvider(areaKey));
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.trip_nearbyTitle, style: context.text.title)),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.group_add_rounded),
                label: Text(l10n.trip_create),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          switch (trips) {
            AsyncData(:final value) when value.isEmpty => Text(
              l10n.trip_nearbyEmpty,
              style: context.text.body,
            ),
            AsyncData(:final value) => Column(
              spacing: AppSpacing.sm,
              children: [for (final t in value) _TripCard(trip: t, onTap: () => onOpen(t))],
            ),
            AsyncError() => Text(l10n.trip_loadError, style: context.text.body),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ],
      ),
    );
  }
}

class _TripCard extends ConsumerWidget {
  const _TripCard({required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final t = trip;
    final km = t.distanceKm;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            spacing: AppSpacing.md,
            children: [
              CircleAvatar(
                backgroundColor: c.trip.withValues(alpha: 0.15),
                child: Icon(Icons.groups_2_rounded, color: c.trip),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(t.title, style: context.text.bodyStrong, maxLines: 2),
                    Text(tripWhen(t), style: context.text.body),
                    Text(
                      [
                        l10n.trip_members(t.memberCount, t.maxPeople),
                        if (km != null) l10n.spot_distance(LevelFormat.km(km)),
                      ].join(' · '),
                      style: context.text.caption,
                    ),
                    TripStatusChip(trip: t, nowUtc: ref.watch(clockProvider)()),
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
