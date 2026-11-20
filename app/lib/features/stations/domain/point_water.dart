import 'package:rivertide/core/calc/geo/tide_verdict.dart';
import 'package:rivertide/core/calc/geo/tide_zones.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';

/// Where a [WaterHint] came from.
enum WaterHintSource {
  /// The base map drew this water under the tap.
  map,

  /// OpenStreetMap via Overpass at the exact point.
  osm,
}

/// Remembered water kind of a point id, so every screen that opens the point
/// (sheet, detail, fishing tab) treats it the same (P2-47).
class WaterHint {
  const WaterHint({required this.kind, required this.source, this.name, this.fromArea = false});

  final WaterKind kind;
  final String? name;
  final WaterHintSource source;

  /// Inside a mapped water area (lake, river polygon), not only near a line.
  final bool fromArea;

  bool sameAs(WaterHint? other) =>
      other != null &&
      other.kind == kind &&
      other.name == name &&
      other.source == source &&
      other.fromArea == fromArea;
}

/// Water kind and tide verdict of a map point, carried with its tide data.
class PointWater {
  const PointWater({
    required this.kind,
    required this.verdict,
    required this.reason,
    required this.zone,
    this.name,
    this.seaKm,
    this.elevationM,
  });

  final WaterKind kind;
  final String? name;
  final TideVerdict verdict;
  final TideReason reason;
  final TideZone zone;
  final double? seaKm;
  final double? elevationM;

  /// Tide curves and turn times make no sense here.
  bool get noTide => verdict == TideVerdict.none;
}

enum StructureKind { dam, weir, lockGate, sluiceGate, culvert }

/// Dam, weir, lock or sluice near a point (OpenStreetMap).
class WaterStructure {
  const WaterStructure({required this.kind, this.name, this.distanceM});

  final StructureKind kind;
  final String? name;
  final double? distanceM;
}

/// What OpenStreetMap knows around a point: its water (null when nothing
/// could be decided) and structures within [structureRadiusM].
class PointSurroundings {
  const PointSurroundings({required this.water, required this.structures});

  final WaterHint? water;
  final List<WaterStructure> structures;
}

/// Structures this close get the safety note.
const double structureRadiusM = 300;

enum _Family { sea, flowing, still, other }

_Family _family(WaterKind k) => switch (k) {
  WaterKind.sea || WaterKind.dock => _Family.sea,
  WaterKind.lagoon || WaterKind.lake || WaterKind.pond || WaterKind.reservoir => _Family.still,
  _ when k.isFlowing => _Family.flowing,
  _ => _Family.other,
};

/// The hint to keep when OpenStreetMap ([osm]) answers for a point that may
/// already have one ([current], usually from the map tap). OSM fills a
/// missing, land or unknown hint, and refines a map area of the same family
/// (a map "lake" that OSM tags as reservoir or lagoon, a river polygon that is
/// a canal). A map hit on water is never overruled by OSM finding nothing.
WaterHint? mergeOsmHint(WaterHint? current, WaterHint? osm) {
  if (osm == null) return current;
  if (current == null || current.source == WaterHintSource.osm) return osm;
  if (current.kind == WaterKind.land || current.kind == WaterKind.unknown) return osm;
  final same = _family(current.kind) == _family(osm.kind);
  if (same && osm.fromArea) {
    return WaterHint(
      kind: osm.kind,
      name: osm.name ?? current.name,
      source: WaterHintSource.osm,
      fromArea: true,
    );
  }
  if (current.name == null && osm.kind == current.kind && osm.name != null) {
    return WaterHint(
      kind: current.kind,
      name: osm.name,
      source: current.source,
      fromArea: current.fromArea,
    );
  }
  return current;
}
