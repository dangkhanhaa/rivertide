// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_focus.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Show this station on the map": set by lists, consumed once by the map screen.
/// Lives in core so the stations feature need not import the map feature.

@ProviderFor(MapFocus)
final mapFocusProvider = MapFocusProvider._();

/// "Show this station on the map": set by lists, consumed once by the map screen.
/// Lives in core so the stations feature need not import the map feature.
final class MapFocusProvider extends $NotifierProvider<MapFocus, String?> {
  /// "Show this station on the map": set by lists, consumed once by the map screen.
  /// Lives in core so the stations feature need not import the map feature.
  MapFocusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapFocusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapFocusHash();

  @$internal
  @override
  MapFocus create() => MapFocus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String?>(value));
  }
}

String _$mapFocusHash() => r'6fa8c72d804e5b74dcb226c7eb00f044070751ac';

/// "Show this station on the map": set by lists, consumed once by the map screen.
/// Lives in core so the stations feature need not import the map feature.

abstract class _$MapFocus extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<String?, String?>, String?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
