import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/sun_moon_lines.dart';

/// Fishing score for the current hour at this place + today's best window.
class FishingNow extends ConsumerWidget {
  const FishingNow({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fishing = ref.watch(stationFishingProvider(view.tide.data.station.id)).value;
    if (fishing == null) return const SizedBox.shrink();
    final now = view.nowUtc;
    final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
    final current = fishing.hours.firstWhereOrNull((h) => h.hourUtc == hour);
    if (current == null) return const SizedBox.shrink();
    final dayStart = TimeFormat.vnDayStartUtc(now);
    final today = [
      for (final h in fishing.hours)
        if (!h.hourUtc.isBefore(dayStart) &&
            h.hourUtc.isBefore(dayStart.add(const Duration(days: 1))))
          h,
    ];
    final best = goldenWindows(today).where((w) => w.endUtc.isAfter(now)).firstOrNull;
    final l10n = context.l10n;
    final c = context.colors;
    final s = current.score;
    final color = s >= 7 ? c.fishHigh : (s >= 5 ? c.alarm1 : c.stale);
    final label = s >= 7
        ? l10n.fishing_levelGood
        : (s >= 5 ? l10n.fishing_levelFair : l10n.fishing_levelPoor);
    return _Section(
      icon: Icons.phishing_rounded,
      title: l10n.fish_now_title,
      children: [
        Row(
          children: [
            Container(
              width: AppIconSize.lg + AppSpacing.md,
              height: AppIconSize.lg + AppSpacing.md,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: Text(LevelFormat.decimal1(s), style: context.text.bodyStrong),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                l10n.fishing_level(LevelFormat.decimal1(s), label),
                style: context.text.bodyStrong,
              ),
            ),
          ],
        ),
        if (current.safety != SafetyLevel.none)
          Text(l10n.fish_unsafe, style: context.text.bodyStrong.copyWith(color: c.alarm3)),
        Text(
          best == null
              ? l10n.fish_noWindow
              : l10n.fish_best(TimeFormat.hm(best.startUtc), TimeFormat.hm(best.endUtc)),
          style: context.text.body,
        ),
      ],
    );
  }
}

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
