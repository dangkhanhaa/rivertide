import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/geo/admin_provider.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/detail_host.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/point_id.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/presentation/widgets/directions_button.dart';
import 'package:rivertide/features/stations/presentation/widgets/share_place.dart';
import 'package:rivertide/features/stations/presentation/widgets/station_sheet.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Any tapped map point: coordinates, water there (sea model or nearest river
/// station, labelled), weather, sun and the nearest stations (F-MAP-03).
class PointSheet extends ConsumerWidget {
  const PointSheet({
    required this.lat,
    required this.lon,
    this.onWater,
    this.title,
    this.actions = const [],
    super.key,
  });

  /// Buttons from other features shown beside "Chỉ đường" (e.g. "Ghim công khai").
  final List<Widget> actions;

  final double lat;
  final double lon;

  /// Name of the searched place ("Cầu Thanh Trì"); null for a tapped point.
  final String? title;

  /// Whether the base map draws water here; null when unknown.
  final bool? onWater;

  /// Where the point is, in a few words — never how the number was computed.
  String? _place(BuildContext context, StationView v) {
    final l10n = context.l10n;
    final ref = v.tide.data.reference;
    final river = ref?.river;
    if (ref?.alongKm != null && river != null) return l10n.loc_river(river);
    if (ref?.stationId == coastReferenceId) return l10n.loc_nearCoast;
    if (ref == null && levelUnknown(v.tide.data)) return (onWater ?? false) ? l10n.loc_water : null;
    if (ref == null) return onWater == false ? null : l10n.loc_sea;
    if (onWater ?? false) return l10n.loc_water;
    return river == null ? null : l10n.loc_nearRiver(river);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = PointId.encode(lat, lon);
    final coords = '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
    final view = ref.watch(stationViewProvider(id));
    final isFavorite = ref.watch(favoriteIdsProvider).value?.contains(id) ?? false;
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
                    Text(title ?? l10n.point_title, style: context.text.title),
                    SelectableText(l10n.point_coords(coords), style: context.text.body),
                    if (adminLine(ref, lat, lon) case final a?)
                      Text(a, style: context.text.caption),
                  ],
                ),
              ),
              SharePlaceButton(stationId: id, title: title ?? l10n.point_coords(coords)),
              IconButton(
                tooltip: isFavorite ? l10n.station_unfollow : l10n.station_follow,
                icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                onPressed: () => toggleFavorite(ref, id),
              ),
              IconButton(
                tooltip: l10n.point_copy,
                icon: const Icon(Icons.copy_rounded),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: coords));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(l10n.point_copied)));
                },
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              DirectionsButton(lat: lat, lon: lon),
              ...actions,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Riverpod retries failures and reports loading meanwhile: check the error first.
          if (view.hasValue)
            StationSummaryBody(view: view.requireValue, place: _place(context, view.requireValue))
          else if (view.error is NotFoundException)
            Text(l10n.point_noData, style: context.text.body)
          else if (view.error case final Object error)
            ErrorView(error: error, onRetry: () => ref.invalidate(stationTideProvider(id)))
          else
            const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: AppSpacing.md),
          _Nearby(lat: lat, lon: lon),
          if (view.hasValue) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouch),
              ),
              icon: const Icon(Icons.phishing_rounded),
              label: Text(l10n.fish_here),
              onPressed: () {
                ref.read(fishingSpotProvider.notifier).choose(id);
                DetailHost.closeOf(context);
                context.go(fishingRoute);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouch),
              ),
              onPressed: () {
                DetailHost.closeOf(context);
                unawaited(context.push('/station/$id'));
              },
              child: Text(l10n.point_openDetail),
            ),
          ],
        ],
      ),
    );
  }
}

class _Nearby extends ConsumerWidget {
  const _Nearby({required this.lat, required this.lon});

  final double lat;
  final double lon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stations = ref.watch(stationListProvider).value ?? const <Station>[];
    final nearest = stations
        .map((s) => (s: s, km: haversineKm(lat, lon, s.lat, s.lon)))
        .sortedBy<num>((r) => r.km)
        .take(3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.point_nearby, style: context.text.label),
        for (final r in nearest)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(stationKindIcon(r.s.kind)),
            title: Text(r.s.name),
            subtitle: Text(
              '${r.s.river ?? r.s.region} · ${l10n.point_distance(LevelFormat.km(r.km))}',
            ),
            onTap: () {
              DetailHost.closeOf(context);
              unawaited(context.push('/station/${r.s.id}'));
            },
          ),
      ],
    );
  }
}

/// "Phường Hoàn Kiếm, Thành phố Hà Nội" for a point (2025 units, offline);
/// null at sea, abroad, or while the list loads.
String? adminLine(WidgetRef ref, double lat, double lon) {
  final a = ref.watch(adminIndexProvider).value?.lookup(lat, lon);
  final parts = [?a?.commune, ?a?.province];
  return parts.isEmpty ? null : parts.join(', ');
}
