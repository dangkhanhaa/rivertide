import 'package:collection/collection.dart';
import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

typedef TideLoader = Future<Cached<StationTide>> Function(Station station, {bool forceRefresh});

/// A river station farther than this does not describe the point.
const double maxRiverReferenceKm = 40;

/// Beyond this the reference is shown with low confidence.
const double nearRiverReferenceKm = 10;

/// Virtual station for a tapped map point; the name is its coordinates.
Station pointStation(String id, double lat, double lon) => Station(
  id: id,
  name: '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
  region: '',
  lat: lat,
  lon: lon,
  kind: StationKind.model,
);

/// Water level for any map point: the ocean model at the point itself when it
/// has sea there, otherwise the nearest KTTV river station (labelled with its
/// distance). Never invents data for a point with neither.
class PointTideSource {
  PointTideSource({required this._catalog, required this._sea, required this._river});

  final Future<List<Station>> Function() _catalog;
  final TideLoader _sea;
  final TideLoader _river;

  Future<Cached<StationTide>> tide(Station point, {bool forceRefresh = false}) async {
    try {
      final sea = await _sea(point, forceRefresh: forceRefresh);
      if (sea.data.prediction != null) return sea;
    } on AppException {
      // Inland or model unreachable: try the river network next.
    }
    final ref = await nearestRiverStation(point.lat, point.lon);
    if (ref == null) throw NotFoundException('no water data near ${point.id}');
    final base = await _river(ref.station, forceRefresh: forceRefresh);
    final far = ref.km > nearRiverReferenceKm;
    final model = base.data.model;
    return Cached(
      data: base.data.copyWith(
        station: ref.station.copyWith(
          id: point.id,
          name: point.name,
          lat: point.lat,
          lon: point.lon,
          coordApprox: false,
        ),
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
