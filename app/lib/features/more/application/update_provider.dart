import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/core/network/dio_client.dart';

part 'update_provider.g.dart';

/// True when the published web build (build.json next to the app, written by
/// CI) differs from the running one. False on mobile, in local builds and on
/// any error — the "new version" notice is shown only when it is certain.
@riverpod
Future<bool> updateAvailable(Ref ref) async {
  if (!kIsWeb || Env.buildSha.isEmpty) return false;
  final stamp = ref.read(clockProvider)().millisecondsSinceEpoch;
  final uri = Uri.base.resolve('build.json').replace(queryParameters: {'t': '$stamp'});
  try {
    final body = await getText(ref.watch(dioProvider), uri);
    if (jsonDecode(body) case {'sha': final String sha} when sha.isNotEmpty) {
      return sha != Env.buildSha;
    }
    return false;
  } on AppException catch (e) {
    log.info('update check skipped', {'error': e.debugMessage});
    return false;
  } on FormatException {
    return false;
  }
}
