import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/core/calc/river/river_reach.dart';

/// Line features for the parts of mapped rivers where an along-river estimate
/// is made. Each segment carries `conf`: 1 at the station, falling to 0 at the
/// upstream limit ([maxReachUpstreamKm]) and to [_minDownstreamConf] at the
/// mouth (the sea end is a real boundary too, so it never vanishes). Drawn
/// under the station markers so users see where the numbers are firmer.
Map<String, Object?> riverReachGeoJson(List<RiverLine> rivers) => {
  'type': 'FeatureCollection',
  'features': [
    for (final r in rivers)
      for (final stationKm in r.stationKm.values)
        for (var i = 0; i < r.points.length - 1; i++)
          if (_conf(r.points[i].km, r.points[i + 1].km, stationKm) case final c? when c > 0)
            {
              'type': 'Feature',
              'geometry': {
                'type': 'LineString',
                'coordinates': [
                  [r.points[i].lon, r.points[i].lat],
                  [r.points[i + 1].lon, r.points[i + 1].lat],
                ],
              },
              'properties': {'conf': c},
            },
  ],
};

/// Confidence of a segment from its mid-point's distance to the station.
double? _conf(double kmA, double kmB, double stationKm) {
  final along = (kmA + kmB) / 2 - stationKm;
  if (along > maxReachUpstreamKm || along < -stationKm) return null;
  final c = along >= 0
      ? 1 - along / maxReachUpstreamKm
      : (1 + along / stationKm).clamp(_minDownstreamConf, 1.0);
  // Rounded before the `> 0` filter so no invisible 0.00 segment is emitted.
  return double.parse(c.toStringAsFixed(2));
}

const double _minDownstreamConf = 0.3;
