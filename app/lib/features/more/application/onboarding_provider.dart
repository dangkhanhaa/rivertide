import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/features/more/domain/user_profile.dart';

part 'onboarding_provider.g.dart';

/// Versioned, so a later redesign can be shown once more (`_v2`).
const String _key = 'onboarding_v1';
const String _done = 'done';
const String _profileKey = 'user_profile';

/// Steps of the welcome flow: welcome, language, name, who, preferences, look.
const int onboardingSteps = 6;

/// Welcome flow progress (P2-53): null = finished (or never needed), else the
/// step to resume at. The step is saved as the user moves, so an app killed
/// or a web page reloaded mid-way comes back where it left off.
@Riverpod(keepAlive: true)
class OnboardingProgress extends _$OnboardingProgress {
  @override
  Future<int?> build() async {
    final db = ref.watch(appDatabaseProvider);
    final raw = await db.readSetting(_key);
    if (raw == _done) return null;
    if (raw == null) {
      // Installs that already hold settings or favourites updated from a
      // version without this flow: they know the app, never interrupt them.
      if (await db.hasUserData()) {
        await db.writeSetting(_key, _done);
        return null;
      }
      // Marked before any other setting is written, so a half-finished flow
      // is never mistaken for an existing user on the next launch.
      await db.writeSetting(_key, '0');
      return 0;
    }
    return (int.tryParse(raw) ?? 0).clamp(0, onboardingSteps - 1);
  }

  /// Remembers the current step; does not rebuild the flow.
  Future<void> saveStep(int step) async {
    if (state.value == null) return;
    await ref.read(appDatabaseProvider).writeSetting(_key, '$step');
  }

  Future<void> finish() async {
    state = const AsyncData(null);
    await ref.read(appDatabaseProvider).writeSetting(_key, _done);
  }
}

/// "Bạn là ai?" and favourite waters (P2-53), kept on the device only.
@Riverpod(keepAlive: true)
class UserProfileSettings extends _$UserProfileSettings {
  @override
  Future<UserProfile> build() async =>
      UserProfile.fromJson(await ref.watch(appDatabaseProvider).readSetting(_profileKey));

  Future<void> change(UserProfile Function(UserProfile current) edit) async {
    final next = edit(state.value ?? const UserProfile());
    state = AsyncData(next);
    await ref.read(appDatabaseProvider).writeSetting(_profileKey, next.toJson());
  }
}
