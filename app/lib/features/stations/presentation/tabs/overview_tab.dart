import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/presentation/widgets/countdown_card.dart';
import 'package:rivertide/features/stations/presentation/widgets/daily_extremes_card.dart';
import 'package:rivertide/features/stations/presentation/widgets/flow_card.dart';
import 'package:rivertide/features/stations/presentation/widgets/source_line.dart';
import 'package:rivertide/features/stations/presentation/widgets/station_sheet.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_chart.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = view.now;
    final tide = view.tide.data;
    final correction = now.correctionCm;
    final springNeap = now.springNeap;
    final range = now.dailyRangeCm;
    final daily = tide.dailyExtremes;
    if (levelUnknown(tide)) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [FlowCard(stationId: tide.station.id, nowUtc: view.nowUtc, primary: true)],
      );
    }
    if (tide.prediction == null && daily != null) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          DailyExtremesCard(extremes: daily),
          const SizedBox(height: AppSpacing.md),
          SourceLine(view: view, showSource: false, showReference: false),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        LevelHeroBlock(view: view),
        const SizedBox(height: AppSpacing.lg),
        CountdownCard(now: now, nowUtc: view.nowUtc),
        const SizedBox(height: AppSpacing.lg),
        TideChart(
          bandCm: tide.predictionKind == LevelDataKind.estimate ? tide.model?.rmseCm : null,
          // Whole-hour window so axis ticks fall on 00:00, 06:00, …
          fromUtc: _hourFloor(view.nowUtc).subtract(const Duration(hours: 12)),
          toUtc: _hourFloor(view.nowUtc).add(const Duration(hours: 24)),
          nowUtc: view.nowUtc,
          observed: {for (final o in tide.observations) o.timeUtc: o.levelCm},
          prediction: tide.prediction,
          latestObservation: tide.anchor,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              '${l10n.common_today}: ${l10n.station_lunarDay(now.lunar.day, now.lunar.month)}',
              style: context.text.body,
            ),
            if (springNeap != null)
              Text(context.springNeapName(springNeap), style: context.text.body),
            if (range != null)
              Text(l10n.station_dailyRange(LevelFormat.meters(range)), style: context.text.body),
          ],
        ),
        if (correction != null && tide.prediction != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.tide_correctedBy(LevelFormat.signedCm(correction)),
            style: context.text.caption,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        SourceLine(view: view, showSource: false, showReference: false),
        if (tide.station.kind == StationKind.river)
          FlowCard(stationId: tide.station.id, nowUtc: view.nowUtc),
      ],
    );
  }
}

DateTime _hourFloor(DateTime t) => DateTime.utc(t.year, t.month, t.day, t.hour);

/// Hero number wrapped in a card.
class LevelHeroBlock extends StatelessWidget {
  const LevelHeroBlock({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LevelHeroContent(view: view),
    ),
  );
}

class LevelHeroContent extends StatelessWidget {
  const LevelHeroContent({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final level = view.now.levelCm;
    final state = view.now.state;
    final rate = view.now.rateCmPerH;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(context.l10n.station_levelNow, style: context.text.label),
            DataKindBadge(kind: view.now.kind),
          ],
        ),
        Semantics(
          label: [
            context.l10n.station_levelNow,
            if (level != null) LevelFormat.meters(level),
            if (rate != null) LevelFormat.rate(rate),
          ].join(', '),
          excludeSemantics: true,
          child: Text(
            level == null ? '—' : LevelFormat.meters(level),
            style: context.text.displayLevel,
          ),
        ),
        if (state != null)
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TrendLabel(state: state),
              if (rate != null) Text('(${LevelFormat.rate(rate)})', style: context.text.body),
            ],
          ),
      ],
    );
  }
}
