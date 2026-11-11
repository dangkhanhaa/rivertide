import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/presentation/widgets/calendar/calendar_month.dart';
import 'package:rivertide/features/stations/presentation/widgets/calendar/moon_glyph.dart';
import 'package:rivertide/features/stations/presentation/widgets/moon_text.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Monday-first month grid: solar day, lunar day, moon, spring/neap mark, range bar.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.month,
    required this.todayUtc,
    required this.selectedUtc,
    required this.onSelect,
    super.key,
  });

  final CalendarMonth month;

  /// 00:00 VN of today and of the selected day (UTC instants).
  final DateTime todayUtc;
  final DateTime? selectedUtc;
  final ValueChanged<CalendarDay> onSelect;

  static const double cellHeight = 72;

  @override
  Widget build(BuildContext context) {
    final maxRange = month.maxRangeCm;
    final weeks = month.days.length ~/ 7;
    return Column(
      children: [
        Row(
          children: [
            for (final d in month.days.take(7))
              Expanded(
                child: Center(
                  child: Text(TimeFormat.weekday(d.dayStartUtc), style: context.text.caption),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var w = 0; w < weeks; w++)
          Row(
            children: [
              for (final d in month.days.skip(w * 7).take(7))
                Expanded(
                  child: _Cell(
                    day: d,
                    maxRangeCm: maxRange,
                    isToday: d.dayStartUtc == todayUtc,
                    isSelected: d.dayStartUtc == selectedUtc,
                    onTap: () => onSelect(d),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.day,
    required this.maxRangeCm,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final CalendarDay day;
  final int? maxRangeCm;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  String _lunarText() => day.lunar.day == 1 || day.lunar.day == 15
      ? '${day.lunar.day}/${day.lunar.month}'
      : '${day.lunar.day}';

  String _semantics(BuildContext context) => [
    TimeFormat.dayShort(day.dayStartUtc),
    context.l10n.station_lunarDay(day.lunar.day, day.lunar.month),
    context.moonPhaseName(day.moon.phaseName),
    if (day.springNeap case final s?) context.springNeapName(s),
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final muted = !day.inMonth;
    final keyDay = day.lunar.day == 1 || day.lunar.day == 15;
    return Semantics(
      button: true,
      selected: isSelected,
      label: _semantics(context),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          height: MonthGrid.cellHeight,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isSelected ? c.primary.withValues(alpha: 0.16) : null,
            border: isToday ? Border.all(color: c.primary, width: 2) : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Opacity(
            opacity: muted ? 0.4 : 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${day.solarDay}', style: context.text.bodyStrong),
                    Text(
                      _lunarText(),
                      style: keyDay
                          ? context.text.caption.copyWith(color: c.alarm3)
                          : context.text.caption,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2,
                      children: [
                        MoonGlyph(moon: day.moon, size: AppSpacing.md),
                        _SpringNeapMark(value: day.springNeap),
                      ],
                    ),
                    const SizedBox(height: 2),
                    _RangeBar(rangeCm: day.rangeCm, maxCm: maxRangeCm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ● spring · ○ neap: shape differs, not only colour.
class _SpringNeapMark extends StatelessWidget {
  const _SpringNeapMark({required this.value});

  final SpringNeap? value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const size = AppSpacing.sm;
    return switch (value) {
      SpringNeap.spring => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
      ),
      SpringNeap.neap => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.stale, width: 1.5),
        ),
      ),
      SpringNeap.normal || null => const SizedBox(width: size, height: size),
    };
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.rangeCm, required this.maxCm});

  final int? rangeCm;
  final int? maxCm;

  static const double _width = AppSpacing.xxl;

  @override
  Widget build(BuildContext context) {
    final r = rangeCm;
    final m = maxCm;
    final c = context.colors;
    final fraction = r == null || m == null || m <= 0 ? 0.0 : (r / m).clamp(0.0, 1.0);
    return Container(
      width: _width,
      height: 3,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: c.stale.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Container(
        width: _width * fraction,
        decoration: BoxDecoration(color: c.water, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
