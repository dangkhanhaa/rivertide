import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/features/gear/domain/gear_data.dart';

const String _key = 'gear_checks';

/// Ticked packing items, kept on the device until "Bỏ tích hết" (P2-38).
class GearChecks extends AsyncNotifier<Set<GearItem>> {
  @override
  Future<Set<GearItem>> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_key);
    if (raw == null || raw.length > 4000) return {};
    try {
      final list = jsonDecode(raw);
      if (list is! List) return {};
      return {
        for (final n in list.whereType<String>()) ...GearItem.values.where((g) => g.name == n),
      };
    } on FormatException {
      return {};
    }
  }

  Future<void> toggle(GearItem item) async {
    final next = {...state.value ?? const <GearItem>{}};
    if (!next.remove(item)) next.add(item);
    await _save(next);
  }

  Future<void> clear() => _save({});

  Future<void> _save(Set<GearItem> items) async {
    state = AsyncData(items);
    await ref
        .read(appDatabaseProvider)
        .writeSetting(_key, jsonEncode([for (final i in items) i.name]));
  }
}

final AsyncNotifierProvider<GearChecks, Set<GearItem>> gearChecksProvider = AsyncNotifierProvider(
  GearChecks.new,
);
