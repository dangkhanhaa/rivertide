// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Light / dark / system, persisted in the local settings table.

@ProviderFor(AppThemeMode)
final appThemeModeProvider = AppThemeModeProvider._();

/// Light / dark / system, persisted in the local settings table.
final class AppThemeModeProvider extends $AsyncNotifierProvider<AppThemeMode, ThemeMode> {
  /// Light / dark / system, persisted in the local settings table.
  AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  AppThemeMode create() => AppThemeMode();
}

String _$appThemeModeHash() => r'9169ff2621682920bd5de7e954c89b5e1486e6b7';

/// Light / dark / system, persisted in the local settings table.

abstract class _$AppThemeMode extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
