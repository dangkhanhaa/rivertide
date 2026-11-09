import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';

/// Visual data classes (CLAUDE.md 3.3): solid / dashed / hatched + label.
enum LevelDataKind { observed, forecast, estimate }

sealed class TimelineEntry {
  const TimelineEntry(this.timeUtc);
  final DateTime timeUtc;
}

final class HourEntry extends TimelineEntry {
  const HourEntry({
    required DateTime hourUtc,
    required this.levelCm,
    required this.kind,
    this.rateCmPerH,
    this.predictedCm,
  }) : super(hourUtc);

  final double levelCm;
  final LevelDataKind kind;
  final double? rateCmPerH;

  /// Raw model value at this hour, for the "observed − forecast" detail.
  final double? predictedCm;

  TideState? get state {
    final rate = rateCmPerH;
    return rate == null ? null : classifyRate(rate);
  }

  double? get observedMinusPredictedCm {
    final predicted = predictedCm;
    return kind == LevelDataKind.observed && predicted != null ? levelCm - predicted : null;
  }
}

final class ExtremeEntry extends TimelineEntry {
  ExtremeEntry(this.extreme) : super(extreme.timeUtc);
  final TideExtreme extreme;
}

/// Builds the F-TIDE-09 list: one row per hour plus high/low rows at their exact minute.
///
/// Past hours use [observedHourly] when present; future hours use [prediction]
/// corrected by the latest observation. Hours with neither are left out (no invented data).
List<TimelineEntry> buildHourlyTimeline({
  required DateTime nowUtc,
  required Map<DateTime, double> observedHourly,
  TideSeries? prediction,
  LevelDataKind predictionKind = LevelDataKind.forecast,
  ({DateTime timeUtc, double levelCm})? latestObservation,
  int hoursBefore = 6,
  int hoursAfter = 18,
}) {
  final nowHour = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, nowUtc.hour);
  final from = nowHour.subtract(Duration(hours: hoursBefore));
  final to = nowHour.add(Duration(hours: hoursAfter));
  final entries = <TimelineEntry>[];
  for (var h = from; !h.isAfter(to); h = h.add(const Duration(hours: 1))) {
    final row = _hourRow(h, nowUtc, observedHourly, prediction, predictionKind, latestObservation);
    if (row != null) entries.add(row);
  }
  if (prediction != null) {
    final end = to.add(const Duration(minutes: 1));
    entries.addAll(prediction.extremesBetween(from, end).map(ExtremeEntry.new));
  }
  entries.sort((a, b) => a.timeUtc.compareTo(b.timeUtc));
  return entries;
}

HourEntry? _hourRow(
  DateTime h,
  DateTime nowUtc,
  Map<DateTime, double> observed,
  TideSeries? prediction,
  LevelDataKind predictionKind,
  ({DateTime timeUtc, double levelCm})? latest,
) {
  final predicted = prediction?.levelAt(h);
  final obs = observed[h];
  if (!h.isAfter(nowUtc) && obs != null) {
    return HourEntry(
      hourUtc: h,
      levelCm: obs,
      kind: LevelDataKind.observed,
      rateCmPerH: _observedRate(h, observed) ?? prediction?.rateCmPerHAt(h),
      predictedCm: predicted,
    );
  }
  if (prediction == null || predicted == null) return null;
  final corrected = prediction.correctedLevelAt(
    h,
    obsTimeUtc: latest?.timeUtc,
    obsLevelCm: latest?.levelCm,
  );
  return HourEntry(
    hourUtc: h,
    levelCm: corrected ?? predicted,
    kind: predictionKind,
    rateCmPerH: prediction.rateCmPerHAt(h),
    predictedCm: predicted,
  );
}

/// Centered difference when both neighbours exist, else one-sided.
double? _observedRate(DateTime h, Map<DateTime, double> observed) {
  final prev = observed[h.subtract(const Duration(hours: 1))];
  final next = observed[h.add(const Duration(hours: 1))];
  final cur = observed[h];
  if (cur == null) return null;
  if (prev != null && next != null) return (next - prev) / 2;
  if (prev != null) return cur - prev;
  if (next != null) return next - cur;
  return null;
}
