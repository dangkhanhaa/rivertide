part of 'map_screen.dart';

/// How long the map ignores clicks after a nearby water is picked.
const Duration _nearbyGrace = Duration(milliseconds: 400);

extension _WaterTaps on _MapScreenState {
  /// Remembered per point id, so every screen that opens it agrees (P2-47).
  Future<void> _rememberWater(double lat, double lon, TapWater water) async {
    if (water.kind == WaterKind.unknown) return;
    await recordWaterHint(
      ref,
      PointId.encode(lat, lon),
      WaterHint(
        kind: water.kind,
        name: water.name,
        source: WaterHintSource.map,
        fromArea: water.inArea,
      ),
    );
  }

  /// A water suggested under a land tap: open that spot as if tapped there.
  void _openNearby(NearbyWater w) => unawaited(() async {
    await dismissDetail();
    // On web this press on the sheet also reaches the map underneath: keep
    // the map locked a moment so it does not open a second point there.
    await whileMapLocked(() => Future<void>.delayed(_nearbyGrace));
    releaseMapLock();
    await _openPoint(w.lat, w.lon, TapWater(kind: w.kind, name: w.name));
  }());
}

/// Rebuilds a layer's GeoJSON only when its list changes (the map re-sends a
/// source whenever the object differs).
class _GeoMemo<T> {
  List<T>? _list;
  Map<String, Object?> _geo = emptyGeo;

  Map<String, Object?> of(List<T> list, Map<String, Object?> Function(T item, int i) feature) {
    if (!identical(list, _list)) {
      _list = list;
      _geo = {
        'type': 'FeatureCollection',
        'features': [for (final (i, x) in list.indexed) feature(x, i)],
      };
    }
    return _geo;
  }
}

Map<String, Object?> _point(int i, double lat, double lon, Map<String, Object?> props) => {
  'type': 'Feature',
  'id': i,
  'geometry': {
    'type': 'Point',
    'coordinates': [lon, lat],
  },
  'properties': props,
};

final _spotsMemo = _GeoMemo<PublicSpot>();
final _tripsMemo = _GeoMemo<Trip>();
final _cellsMemo = _GeoMemo<CheckinCell>();
final _pondsMemo = _GeoMemo<Pond>();
