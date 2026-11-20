import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rivertide/core/notify/flood_alarm.dart';
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper over the OS notifications (Android). On the web nothing is
/// scheduled: a browser tab cannot ring when closed.
class AlertNotifier {
  /// [channelName]/[channelDescription] are shown in Android settings (l10n).
  AlertNotifier({required this.channelName, required this.channelDescription})
    : _plugin = FlutterLocalNotificationsPlugin();

  final String channelName;
  final String channelDescription;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  AndroidNotificationDetails get _channel => AndroidNotificationDetails(
    'tide_alerts',
    channelName,
    channelDescription: channelDescription,
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<bool> _init() async {
    if (!supported) return false;
    if (_ready) return true;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_con_nuoc'),
      ),
    );
    _ready = true;
    return true;
  }

  /// Asks for the Android 13+ notification permission; true when allowed.
  Future<bool> requestPermission() async {
    if (!await _init()) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Cancels the tide/golden alarms only: the flood-out alarm (P2-33) is set
  /// by hand for one trip and must survive the rebuild on app start.
  Future<void> cancelAll() async {
    if (!await _init()) return;
    for (final p in await _plugin.pendingNotificationRequests()) {
      if (p.id != FloodAlarm.id) await _plugin.cancel(id: p.id);
    }
  }

  Future<void> schedule({
    required int id,
    required DateTime atUtc,
    required String title,
    required String body,
  }) async {
    if (!await _init()) return;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(atUtc, tz.UTC),
      notificationDetails: NotificationDetails(android: _channel),
      // Inexact: no exact-alarm permission; a few minutes late is fine here.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
    );
  }
}
