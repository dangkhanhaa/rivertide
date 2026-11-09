import 'package:freezed_annotation/freezed_annotation.dart';

part 'station.freezed.dart';
part 'station.g.dart';

/// How a station gets its water levels in V0 (PROJECT.md 3.0).
@JsonEnum(fieldRename: FieldRename.snake)
enum StationKind {
  /// Real-time gauge (IOC) + harmonic prediction shipped with the app.
  gauge,

  /// Ocean model only (Open-Meteo Marine) — no measurements.
  model,

  /// KTTV river gauge: 4 bulletin observations/day + forecast; hourly curve is
  /// reconstructed in the app (core/calc/river).
  river,

  /// KTTV tidal-river gauge with only the 24–36 h highest/lowest values.
  riverDaily,
}

@freezed
abstract class Station with _$Station {
  const factory Station({
    required String id,
    required String name,
    required String region,
    required double lat,
    required double lon,
    required StationKind kind,
    @Default(false) bool coordApprox,
    String? iocCode,
    String? iocSensor,
    String? tideAsset,

    /// River name for river stations ("Hồng").
    String? river,

    /// Station label as printed in the KTTV bulletin, spaces removed ("HàNội").
    String? kttvKey,

    /// Water oscillates with the sea tide here (bulletin says "dao động theo triều").
    @Default(false) bool tidal,

    /// Sea point whose tide drives this river reach (Open-Meteo Marine).
    double? seaRefLat,
    double? seaRefLon,
  }) = _Station;

  factory Station.fromJson(Map<String, Object?> json) => _$StationFromJson(json);
}
