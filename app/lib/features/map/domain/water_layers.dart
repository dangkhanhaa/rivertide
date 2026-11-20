import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/geo/coast_distance.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';

/// What the base map draws under a tap (P2-47), from the OpenMapTiles
/// `water` (areas: ocean, lake, river, pond, dock, swimming_pool) and
/// `waterway` (lines: river, canal, stream, drain, ditch) layers.
class TapWater {
  const TapWater({required this.kind, this.name, this.inArea = false, this.nearby = const []});

  static const TapWater unknown = TapWater(kind: WaterKind.unknown);

  final WaterKind kind;

  /// Name of the watercourse (lines carry names; areas do not).
  final String? name;

  /// Inside a water area, not only next to a line.
  final bool inArea;

  /// For a tap on land: water drawn around it, nearest first.
  final List<NearbyWater> nearby;
}

/// An empty answer means land only from this zoom: below it the tiles leave
/// out streams, ditches and small ponds.
const double landMinZoom = 14;

/// Tap tolerance (logical px, each side): river lines are thin.
const double tapSlopPx = 4;

/// Land taps list water within about this distance.
const double nearbySearchM = 400;

const int _maxNearby = 3;
const int _maxNameChars = 80;

/// A point this far inside an area (from its nearest edge) is on its water.
const double _insideNudgeM = 15;

/// Ids of the style layers that draw seas, lakes, rivers, canals, streams and
/// ditches (source layers `water` / `waterway`). Empty when [style] is not
/// style JSON (e.g. the plain-URL fallback), in which case the kind stays
/// unknown.
List<String> waterLayerIds(String style) {
  final Object? decoded;
  try {
    decoded = jsonDecode(style);
  } on FormatException {
    return const [];
  }
  if (decoded case {'layers': final List<Object?> layers}) {
    return [
      for (final l in layers)
        if (l case {'id': final String id, 'source-layer': 'water' || 'waterway'})
          if (!id.contains('label') && !id.contains('tunnel')) id,
    ];
  }
  return const [];
}

/// Ids of the style layers that label lakes, lagoons and seas (source layer
/// `water_name`): the water areas themselves carry no name.
List<String> waterNameLayerIds(String style) {
  final Object? decoded;
  try {
    decoded = jsonDecode(style);
  } on FormatException {
    return const [];
  }
  if (decoded case {'layers': final List<Object?> layers}) {
    return [
      for (final l in layers)
        if (l case {'id': final String id, 'source-layer': 'water_name'}) id,
    ];
  }
  return const [];
}

/// First words of lagoon names ("Phá Tam Giang", "Đầm Thị Nại", "Vũng Rô").
/// OpenMapTiles draws lagoons as class "lake", so only their label tells.
/// "Đầm" is also an inland lake word (Đầm Sen): the tide verdict treats a
/// "lagoon" far from the coast as a lake.
const Set<String> _lagoonWords = {'phá', 'đầm', 'vũng'};

/// Name of a lagoon labelled near a tapped "lake", or null.
String? lagoonLabel(List<Object?> labels) {
  for (final f in labels) {
    if (f case {'properties': final Map<Object?, Object?> p}) {
      final name = p['name:vi'] ?? p['name'];
      if (name is! String || name.length > _maxNameChars) continue;
      final first = name.trim().toLowerCase().split(' ').first;
      if (_lagoonWords.contains(first)) return name.trim();
    }
  }
  return null;
}

/// Lagoon labels are looked for this far around a tap on a "lake" (px).
const double lagoonLabelPx = 200;

/// Logical pixels → metres at [lat] and [zoom] (512-px tiles).
double metersPerPixel(double lat, double zoom) =>
    40075016.686 * math.cos(lat * math.pi / 180) / (512 * math.pow(2, zoom));

/// One rendered water feature, in a form the rules can use.
typedef _Hit = ({WaterKind kind, String? name, bool area, List<List<(double, double)>> parts});

/// Kind at the tap from features answered by the map for a small box around
/// it. A lake or pond area wins over a river line crossing it; inside a
/// river area the line drawn there names it (a canal or creek mapped as a
/// "river" area); otherwise the line nearest the tap.
TapWater classifyTap(
  List<Object?> features, {
  required double lat,
  required double lon,
  required double zoom,
}) {
  final hits = [for (final f in features) ?_hit(f)];
  final areas = hits.where((h) => h.area).toList();
  final lines = hits.where((h) => !h.area).toList();
  if (areas.any((h) => h.kind == WaterKind.sea)) {
    return const TapWater(kind: WaterKind.sea, inArea: true);
  }
  final still = areas
      .where((h) => h.kind != WaterKind.river)
      .sortedBy<num>((h) => h.kind.rank)
      .lastOrNull;
  if (still != null) return TapWater(kind: still.kind, inArea: true);
  if (areas.isNotEmpty) {
    // The biggest line inside a river area is its centre line (a stream
    // ending there must not rename the river).
    final centre = lines.sortedBy<num>((h) => h.kind.rank).firstOrNull;
    return TapWater(kind: centre?.kind ?? WaterKind.river, name: centre?.name, inArea: true);
  }
  final line = lines.sortedBy<num>((h) => _nearest(h, lat, lon)?.km ?? double.infinity).firstOrNull;
  if (line != null) return TapWater(kind: line.kind, name: line.name);
  return zoom >= landMinZoom ? const TapWater(kind: WaterKind.land) : TapWater.unknown;
}

/// Water around a land tap from features answered for a wider box: nearest
/// first, one entry per kind. A river is drawn twice (an unnamed area and a
/// named centre line): the entry takes the nearest part and the name.
List<NearbyWater> nearbyWater(List<Object?> features, {required double lat, required double lon}) {
  final best = <WaterKind, NearbyWater>{};
  final names = <WaterKind, String>{};
  for (final f in features) {
    final h = _hit(f);
    if (h == null) continue;
    final near = _nearest(h, lat, lon);
    if (near == null || near.km * 1000 > nearbySearchM) continue;
    if (h.name case final n?) names.putIfAbsent(h.kind, () => n);
    final d = near.km * 1000;
    if ((best[h.kind]?.distanceM ?? double.infinity) <= d) continue;
    final at = h.area ? _nudgeInside(lat, lon, near.lat, near.lon) : (lat: near.lat, lon: near.lon);
    best[h.kind] = NearbyWater(kind: h.kind, lat: at.lat, lon: at.lon, distanceM: d);
  }
  // An unnamed "river" area next to a named canal/creek line is that canal
  // (OpenMapTiles files water=canal areas as class river): list it once.
  final river = best[WaterKind.river];
  if (river != null && names[WaterKind.river] == null) {
    final same = best.values.any(
      (w) => w.kind != WaterKind.river && w.kind.isFlowing && w.distanceM <= river.distanceM + 60,
    );
    if (same) best.remove(WaterKind.river);
  }
  return best.values
      .map(
        (w) => NearbyWater(
          kind: w.kind,
          name: names[w.kind],
          lat: w.lat,
          lon: w.lon,
          distanceM: w.distanceM,
        ),
      )
      .sortedBy<num>((w) => w.distanceM)
      .take(_maxNearby)
      .toList();
}

_Hit? _hit(Object? feature) {
  if (feature is! Map) return null;
  final props = feature['properties'];
  final geometry = feature['geometry'];
  if (props is! Map || geometry is! Map) return null;
  final type = geometry['type'];
  final area = type == 'Polygon' || type == 'MultiPolygon';
  if (!area && type != 'LineString' && type != 'MultiLineString') return null;
  final cls = props['class'];
  final kind = area ? _areaKind(cls) : _lineKind(cls);
  final parts = <List<(double, double)>>[];
  _collect(geometry['coordinates'], parts);
  final name = props['name:vi'] ?? props['name'];
  return (
    kind: kind,
    name: name is String && name.trim().isNotEmpty && name.length <= _maxNameChars
        ? name.trim()
        : null,
    area: area,
    parts: parts,
  );
}

WaterKind _areaKind(Object? cls) => switch (cls) {
  'ocean' => WaterKind.sea,
  'river' => WaterKind.river,
  'pond' || 'swimming_pool' => WaterKind.pond,
  'dock' => WaterKind.dock,
  _ => WaterKind.lake,
};

WaterKind _lineKind(Object? cls) => switch (cls) {
  'river' => WaterKind.river,
  'canal' => WaterKind.canal,
  'drain' || 'ditch' => WaterKind.ditch,
  _ => WaterKind.stream,
};

/// Flattens GeoJSON coordinates (any nesting) into runs of (lat, lon).
void _collect(Object? coords, List<List<(double, double)>> out) {
  if (coords is! List || coords.isEmpty) return;
  if (coords.first case [final num _, final num _, ...]) {
    out.add([
      for (final p in coords)
        if (p case [final num lon, final num lat, ...]) (lat.toDouble(), lon.toDouble()),
    ]);
    return;
  }
  for (final c in coords) {
    _collect(c, out);
  }
}

({double lat, double lon, double km})? _nearest(_Hit h, double lat, double lon) {
  ({double lat, double lon, double km})? best;
  for (final run in h.parts) {
    for (var i = 0; i + 1 < run.length; i++) {
      final (aLat, aLon) = run[i];
      final (bLat, bLon) = run[i + 1];
      final p = nearestOnSegment(lat, lon, aLat, aLon, bLat, bLon);
      if (best == null || p.km < best.km) best = p;
    }
  }
  return best;
}

/// From the tap through the nearest edge point, [_insideNudgeM] further.
({double lat, double lon}) _nudgeInside(double lat, double lon, double eLat, double eLon) {
  final k = math.cos(lat * math.pi / 180);
  final dy = eLat - lat;
  final dx = (eLon - lon) * k;
  final len = math.sqrt(dx * dx + dy * dy);
  if (len == 0) return (lat: eLat, lon: eLon);
  const step = _insideNudgeM / 111195;
  return (lat: eLat + dy / len * step, lon: eLon + dx / len * step / k);
}
