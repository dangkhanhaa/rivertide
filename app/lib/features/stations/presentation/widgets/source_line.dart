import 'package:flutter/material.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// One short source line under every data block (CLAUDE.md 3.3); ⓘ expands
/// the full source, datum, update time, measured error and confidence.
class SourceLine extends StatefulWidget {
  const SourceLine({
    required this.view,
    this.showReference = true,
    this.initiallyOpen = false,
    this.showSource = true,
    super.key,
  });

  final StationView view;

  /// False where the reference station is already shown (point banner).
  final bool showReference;

  /// The info tab shows everything without a tap.
  final bool initiallyOpen;

  /// False on summary screens: sources live in Thêm → Nguồn dữ liệu and the
  /// station's Thông tin tab (owner decision 2026-11-09).
  final bool showSource;

  @override
  State<SourceLine> createState() => _SourceLineState();
}

class _SourceLineState extends State<SourceLine> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final view = widget.view;
    final station = view.tide.data.station;
    final model = view.tide.data.model;
    final isRiver = station.kind == StationKind.river || station.kind == StationKind.riverDaily;
    final withTide = model?.sourceName.contains('Open-Meteo') ?? false;
    final ref = view.tide.data.reference;
    final fetched = view.tide.fetchedAtUtc;
    final updated = isRiver
        ? '${TimeFormat.hm(fetched)} ${TimeFormat.dm(fetched)}'
        : TimeFormat.hm(fetched);
    final short = switch (station.kind) {
      StationKind.gauge => l10n.source_shortGauge,
      StationKind.model => l10n.source_shortModel,
      StationKind.river ||
      StationKind.riverDaily => withTide ? l10n.source_shortRiverTide : l10n.source_shortRiver,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ref != null && widget.showReference)
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
        if (widget.showSource)
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.source_compact(short, updated),
                  style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted),
                ),
              ),
              IconButton(
                tooltip: l10n.source_details,
                icon: Icon(_open ? Icons.expand_less_rounded : Icons.info_outline_rounded),
                onPressed: () => setState(() => _open = !_open),
              ),
            ],
          ),
        if (_open && widget.showSource) _Details(view: view, isRiver: isRiver, withTide: withTide),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.view, required this.isRiver, required this.withTide});

  final StationView view;
  final bool isRiver;
  final bool withTide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final station = view.tide.data.station;
    final model = view.tide.data.model;
    final mae = model?.rmseCm;
    final source = switch (station.kind) {
      StationKind.gauge => l10n.station_sourceGauge,
      StationKind.model => l10n.station_sourceModel,
      StationKind.river ||
      StationKind.riverDaily => withTide ? l10n.station_sourceRiverTide : l10n.station_sourceRiver,
    };
    final datum = switch (station.kind) {
      StationKind.gauge => l10n.station_datumChart,
      StationKind.model => l10n.station_datumMsl,
      StationKind.river || StationKind.riverDaily => l10n.station_datumNational,
    };
    final fetched = view.tide.fetchedAtUtc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SourceAttribution(source: source),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.station_datumNote(datum), style: context.text.caption),
        Text(
          isRiver
              ? l10n.station_issued('${TimeFormat.hm(fetched)} ${TimeFormat.dm(fetched)}')
              : l10n.common_updatedAt(TimeFormat.hm(fetched)),
          style: context.text.caption,
        ),
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
