// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fishing_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Station currently chosen on the fishing tab (defaults to the Vũng Tàu gauge).

@ProviderFor(FishingStation)
final fishingStationProvider = FishingStationProvider._();

/// Station currently chosen on the fishing tab (defaults to the Vũng Tàu gauge).
final class FishingStationProvider extends $NotifierProvider<FishingStation, String> {
  /// Station currently chosen on the fishing tab (defaults to the Vũng Tàu gauge).
  FishingStationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fishingStationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fishingStationHash();

  @$internal
  @override
  FishingStation create() => FishingStation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String>(value));
  }
}

String _$fishingStationHash() => r'd23d24b9e20b0e54ff6e64d2c2055f2e66519ac4';

/// Station currently chosen on the fishing tab (defaults to the Vũng Tàu gauge).

abstract class _$FishingStation extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<String, String>, String, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
