import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/calc/tide/observation.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/features/stations/domain/station.dart';

part 'station_tide.freezed.dart';

enum TideConfidence { high, medium, low }

/// Where the prediction came from and how good it measured (P0-05 / F-TIDE-09).
@freezed
abstract class TideModelInfo with _$TideModelInfo {
  const factory TideModelInfo({
    required String sourceName,
    required TideConfidence confidence,
    double? rmseCm,
    double? extremeTimeErrMin,
    double? extremeHeightErrCm,
    String? fitFrom,
    String? fitTo,
  }) = _TideModelInfo;
}

/// Highest/lowest values a KTTV bulletin gives for tidal rivers (no times).
@freezed
abstract class DailyExtremes with _$DailyExtremes {
  const factory DailyExtremes({
    required int windowHours,
    required int obsMaxCm,
    required int obsMinCm,
    required int fcMaxCm,
    required int fcMinCm,
    required DateTime issuedUtc,
  }) = _DailyExtremes;
}

/// Station used for a map point that has no data of its own.
@freezed
abstract class ReferenceStation with _$ReferenceStation {
  const factory ReferenceStation({
    required String stationId,
    required String name,
    required double distanceKm,
    String? river,
  }) = _ReferenceStation;
}

/// Everything the station screens need about water level for one station.
@freezed
abstract class StationTide with _$StationTide {
  const factory StationTide({
    required Station station,
    required List<WaterObservation> observations,
    required LevelDataKind predictionKind,
    TideSeries? prediction,
    TideModelInfo? model,

    /// False when nudging the forecast toward the last observation makes it worse
    /// (river backtest: 11,3 cm with vs 8,9 cm without).
    @Default(true) bool correctWithObservations,
    DailyExtremes? dailyExtremes,

    /// For a map point: the station whose data stands in for it.
    ReferenceStation? reference,
  }) = _StationTide;

  const StationTide._();

  /// Latest observation used to correct the forecast, or null when not wanted.
  ({DateTime timeUtc, double levelCm})? get anchor {
    if (!correctWithObservations || observations.isEmpty) return null;
    final o = latestObservation(observations);
    return o == null ? null : (timeUtc: o.timeUtc, levelCm: o.levelCm);
  }
}
