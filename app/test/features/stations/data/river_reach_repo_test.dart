import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/features/stations/data/station_repository_impl.dart';
import 'package:rivertide/features/stations/domain/point_id.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

import 'station_repository_test.dart' show FakeRemote, loadFromDisk;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late StationRepositoryImpl repo;
  final now = DateTime.utc(2026, 11, 9, 8);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = StationRepositoryImpl(
      remote: FakeRemote(),
      db: db,
      loadAsset: loadFromDisk,
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  Future<StationTide> pointTide(double lat, double lon) async {
    final p = await repo.getById(PointId.encode(lat, lon));
    return (await repo.getTide(p)).data;
  }

  test('river lines load with station km from the OSM build', () async {
    final rivers = await repo.getRivers();
    final hong = rivers.firstWhere((r) => r.id == 'hong');
    expect(hong.stationKm['kttv-ha-noi'], closeTo(165.6, 0.5));
    expect(hong.lengthKm, closeTo(309, 1));
  });

  test('Thanh Trì bridge: downstream of Hà Nội, earlier tide, lower water, own curve', () async {
    final station = (await repo.getTide(await repo.getById('kttv-ha-noi'))).data;
    final t = await pointTide(20.999, 105.885);
    final ref = t.reference!;
    expect(ref.stationId, 'kttv-ha-noi');
    expect(ref.alongKm, closeTo(-5.7, 0.3)); // measured along the river, not straight line
    expect(ref.lagShiftMinutes, lessThan(-10)); // turns earlier than at Long Biên
    expect(ref.lagShiftMinutes, greaterThan(-30));
    expect(ref.meanShiftCm, lessThan(0)); // lower towards the sea
    expect(ref.celerityKmH, inInclusiveRange(15, 25));
    expect(t.predictionKind, LevelDataKind.estimate);
    expect(t.observations, isEmpty); // station readings are not this point's
    // The point's curve differs from the station's (not a copy).
    final a = station.prediction!.levelAt(now)!;
    final b = t.prediction!.levelAt(now)!;
    expect((a - b).abs(), greaterThan(0.5));
    expect((a - b).abs(), lessThan(40));
  });

  test('upstream point on the Red River (Chèm, ~8 km up) turns later', () async {
    final t = await pointTide(21.088, 105.786);
    expect(t.reference!.alongKm, greaterThan(0));
    expect(t.reference!.lagShiftMinutes, greaterThan(0));
  });

  test('a street 3 km from the river: no along-river estimate, nearest-station fallback', () async {
    final t = await pointTide(21.03, 105.80);
    expect(t.reference!.alongKm, isNull);
    expect(t.reference!.stationId, 'kttv-ha-noi');
  });

  test('far downstream beyond the defensible range: fallback, no along-river claim', () async {
    // Red River near Hưng Yên–Thái Bình, ~80 km below Hà Nội.
    final t = pointTide(20.55, 106.15);
    await expectLater(t, completes);
    final r = (await t).reference;
    expect(r?.alongKm, isNull);
  });

  test('Sông Mã at Thanh Hóa: the model snaps to a sea cell 16 km off, which is not '
      '"sea here"; the Giàng station 2 km away answers', () async {
    final t = await pointTide(19.86, 105.80);
    expect(t.reference?.stationId, 'kttv-giang');
  });

  test('Thái Bình city: model has sea level on delta land (11 m) → coast estimate, '
      'low confidence, not "sea here"', () async {
    final t = await pointTide(20.45, 106.34);
    expect(t.reference?.stationId, coastReferenceId);
    expect(t.predictionKind, LevelDataKind.estimate);
    expect(t.model?.confidence, TideConfidence.low);
    expect(t.prediction, isNotNull);
  });

  test('open sea off Vũng Tàu: the model at the point itself', () async {
    final t = await pointTide(10.3, 107.1);
    expect(t.reference, isNull);
    expect(t.prediction, isNotNull);
  });

  test('Sông Mã flow: main stem picked from the real 3×3 GloFAS cells', () async {
    final p = await repo.getById(PointId.encode(19.86, 105.80));
    final flow = (await repo.getFlow(p)).data!;
    expect(flow.cellLon, closeTo(105.775, 0.001));
    expect(flow.on(DateTime.utc(2026, 11, 10)), closeTo(708.58, 0.01));
  });

  test('Sông Đà at Hòa Bình: no sea, no station within 40 km → no level, no error', () async {
    final t = await pointTide(20.82, 105.34);
    expect(t.prediction, isNull);
    expect(t.observations, isEmpty);
    expect(t.dailyExtremes, isNull);
    expect(t.reference, isNull);
    expect(t.station.kind, StationKind.river);
  });
}
