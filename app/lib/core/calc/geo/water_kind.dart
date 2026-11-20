/// What kind of water (or land) a map point is on (P2-47).
///
/// [creek] is a tidal creek of the delta network ("rạch", "xẻo", "lạch");
/// [stream] a hill or mountain stream ("suối"). OpenStreetMap tags both
/// `waterway=stream`, so the name and the region tell them apart
/// ([refineWaterKind]).
enum WaterKind {
  sea,
  river,
  canal,
  creek,
  stream,
  ditch,
  lake,
  pond,
  reservoir,
  lagoon,
  dock,
  land,
  unknown;

  /// Water that runs (can carry a current / river flow).
  bool get isFlowing => switch (this) {
    river || canal || creek || stream || ditch => true,
    _ => false,
  };

  /// Standing water: no tide, no river flow.
  bool get isStill => switch (this) {
    lake || pond || reservoir => true,
    _ => false,
  };

  /// Waterways ranked by how much they dominate a spot (bigger first): when a
  /// point touches several, the biggest one decides.
  int get rank => switch (this) {
    sea => 0,
    dock => 1,
    river => 2,
    lagoon => 3,
    reservoir => 4,
    lake => 5,
    canal => 6,
    creek => 7,
    stream => 8,
    pond => 9,
    ditch => 10,
    land || unknown => 99,
  };
}

/// Water feature near a point, e.g. a suggestion for a tap on land.
class NearbyWater {
  const NearbyWater({
    required this.kind,
    required this.lat,
    required this.lon,
    required this.distanceM,
    this.name,
  });

  final WaterKind kind;
  final String? name;

  /// A point on that water (its nearest part, nudged inside an area).
  final double lat;
  final double lon;
  final double distanceM;
}

/// Name prefixes Vietnamese maps use for each kind of watercourse. The name
/// is more specific than the OSM tag (a "Rạch" is often tagged `stream`, a
/// "Kinh" `river`), so it wins for flowing water.
const Map<String, WaterKind> _flowingPrefixes = {
  'sông': WaterKind.river,
  'kênh': WaterKind.canal,
  'kinh': WaterKind.canal,
  'rạch': WaterKind.creek,
  'xẻo': WaterKind.creek,
  'lạch': WaterKind.creek,
  'suối': WaterKind.stream,
  'mương': WaterKind.ditch,
};

/// Same for areas: only names that are unambiguous ("Đầm Sen" is a park lake,
/// so "đầm" is not used).
const Map<String, WaterKind> _areaPrefixes = {'phá': WaterKind.lagoon, 'ao': WaterKind.pond};

/// [kind] corrected by the Vietnamese [name] ("Rạch Cái Răng" → creek).
WaterKind refineWaterKind(WaterKind kind, String? name) {
  final words = (name ?? '').trim().toLowerCase().split(RegExp(r'\s+'));
  if (words.length < 2) return kind;
  final first = words.first;
  if (kind.isFlowing) return _flowingPrefixes[first] ?? kind;
  if (kind.isStill || kind == WaterKind.lagoon) return _areaPrefixes[first] ?? kind;
  return kind;
}
