import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/lunar/lunar_calendar.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/moon_text.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// F-TIDE-03: 7 days from today (Vietnam time), highs/lows, spring/neap, lunar day, moon.
class CalendarTab extends StatelessWidget {
  const CalendarTab({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final prediction = view.tide.data.prediction;
    if (prediction == null) return EmptyView(message: context.l10n.tide_noPrediction);
    final today = TimeFormat.vnDayStartUtc(view.nowUtc);
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 7,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _DayCard(
          dayStartUtc: today.add(Duration(days: i)),
          prediction: prediction,
          nowUtc: view.nowUtc,
          isToday: i == 0,
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.dayStartUtc,
    required this.prediction,
    required this.nowUtc,
    required this.isToday,
  });

  final DateTime dayStartUtc;
  final TideSeries prediction;
  final DateTime nowUtc;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vn = TimeFormat.toVn(dayStartUtc);
    final lunar = solarToLunar(vn.year, vn.month, vn.day);
    final moon = moonIllumination(dayStartUtc.add(const Duration(hours: 12)));
    final springNeap = prediction.springNeapAt(dayStartUtc);
    final range = prediction.dailyRangeCm(dayStartUtc);
    final extremes = prediction.extremesBetween(
      dayStartUtc,
      dayStartUtc.add(const Duration(days: 1)),
    );
    final header = [
      '${TimeFormat.dayShort(dayStartUtc)} (${l10n.station_lunarDay(lunar.day, lunar.month)})',
      if (springNeap != null) context.springNeapName(springNeap),
    ].join(' · ');
    return Card(
      shape: isToday
          ? RoundedRectangleBorder(
              side: BorderSide(color: context.colors.primary, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isToday ? '${l10n.common_today} · $header' : header, style: context.text.title),
            Text(context.moonPhaseName(moon.phaseName), style: context.text.caption),
            const SizedBox(height: AppSpacing.sm),
            for (final e in extremes) _ExtremeLine(extreme: e, isPast: e.timeUtc.isBefore(nowUtc)),
            if (range != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  l10n.station_dailyRange(LevelFormat.meters(range)),
                  style: context.text.caption,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExtremeLine extends StatelessWidget {
  const _ExtremeLine({required this.extreme, required this.isPast});

  final TideExtreme extreme;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final isHigh = extreme.kind == TideExtremeKind.high;
    final style = context.text.body.copyWith(color: isPast ? context.colors.onSurfaceMuted : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '${isHigh ? '▲' : '▼'} ${context.extremeName(extreme.kind)} '
        '${TimeFormat.hm(extreme.timeUtc)} · ${LevelFormat.meters(extreme.levelCm)}',
        style: style,
      ),
    );
  }
}
