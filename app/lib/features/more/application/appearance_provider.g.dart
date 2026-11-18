// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Giao diện của tôi" (P2-31): accent, backdrop, font, text size, language,
/// motion, start tab. Persisted locally; applied app-wide by `app.dart`.

@ProviderFor(AppearanceSettings)
final appearanceSettingsProvider = AppearanceSettingsProvider._();

/// "Giao diện của tôi" (P2-31): accent, backdrop, font, text size, language,
/// motion, start tab. Persisted locally; applied app-wide by `app.dart`.
final class AppearanceSettingsProvider
    extends $AsyncNotifierProvider<AppearanceSettings, Appearance> {
  /// "Giao diện của tôi" (P2-31): accent, backdrop, font, text size, language,
  /// motion, start tab. Persisted locally; applied app-wide by `app.dart`.
  AppearanceSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appearanceSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appearanceSettingsHash();

  @$internal
  @override
  AppearanceSettings create() => AppearanceSettings();
}

String _$appearanceSettingsHash() => r'91ebda8f8758869e8d084e92841c984c7c825371';

/// "Giao diện của tôi" (P2-31): accent, backdrop, font, text size, language,
/// motion, start tab. Persisted locally; applied app-wide by `app.dart`.

abstract class _$AppearanceSettings extends $AsyncNotifier<Appearance> {
  FutureOr<Appearance> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Appearance>, Appearance>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Appearance>, Appearance>,
              AsyncValue<Appearance>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
