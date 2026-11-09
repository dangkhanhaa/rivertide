import 'dart:convert';

import 'package:rivertide/core/calc/river/river_curve.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

/// Compact KTTV bulletin produced by tools/nchmf/export_bulletin.py.
class KttvBulletin {
  const KttvBulletin({required this.issuedUtc, required this.series, required this.daily});

  final DateTime issuedUtc;

  /// Station key ("HàNội") → points in time order (levels only; discharge dropped).
  final Map<String, List<RiverPoint>> series;
  final Map<String, DailyExtremes> daily;
}

/// Bulletin data is untrusted input: check types and plausible ranges.
const _minCm = -500;
const _maxCm = 100000;
const _maxPointsPerStation = 400;

KttvBulletin parseKttvBulletin(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw ParseException('kttv json: ${e.message}');
  }
  if (decoded case {
    'version': 1,
    'issued_utc': final String issued,
    'stations': final Map<String, Object?> stations,
    'daily': final Map<String, Object?> daily,
  }) {
    final issuedUtc = DateTime.tryParse(issued);
    if (issuedUtc == null || !issuedUtc.isUtc) throw const ParseException('kttv issued_utc');
    return KttvBulletin(
      issuedUtc: issuedUtc,
      series: {for (final MapEntry(:key, :value) in stations.entries) key: ?_series(value)},
      daily: {for (final MapEntry(:key, :value) in daily.entries) key: ?_daily(value, issuedUtc)},
    );
  }
  throw const ParseException('kttv shape');
}

List<RiverPoint>? _series(Object? value) {
  if (value case {'unit': 'cm', 'points': final List<Object?> points}) {
    if (points.length > _maxPointsPerStation) throw const ParseException('kttv too many points');
    final out = <RiverPoint>[];
    for (final p in points) {
      if (p case {'t': final String t, 'v': final int v, 'k': final String k}) {
        final time = DateTime.tryParse(t);
        if (time == null || !time.isUtc || v < _minCm || v > _maxCm || (k != 'o' && k != 'f')) {
          throw const ParseException('kttv point');
        }
        out.add(RiverPoint(timeUtc: time, levelCm: v.toDouble(), observed: k == 'o'));
      } else {
        throw const ParseException('kttv point shape');
      }
    }
    return out..sort((a, b) => a.timeUtc.compareTo(b.timeUtc));
  }
  return null; // discharge (m3/s) rows are not water levels
}

DailyExtremes? _daily(Object? value, DateTime issuedUtc) {
  if (value case {
    'window_h': final int w,
    'obs_max': final int obsMax,
    'obs_min': final int obsMin,
    'fc_max': final int fcMax,
    'fc_min': final int fcMin,
  }) {
    final all = [obsMax, obsMin, fcMax, fcMin];
    if (all.any((v) => v < _minCm || v > _maxCm) || obsMin > obsMax || fcMin > fcMax) {
      throw const ParseException('kttv daily values');
    }
    return DailyExtremes(
      windowHours: w,
      obsMaxCm: obsMax,
      obsMinCm: obsMin,
      fcMaxCm: fcMax,
      fcMinCm: fcMin,
      issuedUtc: issuedUtc,
    );
  }
  return null;
}
