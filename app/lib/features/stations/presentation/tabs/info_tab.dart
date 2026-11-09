import 'package:flutter/material.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/source_line.dart';

/// Coordinates, source, datum, confidence and measured error (S03 Thông tin, F-TIDE-09).
class InfoTab extends StatelessWidget {
  const InfoTab({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final station = view.tide.data.station;
    final model = view.tide.data.model;
    final live = view.now.liveSkill;
    final liveTime = live?.meanAbsExtremeTimeMin;
    final backtestCm = model?.rmseCm;
    final backtestMin = model?.extremeTimeErrMin;
    final fitFrom = model?.fitFrom;
    final fitTo = model?.fitTo;
    final lines = <String>[
      l10n.station_coords(station.lat.toStringAsFixed(3), station.lon.toStringAsFixed(3)),
      if (station.coordApprox) l10n.stations_coordApprox,
      if (fitFrom != null && fitTo != null && fitFrom.isNotEmpty)
        l10n.station_modelFit(fitFrom, fitTo),
      if (backtestCm != null && backtestMin != null)
        l10n.skill_backtest(LevelFormat.decimal1(backtestCm), backtestMin.round().toString())
      else
        l10n.skill_unknown,
      if (live != null && liveTime != null)
        l10n.skill_live(
          (live.sampleCount / 24).floor(),
          LevelFormat.decimal1(live.rmseCm),
          liveTime.round().toString(),
        ),
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(station.name, style: context.text.headline),
        Text(station.region, style: context.text.caption),
        const SizedBox(height: AppSpacing.md),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(line, style: context.text.body),
          ),
        const SizedBox(height: AppSpacing.md),
        SourceLine(view: view),
      ],
    );
  }
}
