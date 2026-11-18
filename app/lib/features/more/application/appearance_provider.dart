import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/theme/appearance.dart';

part 'appearance_provider.g.dart';

const _key = 'appearance';

/// "Giao diện của tôi" (P2-31): accent, backdrop, font, text size, language,
/// motion, start tab. Persisted locally; applied app-wide by `app.dart`.
@Riverpod(keepAlive: true)
class AppearanceSettings extends _$AppearanceSettings {
  @override
  Future<Appearance> build() async =>
      Appearance.fromJson(await ref.watch(appDatabaseProvider).readSetting(_key));

  Future<void> change(Appearance Function(Appearance current) edit) async {
    final next = edit(state.value ?? const Appearance());
    state = AsyncData(next);
    await ref.read(appDatabaseProvider).writeSetting(_key, next.toJson());
  }

  /// Back to the original look (theme mode and outdoor mode are separate).
  Future<void> reset() => change((_) => const Appearance());
}
