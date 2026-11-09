import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/data/kttv_parser.dart';
import 'package:rivertide/features/stations/data/station_repository_impl.dart';

import 'station_repository_test.dart' show FakeRemote, loadFromDisk;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late FakeRemote remote;
  late StationRepositoryImpl repo;
  final now = DateTime.utc(2026, 11, 9, 8);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemote();
    repo = StationRepositoryImpl(remote: remote, db: db, loadAsset: loadFromDisk, clock: () => now);
  });
  tearDown(() => db.close());

  test('catalogue has the KTTV river stations with keys present in the bulletin', () async {
    final all = await repo.getAll();
    final bulletin = parseKttvBulletin(File('assets/data/kttv_tvhn.json').readAsStringSync());
    final rivers = all.where((s) => s.kttvKey != null).toList();
    expect(rivers.length, greaterThanOrEqualTo(22));
    for (final s in rivers) {
      expect(
        bulletin.series.containsKey(s.kttvKey) || bulletin.daily.containsKey(s.kttvKey),
        isTrue,
        reason: s.id,
      );
    }
    expect(all.map((s) => s.id).toSet().length, all.length, reason: 'ids unique');
  });

  test('Hà Nội: hourly estimate from the bundled bulletin, no obs nudging', () async {
    final s = await repo.getById('kttv-ha-noi');
    final tide = (await repo.getTide(s)).data;
    expect(tide.predictionKind, LevelDataKind.estimate);
    expect(tide.correctWithObservations, isFalse);
    expect(tide.anchor, isNull);
    expect(tide.observations, isNotEmpty);
    final p = tide.prediction;
    expect(p, isNotNull);
    expect(p!.stepMinutes, 60);
    expect(p.covers(now), isTrue);
  });

  test('tidal-river station: daily extremes only, no invented curve', () async {
    final s = await repo.getById('kttv-pha-lai');
    final tide = (await repo.getTide(s)).data;
    expect(tide.prediction, isNull);
    expect(tide.dailyExtremes?.windowHours, 36);
    expect(tide.dailyExtremes!.fcMaxCm, greaterThan(tide.dailyExtremes!.fcMinCm));
  });

  test('published bulletin newer than the bundled one wins', () async {
    final bundled =
        jsonDecode(File('assets/data/kttv_tvhn.json').readAsStringSync()) as Map<String, Object?>;
    remote.kttvBody = jsonEncode({...bundled, 'issued_utc': '2026-11-10T03:30:00Z'});
    final s = await repo.getById('kttv-ha-noi');
    final cached = await repo.getTide(s);
    expect(cached.fetchedAtUtc, DateTime.utc(2026, 11, 10, 3, 30));
  });

  test('stale flag after 30 h without a new bulletin', () async {
    final late = StationRepositoryImpl(
      remote: remote,
      db: db,
      loadAsset: loadFromDisk,
      clock: () => DateTime.utc(2026, 11, 11, 12),
    );
    final s = await late.getById('kttv-ha-noi');
    expect((await late.getTide(s)).isStale, isTrue);
  });

  group('parseKttvBulletin rejects bad input', () {
    test('wrong shape / version', () {
      expect(() => parseKttvBulletin('[]'), throwsA(isA<ParseException>()));
      expect(() => parseKttvBulletin('{"version":2}'), throwsA(isA<ParseException>()));
      expect(() => parseKttvBulletin('nope'), throwsA(isA<ParseException>()));
    });

    test('implausible level', () {
      const body =
          '{"version":1,"issued_utc":"2026-11-09T03:30:00Z","daily":{},'
          '"stations":{"X":{"unit":"cm","points":[{"t":"2026-11-09T00:00:00Z","v":999999,"k":"o"}]}}}';
      expect(() => parseKttvBulletin(body), throwsA(isA<ParseException>()));
    });

    test('discharge rows are skipped, not treated as levels', () {
      const body =
          '{"version":1,"issued_utc":"2026-11-09T03:30:00Z","daily":{},'
          '"stations":{"HồHòaBình":{"unit":"m3/s","points":[]}}}';
      expect(parseKttvBulletin(body).series, isEmpty);
    });
  });
}
