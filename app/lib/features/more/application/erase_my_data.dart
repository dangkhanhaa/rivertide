import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/core/notify/notifications_reset.dart';
import 'package:rivertide/core/privacy/temp_files.dart';
import 'package:rivertide/core/social/data_erasure.dart';
import 'package:rivertide/features/watch/watch.dart';

/// Where "Xoá dữ liệu của tôi" stopped (P2-60).
enum EraseFailure {
  /// The server copy could not be erased: nothing was touched on the device,
  /// so the secret that proves "this is mine" is still there for a retry.
  server,

  /// The server copy is gone but this device still holds some data; a retry
  /// finishes the job (the server part is then a no-op).
  device,
}

/// Erases this user's data: first on the server (needs the device secret),
/// then alarms, the home-screen widget, temporary files and every local
/// table (saved places, journal, settings, the secret, the terms acceptance).
/// Returns null when everything is gone. The caller then calls
/// [restartAfterErase] so the app starts over at the welcome/terms gate.
Future<EraseFailure?> eraseMyData(WidgetRef ref) async {
  try {
    await ref.read(dataErasureServiceProvider)?.eraseServerData();
  } on AppException catch (e) {
    log.warn('erase: server part failed', {'error': e.debugMessage});
    return EraseFailure.server;
  }
  try {
    await cancelAllNotifications();
    await clearHomeWidget();
    await clearTemporaryFiles();
    await ref.read(appDatabaseProvider).wipeAll();
    return null;
  } on Exception catch (e) {
    // Database, file or platform-channel errors: reported, never swallowed.
    log.warn('erase: device part failed', {'error': e.runtimeType});
    return EraseFailure.device;
  }
}

/// Reopens the local database: every setting, list and gate is read again
/// from the now empty tables, so the welcome flow and the terms show again.
void restartAfterErase(WidgetRef ref) => ref.invalidate(appDatabaseProvider);
