import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/astro/moon_times.dart';
import 'package:rivertide/core/calc/astro/solunar.dart';
import 'package:rivertide/core/calc/astro/solunar_kind.dart';
import 'package:rivertide/core/calc/astro/sun.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/presentation/widgets/moon_text.dart';

/// Sun and moon for one Vietnam day at a place: rise/set, moon phase, and the
/// solunar feeding windows (major ±60 min around moon transits, minor ±30 min
/// around moonrise/moonset — PROJECT.md 9.5).
class SunMoonLines extends StatelessWidget {
  const SunMoonLines({
    required this.lat,
    required this.lon,
    required this.dayStartUtc,
    required this.nowUtc,
    this.showPhase = true,
    super.key,
  });

  /// False where the moon phase is already shown next to a moon glyph.
  final bool showPhase;

  final double lat;
  final double lon;

  /// 00:00 Vietnam time of the day shown, as a UTC instant.
  final DateTime dayStartUtc;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vn = TimeFormat.toVn(dayStartUtc);
    final sun = sunTimes(year: vn.year, month: vn.month, day: vn.day, lat: lat, lon: lon);
    final mt = moonTimes(year: vn.year, month: vn.month, day: vn.day, lat: lat, lon: lon);
    final moon = moonIllumination(dayStartUtc.add(const Duration(hours: 12)));
    final solunar = solunarForDay(year: vn.year, month: vn.month, day: vn.day, lat: lat, lon: lon);
    final (rise, set) = (sun.sunrise, sun.sunset);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        if (rise != null && set != null)
          Text(l10n.point_sun(TimeFormat.hm(rise), TimeFormat.hm(set)), style: context.text.body),
        Text(_moonTimes(context, mt), style: context.text.body),
        if (showPhase)
          Text(
            l10n.fishing_moon(context.moonPhaseName(moon.phaseName), (moon.fraction * 100).round()),
            style: context.text.body,
          ),
        if (solunar.periods.isNotEmpty) ...[
          Text(
            solunar.isGoodDay ? l10n.solunar_titleGood : l10n.solunar_title,
            style: context.text.label,
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [for (final p in solunar.periods) _PeriodChip(period: p, nowUtc: nowUtc)],
          ),
        ],
      ],
    );
  }

  String _moonTimes(BuildContext context, MoonTimes t) {
    final l10n = context.l10n;
    if (t.isAlwaysUp) return l10n.moon_alwaysUp;
    if (t.isAlwaysDown) return l10n.moon_alwaysDown;
    final (rise, set) = (t.rise, t.set);
    return l10n.moon_times(
      rise == null ? '—' : TimeFormat.hm(rise),
      set == null ? '—' : TimeFormat.hm(set),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.period, required this.nowUtc});

  final SolunarPeriod period;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final major = period.kind == SolunarKind.major;
    final active = period.contains(nowUtc);
    final past = !period.endUtc.isAfter(nowUtc);
    final range = '${TimeFormat.hm(period.startUtc)}–${TimeFormat.hm(period.endUtc)}';
    final text = [
      if (major) l10n.solunar_major(range) else l10n.solunar_minor(range),
      if (active) l10n.solunar_now,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: active ? c.fishHigh.withValues(alpha: 0.15) : c.surfaceAlt,
        border: Border.all(color: major ? c.fishHigh : c.stale.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: (active ? context.text.bodyStrong : context.text.body).copyWith(
          color: past ? c.onSurfaceMuted : null,
        ),
      ),
    );
  }
}
