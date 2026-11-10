import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/core/calc/river/river_reach.dart';

/// Line features for the parts of mapped rivers where an along-river estimate
/// is made. Each segment carries `conf`: 1 at the station, falling to 0 at the
/// range limit ([maxReachUpstreamKm] / [maxReachDownstreamKm]). Drawn under
/// the station markers so users see where the numbers are firmer.
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
  final limit = along >= 0 ? maxReachUpstreamKm : maxReachDownstreamKm;
  if (along.abs() > limit) return null;
  // Rounded before the `> 0` filter so no invisible 0.00 segment is emitted.
  return double.parse((1 - along.abs() / limit).toStringAsFixed(2));
}
