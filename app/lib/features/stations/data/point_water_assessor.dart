import 'package:rivertide/core/calc/geo/tide_verdict.dart';
import 'package:rivertide/core/calc/geo/tide_zones.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';
import 'package:rivertide/features/stations/domain/point_water.dart';
import 'package:rivertide/features/stations/domain/station.dart';

typedef HintLoader = Future<WaterHint?> Function(String pointId);
typedef PlaceNumber = Future<double?> Function(double lat, double lon);

/// Kind of water at a point, as remembered for its id, read in its region.
typedef PointKind = ({WaterKind kind, String? name, TideZone zone});

/// Water kind + tide verdict for a map point (P2-47/P2-48): the remembered
/// hint, the region, the distance to the coast and, for running water, the
/// ground height. Height and coast failures leave those inputs out.
class PointWaterAssessor {
  PointWaterAssessor({required this._hint, required this._seaKm, required this._elevation});

  final HintLoader _hint;
  final PlaceNumber _seaKm;
  final PlaceNumber _elevation;

  Future<PointKind> kindAt(Station point) async {
    final hint = await _hint(point.id);
    final zone = tideZoneAt(point.lat, point.lon);
    final kind = effectiveWaterKind(hint?.kind ?? WaterKind.unknown, hint?.name, zone);
    return (kind: kind, name: hint?.name, zone: zone);
  }

  /// [tidalRiverData]: the point lies on a fitted tidal river line or next to
  /// a KTTV station marked tidal (only used for rivers / unknown water).
  Future<PointWater> assess(Station point, PointKind k, {required bool tidalRiverData}) async {
    final runs = k.kind.isFlowing || k.kind == WaterKind.unknown;
    final elevation = runs ? await _elevation(point.lat, point.lon) : null;
    final seaKm = await _seaKm(point.lat, point.lon);
    final a = assessTide(
      kind: k.kind,
      zone: k.zone,
      elevationM: elevation,
      seaKm: seaKm,
      tidalRiverData: tidalRiverData,
    );
    return PointWater(
      // The verdict may re-read the kind (an inland "Đầm …" is a lake).
      kind: a.kind,
      name: k.name,
      verdict: a.verdict,
      reason: a.reason,
      zone: k.zone,
      seaKm: seaKm,
      elevationM: elevation,
    );
  }
}
