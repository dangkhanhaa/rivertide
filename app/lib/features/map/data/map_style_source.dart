import 'dart:convert';

import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';

/// OpenFreeMap public styles: free, no key, commercial use allowed
/// (openfreemap.org, read 2026-11-09). Attribution is added by MapLibre.
const String openFreeMapLight = 'https://tiles.openfreemap.org/styles/liberty';
const String openFreeMapDark = 'https://tiles.openfreemap.org/styles/dark';

const Duration mapStyleTtl = Duration(days: 7);

/// Styles are ~40 KB; anything far larger is not a style.
const int _maxStyleChars = 2 * 1024 * 1024;

/// Makes every place label prefer the Vietnamese name (`name:vi` in
/// OpenMapTiles) so e.g. the islands read "Quần đảo Hoàng Sa" and the sea
/// "Biển Đông". Returns the style as JSON text for `MapLibreMap.styleString`.
///
/// Throws [ParseException] when [raw] is not a MapLibre style.
String localizeStyle(String raw) {
  if (raw.length > _maxStyleChars) throw const ParseException('style too large');
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException catch (e) {
    throw ParseException('style json: ${e.message}');
  }
  if (decoded is! Map<String, Object?> ||
      decoded['version'] != 8 ||
      decoded['layers'] is! List<Object?> ||
      decoded['sources'] is! Map<String, Object?>) {
    throw const ParseException('not a v8 style');
  }
  for (final layer in decoded['layers']! as List<Object?>) {
    if (layer is! Map<String, Object?>) continue;
    final layout = layer['layout'];
    if (layout is! Map<String, Object?>) continue;
    final field = layout['text-field'];
    if (field is List<Object?> && _usesName(field)) {
      layout['text-field'] = [
        'coalesce',
        ['get', 'name:vi'],
        field,
      ];
    }
  }
  return jsonEncode(decoded);
}

/// Name-based label expressions (not road refs or house numbers).
bool _usesName(List<Object?> expr) => jsonEncode(expr).contains('"name');

/// Loads a base-map style: network → localize → cache 7 days; on failure the
/// cached copy, and as a last resort the plain URL (labels then in local script).
class MapStyleSource {
  MapStyleSource({required this._fetch, required this._db, required this._clock});

  final Future<String> Function(Uri uri) _fetch;
  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<String> load(String url) async {
    final key = 'map_style:$url';
    final cached = await _db.readCache(key);
    final now = _clock();
    if (cached != null && now.difference(cached.fetchedAtUtc) < mapStyleTtl) {
      return cached.payload;
    }
    try {
      final style = localizeStyle(await _fetch(Uri.parse(url)));
      await _db.writeCache(key, style, now);
      return style;
    } on AppException catch (e) {
      log.warn('map style fetch failed', {'error': e.toString()});
      return cached?.payload ?? url;
    }
  }
}
