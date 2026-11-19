// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Welcome flow progress (P2-53): null = finished (or never needed), else the
/// step to resume at. The step is saved as the user moves, so an app killed
/// or a web page reloaded mid-way comes back where it left off.

@ProviderFor(OnboardingProgress)
final onboardingProgressProvider = OnboardingProgressProvider._();

/// Welcome flow progress (P2-53): null = finished (or never needed), else the
/// step to resume at. The step is saved as the user moves, so an app killed
/// or a web page reloaded mid-way comes back where it left off.
final class OnboardingProgressProvider extends $AsyncNotifierProvider<OnboardingProgress, int?> {
  /// Welcome flow progress (P2-53): null = finished (or never needed), else the
  /// step to resume at. The step is saved as the user moves, so an app killed
  /// or a web page reloaded mid-way comes back where it left off.
  OnboardingProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProgressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingProgressHash();

  @$internal
  @override
  OnboardingProgress create() => OnboardingProgress();
}

String _$onboardingProgressHash() => r'97f54228bbfa98a9004682cb65b5a60b054316a2';

/// Welcome flow progress (P2-53): null = finished (or never needed), else the
/// step to resume at. The step is saved as the user moves, so an app killed
/// or a web page reloaded mid-way comes back where it left off.

abstract class _$OnboardingProgress extends $AsyncNotifier<int?> {
  FutureOr<int?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int?>, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int?>, int?>,
              AsyncValue<int?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// "Bạn là ai?" and favourite waters (P2-53), kept on the device only.

@ProviderFor(UserProfileSettings)
final userProfileSettingsProvider = UserProfileSettingsProvider._();

/// "Bạn là ai?" and favourite waters (P2-53), kept on the device only.
final class UserProfileSettingsProvider
    extends $AsyncNotifierProvider<UserProfileSettings, UserProfile> {
  /// "Bạn là ai?" and favourite waters (P2-53), kept on the device only.
  UserProfileSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileSettingsHash();

  @$internal
  @override
  UserProfileSettings create() => UserProfileSettings();
}

String _$userProfileSettingsHash() => r'028dacd3f4a9db589f831f44a8b947bf06342da3';

/// "Bạn là ai?" and favourite waters (P2-53), kept on the device only.

abstract class _$UserProfileSettings extends $AsyncNotifier<UserProfile> {
  FutureOr<UserProfile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserProfile>, UserProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile>, UserProfile>,
              AsyncValue<UserProfile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
