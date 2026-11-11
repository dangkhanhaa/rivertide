import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';

const _key = 'alert_places';

/// Saved places with tide alarms on (stored as a JSON list in settings).
class AlertPlaces extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_key);
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw);
      return list is List ? list.whereType<String>().toSet() : {};
    } on FormatException {
      return {};
    }
  }

  Future<void> setOn(String id, {required bool on}) async {
    final next = {...state.value ?? const <String>{}};
    if (on) {
      next.add(id);
    } else {
      next.remove(id);
    }
    state = AsyncData(next);
    await ref.read(appDatabaseProvider).writeSetting(_key, jsonEncode(next.toList()));
  }
}

final AsyncNotifierProvider<AlertPlaces, Set<String>> alertPlacesProvider = AsyncNotifierProvider(
  AlertPlaces.new,
);

/// Minutes before a high/low or good fishing window that the alarm rings.
const Duration alertLead = Duration(minutes: 30);
