import 'package:rivertide/core/calc/river/river_curve.dart';
import 'package:rivertide/core/calc/tide/extreme_finder.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';

/// How far up- or downstream of the station a reach estimate may go. Beyond
/// this the linear blend below is no longer defensible.
const double maxReachUpstreamKm = 25;
const double maxReachDownstreamKm = 60;

/// Water level at another point of the same tidal river, between the mouth
/// (km 0) and the station (km [stationKm]), from two real boundary conditions:
///
/// * at the mouth the level is the sea tide itself (lag 0, gain 1, mean = the
///   national datum ≈ mean sea level at Hòn Dấu);
/// * at the station it is the fitted station model ([RiverFit]).
///
/// In between, lag, tide gain and river mean level vary linearly with km:
/// lag(x) = lag·f, gain(x) = 1 + (gain − 1)·f, mean(x, t) = mean(t)·f, with
/// f = x / stationKm. The lag part is a constant tide-wave speed
/// (stationKm / lag; Hà Nội: 165,6 km / 8,46 h ≈ 19,6 km/h). Not validated at
/// a second gauge — shown as an estimate with its assumptions.
class RiverReach {
  const RiverReach({required this.fit, required this.stationKm, required this.pointKm})
    : assert(stationKm > 0, 'station must be upstream of the mouth');

  final RiverFit fit;
  final double stationKm;
  final double pointKm;

  double get _f => pointKm / stationKm;

  /// Positive upstream of the station.
  double get alongKm => pointKm - stationKm;

  double get lagHours => fit.lagHours * _f;

  /// Negative: the tide turns here earlier than at the station.
  double get lagShiftMinutes => (lagHours - fit.lagHours) * 60;

  double get gain => (1 + (fit.gain - 1) * _f).clamp(0.0, double.infinity);

  double get celerityKmH => fit.celerityKmH(stationKm);

  bool get inRange =>
      pointKm > 0 && alongKm <= maxReachUpstreamKm && alongKm >= -maxReachDownstreamKm;

  /// River mean-level difference to the station at time [t] (negative downstream).
  double meanShiftCm(DateTime t) => fit.meanAt(t) * (_f - 1);

  double? levelAt(DateTime t, HourlySignal sea) {
    final s = sea.at(t.subtract(hoursToDuration(lagHours)));
    if (s == null) return null;
    return fit.meanAt(t) * _f + gain * s;
  }

  /// Hourly curve over [fromUtc]..[toUtc], trimmed to where sea data exists.
  TideSeries? series(HourlySignal sea, DateTime fromUtc, DateTime toUtc) {
    DateTime? first;
    final levels = <double>[];
    var t = DateTime.utc(fromUtc.year, fromUtc.month, fromUtc.day, fromUtc.hour);
    for (; !t.isAfter(toUtc); t = t.add(const Duration(hours: 1))) {
      final v = levelAt(t, sea);
      if (v == null) {
        if (first == null) continue; // sea data not started yet
        break; // stop at the first gap: series must be regular
      }
      first ??= t;
      levels.add(v);
    }
    final start = first;
    if (start == null || levels.length < 2) return null;
    return TideSeries(
      startUtc: start,
      stepMinutes: 60,
      levelsCm: [for (final v in levels) v.round()],
      extremes: findExtremes(startUtc: start, stepMinutes: 60, levelsCm: levels),
    );
  }
}
