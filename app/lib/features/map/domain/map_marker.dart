import 'package:rivertide/core/calc/tide/tide_state.dart';

/// Marker colour classes (PROJECT.md 10.2 S02). Index = severity, so clusters
/// can take the most severe member with a `max` aggregate.
enum MarkerStatus { stale, normal, alarm1, alarm2, alarm3 }

enum MarkerTrend { rising, falling, slack, unknown }

/// A gauge without an observation for this long is shown grey (AC-MAP01-3).
const Duration markerStaleAfter = Duration(hours: 6);

/// KTTV river stations report 4 times a day in a daily bulletin.
const Duration riverMarkerStaleAfter = Duration(hours: 30);

class MapMarker {
  const MapMarker({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.status,
    required this.trend,
    required this.hasTide,
  });

  final String id;
  final String name;
  final double lat;
  final double lon;
  final MarkerStatus status;
  final MarkerTrend trend;
  final bool hasTide;

  /// Image id registered with the map for the trend arrow.
  String get arrowIcon => 'arrow-${trend.name}';
}

/// What the map knows about one station's data at [nowUtc].
///
/// V0 stations have no alarm thresholds (BĐ I–III come with river gauges), so a
/// station with data is [MarkerStatus.normal].
MarkerStatus markerStatus({
  required bool isGauge,
  required bool hasData,
  required DateTime? lastObservationUtc,
  required DateTime nowUtc,
  Duration staleAfter = markerStaleAfter,
}) {
  if (!hasData) return MarkerStatus.stale;
  if (!isGauge) return MarkerStatus.normal;
  final last = lastObservationUtc;
  if (last == null || nowUtc.difference(last) > staleAfter) return MarkerStatus.stale;
  return MarkerStatus.normal;
}

MarkerTrend markerTrend(TideState? state) => switch (state) {
  null => MarkerTrend.unknown,
  TideState.slack => MarkerTrend.slack,
  TideState.rising || TideState.risingFast => MarkerTrend.rising,
  TideState.falling || TideState.fallingFast => MarkerTrend.falling,
};

class MapFilter {
  const MapFilter({this.onlyTide = false, this.onlyAlarm = false, this.hideStale = false});

  final bool onlyTide;
  final bool onlyAlarm;
  final bool hideStale;

  bool get isActive => onlyTide || onlyAlarm || hideStale;

  MapFilter copyWith({bool? onlyTide, bool? onlyAlarm, bool? hideStale}) => MapFilter(
    onlyTide: onlyTide ?? this.onlyTide,
    onlyAlarm: onlyAlarm ?? this.onlyAlarm,
    hideStale: hideStale ?? this.hideStale,
  );

  bool accepts(MapMarker m) {
    if (onlyTide && !m.hasTide) return false;
    if (onlyAlarm && m.status.index < MarkerStatus.alarm1.index) return false;
    if (hideStale && m.status == MarkerStatus.stale) return false;
    return true;
  }
}

/// GeoJSON for the clustered station source. Feature ids are list indexes
/// because maplibre-gl-js keeps only integer ids.
Map<String, Object?> markersToGeoJson(List<MapMarker> markers) => {
  'type': 'FeatureCollection',
  'features': [
    for (final (i, m) in markers.indexed)
      {
        'type': 'Feature',
        'id': i,
        'geometry': {
          'type': 'Point',
          'coordinates': [m.lon, m.lat], // GeoJSON order is lon, lat
        },
        'properties': {'sid': m.id, 'name': m.name, 'sev': m.status.index, 'arrow': m.arrowIcon},
      },
  ],
};
