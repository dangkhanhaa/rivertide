import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/db/app_database.dart';

part 'outdoor_mode_provider.g.dart';

const _key = 'outdoor_mode';

/// Text enlarged by this factor in outdoor mode (on top of the system size).
const double outdoorTextScale = 1.15;

/// "Chế độ ngoài trời": high contrast + larger text, persisted locally.
@Riverpod(keepAlive: true)
class OutdoorMode extends _$OutdoorMode {
  @override
  Future<bool> build() async => await ref.watch(appDatabaseProvider).readSetting(_key) == 'on';

  Future<void> set({required bool on}) async {
    state = AsyncData(on);
    await ref.read(appDatabaseProvider).writeSetting(_key, on ? 'on' : 'off');
  }
}
