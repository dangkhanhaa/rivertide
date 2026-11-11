import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/calendar/calendar_month.dart';
import 'package:rivertide/features/stations/presentation/widgets/calendar/day_detail.dart';
import 'package:rivertide/features/stations/presentation/widgets/calendar/month_grid.dart';

/// P1-27 / F-TIDE-04: month grid with lunar days, moon, spring/neap and daily
/// range; swipe or arrows change month, tapping a day shows its highs/lows.
class CalendarTab extends StatefulWidget {
  const CalendarTab({required this.view, super.key});

  final StationView view;

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  static const int _startPage = 1; // the list starts one month back
  late final List<(int, int)> _months = calendarMonths(widget.view.nowUtc);
  late final PageController _pages = PageController(initialPage: _startPage);
  final Map<int, CalendarMonth> _built = {};
  int _page = _startPage;
  late DateTime _selected = TimeFormat.vnDayStartUtc(widget.view.nowUtc);

  TideSeries? get _prediction => widget.view.tide.data.prediction;

  // Each month walks ~40 days × 29-day spring/neap windows: build once.
  CalendarMonth _month(int i) =>
      _built[i] ??= CalendarMonth.build(_months[i].$1, _months[i].$2, _prediction);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onPage(int i) {
    final today = TimeFormat.vnDayStartUtc(widget.view.nowUtc);
    final month = _month(i);
    final hasToday = month.days.any((d) => d.inMonth && d.dayStartUtc == today);
    setState(() {
      _page = i;
      _selected = hasToday ? today : month.days.firstWhere((d) => d.inMonth).dayStartUtc;
    });
  }

  void _go(int delta) {
    final target = (_page + delta).clamp(0, _months.length - 1);
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final month = _month(_page);
    final today = TimeFormat.vnDayStartUtc(widget.view.nowUtc);
    final selected = month.days.where((d) => d.dayStartUtc == _selected).firstOrNull;
    final weeks = month.days.length ~/ 7;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.calendar_prev,
              onPressed: _page > 0 ? () => _go(-1) : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                l10n.calendar_month(month.month, month.year),
                style: context.text.title,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: l10n.calendar_next,
              onPressed: _page < _months.length - 1 ? () => _go(1) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        SizedBox(
          // Weekday header + rows; the header grows with the text size.
          height: weeks * (MonthGrid.cellHeight + 2) + AppSpacing.xl * scale,
          child: PageView.builder(
            controller: _pages,
            itemCount: _months.length,
            onPageChanged: _onPage,
            itemBuilder: (_, i) => MonthGrid(
              month: _month(i),
              todayUtc: today,
              selectedUtc: _selected,
              onSelect: (d) => setState(() => _selected = d.dayStartUtc),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _Legend(),
        if (!month.hasTide)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(l10n.calendar_noTideMonth, style: context.text.caption),
          ),
        const SizedBox(height: AppSpacing.md),
        if (selected != null)
          DayDetail(day: selected, prediction: _prediction, nowUtc: widget.view.nowUtc),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    const dot = AppSpacing.sm;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _item(
          context,
          Container(
            width: dot,
            height: dot,
            decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
          ),
          l10n.tide_spring,
        ),
        _item(
          context,
          Container(
            width: dot,
            height: dot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.stale, width: 1.5),
            ),
          ),
          l10n.tide_neap,
        ),
        _item(
          context,
          Container(width: AppSpacing.lg, height: 3, color: c.water),
          l10n.calendar_rangeLegend,
        ),
        Text(l10n.calendar_lunarLegend, style: context.text.caption.copyWith(color: c.alarm3)),
      ],
    );
  }

  Widget _item(BuildContext context, Widget mark, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: AppSpacing.xs,
    children: [
      mark,
      Text(label, style: context.text.caption),
    ],
  );
}
