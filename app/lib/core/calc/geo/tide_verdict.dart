import 'package:rivertide/core/calc/geo/tide_zones.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';

/// Does the sea tide move the water at a point? (P2-48)
enum TideVerdict {
  tidal,

  /// Some tide, small or irregular: shown only as a low-confidence estimate.
  weak,
  none,

  /// Water kind not known: the old source chain runs, with low confidence.
  unknown,
}

/// Why, so the screen can say it in a few words.
enum TideReason {
  sea,
  lagoon,
  stillWater,
  land,
  highGround,

  /// On a fitted tidal river line, or next to a KTTV station that the
  /// bulletin marks as tidal.
  tidalRiverData,
  southNetwork,

  /// Small or upland water inside the southern network: often behind a
  /// sluice or above the tide.
  southSmall,
  northRiver,

  /// Irrigation canals and ditches: sluice gates keep the tide out.
  gated,
  nearSea,
  farFromSea,
  unknownKind,

  /// A lake right by the coast: could be a lagoon (tidal) or a fresh lake.
  coastalLake,

  /// Distance to the sea unknown (coast data missing).
  noSeaDistance,
}

typedef TideAssessment = ({WaterKind kind, TideVerdict verdict, TideReason reason});

/// Ground (surface model) this high is far above any tide in Vietnam. The
/// model reads buildings and trees too (Q1 HCMC: 12 m), so the guard is set
/// well above delta values.
const double highGroundM = 30;

/// An unnamed delta creek this high is a hill stream, not a tidal creek.
const double southCreekHighM = 15;

/// Rivers outside the deltas: some tide up to this far from the coast.
const double riverTideKm = 25;

/// North delta rivers count as fully tidal this close to the coast.
const double northRiverStrongKm = 60;

/// Canals and creeks outside the southern network.
const double smallWaterTideKm = 10;

/// Hill streams reach tide only right at the coast.
const double streamTideKm = 5;

/// A "lagoon" farther inland than this is a lake named "Đầm …".
const double lagoonMaxSeaKm = 10;

/// A "lake" this close to the coast may be a lagoon the map does not tell
/// apart (OpenMapTiles draws both as lakes): the verdict stays open.
const double coastalLakeKm = 3;

/// [kind] as named locally: the name prefix first ("Rạch …", "Suối …"),
/// then, in the southern network, an unnamed stream is a tidal creek.
WaterKind effectiveWaterKind(WaterKind kind, String? name, TideZone zone) {
  final named = refineWaterKind(kind, name);
  final suoi = (name ?? '').trim().toLowerCase().startsWith('suối ');
  if (named == WaterKind.stream && zone == TideZone.south && !suoi) return WaterKind.creek;
  return named;
}

/// Tide verdict from the water kind (already through [effectiveWaterKind]),
/// region, ground height (m, nullable) and distance to the coast (km).
TideAssessment assessTide({
  required WaterKind kind,
  required TideZone zone,
  double? elevationM,
  double? seaKm,
  bool tidalRiverData = false,
}) {
  TideAssessment r(TideVerdict v, TideReason why) => (kind: kind, verdict: v, reason: why);
  switch (kind) {
    case WaterKind.sea || WaterKind.dock:
      return r(TideVerdict.tidal, TideReason.sea);
    case WaterKind.land:
      return r(TideVerdict.none, TideReason.land);
    case WaterKind.lagoon when seaKm != null && seaKm > lagoonMaxSeaKm:
      // An inland "Đầm …" (Đầm Sen, Đầm Vạc) is a lake.
      return (kind: WaterKind.lake, verdict: TideVerdict.none, reason: TideReason.stillWater);
    case WaterKind.lagoon:
      return r(TideVerdict.weak, TideReason.lagoon);
    case WaterKind.lake when seaKm != null && seaKm <= coastalLakeKm:
      return r(TideVerdict.unknown, TideReason.coastalLake);
    case WaterKind.lake || WaterKind.pond || WaterKind.reservoir:
      return r(TideVerdict.none, TideReason.stillWater);
    case _:
  }
  if (elevationM case final e? when e >= highGroundM) {
    return r(TideVerdict.none, TideReason.highGround);
  }
  if (tidalRiverData && (kind == WaterKind.river || kind == WaterKind.unknown)) {
    return r(TideVerdict.tidal, TideReason.tidalRiverData);
  }
  if (kind == WaterKind.unknown) return r(TideVerdict.unknown, TideReason.unknownKind);
  final (verdict, reason) = switch (zone) {
    TideZone.south => _south(kind, elevationM),
    TideZone.north => _north(kind, seaKm),
    TideZone.other => _other(kind, seaKm),
  };
  return r(verdict, reason);
}

(TideVerdict, TideReason) _south(WaterKind kind, double? elevationM) => switch (kind) {
  WaterKind.creek when (elevationM ?? 0) >= southCreekHighM => (
    TideVerdict.weak,
    TideReason.southSmall,
  ),
  WaterKind.river ||
  WaterKind.canal ||
  WaterKind.creek => (TideVerdict.tidal, TideReason.southNetwork),
  _ => (TideVerdict.weak, TideReason.southSmall),
};

(TideVerdict, TideReason) _north(WaterKind kind, double? seaKm) => switch (kind) {
  WaterKind.river || WaterKind.creek =>
    seaKm != null && seaKm <= northRiverStrongKm
        ? (TideVerdict.tidal, TideReason.northRiver)
        : (TideVerdict.weak, TideReason.northRiver),
  WaterKind.canal => (TideVerdict.weak, TideReason.gated),
  WaterKind.stream => _near(seaKm, streamTideKm),
  _ => (TideVerdict.none, TideReason.gated),
};

(TideVerdict, TideReason) _other(WaterKind kind, double? seaKm) => switch (kind) {
  WaterKind.river => _near(seaKm, riverTideKm),
  WaterKind.canal || WaterKind.creek => _near(seaKm, smallWaterTideKm),
  WaterKind.stream => _near(seaKm, streamTideKm),
  _ => (TideVerdict.none, TideReason.gated),
};

(TideVerdict, TideReason) _near(double? seaKm, double limitKm) {
  if (seaKm == null) return (TideVerdict.unknown, TideReason.noSeaDistance);
  return seaKm <= limitKm
      ? (TideVerdict.weak, TideReason.nearSea)
      : (TideVerdict.none, TideReason.farFromSea);
}
