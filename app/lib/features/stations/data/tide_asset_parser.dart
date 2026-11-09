import 'dart:convert';

import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

/// One yearly prediction file produced by tools/tide/export_asset.py (PROJECT.md 8.5).
typedef TideAsset = ({TideSeries series, TideModelInfo model, double obsDatumOffsetCm});

const int _maxSamples = 366 * 144 + 1;

TideAsset parseTideAsset(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw ParseException('tide asset json: ${e.message}');
  }
  if (decoded is! Map<String, Object?>) throw const ParseException('tide asset: not an object');
  final start = DateTime.tryParse(_string(decoded, 'start'));
  final step = decoded['step_minutes'];
  final levels = decoded['levels_cm'];
  final model = decoded['model'];
  if (start == null || !start.isUtc || step is! int || levels is! List<Object?>) {
    throw const ParseException('tide asset: bad header');
  }
  if (levels.length < 2 || levels.length > _maxSamples || model is! Map<String, Object?>) {
    throw const ParseException('tide asset: bad levels/model');
  }
  final series = TideSeries(
    startUtc: start,
    stepMinutes: step,
    levelsCm: [
      for (final v in levels)
        switch (v) {
          final int cm => cm,
          _ => throw const ParseException('tide asset: level'),
        },
    ],
    extremes: _extremes(decoded['extremes']),
  );
  final offset = decoded['obs_datum_offset_cm'];
  return (
    series: series,
    model: TideModelInfo(
      sourceName: 'IOC + utide',
      confidence: _confidence(decoded['confidence']),
      rmseCm: _num(model['rmse_cm']),
      extremeTimeErrMin: _num(model['extreme_time_err_min']),
      extremeHeightErrCm: _num(model['extreme_height_err_cm']),
      fitFrom: _string(model, 'fit_from'),
      fitTo: _string(model, 'fit_to'),
    ),
    obsDatumOffsetCm: offset is num ? offset.toDouble() : 0,
  );
}

List<TideExtreme> _extremes(Object? raw) {
  if (raw is! List<Object?>) throw const ParseException('tide asset: extremes');
  return [for (final e in raw) _extreme(e)];
}

TideExtreme _extreme(Object? row) {
  if (row case [final String time, final int level, final String kind]) {
    final t = DateTime.tryParse(time);
    if (t != null && t.isUtc && (kind == 'H' || kind == 'L')) {
      return TideExtreme(
        timeUtc: t,
        levelCm: level,
        kind: kind == 'H' ? TideExtremeKind.high : TideExtremeKind.low,
      );
    }
  }
  throw const ParseException('tide asset: extreme row');
}

String _string(Map<String, Object?> m, String key) => switch (m[key]) {
  final String s => s,
  _ => '',
};

double? _num(Object? v) => v is num ? v.toDouble() : null;

TideConfidence _confidence(Object? v) => switch (v) {
  'high' => TideConfidence.high,
  'medium' => TideConfidence.medium,
  _ => TideConfidence.low,
};
