import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/sun_moon_lines.dart';

/// Weather now, sunrise/sunset and moon for the place.
class Conditions extends ConsumerWidget {
  const Conditions({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final st = view.tide.data.station;
    final now = view.nowUtc;
    final fishing = ref.watch(stationFishingProvider(st.id)).value;
    final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
    final w = fishing?.weather.firstWhereOrNull((x) => x.timeUtc == hour);
    return _Section(
      icon: Icons.wb_sunny_outlined,
      title: l10n.cond_title,
      children: [
        if (w != null)
          Text(
            l10n.point_weatherNow(
              LevelFormat.decimal1(w.temperatureC ?? 0),
              (w.windKmh ?? 0).round().toString(),
              (w.precipProbPct ?? 0).round(),
            ),
            style: context.text.body,
          ),
        SunMoonLines(
          lat: st.lat,
          lon: st.lon,
          dayStartUtc: TimeFormat.vnDayStartUtc(now),
          nowUtc: now,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children});

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Row(
            children: [
              Icon(icon, size: AppIconSize.sm),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: context.text.label)),
            ],
          ),
          ...children,
        ],
      ),
    ),
  );
}
