import 'dart:convert';

import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/domain/river_flow.dart';

/// Discharge beyond this is not a Vietnamese river (Mekong peak ≈ 60.000 m³/s).
const double _maxDischarge = 100000;

/// Below this mean the best cell is a canal, not a river worth showing.
const double minMainStemDischarge = 50;

/// Picks the main stem from a 3×3 Open-Meteo Flood response: the cell with
/// the largest mean discharge (side cells give a few m³/s, main stem
/// thousands — survey 2026-11-10 at Hà Nội: 1.790 vs < 20). Null when no cell
/// reaches [minMainStemDischarge].
RiverFlow? parseMainStemFlow(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw ParseException('flood json: ${e.message}');
  }
  final cells = decoded is List<Object?> ? decoded : [decoded];
  RiverFlow? best;
  var bestMean = minMainStemDischarge;
  for (final c in cells) {
    final flow = _cell(c);
    if (flow == null || flow.days.isEmpty) continue;
    final mean = flow.days.map((d) => d.$2).reduce((a, b) => a + b) / flow.days.length;
    if (mean >= bestMean) {
      bestMean = mean;
      best = flow;
    }
  }
  return best;
}

RiverFlow? _cell(Object? c) {
  if (c case {
    'latitude': final num lat,
    'longitude': final num lon,
    'daily': {'time': final List<Object?> time, 'river_discharge': final List<Object?> q},
  }) {
    if (time.length != q.length) throw const ParseException('flood lengths');
    final days = <(DateTime, double)>[];
    for (var i = 0; i < time.length; i++) {
      final t = time[i];
      final v = q[i];
      if (t is! String || v is! num) continue; // missing days are skipped
      final day = DateTime.tryParse('${t}T00:00:00Z');
      if (day == null || v < 0 || v > _maxDischarge) throw const ParseException('flood value');
      days.add((day, v.toDouble()));
    }
    return RiverFlow(days: days, cellLat: lat.toDouble(), cellLon: lon.toDouble());
  }
  throw const ParseException('flood shape');
}
