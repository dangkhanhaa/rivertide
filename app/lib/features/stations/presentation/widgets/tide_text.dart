import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

/// Icon per station kind (list, search, map sheet).
IconData stationKindIcon(StationKind kind) => switch (kind) {
  StationKind.gauge => Icons.sensors_rounded,
  StationKind.model => Icons.waves_rounded,
  StationKind.river || StationKind.riverDaily => Icons.water_rounded,
};

/// l10n-backed wording shared by the station widgets.
extension TideText on BuildContext {
  /// "2 giờ 15 phút" / "40 phút" (rounded down to the minute, never negative).
  String durationText(Duration d) {
    final total = d.isNegative ? 0 : d.inMinutes;
    final h = total ~/ 60;
    final m = total % 60;
    return h == 0 ? l10n.duration_m(m) : l10n.duration_hm(h, m);
  }

  String stationKindLabel(StationKind kind) => switch (kind) {
    StationKind.gauge => l10n.stations_kindGauge,
    StationKind.model => l10n.stations_kindModel,
    StationKind.river => l10n.stations_kindRiver,
    StationKind.riverDaily => l10n.stations_kindRiverDaily,
  };

  /// "Nước còn lên thêm khoảng 33 cm" from now to the next turn; null if unknown
  /// or under 1 cm (the turn is now).
  String? changeToNext(double? levelNowCm, TideExtreme next) {
    if (levelNowCm == null) return null;
    final delta = (next.levelCm - levelNowCm).round();
    if (delta.abs() < 1) return null;
    return delta > 0 ? l10n.tide_moreRise(delta) : l10n.tide_moreFall(-delta);
  }

  String extremeName(TideExtremeKind kind) =>
      kind == TideExtremeKind.high ? l10n.tide_high : l10n.tide_low;

  /// "14:40", or "Mai 01:15" when the time is on the next Vietnam day (AC-TIDE02-3).
  String relativeTime(DateTime utc, DateTime nowUtc) {
    final hm = TimeFormat.hm(utc);
    if (TimeFormat.sameVnDay(utc, nowUtc)) return hm;
    final tomorrow = nowUtc.add(const Duration(days: 1));
    if (TimeFormat.sameVnDay(utc, tomorrow)) return '${l10n.common_tomorrow} $hm';
    return '${TimeFormat.dayShort(utc)} $hm';
  }

  String springNeapName(SpringNeap s) => switch (s) {
    SpringNeap.spring => l10n.tide_spring,
    SpringNeap.neap => l10n.tide_neap,
    SpringNeap.normal => l10n.tide_normal,
  };

  String confidenceName(TideConfidence c) => switch (c) {
    TideConfidence.high => l10n.confidence_high,
    TideConfidence.medium => l10n.confidence_medium,
    TideConfidence.low => l10n.confidence_low,
  };
}
