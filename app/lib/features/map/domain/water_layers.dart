import 'dart:convert';

/// What lies under a tapped map point, read from the base map's own layers.
enum PointSurface { water, land, unknown }

/// Ids of the style layers that draw rivers, lakes and sea (OpenMapTiles
/// source layers `water` / `waterway`). Empty when [style] is not style JSON
/// (e.g. the plain-URL fallback), in which case the surface stays unknown.
List<String> waterLayerIds(String style) {
  final Object? decoded;
  try {
    decoded = jsonDecode(style);
  } on FormatException {
    return const [];
  }
  if (decoded case {'layers': final List<Object?> layers}) {
    return [
      for (final l in layers)
        if (l case {'id': final String id, 'source-layer': 'water' || 'waterway'})
          // Rivers, lakes and sea only: rural ditches/streams ("waterway_other")
          // are everywhere and would mark most farmland as water.
          if (!id.contains('label') && !id.contains('tunnel') && !id.contains('other')) id,
    ];
  }
  return const [];
}
