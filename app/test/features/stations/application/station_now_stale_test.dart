import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/features/stations/application/station_now.dart';
import 'package:rivertide/features/stations/data/station_repository_impl.dart';
import 'package:rivertide/features/stations/domain/point_id.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_chart.dart';

import '../data/station_repository_test.dart' show FakeRemote, loadFromDisk;

/// 10/11/2026 17:06 VN: the 09/11 KTTV bulletin's Phú Thọ forecast ended at
/// 07:00 VN and the new bulletin had not been fetched yet. A point on the Red
/// River above Sơn Tây (reported from the live site) showed "—" and an empty
/// chart; it must show the last known level and when it was valid.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final now = DateTime.utc(2026, 11, 10, 10, 6);
  late AppDatabase db;
  late StationRepositoryImpl repo;

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

  Future<StationTide> tideOf(String id) async => (await repo.getTide(await repo.getById(id))).data;

  test('point above Sơn Tây after the forecast ran out: last known level, not nothing', () async {
    final t = await tideOf(PointId.encode(21.22099, 105.44198));
    expect(t.reference?.stationId, 'kttv-phu-tho');
    final p = t.prediction;
    expect(p, isNotNull);
    expect(p?.endUtc, DateTime.utc(2026, 11, 10)); // ended 10 h before "now"
    final n = computeStationNow(t, now);
    expect(n.levelCm, isNull); // no value is invented for now
    final last = n.lastKnown;
    expect(last?.timeUtc, DateTime.utc(2026, 11, 10));
    expect(last?.levelCm, p?.levelsCm.last.toDouble());
  });

  test('Phú Thọ station itself: same last known level from its forecast', () async {
    final n = computeStationNow(await tideOf('kttv-phu-tho'), now);
    expect(n.levelCm, isNull);
    expect(n.lastKnown?.timeUtc, DateTime.utc(2026, 11, 10));
  });

  test('a current value never also reports a last known one', () async {
    final n = computeStationNow(await tideOf('kttv-ha-noi'), now);
    expect(n.levelCm, isNotNull);
    expect(n.lastKnown, isNull);
  });

  test('older than a day and a half is not shown as a level any more', () async {
    final t = await tideOf('kttv-phu-tho');
    final later = DateTime.utc(2026, 11, 11, 13);
    expect(computeStationNow(t, later).lastKnown, isNull);
  });

  test('chart window moves back in 6-hour steps to keep the last values on screen', () {
    final usual = DateTime.utc(2026, 11, 10, 4); // now 10:06 − 6 h
    expect(TideChart.windowStart(usual, null), usual);
    expect(TideChart.windowStart(usual, DateTime.utc(2026, 11, 10, 11)), usual);
    // Data ended 00:00: 6 h before it is 18:00, 10 h back → two 6-hour steps (16:00).
    expect(TideChart.windowStart(usual, DateTime.utc(2026, 11, 10)), DateTime.utc(2026, 11, 9, 16));
  });
}
