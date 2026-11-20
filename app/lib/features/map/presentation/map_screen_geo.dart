part of 'map_screen.dart';

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

/// A later, more accurate GPS reading (P2-56): move the blue dot; recentre
/// and re-pick "around you" only when it moved noticeably, and never while a
/// sheet is open or the user is looking at another spot.
extension _MapRefine on _MapScreenState {
  static const double _recentreKm = 0.15;

  Future<void> _locate({bool open = false}) async {
    final service = ref.read(locationServiceProvider);
    // Lock only while a permission dialog may show, never while awaiting GPS (P2-56).
    final p = await service.hasPermission() && mounted
        ? await runLocateFlow(context, service, onRefined: _refineMe)
        : await whileMapLocked(() => runLocateFlow(context, service, onRefined: _refineMe));
    if (p == null || !mounted) return;
    if (open) {
      _setMe(p);
      releaseMapLock();
      return await _openPoint(p.lat, p.lon, PointSurface.unknown, zoom: 13);
    }
    await _showMe(p);
  }

  void _refineMe(double lat, double lon) {
    final old = _me;
    if (!mounted || old == null) return;
    final moved = haversineKm(old.lat, old.lon, lat, lon) >= _recentreKm;
    _setMe((lat: lat, lon: lon));
    unawaited(ref.read(locationPromptStoreProvider).saveLastPosition(lat, lon));
    if (!moved || !isInVietnamBounds(lat, lon)) return;
    final spot = ref.read(fishingSpotProvider.notifier);
    if (!spot.userChose) spot.choose(PointId.encode(lat, lon), mine: true, byUser: false);
    if (!sheetBusy) unawaited(_map?.flyTo(lat, lon, offset: visibleOffset(detailOpen: false)));
  }
}
