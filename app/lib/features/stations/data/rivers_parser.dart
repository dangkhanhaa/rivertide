import 'dart:convert';

import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/core/errors/app_exception.dart';

/// Parses app/assets/data/rivers.json (tools/rivers/build_rivers.py).
List<RiverLine> parseRivers(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw ParseException('rivers json: ${e.message}');
  }
  if (decoded case {'version': 1, 'rivers': final List<Object?> rivers}) {
    return [for (final r in rivers) _river(r)];
  }
  throw const ParseException('rivers shape');
}

RiverLine _river(Object? r) {
  if (r case {
    'id': final String id,
    'name': final String name,
    'mouth': final String mouth,
    'points': final List<Object?> points,
    'stations': final Map<String, Object?> stations,
  }) {
    final pts = <RiverVertex>[
      for (final p in points)
        if (p case [final num lat, final num lon, final num km])
          (lat: lat.toDouble(), lon: lon.toDouble(), km: km.toDouble())
        else
          throw const ParseException('river point'),
    ];
    // Validate here (RiverLine would throw an Error on bad data).
    if (pts.length < 2) throw ParseException('river $id: too few points');
    for (var i = 1; i < pts.length; i++) {
      if (pts[i].km < pts[i - 1].km) throw ParseException('river $id: km decreases');
    }
    return RiverLine(
      id: id,
      name: name,
      mouth: mouth,
      points: pts,
      stationKm: {
        for (final MapEntry(:key, :value) in stations.entries)
          if (value case final num km)
            key: km.toDouble()
          else
            key: throw const ParseException('station km'),
      },
    );
  }
  throw const ParseException('river shape');
}
