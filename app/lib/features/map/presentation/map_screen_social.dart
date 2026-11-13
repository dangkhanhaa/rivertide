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

/// Community layers on the map: spots (P2-19/25), trips (P2-26) and
/// "đang câu" bubbles (P2-27), with their shortcuts under the search button.
extension _MapSocial on _MapScreenState {
  /// Area the layers are fetched for: the map centre once zoomed in on a
  /// region, else the user's position; null before either is known.
  String? get _socialArea => _area(ref.watch(mapCameraProvider));

  String? _area(MapCamera? cam) {
    if (cam != null && cam.zoom >= 9) return nearbyKey(cam.lat, cam.lon);
    final me = _me;
    return me == null ? null : nearbyKey(me.lat, me.lon);
  }

  List<T> _watch<T>(ProviderListenable<AsyncValue<List<T>>> Function(String key) of) =>
      switch (_socialArea) {
        final k? => ref.watch(of(k)).value ?? <T>[],
        null => <T>[],
      };

  List<T> _read<T>(ProviderListenable<AsyncValue<List<T>>> Function(String key) of) =>
      switch (_area(ref.read(mapCameraProvider))) {
        final k? => ref.read(of(k)).value ?? <T>[],
        null => <T>[],
      };

  Map<MapOverlayId, MapOverlay> _overlays() {
    if (!Env.communityEnabled) return const {};
    final spots = _watch(nearbySpotsProvider.call);
    final trips = _watch(nearbyTripsProvider.call).where((t) => !t.cancelled).toList();
    final cells = _watch(nearbyCheckinsProvider.call);
    return {
      MapOverlayId.community: MapOverlay(
        geojson: _spotsMemo.of(spots, (s, i) => _point(i, s.lat, s.lon, {'title': s.title})),
        onTap: (i) => _tapOn(_read(nearbySpotsProvider.call), i, _openSpot),
      ),
      MapOverlayId.trips: MapOverlay(
        geojson: _tripsMemo.of(trips, (t, i) => _point(i, t.lat, t.lon, {'title': t.title})),
        onTap: (i) => _tapOn(
          _read(nearbyTripsProvider.call).where((t) => !t.cancelled).toList(),
          i,
          _openTrip,
        ),
      ),
      MapOverlayId.checkins: MapOverlay(
        geojson: _cellsMemo.of(
          cells,
          (c, i) => _point(i, c.lat, c.lon, {'people': c.people, 'biting': c.biting}),
        ),
        onTap: (i) => _tapOn(_read(nearbyCheckinsProvider.call), i, _openCell),
      ),
    };
  }

  void _tapOn<T>(List<T> items, int i, Future<void> Function(T item) open) {
    if (i >= 0 && i < items.length) unawaited(open(items[i]));
  }

  Future<void> _openSpot(PublicSpot s) => _openAt(
    SpotSheet(
      key: ValueKey('spot-${s.id}'),
      spot: s,
      onViewWater: () => _viewWater(s.lat, s.lon, s.title),
    ),
    s.lat,
    s.lon,
  );

  Future<void> _openTrip(Trip t) => _openAt(
    TripSheet(
      key: ValueKey('trip-${t.id}'),
      trip: t,
      onViewWater: () => _viewWater(t.lat, t.lon, t.title),
    ),
    t.lat,
    t.lon,
  );

  Future<void> _openCell(CheckinCell c) => _openAt(
    CheckinCellSheet(
      key: ValueKey('cell-${c.lat},${c.lon}'),
      cell: c,
      onViewWater: () => _viewWater(c.lat, c.lon, null),
    ),
    c.lat,
    c.lon,
  );

  Future<void> _openAt(Widget sheet, double lat, double lon) async {
    if (sheetBusy) return;
    await showDetailAt(
      sheet,
      (offset) async => await _map?.flyTo(lat, lon, zoom: 14, offset: offset),
    );
  }

  /// From a spot, trip or bubble to the water level / fishing sheet there.
  void _viewWater(double lat, double lon, String? title) => unawaited(() async {
    await dismissDetail();
    await _openPoint(lat, lon, PointSurface.unknown, zoom: 14, title: title);
  }());

  /// Opens a list sheet; the chosen item opens after the list has closed (the
  /// list's own tap guard would swallow the next sheet otherwise).
  Future<void> _pickFromSheet<T>(
    Widget Function(void Function(T item) choose) sheet,
    Future<void> Function(T item) open,
  ) async {
    T? chosen;
    await showGuardedSheet(
      (ctx) => sheet((item) {
        chosen = item;
        Navigator.of(ctx).pop();
      }),
    );
    if (chosen case final item?) {
      releaseMapLock();
      await open(item);
    }
  }

  /// A trip from the shortcut starts where the user is; other places are
  /// chosen by tapping them on the map ("Rủ đi câu ở đây").
  Future<void> _createTrip() async {
    final at = _me ?? await _locateQuietly();
    if (at == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripFormScreen(lat: at.lat, lon: at.lon),
      ),
    );
  }

  /// Community shortcuts, the ones where something is happening first.
  List<MapAction> _socialActions() {
    if (!Env.communityEnabled) return const [];
    final l10n = context.l10n;
    final c = context.colors;
    final area = _socialArea;
    final trips = _watch(nearbyTripsProvider.call).where((t) => !t.cancelled).length;
    final spots = _watch(nearbySpotsProvider.call).length;
    final cells = _watch(nearbyCheckinsProvider.call);
    final people = cells.fold<int>(0, (n, x) => n + x.people);
    final mine = ref.watch(myCheckinProvider).value;
    final checkin = MapAction(
      icon: mine == null ? Icons.add_location_alt_outlined : Icons.phishing_rounded,
      color: c.fishGood,
      label: mine == null ? l10n.checkin_pill : l10n.checkin_pillOn(_left(mine.until)),
      detail: l10n.checkin_detail,
      hot: mine != null,
      onTap: () => unawaited(showGuardedSheet((_) => CheckinSheet(locate: _locateQuietly))),
    );
    final tripsAction = MapAction(
      icon: Icons.groups_2_rounded,
      color: c.trip,
      label: trips > 0 ? l10n.trip_pill(trips) : l10n.trip_create,
      detail: trips > 0 ? l10n.trip_listDetail : l10n.trip_createDetail,
      hot: trips > 0,
      onTap: () => unawaited(trips > 0 && area != null ? _openTripList(area) : _createTrip()),
    );
    return [
      if (mine != null) checkin,
      if (people > 0)
        MapAction(
          icon: Icons.sensors_rounded,
          color: c.fishPeak,
          label: l10n.checkin_count(people),
          detail: l10n.checkin_peopleDetail,
          hot: true,
          onTap: () => unawaited(_openCellList(cells)),
        ),
      tripsAction,
      if (spots > 0 && area != null)
        MapAction(
          icon: Icons.groups_rounded,
          color: c.spot,
          label: l10n.spot_nearbyChip(spots),
          detail: l10n.spot_listDetail,
          hot: true,
          onTap: () => unawaited(
            _pickFromSheet<PublicSpot>(
              (choose) => NearbySpotsSheet(areaKey: area, onOpen: choose),
              _openSpot,
            ),
          ),
        ),
      if (trips > 0)
        MapAction(
          icon: Icons.group_add_rounded,
          color: c.trip,
          label: l10n.trip_create,
          detail: l10n.trip_createDetail,
          onTap: () => unawaited(_createTrip()),
        ),
      if (mine == null) checkin,
    ];
  }

  Future<void> _openTripList(String area) => _pickFromSheet<Trip>(
    (choose) => NearbyTripsSheet(
      areaKey: area,
      onOpen: choose,
      onCreate: () {
        Navigator.of(context).pop();
        unawaited(_createTrip());
      },
    ),
    _openTrip,
  );

  Future<void> _openCellList(List<CheckinCell> cells) {
    final me = _me;
    return _pickFromSheet<CheckinCell>(
      (choose) => CheckinListSheet(
        cells: cells,
        distanceKm: (x) => me == null ? null : haversineKm(me.lat, me.lon, x.lat, x.lon),
        onOpen: choose,
      ),
      _openCell,
    );
  }

  /// "⋯": every shortcut with a line of explanation.
  void _openShortcuts(List<MapAction> actions) => unawaited(
    _pickFromSheet<MapAction>(
      (choose) =>
          MapActionsSheet(title: context.l10n.more_shortcuts, actions: actions, onPick: choose),
      (a) async => a.onTap(),
    ),
  );

  /// "3:20" until the check-in ends.
  String _left(DateTime untilUtc) {
    final now = ref.watch(minuteTickerProvider).value ?? ref.read(clockProvider)();
    final m = untilUtc.difference(now).inMinutes.clamp(0, 24 * 60);
    return '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';
  }
}
