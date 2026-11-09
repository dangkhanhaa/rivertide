import 'package:flutter/material.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Source, update time, datum and confidence under every data block (CLAUDE.md 3.3).
class SourceLine extends StatelessWidget {
  const SourceLine({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final station = view.tide.data.station;
    final model = view.tide.data.model;
    final isRiver = station.kind == StationKind.river || station.kind == StationKind.riverDaily;
    final ref = view.tide.data.reference;
    final mae = model?.rmseCm;
    final source = switch (station.kind) {
      StationKind.gauge => l10n.station_sourceGauge,
      StationKind.model => l10n.station_sourceModel,
      StationKind.river || StationKind.riverDaily =>
        model?.sourceName.contains('Open-Meteo') ?? false
            ? l10n.station_sourceRiverTide
            : l10n.station_sourceRiver,
    };
    final datum = switch (station.kind) {
      StationKind.gauge => l10n.station_datumChart,
      StationKind.model => l10n.station_datumMsl,
      StationKind.river || StationKind.riverDaily => l10n.station_datumNational,
    };
    final updated = isRiver
        ? l10n.station_issued(
            '${TimeFormat.hm(view.tide.fetchedAtUtc)} ${TimeFormat.dm(view.tide.fetchedAtUtc)}',
          )
        : l10n.common_updatedAt(TimeFormat.hm(view.tide.fetchedAtUtc));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ref != null)
          Text(
            ref.river == null
                ? l10n.point_reference(ref.name, LevelFormat.km(ref.distanceKm))
                : l10n.point_referenceRiver(
                    ref.name,
                    ref.river ?? '',
                    LevelFormat.km(ref.distanceKm),
                  ),
            style: context.text.bodyStrong,
          ),
        SourceAttribution(source: source),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.station_datumNote(datum), style: context.text.caption),
        Text(updated, style: context.text.caption),
        if (mae != null && isRiver)
          Text(l10n.station_backtestMae(LevelFormat.decimal1(mae)), style: context.text.caption),
        if (model != null)
          Text(
            l10n.confidence_label(context.confidenceName(model.confidence)),
            style: context.text.caption,
          ),
      ],
    );
  }
}
