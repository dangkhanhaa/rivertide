import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/display_name_dialog.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/confirm_dialog.dart';
import 'package:rivertide/core/widgets/detail_host.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/features/trips/application/trips_providers.dart';
import 'package:rivertide/features/trips/domain/trip.dart';
import 'package:rivertide/features/trips/presentation/trip_form_screen.dart';
import 'package:rivertide/features/trips/presentation/trip_members_section.dart';
import 'package:rivertide/features/trips/presentation/trip_widgets.dart';
import 'package:share_plus/share_plus.dart';

/// One trip ("kèo câu", P2-26): when, where, who; join / leave / edit /
/// cancel; members see the contact and the group chat.
class TripSheet extends ConsumerWidget {
  const TripSheet({required this.trip, required this.onViewWater, super.key});

  final Trip trip;
  final VoidCallback onViewWater;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    // Membership can change after the list was loaded: prefer the fresh row.
    final t = _fresh(ref) ?? trip;
    final now = ref.watch(clockProvider)();
    final km = t.distanceKm;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Row(
            children: [
              Icon(Icons.groups_2_rounded, size: AppIconSize.sm, color: c.trip),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  t.mine ? l10n.trip_yours : (t.joined ? l10n.trip_joinedTag : l10n.trip_tag),
                  style: context.text.label.copyWith(color: c.trip),
                ),
              ),
              TripStatusChip(trip: t, nowUtc: now),
            ],
          ),
          Text(t.title, style: context.text.headline),
          TripLine(icon: Icons.schedule_rounded, text: tripWhen(t), strong: true),
          TripLine(
            icon: Icons.place_outlined,
            text: [
              if (t.placeName.isNotEmpty) t.placeName,
              // The place name is often the ward itself: do not say it twice.
              if (adminLine(ref, t.lat, t.lon) case final a? when !t.placeName.contains(a)) a,
              if (km != null) l10n.spot_distance(LevelFormat.km(km)),
            ].join(' · '),
          ),
          TripLine(
            icon: Icons.people_alt_outlined,
            text: [
              l10n.trip_members(t.memberCount, t.maxPeople),
              l10n.trip_owner(t.ownerName.isEmpty ? l10n.cmt_anon : t.ownerName),
            ].join(' · '),
          ),
          if (t.note.isNotEmpty) Text(t.note, style: context.text.body),
          _MainAction(trip: t),
          _Links(trip: t, onShare: () => unawaited(_share(context, t)), onViewWater: onViewWater),
          const Divider(),
          if (t.joined)
            TripMembersSection(tripId: t.id)
          else
            Text(l10n.trip_membersOnly, style: context.text.caption),
          if (!t.mine)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => unawaited(_report(context, ref, t)),
                icon: const Icon(Icons.flag_outlined),
                label: Text(l10n.trip_report),
              ),
            ),
        ],
      ),
    );
  }

  /// The same trip from any loaded area list (refetched after join/leave).
  Trip? _fresh(WidgetRef ref) {
    final all = ref.watch(nearbyTripsProvider(nearbyKeyFor(trip)));
    return all.value?.where((x) => x.id == trip.id).firstOrNull;
  }

  Future<void> _share(BuildContext context, Trip t) async {
    final map = DirectionsButton.directionsUri(t.lat, t.lon).toString();
    final text = context.l10n.trip_shareText(
      t.title,
      tripWhen(t),
      t.placeName.isEmpty
          ? '${t.lat.toStringAsFixed(5)}, ${t.lon.toStringAsFixed(5)}'
          : t.placeName,
      map,
      Env.webAppUrl,
    );
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _report(BuildContext context, WidgetRef ref, Trip t) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.trip_reportTitle,
      body: l10n.trip_reportHint,
      ok: l10n.trip_report,
    );
    if (!ok) return;
    try {
      final counted = await reportTrip(ref, t.id);
      messenger.showSnackBar(
        SnackBar(content: Text(counted ? l10n.spot_reportDone : l10n.spot_reportTwice)),
      );
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.trip_error)));
    }
  }
}

class _Links extends StatelessWidget {
  const _Links({required this.trip, required this.onShare, required this.onViewWater});

  final Trip trip;
  final VoidCallback onShare;
  final VoidCallback onViewWater;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      DirectionsButton(lat: trip.lat, lon: trip.lon),
      OutlinedButton.icon(
        onPressed: onShare,
        icon: const Icon(Icons.share_rounded),
        label: Text(context.l10n.trip_share),
      ),
      OutlinedButton.icon(
        onPressed: onViewWater,
        icon: const Icon(Icons.water_rounded),
        label: Text(context.l10n.spot_viewWater),
      ),
    ],
  );
}

/// Area key of the trip's own position, so the sheet can find fresh data.
String nearbyKeyFor(Trip t) => tripAreaKey(t.lat, t.lon);

/// Join / leave for others, edit / cancel for the owner.
class _MainAction extends ConsumerWidget {
  const _MainAction({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = trip;
    if (t.cancelled) return const SizedBox.shrink();
    if (t.mine) {
      return Row(
        spacing: AppSpacing.sm,
        children: [
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => TripFormScreen.edit(t))),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.trip_edit),
            ),
          ),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: context.colors.alarm3),
              onPressed: () => unawaited(_run(context, ref, cancel: true)),
              icon: const Icon(Icons.event_busy_rounded),
              label: Text(l10n.trip_cancel),
            ),
          ),
        ],
      );
    }
    if (t.joined) {
      return OutlinedButton.icon(
        onPressed: () => unawaited(_run(context, ref, cancel: false)),
        icon: const Icon(Icons.logout_rounded),
        label: Text(l10n.trip_leave),
      );
    }
    return FilledButton.icon(
      onPressed: t.full ? null : () => unawaited(_join(context, ref)),
      icon: const Icon(Icons.group_add_rounded),
      label: Text(t.full ? l10n.trip_joinFull : l10n.trip_join),
    );
  }

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    // Members see each other's names: offer to set one first (can stay empty).
    if ((await ref.read(displayNameProvider.future)).isEmpty && context.mounted) {
      await editDisplayName(context, ref);
    }
    try {
      final r = await joinTrip(ref, trip.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (r) {
            JoinResult.joined || JoinResult.already => l10n.trip_joinedSnack,
            JoinResult.full => l10n.trip_joinFull,
            JoinResult.closed => l10n.trip_joinClosed,
          }),
        ),
      );
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.trip_error)));
    }
  }

  Future<void> _run(BuildContext context, WidgetRef ref, {required bool cancel}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: cancel ? l10n.trip_cancelTitle : l10n.trip_leaveTitle,
      ok: cancel ? l10n.trip_cancel : l10n.trip_leave,
      cancel: cancel ? l10n.trip_keep : null,
    );
    if (!ok || !context.mounted) return;
    try {
      if (cancel) {
        await cancelTrip(ref, trip.id);
      } else {
        await leaveTrip(ref, trip.id);
      }
      if (context.mounted && cancel) DetailHost.closeOf(context);
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.trip_error)));
    }
  }
}
