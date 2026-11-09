import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/tide/observation.dart';

/// Compact cache format: [[epochMs, levelCm×10], …] — keeps 30 days small.
String encodeObservations(List<WaterObservation> obs) => jsonEncode([
  for (final o in obs) [o.timeUtc.millisecondsSinceEpoch, (o.levelCm * 10).round()],
]);

/// Lenient decode of our own cache; corrupt rows are skipped (cache can be rebuilt).
List<WaterObservation> decodeObservations(String payload) {
  final Object? decoded;
  try {
    decoded = jsonDecode(payload);
  } on FormatException {
    return const [];
  }
  if (decoded is! List<Object?>) return const [];
  return [
    for (final row in decoded)
      if (row case [final int ms, final int tenths])
        WaterObservation(
          timeUtc: DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
          levelCm: tenths / 10,
        ),
  ];
}

/// Union by timestamp (newer wins), sorted, trimmed to [keepFromUtc].
List<WaterObservation> mergeObservations(
  List<WaterObservation> old,
  List<WaterObservation> fresh,
  DateTime keepFromUtc,
) {
  final byTime = <DateTime, WaterObservation>{
    for (final o in old) o.timeUtc: o,
    for (final o in fresh) o.timeUtc: o,
  };
  return byTime.values.where((o) => !o.timeUtc.isBefore(keepFromUtc)).sortedBy((o) => o.timeUtc);
}
