part of 'map_screen.dart';

/// Community spots on the map (P2-19): pins, "N điểm câu quanh đây", details.
extension _MapCommunity on _MapScreenState {
  /// Area the spots are fetched for: the map centre once zoomed in on a
  /// region, else the user's position; null before either is known.
  String? get _spotsArea => _area(ref.watch(mapCameraProvider));

  /// Same, for callbacks (no watching outside build).
  String? get _spotsAreaNow => _area(ref.read(mapCameraProvider));

  String? _area(MapCamera? cam) {
    if (cam != null && cam.zoom >= 9) return nearbyKey(cam.lat, cam.lon);
    final me = _me;
    return me == null ? null : nearbyKey(me.lat, me.lon);
  }

  List<PublicSpot> get _spots => switch (_spotsArea) {
    final k? => ref.watch(nearbySpotsProvider(k)).value ?? const [],
    null => const [],
  };

  /// Feature `id` = index into [_spots], so a tap finds the spot back.
  Map<String, Object?> _spotsGeo(List<PublicSpot> spots) => {
    'type': 'FeatureCollection',
    'features': [
      for (final (i, s) in spots.indexed)
        {
          'type': 'Feature',
          'id': i,
          'geometry': {
            'type': 'Point',
            'coordinates': [s.lon, s.lat],
          },
          'properties': {'title': s.title},
        },
    ],
  };

  void _tapSpot(int index) {
    final area = _spotsAreaNow;
    final spots = area == null
        ? const <PublicSpot>[]
        : ref.read(nearbySpotsProvider(area)).value ?? const [];
    if (index >= 0 && index < spots.length) unawaited(_openSpot(spots[index]));
  }

  Future<void> _openSpot(PublicSpot s) async {
    if (sheetBusy) return;
    await showDetailAt(
      SpotSheet(
        key: ValueKey('spot-${s.id}'),
        spot: s,
        onViewWater: () => unawaited(_viewWater(s)),
      ),
      (offset) async => await _map?.flyTo(s.lat, s.lon, zoom: 14, offset: offset),
    );
  }

  /// From a spot to its water level / fishing sheet.
  Future<void> _viewWater(PublicSpot s) async {
    await dismissDetail();
    await _openPoint(s.lat, s.lon, PointSurface.unknown, zoom: 14, title: s.title);
  }

  Future<void> _openNearby() async {
    final area = _spotsAreaNow;
    if (area == null) return;
    PublicSpot? chosen;
    await showGuardedSheet(
      (ctx) => NearbySpotsSheet(
        areaKey: area,
        onOpen: (s) {
          chosen = s;
          Navigator.of(ctx).pop();
        },
      ),
    );
    // The list's own tap guard would swallow the next sheet: lift it first.
    if (chosen case final s?) {
      releaseMapLock();
      await _openSpot(s);
    }
  }
}
