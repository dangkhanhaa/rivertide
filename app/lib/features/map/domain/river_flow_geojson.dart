import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';

/// Level change per segment of one river (cm/h, null = no estimate), keyed by
/// the segment's start index in [RiverLine.points].
typedef SegmentRates = Map<int, double>;

/// Segments coloured by what the water does there now — `state` = rising /
/// falling / slack (|rate| < [slackThresholdCmPerH]) — each drawn from its
/// upstream end towards the mouth, so moving dashes show the river current
/// (always seaward; the tide changes the level, it is not shown as reversing).
Map<String, Object?> riverFlowGeoJson(List<RiverLine> rivers, Map<String, SegmentRates> rates) => {
  'type': 'FeatureCollection',
  'features': [
    for (final r in rivers)
      for (final MapEntry(key: i, value: rate) in (rates[r.id] ?? const <int, double>{}).entries)
        if (i >= 0 && i < r.points.length - 1)
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              // points go from the mouth upstream: reversed = flowing seaward.
              'coordinates': [
                [r.points[i + 1].lon, r.points[i + 1].lat],
                [r.points[i].lon, r.points[i].lat],
              ],
            },
            'properties': {
              'state': rate.abs() < slackThresholdCmPerH
                  ? 'slack'
                  : (rate > 0 ? 'rising' : 'falling'),
            },
          },
  ],
};

const Map<String, Object?> emptyFlowGeoJson = {'type': 'FeatureCollection', 'features': <Object>[]};
