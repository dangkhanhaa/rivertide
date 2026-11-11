import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Big number for the place: level, direction + speed, short place context.
class LocationHero extends StatelessWidget {
  const LocationHero({required this.view, this.place, super.key});

  final StationView view;

  /// "Sông Hồng", "Trên mặt nước"… — where, not how it was computed.
  final String? place;

  @override
  Widget build(BuildContext context) {
    final now = view.now;
    final last = now.levelCm == null ? now.lastKnown : null;
    final level = now.levelCm ?? last?.levelCm;
    final state = now.state;
    final rate = now.rateCmPerH;
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.water.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(place ?? context.l10n.station_levelNow, style: context.text.label),
              ),
              DataKindBadge(kind: now.kind),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                level == null ? '—' : LevelFormat.meters(level),
                style: context.text.displayLevel,
              ),
              if (state != null) TrendLabel(state: state),
              if (rate != null) Text(LevelFormat.rate(rate), style: context.text.body),
            ],
          ),
          if (last != null)
            Text(context.lastKnownText(last.timeUtc, view.nowUtc), style: context.text.caption),
        ],
      ),
    );
  }
}

/// Next high and next low side by side: time, level, countdown, cm to go.
class NextTurns extends StatelessWidget {
  const NextTurns({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final p = view.tide.data.prediction;
    if (p == null) return const SizedBox.shrink();
    final first = view.now.nextExtreme;
    final second = view.now.followingExtreme;
    if (first == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TurnTile(view: view, extreme: first, emphasis: true),
        ),
        if (second != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _TurnTile(view: view, extreme: second, emphasis: false),
          ),
        ],
      ],
    );
  }
}

class _TurnTile extends StatelessWidget {
  const _TurnTile({required this.view, required this.extreme, required this.emphasis});

  final StationView view;
  final TideExtreme extreme;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isHigh = extreme.kind == TideExtremeKind.high;
    final change = emphasis ? context.changeToNext(view.now.levelCm, extreme) : null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: emphasis ? c.primary : c.stale.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHigh ? Icons.vertical_align_top_rounded : Icons.vertical_align_bottom_rounded,
                size: AppIconSize.sm,
                color: c.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(child: Text(context.extremeName(extreme.kind), style: context.text.label)),
            ],
          ),
          Text(
            context.relativeTime(extreme.timeUtc, view.nowUtc),
            style: emphasis ? context.text.title : context.text.bodyStrong,
          ),
          Text(LevelFormat.meters(extreme.levelCm), style: context.text.body),
          Text(
            context.l10n.turn_in(context.durationText(extreme.timeUtc.difference(view.nowUtc))),
            style: context.text.caption,
          ),
          if (change != null) Text(change, style: context.text.caption),
        ],
      ),
    );
  }
}

/// Today's highest / lowest (Vietnam day) from the curve, with times.
class DayStats extends StatelessWidget {
  const DayStats({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final p = view.tide.data.prediction;
    // A forecast that ended earlier today would give a half-day "today" range.
    if (p == null || !p.covers(view.nowUtc)) return const SizedBox.shrink();
    final start = TimeFormat.vnDayStartUtc(view.nowUtc);
    final end = start.add(const Duration(days: 1));
    ({DateTime t, double v})? hi;
    ({DateTime t, double v})? lo;
    for (var t = start; t.isBefore(end); t = t.add(const Duration(minutes: 30))) {
      final v = p.levelAt(t);
      if (v == null) continue;
      if (hi == null || v > hi.v) hi = (t: t, v: v);
      if (lo == null || v < lo.v) lo = (t: t, v: v);
    }
    final (h, l) = (hi, lo);
    if (h == null || l == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.common_today, style: context.text.label),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _Chip(l10n.day_high(LevelFormat.meters(h.v), TimeFormat.hm(h.t))),
            _Chip(l10n.day_low(LevelFormat.meters(l.v), TimeFormat.hm(l.t))),
            _Chip(l10n.day_range((h.v - l.v).round())),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
    decoration: BoxDecoration(
      color: context.colors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Text(text, style: context.text.body),
  );
}
