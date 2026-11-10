// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fishing_spot.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lives in core so the map/station sheets can set it ("Câu cá tại đây")
/// without importing the fishing feature.

@ProviderFor(FishingSpot)
final fishingSpotProvider = FishingSpotProvider._();

/// Lives in core so the map/station sheets can set it ("Câu cá tại đây")
/// without importing the fishing feature.
final class FishingSpotProvider extends $NotifierProvider<FishingSpot, FishingSpotChoice> {
  /// Lives in core so the map/station sheets can set it ("Câu cá tại đây")
  /// without importing the fishing feature.
  FishingSpotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fishingSpotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fishingSpotHash();

  @$internal
  @override
  FishingSpot create() => FishingSpot();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FishingSpotChoice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FishingSpotChoice>(value),
    );
  }
}

String _$fishingSpotHash() => r'7b1490676471101496d66a3999cdd71a29d60c17';

/// Lives in core so the map/station sheets can set it ("Câu cá tại đây")
/// without importing the fishing feature.

abstract class _$FishingSpot extends $Notifier<FishingSpotChoice> {
  FishingSpotChoice build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FishingSpotChoice, FishingSpotChoice>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FishingSpotChoice, FishingSpotChoice>,
              FishingSpotChoice,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
