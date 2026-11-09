import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/tide/observation.dart';
import 'package:rivertide/core/errors/app_exception.dart';

/// Plausible sensor range; anything outside is a glitch (IOC data is not QC'd).
const double _minLevelM = -20;
const double _maxLevelM = 20;
const Duration iocBin = Duration(minutes: 10);

/// Parses IOC `service.php?query=data&format=json` and returns 10-minute means
/// (bins centred on :00, :10, …) for one sensor, in cm on the app datum.
List<WaterObservation> parseIocObservations(
  String body, {
  required String sensor,
  required double datumOffsetCm,
}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw ParseException('ioc json: ${e.message}');
  }
  if (decoded is! List<Object?>) throw const ParseException('ioc: not a list');
  final samples = <(DateTime, double)>[];
  for (final rec in decoded) {
    final parsed = _parseRecord(rec, sensor);
    if (parsed != null) samples.add(parsed);
  }
  return _binMeans(samples, datumOffsetCm);
}

(DateTime, double)? _parseRecord(Object? rec, String sensor) {
  if (rec is! Map<String, Object?> || rec['sensor'] != sensor) return null;
  final level = rec['slevel'];
  final time = rec['stime'];
  if (level is! num || time is! String) return null;
  if (level < _minLevelM || level > _maxLevelM) return null;
  final t = DateTime.tryParse('${time.replaceFirst(' ', 'T')}Z');
  return t == null ? null : (t, level.toDouble());
}

List<WaterObservation> _binMeans(List<(DateTime, double)> samples, double offsetCm) {
  final half = iocBin.inMilliseconds ~/ 2;
  final groups = groupBy(samples, (s) {
    final ms = s.$1.millisecondsSinceEpoch + half;
    return ms - ms % iocBin.inMilliseconds;
  });
  final out = <WaterObservation>[];
  groups.forEach((binMs, values) {
    if (values.length < 3) return; // too sparse to trust
    final meanM = values.map((v) => v.$2).average;
    out.add(
      WaterObservation(
        timeUtc: DateTime.fromMillisecondsSinceEpoch(binMs, isUtc: true),
        levelCm: meanM * 100 + offsetCm,
      ),
    );
  });
  return _removeSpikes(out.sortedBy((o) => o.timeUtc));
}

/// Drops bins more than 25 cm from the median of their ±3 neighbours.
List<WaterObservation> _removeSpikes(List<WaterObservation> obs) {
  const maxJumpCm = 25.0;
  return [
    for (var i = 0; i < obs.length; i++)
      if ((obs[i].levelCm - _neighbourMedian(obs, i)).abs() <= maxJumpCm) obs[i],
  ];
}

double _neighbourMedian(List<WaterObservation> obs, int i) {
  final from = (i - 3).clamp(0, obs.length);
  final to = (i + 4).clamp(0, obs.length);
  final values = obs.sublist(from, to).map((o) => o.levelCm).sorted((a, b) => a.compareTo(b));
  return values[values.length ~/ 2];
}
