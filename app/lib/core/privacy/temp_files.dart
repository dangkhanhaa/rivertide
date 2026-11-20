import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rivertide/core/logging/log.dart';

/// Deletes the app's temporary files: photos picked for a catch, a spot or a
/// pond and images made for sharing land there ("Xoá dữ liệu của tôi",
/// P2-60). The browser keeps no such files, so nothing happens on the web.
/// A file that cannot be removed (in use) is logged and skipped: the OS
/// clears this folder on its own later.
Future<void> clearTemporaryFiles() async {
  if (kIsWeb) return;
  try {
    final dir = await getTemporaryDirectory();
    if (!dir.existsSync()) return;
    for (final entry in dir.listSync()) {
      try {
        entry.deleteSync(recursive: true);
      } on FileSystemException catch (e) {
        log.info('temp entry kept', {'error': e.osError?.errorCode});
      }
    }
  } on FileSystemException catch (e) {
    log.warn('temp folder not cleared', {'error': e.osError?.errorCode});
  }
}
