import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// Water level chart: observed = solid, forecast = dashed, "now" line, high/low dots.
/// Tapping reports the touched hour via [onHourTap] (F-TIDE-09 sync).
class TideChart extends StatelessWidget {
  const TideChart({
    required this.fromUtc,
    required this.toUtc,
    required this.nowUtc,
    required this.observed,
    this.prediction,
    this.latestObservation,
    this.selectedHourUtc,
    this.onHourTap,
    this.height = 220,
    this.bandCm,
    super.key,
  });

  final DateTime fromUtc;
  final DateTime toUtc;
  final DateTime nowUtc;

  /// Measured levels (cm) by time, any resolution (10-minute or hourly).
  final Map<DateTime, double> observed;
  final TideSeries? prediction;

  /// Latest measurement: the dashed line starts there and is bias-corrected (F-TIDE-07),
  /// so solid and dashed lines join instead of jumping.
  final ({DateTime timeUtc, double levelCm})? latestObservation;
  final DateTime? selectedHourUtc;
  final ValueChanged<DateTime>? onHourTap;
  final double height;

  /// Half-width of the uncertainty band around the estimate (measured error), cm.
  final double? bandCm;

  static const double _axisStepM = 0.5;

  double _x(DateTime t) => t.difference(fromUtc).inMinutes / 60;

  List<FlSpot> _forecastSpots() {
    final p = prediction;
    if (p == null) return const [];
    final latest = latestObservation;
    final spots = <FlSpot>[];
    // With an anchoring observation the forecast continues from it; without one
    // (model points, river estimates) the whole window is drawn, past included.
    var start = latest == null
        ? fromUtc
        : (latest.timeUtc.isAfter(fromUtc) ? latest.timeUtc : nowUtc);
    if (start.isBefore(fromUtc)) start = fromUtc;
    for (var t = start; !t.isAfter(toUtc); t = t.add(const Duration(minutes: 20))) {
      final v = p.correctedLevelAt(t, obsTimeUtc: latest?.timeUtc, obsLevelCm: latest?.levelCm);
      if (v != null) spots.add(FlSpot(_x(t), v / 100));
    }
    return spots;
  }

  List<FlSpot> _observedSpots() {
    final keys = observed.keys.where((t) => !t.isBefore(fromUtc) && !t.isAfter(nowUtc));
    final sorted = keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      // Break the line across gaps > 70 min instead of drawing through missing data.
      if (i > 0 && sorted[i].difference(sorted[i - 1]) > const Duration(minutes: 70)) {
        spots.add(FlSpot.nullSpot);
      }
      final v = observed[sorted[i]];
      if (v != null) spots.add(FlSpot(_x(sorted[i]), v / 100));
    }
    return spots;
  }

  /// Y range snapped to 0.5 m so axis labels never collide.
  (double, double) _yRange(List<FlSpot> spots) {
    final ys = spots.where((s) => s != FlSpot.nullSpot).map((s) => s.y);
    if (ys.isEmpty) return (0, 1);
    final lo = (ys.reduce((a, b) => a < b ? a : b) / _axisStepM).floor() * _axisStepM;
    final hi = (ys.reduce((a, b) => a > b ? a : b) / _axisStepM).ceil() * _axisStepM;
    return (lo, hi == lo ? lo + _axisStepM : hi);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final observedSpots = _observedSpots();
    final forecast = _forecastSpots();
    final band = bandCm;
    final upper = band == null
        ? const <FlSpot>[]
        : [for (final s in forecast) FlSpot(s.x, s.y + band / 100)];
    final lower = band == null
        ? const <FlSpot>[]
        : [for (final s in forecast) FlSpot(s.x, s.y - band / 100)];
    final (minY, maxY) = _yRange([...observedSpots, ...forecast, ...upper, ...lower]);
    final chart = Semantics(
      label: context.l10n.chart_semantics,
      child: SizedBox(
        height: height,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: _x(toUtc),
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              _bar(
                observedSpots,
                c.water,
                dashed: false,
                // 6-hourly bulletin readings are isolated points: draw them as dots.
                dots: observedSpots.contains(FlSpot.nullSpot) || observedSpots.length < 3,
              ),
              _bar(forecast, c.tidePred, dashed: true),
              if (upper.isNotEmpty) ...[_edge(upper), _edge(lower)],
            ],
            betweenBarsData: [
              if (upper.isNotEmpty)
                BetweenBarsData(
                  fromIndex: 2,
                  toIndex: 3,
                  color: c.tidePred.withValues(alpha: 0.15),
                ),
            ],
            extraLinesData: ExtraLinesData(verticalLines: _verticalLines(context)),
            titlesData: _titles(context, maxY),
            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: c.stale.withValues(alpha: 0.2)),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: _touch(context),
          ),
        ),
      ),
    );
    if (band == null || upper.isEmpty) return chart;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chart,
        Text(context.l10n.chart_band(LevelFormat.decimal1(band)), style: context.text.caption),
      ],
    );
  }

  /// Invisible edge of the uncertainty band (filled by betweenBarsData).
  LineChartBarData _edge(List<FlSpot> spots) => LineChartBarData(
    spots: spots,
    barWidth: 0,
    isCurved: true,
    preventCurveOverShooting: true,
    dotData: const FlDotData(show: false),
  );

  LineChartBarData _bar(
    List<FlSpot> spots,
    Color color, {
    required bool dashed,
    bool dots = false,
  }) => LineChartBarData(
    spots: spots,
    color: color,
    barWidth: dashed ? 2 : 3,
    dashArray: dashed ? const [6, 4] : null,
    isCurved: true,
    preventCurveOverShooting: true,
    dotData: FlDotData(show: dots),
  );

  List<VerticalLine> _verticalLines(BuildContext context) {
    final c = context.colors;
    final lines = <VerticalLine>[];
    if (!nowUtc.isBefore(fromUtc) && !nowUtc.isAfter(toUtc)) {
      lines.add(
        VerticalLine(
          x: _x(nowUtc),
          color: c.alarm3,
          strokeWidth: 1.5,
          label: VerticalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: context.text.caption.copyWith(color: c.alarm3),
            labelResolver: (_) => context.l10n.hourly_now,
          ),
        ),
      );
    }
    final selected = selectedHourUtc;
    if (selected != null) {
      lines.add(VerticalLine(x: _x(selected), color: c.primary, dashArray: const [3, 3]));
    }
    return lines;
  }

  /// Left axis wide enough for the longest label ("111,5" on an upland river).
  double _axisWidth(BuildContext context, double maxY) {
    final chars = LevelFormat.metersShort(maxY * 100).length;
    return MediaQuery.textScalerOf(context).scale(8.0 * chars) + AppSpacing.md;
  }

  FlTitlesData _titles(BuildContext context, double maxY) => FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: _axisStepM,
        reservedSize: _axisWidth(context, maxY),
        getTitlesWidget: (v, meta) => SideTitleWidget(
          meta: meta,
          child: Text(
            LevelFormat.metersShort(v * 100),
            style: context.text.caption,
            softWrap: false,
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 6,
        reservedSize: 24,
        getTitlesWidget: (v, meta) => SideTitleWidget(
          meta: meta,
          child: Text(
            TimeFormat.hm(fromUtc.add(Duration(minutes: (v * 60).round()))),
            style: context.text.caption,
          ),
        ),
      ),
    ),
  );

  LineTouchData _touch(BuildContext context) => LineTouchData(
    touchCallback: (event, response) {
      final spot = response?.lineBarSpots?.firstOrNull;
      if (event is! FlTapUpEvent || spot == null || onHourTap == null) return;
      final t = fromUtc.add(Duration(minutes: (spot.x * 60).round()));
      onHourTap?.call(DateTime.utc(t.year, t.month, t.day, t.hour));
    },
    // Band edges are not data: no marker, no tooltip line.
    getTouchedSpotIndicator: (bar, indexes) => bar.barWidth == 0
        ? [for (final _ in indexes) null]
        : defaultTouchedIndicators(bar, indexes),
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => context.colors.surface,
      // Keep the bubble inside the chart so it never covers text above it.
      fitInsideVertically: true,
      fitInsideHorizontally: true,
      getTooltipItems: (spots) => [
        for (final s in spots)
          if (s.bar.barWidth == 0)
            null
          else
            LineTooltipItem(
              '${TimeFormat.hm(fromUtc.add(Duration(minutes: (s.x * 60).round())))} · '
              '${LevelFormat.meters(s.y * 100)}',
              context.text.caption.copyWith(color: s.bar.color),
            ),
      ],
    ),
  );
}
