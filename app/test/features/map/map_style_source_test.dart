import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/map/data/map_style_source.dart';

/// OpenFreeMap "liberty" style as served on 2026-11-09.
final String _liberty = File('test/fixtures/openfreemap_liberty_20261109.json').readAsStringSync();

List<Map<String, Object?>> _layers(String style) =>
    ((jsonDecode(style) as Map<String, Object?>)['layers']! as List<Object?>)
        .cast<Map<String, Object?>>();

Object? _textField(Map<String, Object?> layer) =>
    (layer['layout'] as Map<String, Object?>?)?['text-field'];

void main() {
  group('localizeStyle', () {
    test('every name label prefers name:vi; road refs untouched', () {
      final out = localizeStyle(_liberty);
      final byId = {for (final l in _layers(out)) l['id']! as String: l};
      for (final id in ['label_country_1', 'label_city', 'water_name_point_label', 'label_other']) {
        final tf = _textField(byId[id]!)! as List<Object?>;
        expect(tf[0], 'coalesce', reason: id);
        expect(tf[1], ['get', 'name:vi'], reason: id);
      }
      expect(_textField(byId['highway-shield-non-us']!), [
        'to-string',
        ['get', 'ref'],
      ]);
      // Nothing else changes: same layer count and ids.
      expect(
        _layers(out).map((l) => l['id']),
        orderedEquals(_layers(_liberty).map((l) => l['id'])),
      );
    });

    test('rejects non-styles and oversized input', () {
      expect(() => localizeStyle('not json'), throwsA(isA<ParseException>()));
      expect(
        () => localizeStyle('{"version": 7, "layers": [], "sources": {}}'),
        throwsA(isA<ParseException>()),
      );
      expect(() => localizeStyle('[]'), throwsA(isA<ParseException>()));
      expect(
        () => localizeStyle('{"pad": "${'x' * (2 * 1024 * 1024)}"}'),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('MapStyleSource', () {
    late AppDatabase db;
    var now = DateTime.utc(2026, 11, 9);
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('fetches once, then serves the cache within 7 days', () async {
      var calls = 0;
      final source = MapStyleSource(
        fetch: (_) async {
          calls++;
          return _liberty;
        },
        db: db,
        clock: () => now,
      );
      final first = await source.load(openFreeMapLight);
      expect(first, contains('name:vi'));
      now = now.add(const Duration(days: 6));
      expect(await source.load(openFreeMapLight), first);
      expect(calls, 1);
    });

    test('network failure: stale cache, else the plain URL', () async {
      final ok = MapStyleSource(fetch: (_) async => _liberty, db: db, clock: () => now);
      final failing = MapStyleSource(
        fetch: (_) async => throw const NetworkException('offline'),
        db: db,
        clock: () => now.add(const Duration(days: 30)),
      );
      expect(await failing.load(openFreeMapDark), openFreeMapDark);
      final cached = await ok.load(openFreeMapLight);
      expect(await failing.load(openFreeMapLight), cached);
    });
  });
}
