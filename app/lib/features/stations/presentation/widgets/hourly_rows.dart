import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Fixed-height rows so the chart can scroll to an hour by index.
class HourlyRows extends StatelessWidget {
  const HourlyRows({
    required this.entries,
    required this.nowUtc,
    required this.controller,
    required this.rowExtent,
    required this.onTapHour,
    this.selectedHourUtc,
    super.key,
  });

  final List<TimelineEntry> entries;
  final DateTime nowUtc;
  final ScrollController controller;
  final double rowExtent;
  final ValueChanged<DateTime> onTapHour;
  final DateTime? selectedHourUtc;

  @override
  Widget build(BuildContext context) {
    final nowHour = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, nowUtc.hour);
    return ListView.builder(
      controller: controller,
      itemCount: entries.length,
      itemExtent: rowExtent,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemBuilder: (context, i) => switch (entries[i]) {
        final HourEntry h => _HourRow(
          entry: h,
          isNow: h.timeUtc == nowHour,
          isSelected: h.timeUtc == selectedHourUtc,
          onTap: () => onTapHour(h.timeUtc),
        ),
        final ExtremeEntry e => _ExtremeRow(extreme: e.extreme),
      },
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.entry,
    required this.isNow,
    required this.isSelected,
    required this.onTap,
  });

  final HourEntry entry;
  final bool isNow;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isObserved = entry.kind == LevelDataKind.observed;
    final style = isObserved ? context.text.bodyStrong : context.text.body;
    final state = entry.state;
    final rate = entry.rateCmPerH;
    return Material(
      color: isSelected
          ? c.primary.withValues(alpha: 0.12)
          : (isNow ? c.alarm3.withValues(alpha: 0.06) : c.surface),
      child: InkWell(
        onTap: onTap,
        // Two lines so narrow phones and text scale 1.6 never overflow.
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _Cell(
                top: TimeFormat.hm(entry.timeUtc),
                bottom: isNow ? '◄ ${context.l10n.hourly_now}' : null,
                topStyle: style,
                bottomStyle: context.text.caption.copyWith(color: c.alarm3),
              ),
            ),
            Expanded(
              flex: 2,
              child: _Cell(top: LevelFormat.meters(entry.levelCm), topStyle: style),
            ),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state != null) TrendLabel(state: state, compact: true),
                  Text(
                    [if (rate != null) LevelFormat.rate(rate), _kindText(context)].join(' · '),
                    style: context.text.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on _HourRow {
  String _kindText(BuildContext context) => switch (entry.kind) {
    LevelDataKind.observed => context.l10n.dataKind_observed,
    LevelDataKind.forecast => context.l10n.dataKind_forecast,
    LevelDataKind.estimate => context.l10n.dataKind_estimate,
  };
}

class _Cell extends StatelessWidget {
  const _Cell({required this.top, required this.topStyle, this.bottom, this.bottomStyle});

  final String top;
  final TextStyle topStyle;
  final String? bottom;
  final TextStyle? bottomStyle;

  @override
  Widget build(BuildContext context) {
    final b = bottom;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(top, style: topStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (b != null) Text(b, style: bottomStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _ExtremeRow extends StatelessWidget {
  const _ExtremeRow({required this.extreme});

  final TideExtreme extreme;

  @override
  Widget build(BuildContext context) {
    final isHigh = extreme.kind == TideExtremeKind.high;
    return Container(
      color: context.colors.tidePred.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            isHigh ? Icons.vertical_align_top_rounded : Icons.vertical_align_bottom_rounded,
            size: AppIconSize.sm,
            color: context.colors.tidePred,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '★ ${context.extremeName(extreme.kind)} ${TimeFormat.hm(extreme.timeUtc)} · '
              '${LevelFormat.meters(extreme.levelCm)} (${context.l10n.common_reference})',
              style: context.text.bodyStrong,
            ),
          ),
        ],
      ),
    );
  }
}
