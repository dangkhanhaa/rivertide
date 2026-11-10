import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/features/map/domain/location_service.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';

import '../../helpers/app_harness.dart';

void main() {
  testWidgets('map tab is first and shows one marker per station with trend', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    expect(find.text('Bản đồ'), findsOneWidget);
    // Vũng Tàu fixture has fresh observations → normal, rising or falling.
    expect(
      find.textContaining(RegExp(r'^pin:ioc-vung:normal:(rising|falling|slack)$')),
      findsOneWidget,
    );
    expect(find.textContaining('pin:'), findsNWidgets(38));
    await disposeApp(tester, db);
  });

  testWidgets('tap marker → sheet with level, countdown, follow, open detail (F-MAP-02)', (
    tester,
  ) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.textContaining('pin:ioc-vung:'));
    await settle(tester);
    expect(find.text('Vũng Tàu'), findsOneWidget);
    // Next-turn tiles: kind, time, level and a countdown.
    expect(find.textContaining(RegExp(r'^(Đỉnh|Chân) triều$')), findsWidgets);
    expect(find.textContaining(RegExp('^còn ')), findsWidgets);
    expect(find.text('Thực đo'), findsWidgets);
    await tester.tap(find.byTooltip('Theo dõi trạm'));
    await settle(tester);
    expect(find.byTooltip('Bỏ theo dõi'), findsOneWidget); // AC-MAP02-2
    await tester.ensureVisible(find.text('Xem chi tiết'));
    await tester.tap(find.text('Xem chi tiết'));
    await settle(tester);
    expect(find.text('Mực nước hiện tại'), findsOneWidget); // AC-MAP02-3
    await disposeApp(tester, db);
  });

  testWidgets('accent-free search finds the station and opens its sheet (AC-MAP04-1)', (
    tester,
  ) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.byIcon(Icons.search_rounded));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'quy nhon');
    await settle(tester);
    expect(find.widgetWithText(ListTile, 'Quy Nhơn'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Quy Nhơn'));
    await settle(tester);
    expect(find.text('Xem chi tiết'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('search with no hit says so', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.byIcon(Icons.search_rounded));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'zzzz');
    await settle(tester);
    expect(find.text('Không tìm thấy trạm phù hợp'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('filter "only alarm" hides every V0 station and says so (AC-MAP01-5)', (
    tester,
  ) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.byTooltip('Bộ lọc'));
    await settle(tester);
    await tester.tap(find.text('Chỉ trạm đang báo động'));
    await settle(tester);
    await tester.tapAt(const Offset(20, 20)); // close sheet
    await settle(tester);
    expect(find.textContaining('pin:'), findsNothing);
    expect(find.text('Không có trạm nào khớp bộ lọc'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('legend explains colours in words', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.byTooltip('Chú giải'));
    await settle(tester);
    expect(find.text('Báo động II'), findsOneWidget);
    expect(find.text('Mất dữ liệu quá 6 giờ'), findsOneWidget);
    expect(find.textContaining('OpenStreetMap'), findsWidgets);
    await disposeApp(tester, db);
  });

  testWidgets('locate: granted → my position shown', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.byTooltip('Vị trí của tôi'));
    await settle(tester);
    expect(find.text('me'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('first open without permission: explained request once; "Để sau" does nothing', (
    tester,
  ) async {
    final location = FakeLocation(granted: false);
    final db = await pumpApp(tester, startOnMap: true, location: location);
    expect(find.text('Dùng vị trí của bạn?'), findsOneWidget);
    await tester.tap(find.text('Để sau'));
    await settle(tester);
    expect(find.text('me'), findsNothing);
    await disposeApp(tester, db);
  });

  testWidgets('opens on my position when permission already exists', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    expect(find.text('me'), findsOneWidget);
    expect(find.text('Dùng vị trí của bạn?'), findsNothing);
    await disposeApp(tester, db);
  });

  testWidgets('tap a river bank → own level, turns and day stats for that place', (tester) async {
    // Clock inside the real bulletin + Hòn Dấu data window.
    final db = await pumpApp(tester, startOnMap: true, now: DateTime.utc(2026, 11, 9, 8));
    expect(find.textContaining('Chạm vào bất kỳ đâu'), findsOneWidget);
    await tester.tap(find.text('tap-river'));
    await settle(tester);
    expect(find.text('pin'), findsOneWidget);
    expect(find.text('Điểm đã chọn'), findsOneWidget);
    expect(find.textContaining('20.99500, 105.88000'), findsOneWidget);
    // The place's own numbers, no "based on station…" explanations.
    expect(find.text('Sông Hồng'), findsOneWidget);
    expect(find.textContaining('trạm Hà Nội'), findsNothing);
    expect(find.textContaining('Dựa theo'), findsNothing);
    expect(find.text('Ước tính'), findsWidgets);
    expect(find.textContaining(RegExp(r'^\d+,\d\d m$')), findsWidgets); // level here
    expect(find.text('Hôm nay'), findsOneWidget);
    expect(find.textContaining('Mặt trời mọc'), findsOneWidget);
    expect(find.text('Trạm gần nhất'), findsOneWidget);
    await tester.ensureVisible(find.text('Xem chi tiết theo giờ'));
    await tester.tap(find.text('Xem chi tiết theo giờ'));
    await settle(tester);
    expect(find.text('20.9950, 105.8800'), findsOneWidget); // detail title = coordinates
    expect(find.text('Theo giờ'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('tap a street (not water) → nearby river named, still an estimate', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.text('tap-street'));
    await settle(tester);
    expect(find.text('Gần sông Hồng'), findsOneWidget);
    expect(find.textContaining('Dựa theo'), findsNothing);
    expect(find.text('Ước tính'), findsWidgets);
    expect(find.text('Trạm gần nhất'), findsOneWidget); // stations only as a list
    await disposeApp(tester, db);
  });

  testWidgets('a tapped point can be starred and reopens from the watch list', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.text('tap-river'));
    await settle(tester);
    await tester.tap(find.byTooltip('Theo dõi trạm'));
    await settle(tester);
    expect(find.byTooltip('Bỏ theo dõi'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await settle(tester);
    await tester.tap(find.text('Theo dõi'));
    await settle(tester);
    expect(find.text('20.9950, 105.8800'), findsOneWidget); // saved point, named by coordinates
    await tester.tap(find.text('20.9950, 105.8800'));
    await settle(tester);
    expect(find.text('Điểm đã chọn'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('layer button switches to satellite and remembers it', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    expect(find.textContaining('"layer":"standard"'), findsOneWidget);
    await tester.tap(find.byTooltip('Lớp bản đồ'));
    await settle(tester);
    expect(find.textContaining('Sentinel-2'), findsOneWidget);
    await tester.tap(find.text('Ảnh vệ tinh'));
    await settle(tester);
    expect(find.textContaining('"layer":"satellite"'), findsOneWidget);
    expect(await db.readSetting('map_base_layer'), 'satellite');
    await disposeApp(tester, db);
  });

  testWidgets(
    'web click-through: clicks on buttons, search bar or under a sheet are not map taps',
    (tester) async {
      final db = await pumpApp(tester, startOnMap: true);
      final blocks = FakeBaseMap.last?.blocksTapAt;
      expect(blocks, isNotNull);
      final search = tester.getCenter(find.byType(SearchBar));
      final layersButton = tester.getCenter(find.byTooltip('Lớp bản đồ'));
      expect(blocks!(search), isTrue);
      expect(blocks(layersButton), isTrue);
      expect(blocks(const Offset(60, 700)), isFalse); // open map
      await tester.tap(find.byTooltip('Lớp bản đồ'));
      await settle(tester);
      expect(blocks(const Offset(60, 700)), isTrue); // a sheet is open above the map
      await disposeApp(tester, db);
    },
  );

  testWidgets('map keeps a one-line licence credit; tapping it shows the full text', (
    tester,
  ) async {
    final db = await pumpApp(tester, startOnMap: true);
    expect(find.text('© OpenFreeMap · © OpenStreetMap'), findsOneWidget);
    await tester.tap(find.text('© OpenFreeMap · © OpenStreetMap'));
    await settle(tester);
    expect(find.text('Nguồn bản đồ'), findsOneWidget);
    expect(find.textContaining('dữ liệu © OpenStreetMap'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('phone: a tapped point is centred above the detail sheet, below the search bar', (
    tester,
  ) async {
    final db = await pumpApp(tester, startOnMap: true);
    FakeBaseMap.flights.clear();
    await tester.tap(find.text('tap-river'));
    await settle(tester);
    final f = FakeBaseMap.flights.last;
    expect((f.lat, f.lon), (20.995, 105.88));
    expect(f.offset.dx, 0); // full width visible
    // Sheet covers the lower ~55 %: the point must sit well above the view centre.
    final mapSize = tester.getSize(find.byType(FakeBaseMap));
    expect(f.offset.dy, greaterThan(mapSize.height * 0.15));
    await disposeApp(tester, db);
  });

  testWidgets('wide: a tapped point is centred in the map left of the side panel', (tester) async {
    final db = await pumpApp(
      tester,
      startOnMap: true,
      physicalSize: const Size(1400, 900),
      devicePixelRatio: 1,
    );
    FakeBaseMap.flights.clear();
    await tester.tap(find.text('tap-river'));
    await settle(tester);
    final f = FakeBaseMap.flights.last;
    // The map shrinks beside the panel (no web click/scroll-through) and keeps
    // its centre, so no sideways offset is needed.
    expect(f.offset.dx, 0);
    final mapBox = tester.getRect(find.byType(FakeBaseMap));
    expect(mapBox.right, closeTo(1400 - 420, 1));
    expect(f.offset.dy, lessThan(0)); // nudged down below the search bar
    await disposeApp(tester, db);
  });

  testWidgets('station from search or list flies there zoomed with the same centring', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    FakeBaseMap.flights.clear();
    await tester.tap(find.text('Quy Nhơn'));
    await settle(tester);
    final f = FakeBaseMap.flights.last;
    expect(f.lat, closeTo(13.7751, 1e-3));
    expect(f.offset.dy, greaterThan(0));
    await disposeApp(tester, db);
  });

  testWidgets('a point on the river shows the main-stem discharge (GloFAS)', (tester) async {
    // Clock inside the real GloFAS extract (2026-11-07 → 16).
    final db = await pumpApp(tester, startOnMap: true, now: DateTime.utc(2026, 11, 10, 2));
    await tester.tap(find.text('tap-river'));
    await settle(tester);
    expect(find.text('Dòng chảy sông'), findsOneWidget);
    expect(find.textContaining(RegExp(r'Lưu lượng hôm nay ≈ [\d.]+ m³/s')), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('map gestures are locked while a sheet covers it, then released', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    expect(find.text('map-locked'), findsNothing);
    await tester.tap(find.text('tap-river'));
    await settle(tester);
    expect(find.text('map-locked'), findsOneWidget); // drags on the sheet cannot pan the map
    await tester.tap(find.byTooltip('Đóng'));
    await settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('map-locked'), findsNothing);
    await disposeApp(tester, db);
  });

  testWidgets('tap the sea → model at the point itself, no reference station', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.text('tap-sea'));
    await settle(tester);
    expect(find.textContaining('10.30000, 107.10000'), findsOneWidget);
    expect(find.textContaining('Ước tính theo trạm'), findsNothing);
    // Sources live in Thêm → Nguồn dữ liệu and the Thông tin tab, not here.
    expect(find.textContaining('Nguồn:'), findsNothing);
    expect(find.byTooltip('Chi tiết nguồn'), findsNothing);
    expect(find.text('Vùng biển'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('tap far from any water data → says so instead of inventing', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.text('tap-none'));
    await settle(tester);
    expect(find.textContaining('Chưa có dữ liệu mực nước cho điểm này'), findsOneWidget);
    expect(find.text('Trạm gần nhất'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('closing a point sheet does not open another point (web click-through)', (
    tester,
  ) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.text('tap-river'));
    await settle(tester);
    expect(find.text('Điểm đã chọn'), findsOneWidget);
    // On web the map under the sheet also receives clicks: ignored while open…
    FakeBaseMap.last?.onMapTap(10.3, 107.1, PointSurface.water);
    await settle(tester);
    expect(find.textContaining('10.30000, 107.10000'), findsNothing);
    // …and the click that closes the sheet must not open a new one.
    // The sheet is tall, so close it the way a barrier tap does: pop the route.
    Navigator.of(tester.element(find.text('Điểm đã chọn'))).pop();
    await tester.pump();
    FakeBaseMap.last?.onMapTap(10.3, 107.1, PointSurface.water);
    await settle(tester);
    expect(find.text('Điểm đã chọn'), findsNothing);
    expect(find.text('pin'), findsNothing);
    // A deliberate tap afterwards works again.
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('tap-sea'));
    await settle(tester);
    expect(find.textContaining('10.30000, 107.10000'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('wide screen: details in a right-hand panel, map stays usable', (tester) async {
    final db = await pumpApp(
      tester,
      startOnMap: true,
      physicalSize: const Size(1400, 900),
      devicePixelRatio: 1,
    );
    await tester.tap(find.text('tap-river'));
    await settle(tester);
    expect(find.text('Điểm đã chọn'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    // Another tap on the map replaces the panel content.
    await tester.tap(find.text('tap-sea'));
    await settle(tester);
    expect(find.textContaining('10.30000, 107.10000'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await settle(tester);
    expect(find.text('Điểm đã chọn'), findsNothing);
    await disposeApp(tester, db);
  });

  testWidgets('tap outside Vietnam → message, no sheet', (tester) async {
    final db = await pumpApp(tester, startOnMap: true);
    await tester.tap(find.text('tap-outside'));
    await settle(tester);
    expect(find.text('Vị trí nằm ngoài vùng hỗ trợ'), findsOneWidget);
    expect(find.text('Điểm đã chọn'), findsNothing);
    await disposeApp(tester, db);
  });

  testWidgets('locate: denied forever → settings dialog (AC-MAP04-3)', (tester) async {
    final location = FakeLocation(result: const LocationDenied(forever: true));
    final db = await pumpApp(tester, startOnMap: true, location: location);
    await tester.tap(find.byTooltip('Vị trí của tôi'));
    await settle(tester);
    expect(find.text('Quyền vị trí đang bị chặn'), findsOneWidget);
    await tester.tap(find.text('Mở Cài đặt'));
    await settle(tester);
    expect(location.settingsOpened, 1);
    await disposeApp(tester, db);
  });

  testWidgets('locate: service off → message', (tester) async {
    final location = FakeLocation(result: const LocationServiceOff());
    final db = await pumpApp(tester, startOnMap: true, location: location);
    await tester.tap(find.byTooltip('Vị trí của tôi'));
    await settle(tester);
    expect(find.textContaining('Định vị đang tắt'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('station list failure on the map shows retry', (tester) async {
    final db = await pumpApp(tester, startOnMap: true, repo: FailingRepo.new);
    expect(find.text('Không tải được danh sách trạm'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('map screen survives text scale 1.6', (tester) async {
    final db = await pumpApp(tester, startOnMap: true, textScale: 1.6);
    await tester.tap(find.textContaining('pin:ioc-vung:'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await disposeApp(tester, db);
  });
}
