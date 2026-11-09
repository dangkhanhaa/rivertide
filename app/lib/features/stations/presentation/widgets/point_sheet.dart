import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/calc/astro/sun.dart';
import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/detail_host.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/point_id.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/presentation/widgets/station_sheet.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Any tapped map point: coordinates, water there (sea model or nearest river
/// station, labelled), weather, sun and the nearest stations (F-MAP-03).
class PointSheet extends ConsumerWidget {
  const PointSheet({required this.lat, required this.lon, this.onWater, super.key});

  final double lat;
  final double lon;

  /// Whether the base map draws water here; null when unknown.
  final bool? onWater;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = PointId.encode(lat, lon);
    final coords = '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
    final view = ref.watch(stationViewProvider(id));
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
                    Text(l10n.point_title, style: context.text.title),
                    SelectableText(l10n.point_coords(coords), style: context.text.body),
                  ],
                ),
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
          const SizedBox(height: AppSpacing.sm),
          // Riverpod retries failures and reports loading meanwhile: check the error first.
          if (view.hasValue) ...[
            _EstimateBanner(view: view.requireValue, onWater: onWater),
            const SizedBox(height: AppSpacing.sm),
            StationSummaryBody(view: view.requireValue),
          ] else if (view.error is NotFoundException)
            Text(l10n.point_noData, style: context.text.body)
          else if (view.error case final Object error)
            ErrorView(error: error, onRetry: () => ref.invalidate(stationTideProvider(id)))
          else
            const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: AppSpacing.md),
          _WeatherSun(id: id, lat: lat, lon: lon),
          const SizedBox(height: AppSpacing.md),
          _Nearby(lat: lat, lon: lon),
          if (view.hasValue) ...[
            const SizedBox(height: AppSpacing.md),
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

class _WeatherSun extends ConsumerWidget {
  const _WeatherSun({required this.id, required this.lat, required this.lon});

  final String id;
  final double lat;
  final double lon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final vn = TimeFormat.toVn(now);
    final sun = sunTimes(year: vn.year, month: vn.month, day: vn.day, lat: lat, lon: lon);
    final (rise, set) = (sun.sunrise, sun.sunset);
    final hour = ref
        .watch(stationWeatherProvider(id))
        .value
        ?.data
        .firstWhereOrNull(
          (h) => !h.timeUtc.isAfter(now) && now.difference(h.timeUtc) < const Duration(hours: 1),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hour != null)
          Text(
            l10n.point_weatherNow(
              LevelFormat.decimal1(hour.temperatureC ?? 0),
              (hour.windKmh ?? 0).round().toString(),
              (hour.precipProbPct ?? 0).round(),
            ),
            style: context.text.body,
          ),
        if (rise != null && set != null)
          Text(l10n.point_sun(TimeFormat.hm(rise), TimeFormat.hm(set)), style: context.text.body),
      ],
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

/// Makes clear the numbers are an estimate for this exact point, and what they
/// are based on (the point's own sea model, or a station some km away).
class _EstimateBanner extends StatelessWidget {
  const _EstimateBanner({required this.view, required this.onWater});

  final StationView view;
  final bool? onWater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ref = view.tide.data.reference;
    final distance = ref == null ? null : LevelFormat.km(ref.distanceKm);
    final basis = switch ((ref, distance)) {
      (final r?, final d?) when r.river != null => l10n.point_basisRiver(r.name, r.river ?? '', d),
      (final r?, final d?) => l10n.point_basisStation(r.name, d),
      _ => l10n.point_seaModel,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.estimateHatch,
        border: Border.all(color: context.colors.alarm2),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place_rounded, color: context.colors.alarm2),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.point_estimateHere, style: context.text.bodyStrong),
                if (onWater case final w?)
                  Text(w ? l10n.point_onWater : l10n.point_onLand, style: context.text.body),
                Text(basis, style: context.text.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
