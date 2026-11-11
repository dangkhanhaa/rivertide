import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/level_format.dart';
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

  /// Lines describing how a map point relates to its reference station:
  /// along-river position, tide timing, mean level and tide-wave speed.
  List<String> referenceLines(ReferenceStation ref) {
    final along = ref.alongKm;
    if (ref.stationId == coastReferenceId) {
      return [l10n.point_basisCoast];
    }
    if (along == null) {
      return [
        if (ref.river case final river?)
          l10n.point_basisRiver(ref.name, river, LevelFormat.km(ref.distanceKm))
        else
          l10n.point_basisStation(ref.name, LevelFormat.km(ref.distanceKm)),
      ];
    }
    final river = ref.river ?? '';
    final dist = LevelFormat.km(along.abs());
    final lag = (ref.lagShiftMinutes ?? 0).round();
    final mean = (ref.meanShiftCm ?? 0).round();
    return [
      if (along < 0)
        l10n.point_alongDown(ref.name, dist, river)
      else
        l10n.point_alongUp(ref.name, dist, river),
      if (lag.abs() < 2)
        l10n.point_lagSame
      else if (lag < 0)
        l10n.point_lagEarlier(-lag)
      else
        l10n.point_lagLater(lag),
      if (mean <= -1) l10n.point_meanLower(-mean) else if (mean >= 1) l10n.point_meanHigher(mean),
      if (ref.celerityKmH case final c?) l10n.point_celerity(LevelFormat.decimal1(c)),
      l10n.point_reachNote,
    ];
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

  /// "Số mới nhất lúc 07:00 · …" for a value that is not for now any more.
  String lastKnownText(DateTime utc, DateTime nowUtc) {
    final hm = TimeFormat.hm(utc);
    return l10n.level_lastKnown(
      TimeFormat.sameVnDay(utc, nowUtc) ? hm : '$hm ${TimeFormat.dayShort(utc)}',
    );
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
