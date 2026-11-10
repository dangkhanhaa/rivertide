import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/hour_detail_panel.dart';
import 'package:rivertide/features/stations/presentation/widgets/hourly_rows.dart';
import 'package:rivertide/features/stations/presentation/widgets/hourly_weather_list.dart';
import 'package:rivertide/features/stations/presentation/widgets/station_sheet.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_chart.dart';

/// F-TIDE-09: chart + hourly list kept in sync; tapping the chart scrolls the list
/// and opens the detail panel for that hour.
class HourlyTab extends StatefulWidget {
  const HourlyTab({required this.view, super.key});

  final StationView view;

  @override
  State<HourlyTab> createState() => _HourlyTabState();
}

class _HourlyTabState extends State<HourlyTab> {
  static const double _rowExtent = 64;
  final _scroll = ScrollController();
  DateTime? _selected;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<TimelineEntry> _entries() {
    final tide = widget.view.tide.data;
    return buildHourlyTimeline(
      nowUtc: widget.view.nowUtc,
      observedHourly: widget.view.now.observedHourly,
      prediction: tide.prediction,
      predictionKind: tide.predictionKind,
      latestObservation: tide.anchor,
      hoursAfter: 72,
    );
  }

  void _select(DateTime hourUtc, List<TimelineEntry> entries) {
    setState(() => _selected = hourUtc);
    final index = entries.indexWhere((e) => e is HourEntry && e.timeUtc == hourUtc);
    if (index < 0 || !_scroll.hasClients) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final offset = (index * _rowExtent).clamp(0.0, _scroll.position.maxScrollExtent);
    if (reduceMotion) {
      _scroll.jumpTo(offset);
    } else {
      _scroll.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (levelUnknown(widget.view.tide.data)) return HourlyWeatherList(view: widget.view);
    final entries = _entries();
    if (entries.isEmpty) return EmptyView(message: context.l10n.hourly_empty);
    final view = widget.view;
    final nowHour = DateTime.utc(
      view.nowUtc.year,
      view.nowUtc.month,
      view.nowUtc.day,
      view.nowUtc.hour,
    );
    final selected = _selected;
    final selectedEntry = selected == null
        ? null
        : entries.whereType<HourEntry>().where((e) => e.timeUtc == selected).firstOrNull;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          child: TideChart(
            fromUtc: nowHour.subtract(const Duration(hours: 6)),
            toUtc: nowHour.add(const Duration(hours: 18)),
            nowUtc: view.nowUtc,
            // Hourly means here, so the chart matches the list rows exactly.
            observed: view.now.observedHourly,
            prediction: view.tide.data.prediction,
            latestObservation: view.tide.data.anchor,
            selectedHourUtc: selected,
            onHourTap: (h) => _select(h, entries),
            height: 180,
          ),
        ),
        if (selectedEntry != null)
          HourDetailPanel(
            entry: selectedEntry,
            view: view,
            onClose: () => setState(() => _selected = null),
          ),
        Expanded(
          child: HourlyRows(
            entries: entries,
            nowUtc: view.nowUtc,
            controller: _scroll,
            rowExtent: _rowExtent,
            selectedHourUtc: selected,
            onTapHour: (h) => _select(h, entries),
          ),
        ),
      ],
    );
  }
}
