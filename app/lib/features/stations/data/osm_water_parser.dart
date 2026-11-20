import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/domain/point_water.dart';

/// Watercourses and water areas this close count as "the water here" (a tap
/// on the bank or an angler standing next to it).
const int osmNearRadiusM = 80;

/// Answers with more elements than this are not what we asked for.
const int _maxElements = 400;
const int _maxNameChars = 80;

/// One Overpass QL request (P2-47/P2-52): water areas containing the point,
/// waterways and water areas within [osmNearRadiusM], and dams, weirs, locks,
/// sluices and culverts within [structureRadiusM]. Tags and centres only: no
/// geometry, so the answer stays a few KB. [lat]/[lon] are rounded to 4
/// decimals (~11 m, the point id precision).
String overpassWaterQuery(double lat, double lon) {
  final p = '${lat.toStringAsFixed(4)},${lon.toStringAsFixed(4)}';
  const r = osmNearRadiusM;
  final s = structureRadiusM.round();
  const lines = r'^(river|canal|stream|ditch|drain|tidal_channel)$';
  const gates = r'^(dam|weir|lock_gate|sluice_gate)$';
  const pools = r'^(reservoir|basin|aquaculture)$';
  return [
    '[out:json][timeout:8];',
    'is_in($p)->.a;',
    '(area.a["natural"="water"];area.a["natural"="bay"];area.a["waterway"="riverbank"];',
    'area.a["landuse"~"$pools"];);out tags;',
    '(way(around:$r,$p)["waterway"~"$lines"];way(around:$r,$p)["natural"="water"];',
    'rel(around:$r,$p)["natural"="water"];way(around:$r,$p)["waterway"="riverbank"];',
    'way(around:$r,$p)["landuse"="reservoir"];);out tags center;',
    '(nwr(around:$s,$p)["waterway"~"$gates"];',
    'way(around:$s,$p)["waterway"]["tunnel"="culvert"];);out tags center;',
  ].join('\n');
}

/// Parses the answer to [overpassWaterQuery]. Throws [ParseException] when
/// the body is not an Overpass JSON answer.
PointSurroundings parseOverpassWater(String body, double lat, double lon) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw ParseException('overpass json: ${e.message}');
  }
  if (decoded case {'remark': final String r} when r.contains('error')) {
    // A query that ran out of time or memory answers 200 with a partial list.
    throw const ParseException('overpass runtime error');
  }
  final elements = switch (decoded) {
    {'elements': final List<Object?> list} => list,
    _ => throw const ParseException('overpass shape'),
  };
  if (elements.length > _maxElements) throw const ParseException('overpass too many elements');
  final inside = <WaterHint>[];
  final near = <WaterHint>[];
  final structures = <WaterStructure>[];
  for (final e in elements) {
    if (e is! Map<String, Object?>) continue;
    final tags = _tags(e['tags']);
    if (tags.isEmpty) continue;
    if (_structure(tags) case final kind?) {
      structures.add(
        WaterStructure(kind: kind, name: _name(tags), distanceM: _distanceM(e, lat, lon)),
      );
      if (tags['tunnel'] != 'culvert') continue;
    }
    final kind = osmWaterKind(tags);
    if (kind == null) continue;
    final hint = WaterHint(
      kind: kind,
      name: _name(tags),
      source: WaterHintSource.osm,
      fromArea: e['type'] == 'area',
    );
    (hint.fromArea ? inside : near).add(hint);
  }
  return PointSurroundings(
    // Nested areas (an estuary inside a bay): the most specific one. Several
    // waters nearby: the biggest one decides.
    water:
        inside.sortedBy<num>((h) => h.kind.rank).lastOrNull ??
        near.sortedBy<num>((h) => h.kind.rank).firstOrNull,
    structures: structures.sortedBy<num>((s) => s.distanceM ?? structureRadiusM).take(3).toList(),
  );
}

/// OSM tags → kind (wiki.openstreetmap.org: Key:water, Key:waterway,
/// Tag:landuse=reservoir/basin/aquaculture, Tag:natural=bay); null for
/// anything that is not open water.
WaterKind? osmWaterKind(Map<String, String> t) {
  switch (t['waterway']) {
    case 'river' || 'riverbank':
      return WaterKind.river;
    case 'canal':
      return WaterKind.canal;
    case 'stream':
      return WaterKind.stream;
    case 'ditch' || 'drain':
      return WaterKind.ditch;
    case 'tidal_channel':
      return WaterKind.creek;
    case 'dock':
      return WaterKind.dock;
  }
  if (t['natural'] == 'bay') return WaterKind.sea;
  switch (t['landuse']) {
    case 'reservoir':
      return WaterKind.reservoir;
    case 'basin' || 'aquaculture':
      return WaterKind.pond;
  }
  if (t['natural'] != 'water') return null;
  return switch (t['water']) {
    'reservoir' => WaterKind.reservoir,
    'lagoon' => WaterKind.lagoon,
    'pond' ||
    'basin' ||
    'fishpond' ||
    'wastewater' ||
    'reflecting_pool' ||
    'salt_pool' => WaterKind.pond,
    'river' || 'rapids' => WaterKind.river,
    'canal' || 'moat' || 'lock' => WaterKind.canal,
    'stream' => WaterKind.stream,
    'ditch' || 'drain' => WaterKind.ditch,
    _ => WaterKind.lake,
  };
}

StructureKind? _structure(Map<String, String> t) => switch (t['waterway']) {
  'dam' => StructureKind.dam,
  'weir' => StructureKind.weir,
  'lock_gate' => StructureKind.lockGate,
  'sluice_gate' => StructureKind.sluiceGate,
  _ when t['tunnel'] == 'culvert' => StructureKind.culvert,
  _ => null,
};

Map<String, String> _tags(Object? raw) => {
  if (raw is Map<String, Object?>)
    for (final e in raw.entries)
      if (e.value case final String v when v.length <= 200) e.key: v,
};

/// Vietnamese name first; control characters dropped, length capped.
String? _name(Map<String, String> t) {
  final raw = (t['name:vi'] ?? t['name'])?.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '').trim();
  if (raw == null || raw.isEmpty) return null;
  return raw.length > _maxNameChars ? raw.substring(0, _maxNameChars) : raw;
}

/// Metres from the point to a node or an element centre, when given.
double? _distanceM(Map<String, Object?> e, double lat, double lon) {
  final c = e['center'];
  final (Object? la, Object? lo) = c is Map<String, Object?>
      ? (c['lat'], c['lon'])
      : (e['lat'], e['lon']);
  if (la is! num || lo is! num) return null;
  if (la.abs() > 90 || lo.abs() > 180) return null;
  return haversineKm(lat, lon, la.toDouble(), lo.toDouble()) * 1000;
}
