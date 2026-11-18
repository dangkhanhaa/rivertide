import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/weather_shift.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/stations.dart';

/// "Sắp đổi thời tiết" (P2-34) for the chosen spot: what changes in the next
/// three days and what it means for fishing. Hidden when nothing changes.
class WeatherShiftCard extends ConsumerWidget {
  const WeatherShiftCard({required this.spotId, super.key});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(stationFishingProvider(spotId)).value?.weather;
    if (weather == null || weather.isEmpty) return const SizedBox.shrink();
    final now = ref.watch(clockProvider)();
    final today = TimeFormat.vnDayStartUtc(now);
    final shifts = weatherShifts(
      [
        for (final w in weather)
          (
            timeUtc: w.timeUtc,
            tempC: w.temperatureC,
            pressureHpa: w.pressureHpa,
            rainMm: w.precipitationMm,
          ),
      ],
      now,
      [for (var d = 0; d < 5; d++) today.add(Duration(days: d))],
    );
    if (shifts.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: c.alarm1.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: c.alarm1.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Text(context.l10n.shift_title, style: context.text.title),
            for (final s in shifts) _Line(shift: s, nowUtc: now),
            Text(context.l10n.shift_note, style: context.text.caption),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.shift, required this.nowUtc});

  final WeatherShift shift;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final days = TimeFormat.vnDayStartUtc(shift.atUtc)
        .difference(TimeFormat.vnDayStartUtc(nowUtc))
        .inDays;
    final when = switch (days) {
      0 => l10n.common_today,
      1 => l10n.common_tomorrow,
      2 => l10n.shift_dayAfter,
      _ => TimeFormat.dayShort(shift.atUtc),
    };
    final (icon, color, text) = switch (shift.kind) {
      ShiftKind.coldFront => (Icons.ac_unit_rounded, c.water, l10n.shift_coldFront(when)),
      ShiftKind.heavyRain => (Icons.thunderstorm_rounded, c.primary, l10n.shift_heavyRain(when)),
      // Mid-sentence there ("Từ ngày kia…"): lower-case the day word.
      ShiftKind.pressureDrop => (
        Icons.speed_rounded,
        c.alarm2,
        l10n.shift_pressureDrop(_lower(when)),
      ),
      ShiftKind.heatWave => (Icons.wb_sunny_rounded, c.alarm2, l10n.shift_heatWave(when)),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Icon(icon, color: color, size: AppIconSize.sm),
        Expanded(child: Text(text, style: context.text.body)),
      ],
    );
  }
}

String _lower(String s) => s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);
