import 'package:collection/collection.dart';
import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/core/calc/river/river_reach.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

typedef TideLoader = Future<Cached<StationTide>> Function(Station station, {bool forceRefresh});

/// Ocean model at a point: how far away the cell it answered for lies, and
/// whether the point itself is land (terrain above sea level).
typedef SeaTide = ({Cached<StationTide> tide, double cellKm, bool onLand});

typedef SeaLoader = Future<SeaTide> Function(Station station, {bool forceRefresh});

typedef ReachLoader = Future<({Cached<StationTide> tide, RiverReach reach})?> Function(
  Station station,
  Station point, {
  required double stationKm,
  required double pointKm,
  bool forceRefresh,
});

/// A tapped point counts as "on the river" within this distance of its centre
/// line (the Red River is ~1 km wide at Hà Nội).
const double onRiverMaxOffsetKm = 1;

/// A river station farther than this does not describe the point.
const double maxRiverReferenceKm = 40;

/// Beyond this the reference is shown with low confidence.
const double nearRiverReferenceKm = 10;

/// The marine grid is 1/12° (cells ≤ ~6,5 km from any sea point): a cell
/// farther than this means the point itself is on land.
const double seaAtPointKm = 8;

/// For land/river points near the coast, a sea cell this close still gives
/// the best tide signal (a low-confidence estimate, never "sea here").
const double coastReferenceKm = 25;

/// Water for any map point, best source first: the ocean model at the point,
/// the along-river model, the nearest KTTV river station, the tide of the
/// nearest sea cell. A point with none of these still gets a result without a
/// level curve, so river flow, fishing and weather are computed for it.
class PointTideSource {
  PointTideSource({
    required this._catalog,
    required this._sea,
    required this._river,
    required this._rivers,
    required this._reach,
    required this._clock,
  });

  final Future<List<Station>> Function() _catalog;
  final SeaLoader _sea;
  final TideLoader _river;
  final Future<List<RiverLine>> Function() _rivers;
  final ReachLoader _reach;
  final DateTime Function() _clock;

  Future<Cached<StationTide>> tide(Station point, {bool forceRefresh = false}) async {
    SeaTide? sea;
    try {
      sea = await _sea(point, forceRefresh: forceRefresh);
      final hasTide = sea.tide.data.prediction != null;
      if (hasTide && !sea.onLand && sea.cellKm <= seaAtPointKm) return sea.tide;
    } on AppException catch (e) {
      // Model unreachable: the river network may still answer.
      log.info('point sea model unavailable', {'error': e.debugMessage});
    }
    if (await _alongRiver(point, forceRefresh) case final r?) return r;
    final ref = await nearestRiverStation(point.lat, point.lon);
    if (ref == null) {
      if (sea != null && sea.tide.data.prediction != null && sea.cellKm <= coastReferenceKm) {
        return _nearCoast(sea.tide, sea.cellKm);
      }
      return _levelUnknown(point);
    }
    final base = await _river(ref.station, forceRefresh: forceRefresh);
    final far = ref.km > nearRiverReferenceKm;
    final model = base.data.model;
    return Cached(
      data: base.data.copyWith(
        station: _asPoint(ref.station, point),
        reference: ReferenceStation(
          stationId: ref.station.id,
          name: ref.station.name,
          river: ref.station.river,
          distanceKm: ref.km,
        ),
        model: far && model != null ? model.copyWith(confidence: TideConfidence.low) : model,
      ),
      fetchedAtUtc: base.fetchedAtUtc,
      isStale: base.isStale,
    );
  }

  /// The point lies on a mapped tidal river that has a fitted station: level
  /// from the along-river model (lag, tide gain and mean level by km).
  Future<Cached<StationTide>?> _alongRiver(Station point, bool forceRefresh) async {
    final catalog = await _catalog();
    for (final line in await _rivers()) {
      final proj = line.project(point.lat, point.lon);
      if (proj.offsetKm > onRiverMaxOffsetKm) continue;
      for (final MapEntry(key: stationId, value: stationKm) in line.stationKm.entries) {
        final station = catalog.firstWhereOrNull((s) => s.id == stationId);
        if (station == null) continue;
        final r = await _reach(
          station,
          _asPoint(station, point),
          stationKm: stationKm,
          pointKm: proj.km,
          forceRefresh: forceRefresh,
        );
        if (r == null) continue;
        return Cached(
          data: r.tide.data.copyWith(
            reference: ReferenceStation(
              stationId: station.id,
              name: station.name,
              river: station.river,
              distanceKm: r.reach.alongKm.abs(),
              alongKm: r.reach.alongKm,
              lagShiftMinutes: r.reach.lagShiftMinutes,
              meanShiftCm: r.reach.meanShiftCm(_clock()),
              celerityKmH: r.reach.celerityKmH,
            ),
          ),
          fetchedAtUtc: r.tide.fetchedAtUtc,
          isStale: r.tide.isStale,
        );
      }
    }
    return null;
  }

  Cached<StationTide> _nearCoast(Cached<StationTide> sea, double cellKm) => Cached(
    data: sea.data.copyWith(
      predictionKind: LevelDataKind.estimate,
      model: sea.data.model?.copyWith(confidence: TideConfidence.low),
      reference: ReferenceStation(stationId: coastReferenceId, name: '', distanceKm: cellKm),
    ),
    fetchedAtUtc: sea.fetchedAtUtc,
    isStale: sea.isStale,
  );

  /// No level source reaches the point: no curve, but a river-kind place so
  /// the sheet computes discharge, fishing and weather for it.
  Cached<StationTide> _levelUnknown(Station point) => Cached(
    data: StationTide(
      station: point.copyWith(kind: StationKind.river),
      observations: const [],
      predictionKind: LevelDataKind.estimate,
    ),
    fetchedAtUtc: _clock(),
    isStale: false,
  );

  Station _asPoint(Station ref, Station point) => ref.copyWith(
    id: point.id,
    name: point.name,
    lat: point.lat,
    lon: point.lon,
    coordApprox: false,
  );

  /// Nearest KTTV river station within [maxRiverReferenceKm], or null.
  Future<({Station station, double km})?> nearestRiverStation(double lat, double lon) async {
    final rivers = (await _catalog()).where(
      (s) => s.kind == StationKind.river || s.kind == StationKind.riverDaily,
    );
    final best = rivers
        .map((s) => (station: s, km: haversineKm(lat, lon, s.lat, s.lon)))
        .sortedBy<num>((r) => r.km)
        .firstOrNull;
    return best == null || best.km > maxRiverReferenceKm ? null : best;
  }
}
