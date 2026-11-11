import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/alerts/application/alert_scheduler.dart';
import 'package:rivertide/features/alerts/application/alert_settings.dart';
import 'package:rivertide/features/alerts/data/alert_notifier.dart';

/// Alarms ring only in the Android app.
bool get alertsSupported => AlertNotifier.supported;

/// Whether [id] has alarms on (false while loading).
bool alertOnFor(WidgetRef ref, String id) =>
    ref.watch(alertPlacesProvider).value?.contains(id) ?? false;

/// Turns alarms for one saved place on/off; asks for notification permission
/// the first time and reschedules everything.
Future<void> toggleAlert(BuildContext context, WidgetRef ref, String id) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final on = !alertOnFor(ref, id);
  if (on) {
    final notifier = AlertNotifier(
      channelName: l10n.alert_channel,
      channelDescription: l10n.alert_channelHint,
    );
    if (!await notifier.requestPermission()) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.alert_denied)));
      return;
    }
  }
  await ref.read(alertPlacesProvider.notifier).setOn(id, on: on);
  await rescheduleAlerts(ref);
  if (on) messenger.showSnackBar(SnackBar(content: Text(l10n.alert_onSnack)));
}
