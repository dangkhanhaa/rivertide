import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';

/// Hour by hour for a place without a level curve: fishing score and weather
/// for the next two days, so the hourly tab is never empty there.
class HourlyWeatherList extends ConsumerWidget {
  const HourlyWeatherList({required this.view, super.key});

  final StationView view;

  static const int _hours = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = view.tide.data.station.id;
    final now = view.nowUtc;
    final nowHour = DateTime.utc(now.year, now.month, now.day, now.hour);
    return AsyncValueView(
      value: ref.watch(stationFishingProvider(id)),
      onRetry: () => ref.invalidate(stationFishingProvider(id)),
      data: (fishing) {
        final weather = {for (final w in fishing.weather) w.timeUtc: w};
        final hours = [
          for (final h in fishing.hours)
            if (!h.hourUtc.isBefore(nowHour) &&
                h.hourUtc.isBefore(nowHour.add(const Duration(hours: _hours))))
              h,
        ];
        if (hours.isEmpty) return EmptyView(message: context.l10n.hourly_empty);
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: hours.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final h = hours[i];
            final w = weather[h.hourUtc];
            final local = TimeFormat.toVn(h.hourUtc);
            final time = i == 0 || local.hour == 0
                ? '${TimeFormat.dayShort(h.hourUtc)} ${TimeFormat.hm(h.hourUtc)}'
                : TimeFormat.hm(h.hourUtc);
            return _Row(
              time: time,
              isNow: h.hourUtc == nowHour,
              score: h.score,
              weather: w == null
                  ? null
                  : context.l10n.hourly_weather(
                      w.temperatureC?.round().toString() ?? '—',
                      w.windKmh?.round().toString() ?? '—',
                      w.precipitationMm == null
                          ? '—'
                          : LevelFormat.decimal1(w.precipitationMm ?? 0),
                    ),
            );
          },
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.time, required this.isNow, required this.score, this.weather});

  final String time;
  final bool isNow;
  final double score;
  final String? weather;

  String _label(BuildContext context) => score >= 7
      ? context.l10n.fishing_levelGood
      : (score >= 5 ? context.l10n.fishing_levelFair : context.l10n.fishing_levelPoor);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = score >= 7 ? c.fishHigh : (score >= 5 ? c.alarm1 : c.stale);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNow ? '$time · ${context.l10n.hourly_now}' : time,
                    style: isNow ? context.text.bodyStrong : context.text.body,
                  ),
                  if (weather case final w?) Text(w, style: context.text.caption),
                ],
              ),
            ),
            Icon(Icons.phishing_rounded, color: color, size: AppIconSize.sm),
            Text(
              context.l10n.fishing_level(LevelFormat.decimal1(score), _label(context)),
              style: context.text.label,
            ),
          ],
        ),
      ),
    );
  }
}
