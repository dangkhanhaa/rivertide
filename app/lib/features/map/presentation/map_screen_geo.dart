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
