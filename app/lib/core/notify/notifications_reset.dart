import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Cancels every notification the app scheduled (tide, golden-hour and
/// flood-out alarms) for "Xoá dữ liệu của tôi" (P2-60). Android only: the app
/// schedules nothing on iOS or the web.
Future<void> cancelAllNotifications() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await plugin.cancelAll();
}
