import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';

const String _key = 'map_hidden_layers';

/// Map layers the user switched off (ponds, community spots, trips, people
/// fishing), by overlay name; remembered on the device (P2-43).
class HiddenOverlays extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_key);
    if (raw == null || raw.length > 500) return {};
    try {
      final list = jsonDecode(raw);
      return list is List ? list.whereType<String>().toSet() : {};
    } on FormatException {
      return {};
    }
  }

  Future<void> setVisible(String name, {required bool visible}) async {
    final next = {...state.value ?? const <String>{}};
    if (visible) {
      next.remove(name);
    } else {
      next.add(name);
    }
    state = AsyncData(next);
    await ref.read(appDatabaseProvider).writeSetting(_key, jsonEncode(next.toList()));
  }
}

final AsyncNotifierProvider<HiddenOverlays, Set<String>> hiddenOverlaysProvider =
    AsyncNotifierProvider(HiddenOverlays.new);
