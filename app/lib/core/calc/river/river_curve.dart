import 'dart:math' as math;

import 'package:rivertide/core/calc/tide/extreme_finder.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';

/// One KTTV bulletin value (observed or forecast) for a river station.
class RiverPoint {
  const RiverPoint({required this.timeUtc, required this.levelCm, required this.observed});

  final DateTime timeUtc;
  final double levelCm;
  final bool observed;
}

/// Hourly sea-level signal (e.g. Open-Meteo Marine at the river mouth), cm.
class HourlySignal {
  HourlySignal({required this.startUtc, required List<double?> values})
    : values = List.unmodifiable(values);

  final DateTime startUtc;
  final List<double?> values;

  /// Linear interpolation; null outside the data or across a gap.
  double? at(DateTime t) {
    final pos = t.difference(startUtc).inMinutes / 60;
    if (pos < 0 || pos > values.length - 1) return null;
    final i = pos.floor();
    final a = values[i];
    if (i == values.length - 1) return a;
    final b = values[i + 1];
    if (a == null || b == null) return null;
    return a + (b - a) * (pos - i);
  }
}

/// level(t) = intercept + slope·(t − t0) + gain·sea(t − lag), fitted by least squares.
/// Backtest at Hà Nội (tools/nchmf/river_backtest.py): 8,9 cm vs 21 cm for plain
/// interpolation of the 6-hourly points.
class RiverFit {
  const RiverFit({
    required this.lagHours,
    required this.gain,
    required this.intercept,
    required this.slopeCmPerH,
    required this.t0Utc,
    required this.rmsCm,
  });

  /// Hours the sea tide takes to reach the station (0.25 h steps).
  final double lagHours;
  final double gain;
  final double intercept;
  final double slopeCmPerH;
  final DateTime t0Utc;

  /// Residual RMS at the fitted points.
  final double rmsCm;

  double? levelAt(DateTime t, HourlySignal sea) {
    final s = sea.at(t.subtract(hoursToDuration(lagHours)));
    if (s == null) return null;
    return meanAt(t) + gain * s;
  }

  /// River (non-tidal) part of the level: intercept + slope·(t − t0).
  double meanAt(DateTime t) => intercept + slopeCmPerH * _hours(t, t0Utc);

  /// Along-river speed of the tide wave given the station's distance from the mouth.
  double celerityKmH(double stationKm) => lagHours <= 0 ? double.infinity : stationKm / lagHours;
}

/// Lags tried when propagating the sea tide up-river.
const double maxRiverLagHours = 24;

/// Lag resolution: backtest found Hà Nội 8,46 ± 0,34 h, so whole hours are too coarse.
const double riverLagStepHours = 0.25;

Duration hoursToDuration(double h) => Duration(seconds: (h * 3600).round());

/// Minimum points for a 3-parameter fit to mean anything.
const int minRiverFitPoints = 6;

double _hours(DateTime t, DateTime t0) => t.difference(t0).inMinutes / 60;

/// Best fit over lags 0..[maxLag]; null when too few points or the tide signal
/// does not explain the data (gain must be positive: the tide is not inverted).
RiverFit? fitTidalRiver(
  List<RiverPoint> points,
  HourlySignal sea, {
  double maxLag = maxRiverLagHours,
}) {
  if (points.length < minRiverFitPoints) return null;
  final t0 = points.first.timeUtc;
  RiverFit? best;
  var bestSse = double.infinity;
  final steps = (maxLag / riverLagStepHours).round();
  for (var k = 0; k <= steps; k++) {
    final lag = k * riverLagStepHours;
    final rows = <(double, double, double)>[]; // (t, sea, y)
    for (final p in points) {
      final s = sea.at(p.timeUtc.subtract(hoursToDuration(lag)));
      if (s != null) rows.add((_hours(p.timeUtc, t0), s, p.levelCm));
    }
    if (rows.length < minRiverFitPoints) continue;
    final coef = _solve3(rows);
    if (coef == null || coef.$3 <= 0) continue;
    var sse = 0.0;
    for (final (t, s, y) in rows) {
      final r = coef.$1 + coef.$2 * t + coef.$3 * s - y;
      sse += r * r;
    }
    if (sse < bestSse) {
      bestSse = sse;
      best = RiverFit(
        lagHours: lag,
        intercept: coef.$1,
        slopeCmPerH: coef.$2,
        gain: coef.$3,
        t0Utc: t0,
        rmsCm: math.sqrt(sse / rows.length),
      );
    }
  }
  return best;
}

/// Least squares for y = a + b·t + c·s via the 3×3 normal equations (Cramer).
(double, double, double)? _solve3(List<(double, double, double)> rows) {
  var n = 0.0;
  var st = 0.0;
  var ss = 0.0;
  var stt = 0.0;
  var sts = 0.0;
  var sss = 0.0;
  var sy = 0.0;
  var sty = 0.0;
  var ssy = 0.0;
  for (final (t, s, y) in rows) {
    n += 1;
    st += t;
    ss += s;
    stt += t * t;
    sts += t * s;
    sss += s * s;
    sy += y;
    sty += t * y;
    ssy += s * y;
  }
  double det(
    double a,
    double b,
    double c,
    double d,
    double e,
    double f,
    double g,
    double h,
    double i,
  ) => a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
  final d = det(n, st, ss, st, stt, sts, ss, sts, sss);
  if (d.abs() < 1e-9) return null;
  return (
    det(sy, st, ss, sty, stt, sts, ssy, sts, sss) / d,
    det(n, sy, ss, st, sty, sts, ss, ssy, sss) / d,
    det(n, st, sy, st, stt, sty, ss, sts, ssy) / d,
  );
}

/// Monotone cubic (Fritsch–Carlson): never overshoots between points, so it
/// never invents a peak the bulletin does not show.
double pchipAt(List<double> xs, List<double> ys, double x) {
  final n = xs.length;
  if (n == 0) throw ArgumentError('no points');
  if (n == 1 || x <= xs.first) return ys.first;
  if (x >= xs.last) return ys.last;
  final h = [for (var i = 0; i < n - 1; i++) xs[i + 1] - xs[i]];
  final delta = [for (var i = 0; i < n - 1; i++) (ys[i + 1] - ys[i]) / h[i]];
  final m = List<double>.filled(n, 0);
  m[0] = delta[0];
  m[n - 1] = delta[n - 2];
  for (var i = 1; i < n - 1; i++) {
    if (delta[i - 1] * delta[i] <= 0) continue;
    final w1 = 2 * h[i] + h[i - 1];
    final w2 = h[i] + 2 * h[i - 1];
    m[i] = (w1 + w2) / (w1 / delta[i - 1] + w2 / delta[i]);
  }
  var k = 0;
  while (k < n - 2 && x > xs[k + 1]) {
    k++;
  }
  final u = (x - xs[k]) / h[k];
  final u2 = u * u;
  final u3 = u2 * u;
  return (2 * u3 - 3 * u2 + 1) * ys[k] +
      (u3 - 2 * u2 + u) * h[k] * m[k] +
      (-2 * u3 + 3 * u2) * ys[k + 1] +
      (u3 - u2) * h[k] * m[k + 1];
}

/// Hourly curve between the first and last bulletin point.
///
/// Tidal stations use [fitTidalRiver] when [sea] is given and the fit works;
/// otherwise (and for non-tidal stations) monotone interpolation of the points.
({TideSeries series, RiverFit? fit})? buildRiverSeries({
  required List<RiverPoint> points,
  required bool tidal,
  HourlySignal? sea,
}) {
  if (points.length < 2) return null;
  final sorted = [...points]..sort((a, b) => a.timeUtc.compareTo(b.timeUtc));
  final first = sorted.first.timeUtc;
  final start = DateTime.utc(first.year, first.month, first.day, first.hour);
  final hours = (sorted.last.timeUtc.difference(start).inMinutes / 60).floor();
  final fit = tidal && sea != null ? fitTidalRiver(sorted, sea) : null;
  final fitted = switch ((fit, sea)) {
    (final f?, final s?) => (f, s),
    _ => null,
  };
  final xs = [for (final p in sorted) _hours(p.timeUtc, start)];
  final ys = [for (final p in sorted) p.levelCm];
  final levels = <double>[];
  for (var h = 0; h <= hours; h++) {
    final t = start.add(Duration(hours: h));
    levels.add(fitted?.$1.levelAt(t, fitted.$2) ?? pchipAt(xs, ys, h.toDouble()));
  }
  if (levels.length < 2) return null;
  return (
    series: TideSeries(
      startUtc: start,
      stepMinutes: 60,
      levelsCm: [for (final v in levels) v.round()],
      extremes: findExtremes(startUtc: start, stepMinutes: 60, levelsCm: levels),
    ),
    fit: fit,
  );
}
