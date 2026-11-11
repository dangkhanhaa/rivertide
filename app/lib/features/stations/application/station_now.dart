import 'package:rivertide/core/calc/lunar/lunar_calendar.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/calc/tide/observation.dart';
import 'package:rivertide/core/calc/tide/skill.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

/// An observation older than this is not "now" any more; fall back to the forecast.
const Duration observationFreshness = Duration(minutes: 40);

/// How long after the data ends its last value is still shown (with its time).
/// KTTV forecasts end at 07:00 VN and the next bulletin comes ~10:30 VN; a
/// missed day still shows yesterday's level, older than this shows nothing.
const Duration lastKnownMaxAge = Duration(hours: 36);

/// Everything the overview card shows, derived from [StationTide] at one instant.
class StationNow {
  const StationNow({
    required this.levelCm,
    required this.kind,
    required this.observedHourly,
    required this.lunar,
    this.rateCmPerH,
    this.nextExtreme,
    this.followingExtreme,
    this.isTurning = false,
    this.springNeap,
    this.dailyRangeCm,
    this.correctionCm,
    this.liveSkill,
    this.lastObservationUtc,
    this.lastKnown,
  });

  final double? levelCm;
  final LevelDataKind kind;
  final double? rateCmPerH;
  final TideExtreme? nextExtreme;
  final TideExtreme? followingExtreme;
  final bool isTurning;
  final SpringNeap? springNeap;
  final int? dailyRangeCm;

  /// Latest observed − predicted, used to nudge the forecast (F-TIDE-07).
  final double? correctionCm;
  final Map<DateTime, double> observedHourly;
  final TideSkill? liveSkill;

  /// Time of the newest measurement, null for model points.
  final DateTime? lastObservationUtc;

  /// When there is no value for now (forecast ran out, readings stopped): the
  /// newest value there is and its time, so screens show it as old data.
  final ({DateTime timeUtc, double levelCm})? lastKnown;
  final LunarDate lunar;

  TideState? get state {
    final rate = rateCmPerH;
    return rate == null ? null : classifyRate(rate);
  }
}

StationNow computeStationNow(StationTide tide, DateTime nowUtc) {
  final prediction = tide.prediction;
  // Ignore readings stamped after "now" (device clock behind the source).
  final latest = latestObservation([
    for (final o in tide.observations)
      if (!o.timeUtc.isAfter(nowUtc)) o,
  ]);
  final hasFreshObs = latest != null && nowUtc.difference(latest.timeUtc) <= observationFreshness;
  final observedHourly = tide.observations.isEmpty
      ? const <DateTime, double>{}
      : hourlyMeans(
          tide.observations,
          tide.observations.first.timeUtc,
          nowUtc,
          minSamples: 1, // observations are already 10-minute means
        );
  final anchor = tide.anchor;
  final predAtAnchor = anchor == null ? null : prediction?.levelAt(anchor.timeUtc);
  final next = prediction?.nextExtreme(nowUtc);
  final dayStart = TimeFormat.vnDayStartUtc(nowUtc);
  final vn = TimeFormat.toVn(nowUtc);
  final level = hasFreshObs
      ? latest.levelCm
      : prediction?.correctedLevelAt(
          nowUtc,
          obsTimeUtc: anchor?.timeUtc,
          obsLevelCm: anchor?.levelCm,
        );
  return StationNow(
    levelCm: level,
    lastKnown: level == null ? _lastKnown(prediction, latest, nowUtc) : null,
    kind: hasFreshObs ? LevelDataKind.observed : tide.predictionKind,
    rateCmPerH: prediction?.rateCmPerHAt(nowUtc),
    nextExtreme: next,
    followingExtreme: next == null ? null : prediction?.nextExtreme(next.timeUtc),
    isTurning: prediction?.isTurning(nowUtc) ?? false,
    springNeap: prediction?.springNeapAt(dayStart),
    dailyRangeCm: prediction?.dailyRangeCm(dayStart),
    correctionCm: anchor == null || predAtAnchor == null ? null : anchor.levelCm - predAtAnchor,
    observedHourly: observedHourly,
    liveSkill: prediction == null ? null : computeSkill(observedHourly, prediction),
    lunar: solarToLunar(vn.year, vn.month, vn.day),
    lastObservationUtc: latest?.timeUtc,
  );
}

({DateTime timeUtc, double levelCm})? _lastKnown(
  TideSeries? prediction,
  WaterObservation? latest,
  DateTime nowUtc,
) {
  final candidates = [
    if (latest != null) (timeUtc: latest.timeUtc, levelCm: latest.levelCm),
    if (prediction != null && prediction.levelsCm.isNotEmpty && prediction.endUtc.isBefore(nowUtc))
      (timeUtc: prediction.endUtc, levelCm: prediction.levelsCm.last.toDouble()),
  ];
  if (candidates.isEmpty) return null;
  final newest = candidates.reduce((a, b) => b.timeUtc.isAfter(a.timeUtc) ? b : a);
  return nowUtc.difference(newest.timeUtc) > lastKnownMaxAge ? null : newest;
}
