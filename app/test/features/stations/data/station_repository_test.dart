import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/data/remote_sources.dart';
import 'package:rivertide/features/stations/data/station_repository_impl.dart';
import 'package:rivertide/features/stations/domain/station.dart';

class FakeRemote extends RemoteSources {
  FakeRemote() : super(Dio());

  int iocCalls = 0;
  int marineCalls = 0;
  bool offline = false;
  DateTime? lastIocFrom;

  @override
  Future<String> fetchIoc(String code, DateTime fromUtc, DateTime toUtc) async {
    iocCalls++;
    lastIocFrom = fromUtc;
    if (offline) throw const NetworkException('offline');
    return File('test/fixtures/vung_20261104.json').readAsStringSync();
  }

  @override
  Future<String> fetchMarine(double lat, double lon) async {
    marineCalls++;
    if (offline) throw const NetworkException('offline');
    // Sea reference of the Red River (Hòn Dấu): real Open-Meteo extract.
    if ((lat - 20.67).abs() < 1e-6 && (lon - 106.81).abs() < 1e-6) {
      return File('test/fixtures/om_hondau_20261025_20261112.json').readAsStringSync();
    }
    // Open sea off Vũng Tàu (the map test's sea tap).
    if ((lat - 10.3).abs() < 1e-6 && (lon - 107.1).abs() < 1e-6) {
      return File('test/fixtures/marine_sea_offvungtau_20261110.json').readAsStringSync();
    }
    // Thái Bình city: 25 km inland, yet the model has sea level here.
    if ((lat - 20.45).abs() < 1e-6 && (lon - 106.34).abs() < 1e-6) {
      return File('test/fixtures/marine_thaibinh_20261110.json').readAsStringSync();
    }
    // Thanh Hóa city: real answer snapped to a sea cell 16 km away.
    if ((lat - 19.86).abs() < 1e-6 && (lon - 105.80).abs() < 1e-6) {
      return File('test/fixtures/marine_land_thanhhoa_20261110.json').readAsStringSync();
    }
    // Open-Meteo returns all-null sea level over land.
    final inland = (lat > 20.8 && lon < 106.5) || (lat > 12 && lat < 15 && lon < 108.5);
    return File(
      inland
          ? 'test/fixtures/marine_land_hanoi_20261110.json'
          : 'test/fixtures/marine_vungtau_20261106.json',
    ).readAsStringSync();
  }

  /// Null: the published bulletin is not reachable (falls back to the bundled copy).
  String? kttvBody;

  @override
  Future<String> fetchKttv() async {
    final body = kttvBody;
    if (offline || body == null) throw const NetworkException('kttv offline');
    return body;
  }

  @override
  Future<String> fetchFlood(double lat, double lon) async {
    if (offline) throw const NetworkException('offline');
    if ((lat - 19.86).abs() < 1e-6 && (lon - 105.80).abs() < 1e-6) {
      return File('test/fixtures/flood_thanhhoa_3x3_20261110.json').readAsStringSync();
    }
    return File('test/fixtures/flood_hanoi_3x3_20261110.json').readAsStringSync();
  }

  @override
  Future<String> fetchWeather(double lat, double lon, List<String> fields) async {
    if (offline) throw const NetworkException('offline');
    return File('test/fixtures/forecast_cantho_20261106.json').readAsStringSync();
  }
}

Future<String?> loadFromDisk(String path) async {
  final f = File(path);
  return f.existsSync() ? f.readAsStringSync() : null;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late FakeRemote remote;
  var now = DateTime.utc(2026, 11, 5);

  StationRepositoryImpl repo() =>
      StationRepositoryImpl(remote: remote, db: db, loadAsset: loadFromDisk, clock: () => now);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemote();
    now = DateTime.utc(2026, 11, 5);
  });
  tearDown(() => db.close());

  test('catalogue loads all stations with valid ids and coordinates in Vietnam', () async {
    final all = await repo().getAll();
    expect(all.length, greaterThanOrEqualTo(10));
    for (final s in all) {
      expect(RegExp(r'^[a-z0-9-]{3,64}$').hasMatch(s.id), isTrue);
      expect(s.lat, inInclusiveRange(8.0, 23.5));
      expect(s.lon, inInclusiveRange(102.0, 117.5));
    }
    await expectLater(repo().getById('nope'), throwsA(isA<NotFoundException>()));
  });

  test('gauge: prediction from bundled asset + observations, cached within TTL', () async {
    final r = repo();
    final vung = await r.getById('ioc-vung');
    final first = await r.getTide(vung);
    expect(first.isStale, isFalse);
    expect(first.data.prediction, isNotNull);
    expect(first.data.observations, isNotEmpty);
    expect(remote.lastIocFrom, now.subtract(const Duration(days: 3)));
    await r.getTide(vung);
    expect(remote.iocCalls, 1, reason: 'second call within 15 min uses cache');
  });

  test('gauge offline: prediction still available, observations stale', () async {
    final r = repo();
    final vung = await r.getById('ioc-vung');
    await r.getTide(vung);
    remote.offline = true;
    now = now.add(const Duration(hours: 1));
    final offline = await r.getTide(vung);
    expect(offline.isStale, isTrue);
    expect(offline.data.observations, isNotEmpty);
    expect(offline.data.prediction, isNotNull);
  });

  test('model station: marine cached, offline without cache throws AppException', () async {
    final r = repo();
    final model = (await r.getAll()).firstWhere((s) => s.kind == StationKind.model);
    remote.offline = true;
    await expectLater(r.getTide(model), throwsA(isA<NetworkException>()));
    remote.offline = false;
    final ok = await r.getTide(model);
    expect(ok.data.prediction, isNotNull);
    remote.offline = true;
    now = now.add(const Duration(hours: 4));
    final stale = await r.getTide(model);
    expect(stale.isStale, isTrue);
    expect(remote.marineCalls, 3);
  });

  test('weather parses and caches', () async {
    final r = repo();
    final vung = await r.getById('ioc-vung');
    final w = await r.getWeather(vung);
    expect(w.data, isNotEmpty);
  });
}
