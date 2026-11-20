import 'dart:convert';

import 'package:rivertide/core/calc/geo/water_kind.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/stations/domain/point_water.dart';

/// Points remembered; the oldest is dropped beyond this.
const int maxWaterHints = 200;

const String _key = 'water_hints_v1';

/// Water kind per point id (P2-47), kept in the settings table as one small
/// JSON list `[[id, kind, name|null, source, inArea 0/1], …]`, newest last.
class WaterHintStore {
  WaterHintStore(this._db);

  final AppDatabase _db;
  Map<String, WaterHint>? _hints;

  Future<Map<String, WaterHint>> _load() async {
    final cached = _hints;
    if (cached != null) return cached;
    return _hints = _decode(await _db.readSetting(_key));
  }

  Future<WaterHint?> get(String id) async => (await _load())[id];

  Future<void> put(String id, WaterHint hint) async {
    final hints = await _load();
    if (hint.sameAs(hints[id])) return;
    // Re-insert so the map's order stays oldest → newest.
    hints
      ..remove(id)
      ..[id] = hint;
    while (hints.length > maxWaterHints) {
      hints.remove(hints.keys.first);
    }
    await _db.writeSetting(_key, _encode(hints));
  }

  static String _encode(Map<String, WaterHint> hints) => jsonEncode([
    for (final MapEntry(key: id, value: h) in hints.entries)
      [id, h.kind.name, h.name, h.source.name, if (h.fromArea) 1 else 0],
  ]);

  /// Rows that do not parse are skipped: a bad row must not lose the others.
  static Map<String, WaterHint> _decode(String? raw) {
    final hints = <String, WaterHint>{};
    if (raw == null || raw.isEmpty) return hints;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      log.warn('water hints unreadable', {'error': e.message});
      return hints;
    }
    if (decoded is! List<Object?>) return hints;
    for (final row in decoded) {
      if (row case [
        final String id,
        final String kind,
        final String? name,
        final String source,
        final int area,
      ]) {
        final k = WaterKind.values.asNameMap()[kind];
        final s = WaterHintSource.values.asNameMap()[source];
        if (k == null || s == null) continue;
        hints[id] = WaterHint(kind: k, name: name, source: s, fromArea: area == 1);
      }
    }
    return hints;
  }
}
