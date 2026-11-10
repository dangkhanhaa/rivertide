import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/app.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/errors/retry_policy.dart';
import 'package:rivertide/features/map/application/map_providers.dart';
import 'package:rivertide/features/map/domain/location_service.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/data/station_repository_impl.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_repository.dart';

import '../features/stations/data/station_repository_test.dart' show FakeRemote, loadFromDisk;

final testNow = DateTime.utc(2026, 11, 4, 12, 5);

class FailingRepo extends StationRepositoryImpl {
  FailingRepo(AppDatabase db)
    : super(remote: FakeRemote(), db: db, loadAsset: loadFromDisk, clock: () => testNow);

  @override
  Future<List<Station>> getAll() async => throw const NetworkException('down');
}

/// Stand-in for the platform map: one button per marker ("pin:id:status:trend").
class FakeBaseMap extends StatelessWidget implements BaseMapHandle {
  const FakeBaseMap({required this.config, super.key});

  final BaseMapConfig config;

  /// Lets tests deliver a map tap the way web does: while a sheet covers the map.
  static BaseMapConfig? last;

  @override
  Future<void> flyTo(double lat, double lon, {double? zoom, Offset offset = Offset.zero}) async {
    flights.add((lat: lat, lon: lon, offset: offset));
  }

  /// Camera moves requested by the screen, newest last.
  static final flights = <({double lat, double lon, Offset offset})>[];

  @override
  Widget build(BuildContext context) {
    config.onReady(this);
    last = config;
    Widget tap(String label, double lat, double lon, [PointSurface s = PointSurface.water]) =>
        TextButton(onPressed: () => config.onMapTap(lat, lon, s), child: Text(label));
    return Padding(
      padding: const EdgeInsets.only(top: 300), // below search bar + hint card
      child: Wrap(
        children: [
          if (config.userPosition != null) const Text('me'),
          if (config.pin != null) const Text('pin'),
          if (!config.gesturesEnabled) const Text('map-locked'),
          Text('style:${config.styleString}'),
          tap('tap-river', 20.995, 105.88), // Red River bank near Thanh Trì bridge
          tap('tap-sea', 10.3, 107.1), // open sea off Vũng Tàu
          tap('tap-none', 13, 107.6), // Central Highlands, no station within 40 km
          tap('tap-outside', 30, 120),
          tap('tap-street', 21.03, 105.80, PointSurface.land), // Cầu Giấy streets, not water
          for (final m in config.markers)
            TextButton(
              style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero),
              onPressed: () => config.onStationTap(m.id),
              child: Text('pin:${m.id}:${m.status.name}:${m.trend.name}'),
            ),
        ],
      ),
    );
  }
}

class FakeLocation implements LocationService {
  FakeLocation({this.result = const Located(10.35, 107.08), this.granted = true});

  final LocateResult result;
  final bool granted;
  int settingsOpened = 0;

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<LocateResult> locate() async => result;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

/// Pumps the whole app with fakes; starts on the station list unless [startOnMap].
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  StationRepository Function(AppDatabase db)? repo,
  double textScale = 1,
  bool startOnMap = false,
  LocationService? location,
  Size physicalSize = const Size(1080, 2340),
  double devicePixelRatio = 2.75,
  DateTime? now,
}) async {
  final clock = now ?? testNow;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: providerRetry,
      overrides: [
        clockProvider.overrideWithValue(() => clock),
        minuteTickerProvider.overrideWith((ref) => Stream.value(clock)),
        appDatabaseProvider.overrideWithValue(db),
        stationRepositoryProvider.overrideWithValue(
          repo?.call(db) ??
              StationRepositoryImpl(
                remote: FakeRemote(),
                db: db,
                loadAsset: loadFromDisk,
                clock: () => clock,
              ),
        ),
        mapStyleProvider.overrideWith((ref, args) async => '{"layer":"${args.$2.name}"}'),
        baseMapBuilderProvider.overrideWithValue((config) => FakeBaseMap(config: config)),
        locationServiceProvider.overrideWithValue(location ?? FakeLocation()),
      ],
      child: MediaQuery(
        // fromView: a bare MediaQueryData has size 0 and breaks full-screen routes.
        data: MediaQueryData.fromView(tester.view)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: const RiverTideApp(),
      ),
    ),
  );
  await settle(tester);
  if (!startOnMap) {
    await tester.tap(find.text('Trạm'));
    await settle(tester);
  }
  return db;
}

/// Real file I/O happens inside the fake sources, so let it run outside fake async.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Unmount only: closing the in-memory DB inside runAsync deadlocks on stream queries
/// scheduled in the fake-async zone; the memory DB is dropped with the test anyway.
Future<void> disposeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

/// Station list → map (zoomed, detail sheet) → "Xem chi tiết" → detail screen.
Future<void> openDetailFromList(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await settle(tester);
  final open = find.text('Xem chi tiết');
  await tester.ensureVisible(open);
  await tester.tap(open);
  await settle(tester);
}
