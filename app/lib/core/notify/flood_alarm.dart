import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:timezone/timezone.dart' as tz;

/// One "leave now, the water is coming" alarm (P2-33), Android only. Kept
/// apart from the tide/golden alarms, which are rebuilt on every app start:
/// those must not cancel this one (see `AlertNotifier.cancelAll`).
abstract final class FloodAlarm {
  static const int id = 990001;
  static const String _key = 'flood_alarm';

  static bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Schedules the alarm and remembers it; false when not supported or the
  /// notification permission is refused.
  static Future<bool> set(
    AppDatabase db, {
    required DateTime atUtc,
    required String spotId,
    required String title,
    required String body,
    required String channelName,
  }) async {
    if (!supported) return false;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_con_nuoc'),
      ),
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (!(await android?.requestNotificationsPermission() ?? false)) return false;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(atUtc, tz.UTC),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'flood_out',
          channelName,
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
    );
    await db.writeSetting(
      _key,
      jsonEncode({'spot': spotId, 'at': atUtc.toUtc().toIso8601String()}),
    );
    return true;
  }

  static Future<void> cancel(AppDatabase db) async {
    if (supported) await _plugin.cancel(id: id);
    await db.writeSetting(_key, '');
  }

  /// The alarm set for [spotId] that has not rung yet, or null.
  static Future<DateTime?> pendingFor(AppDatabase db, String spotId, DateTime nowUtc) async {
    final raw = await db.readSetting(_key);
    if (raw == null || raw.isEmpty || raw.length > 300) return null;
    try {
      final m = jsonDecode(raw);
      if (m is! Map<String, Object?> || m['spot'] != spotId) return null;
      final at = DateTime.tryParse('${m['at']}');
      return at != null && at.isAfter(nowUtc) ? at : null;
    } on FormatException {
      return null;
    }
  }
}
