import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  testWidgets('station list shows gauges and model points with data kind labels', (tester) async {
    final db = await pumpApp(tester);
    expect(find.text('Vũng Tàu'), findsOneWidget);
    expect(find.text('Có máy đo'), findsWidgets);
    expect(find.text('Thực đo'), findsWidgets);
    await disposeApp(tester, db);
  });

  testWidgets('station detail: level, countdown, hourly tab with now marker and detail', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openDetailFromList(tester, 'Vũng Tàu');
    expect(find.text('Mực nước hiện tại'), findsOneWidget);
    expect(find.textContaining(RegExp('(Đỉnh|Chân) triều sau|Đang đổi con nước')), findsOneWidget);
    await tester.tap(find.text('Theo giờ'));
    await settle(tester);
    expect(find.textContaining('Bây giờ'), findsWidgets);
    expect(find.textContaining('Thực đo'), findsWidgets);
    expect(find.textContaining('Dự báo · tham khảo'), findsWidgets);
    expect(find.textContaining('★'), findsWidgets);
    // The chart axis also shows "13:00"; tap the list row.
    await tester.tap(
      find.descendant(of: find.byType(ListView), matching: find.text('13:00')).first,
    );
    await settle(tester);
    expect(find.text('Chi tiết lúc 13:00'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('calendar and info tabs show lunar day and measured error', (tester) async {
    final db = await pumpApp(tester);
    await openDetailFromList(tester, 'Vũng Tàu');
    await tester.tap(find.text('Lịch triều'));
    await settle(tester);
    expect(find.textContaining('ÂL'), findsWidgets);
    await tester.tap(find.text('Thông tin'));
    await settle(tester);
    expect(find.textContaining('Kiểm thử ngược'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('error state offers retry', (tester) async {
    final db = await pumpApp(tester, repo: FailingRepo.new);
    expect(find.text('Thử lại'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('watch tab empty state, follow a station, then it is listed', (tester) async {
    final db = await pumpApp(tester);
    await tester.tap(find.text('Theo dõi'));
    await settle(tester);
    expect(find.textContaining('chưa theo dõi'), findsOneWidget);
    await tester.tap(find.text('Trạm'));
    await settle(tester);
    // The star sits on the list card itself.
    final card = find.ancestor(of: find.text('Quy Nhơn'), matching: find.byType(Card));
    await tester.tap(find.descendant(of: card, matching: find.byIcon(Icons.star_outline_rounded)));
    await settle(tester);
    expect(find.descendant(of: card, matching: find.byIcon(Icons.star_rounded)), findsOneWidget);
    await tester.tap(find.text('Theo dõi'));
    await settle(tester);
    expect(find.text('Quy Nhơn'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('tap a station in the list → map tab with its detail sheet', (tester) async {
    final db = await pumpApp(tester);
    await tester.tap(find.text('Quy Nhơn'));
    await settle(tester);
    // Sheet over the map: station name, close button, "Xem chi tiết".
    expect(find.byTooltip('Đóng'), findsOneWidget);
    expect(find.text('Xem chi tiết'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await settle(tester);
    expect(find.text('Xem chi tiết'), findsNothing);
    await disposeApp(tester, db);
  });

  testWidgets('fishing tab shows day score and 7-day strip', (tester) async {
    final db = await pumpApp(tester);
    await tester.tap(find.text('Câu cá'));
    await settle(tester);
    expect(find.text('Điểm hôm nay'), findsOneWidget);
    expect(find.text('7 ngày tới'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('text scale 1.6 does not overflow on list and overview', (tester) async {
    final db = await pumpApp(tester, textScale: 1.6);
    await openDetailFromList(tester, 'Vũng Tàu');
    expect(tester.takeException(), isNull);
    await disposeApp(tester, db);
  });

  test('fixtures exist', () {
    expect(File('test/fixtures/vung_20261104.json').existsSync(), isTrue);
  });
}
