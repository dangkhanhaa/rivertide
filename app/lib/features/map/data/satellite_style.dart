import 'dart:convert';

import 'package:rivertide/core/errors/app_exception.dart';

/// EOX Sentinel-2 cloudless 2025 (10 m): free, no key, CC BY-NC-SA 4.0 —
/// non-commercial only (cloudless.eox.at/license-non-commercial, read 2026-11-09).
/// Commercial release needs the 2016 CC BY layer or a paid EOX licence.
const String satelliteTiles =
    'https://tiles.maps.eox.at/wmts/1.0.0/s2cloudless-2025_3857/default/GoogleMapsCompatible/{z}/{y}/{x}.jpg';

const String satelliteAttribution =
    'EOxCloudless https://cloudless.eox.at by EOX IT Services GmbH '
    '(Contains modified Copernicus Sentinel data 2025)';

/// Hybrid style: satellite imagery under the (already localized) vector labels
/// and borders of [vectorStyle]. Water layers stay but are invisible so a tap
/// can still tell water from land.
String satelliteStyle(String vectorStyle) {
  final Object? decoded;
  try {
    decoded = jsonDecode(vectorStyle);
  } on FormatException catch (e) {
    throw ParseException('vector style: ${e.message}');
  }
  if (decoded is! Map<String, Object?> ||
      decoded['layers'] is! List<Object?> ||
      decoded['sources'] is! Map<String, Object?>) {
    throw const ParseException('vector style shape');
  }
  final layers = <Object?>[
    {'id': 'satellite', 'type': 'raster', 'source': 'satellite'},
  ];
  for (final l in decoded['layers']! as List<Object?>) {
    if (l is! Map<String, Object?>) continue;
    final sourceLayer = l['source-layer'];
    final id = l['id'];
    if (l['type'] == 'symbol' || (id is String && id.startsWith('boundary'))) {
      layers.add(l);
    } else if ((sourceLayer == 'water' || sourceLayer == 'waterway') && l['type'] != 'symbol') {
      // Kept for the "is this water?" query, drawn fully transparent.
      final type = l['type'];
      final paint = <String, Object?>{
        if (type == 'fill') 'fill-opacity': 0,
        if (type == 'line') 'line-opacity': 0,
      };
      layers.add({...l, 'paint': paint});
    }
  }
  return jsonEncode({
    ...decoded,
    'sources': {
      ...(decoded['sources']! as Map<String, Object?>),
      'satellite': {
        'type': 'raster',
        'tiles': [satelliteTiles],
        'tileSize': 256,
        // Sentinel-2 is 10 m: deeper tiles add nothing, MapLibre overzooms.
        'maxzoom': 14,
        'attribution': satelliteAttribution,
      },
    },
    'layers': layers,
  });
}
