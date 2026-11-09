import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/db/app_database.dart';

part 'theme_mode_provider.g.dart';

const _key = 'theme_mode';

/// Light / dark / system, persisted in the local settings table.
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  Future<ThemeMode> build() async {
    final stored = await ref.watch(appDatabaseProvider).readSetting(_key);
    return ThemeMode.values.firstWhere((m) => m.name == stored, orElse: () => ThemeMode.system);
  }

  Future<void> set(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref.read(appDatabaseProvider).writeSetting(_key, mode.name);
  }
}
