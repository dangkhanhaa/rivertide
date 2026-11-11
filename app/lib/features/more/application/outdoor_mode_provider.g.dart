// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outdoor_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Chế độ ngoài trời": high contrast + larger text, persisted locally.

@ProviderFor(OutdoorMode)
final outdoorModeProvider = OutdoorModeProvider._();

/// "Chế độ ngoài trời": high contrast + larger text, persisted locally.
final class OutdoorModeProvider extends $AsyncNotifierProvider<OutdoorMode, bool> {
  /// "Chế độ ngoài trời": high contrast + larger text, persisted locally.
  OutdoorModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outdoorModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outdoorModeHash();

  @$internal
  @override
  OutdoorMode create() => OutdoorMode();
}

String _$outdoorModeHash() => r'0cbd57b970a998449234557c90a9661de704902e';

/// "Chế độ ngoài trời": high contrast + larger text, persisted locally.

abstract class _$OutdoorMode extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
