// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Base-map style (JSON text or URL) for the current brightness.

@ProviderFor(mapStyle)
final mapStyleProvider = MapStyleFamily._();

/// Base-map style (JSON text or URL) for the current brightness.

final class MapStyleProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Base-map style (JSON text or URL) for the current brightness.
  MapStyleProvider._({required MapStyleFamily super.from, required Brightness super.argument})
    : super(
        retry: null,
        name: r'mapStyleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapStyleHash();

  @override
  String toString() {
    return r'mapStyleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as Brightness;
    return mapStyle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MapStyleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mapStyleHash() => r'54fbf59dc2c58467d105df25dc09a1c6d0ab005c';

/// Base-map style (JSON text or URL) for the current brightness.

final class MapStyleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, Brightness> {
  MapStyleFamily._()
    : super(
        retry: null,
        name: r'mapStyleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Base-map style (JSON text or URL) for the current brightness.

  MapStyleProvider call(Brightness brightness) =>
      MapStyleProvider._(argument: brightness, from: this);

  @override
  String toString() => r'mapStyleProvider';
}

@ProviderFor(locationService)
final locationServiceProvider = LocationServiceProvider._();

final class LocationServiceProvider
    extends $FunctionalProvider<LocationService, LocationService, LocationService>
    with $Provider<LocationService> {
  LocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  $ProviderElement<LocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationService create(Ref ref) {
    return locationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationService>(value),
    );
  }
}

String _$locationServiceHash() => r'33637312fa510b0662eebf6c32e8e62519b7c7c3';

@ProviderFor(locationPromptStore)
final locationPromptStoreProvider = LocationPromptStoreProvider._();

final class LocationPromptStoreProvider
    extends $FunctionalProvider<LocationPromptStore, LocationPromptStore, LocationPromptStore>
    with $Provider<LocationPromptStore> {
  LocationPromptStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPromptStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPromptStoreHash();

  @$internal
  @override
  $ProviderElement<LocationPromptStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationPromptStore create(Ref ref) {
    return locationPromptStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationPromptStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationPromptStore>(value),
    );
  }
}

String _$locationPromptStoreHash() => r'56d919a8f0b7fdc6ed35dca2887b87e8ef0a54fc';

@ProviderFor(MapFilterState)
final mapFilterStateProvider = MapFilterStateProvider._();

final class MapFilterStateProvider extends $NotifierProvider<MapFilterState, MapFilter> {
  MapFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapFilterStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapFilterStateHash();

  @$internal
  @override
  MapFilterState create() => MapFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapFilter value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<MapFilter>(value));
  }
}

String _$mapFilterStateHash() => r'd732114cb981fabc08cec166f656ed898a1705e3';

abstract class _$MapFilterState extends $Notifier<MapFilter> {
  MapFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MapFilter, MapFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapFilter, MapFilter>,
              MapFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One marker per station; markers appear as soon as the station list is
/// known and gain colour/trend as each station's data arrives.

@ProviderFor(mapMarkers)
final mapMarkersProvider = MapMarkersProvider._();

/// One marker per station; markers appear as soon as the station list is
/// known and gain colour/trend as each station's data arrives.

final class MapMarkersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MapMarker>>,
          AsyncValue<List<MapMarker>>,
          AsyncValue<List<MapMarker>>
        >
    with $Provider<AsyncValue<List<MapMarker>>> {
  /// One marker per station; markers appear as soon as the station list is
  /// known and gain colour/trend as each station's data arrives.
  MapMarkersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapMarkersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapMarkersHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<MapMarker>>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<List<MapMarker>> create(Ref ref) {
    return mapMarkers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<MapMarker>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<MapMarker>>>(value),
    );
  }
}

String _$mapMarkersHash() => r'9777b28bbf92bdd5e82f1010bfa7d88c23f58635';
