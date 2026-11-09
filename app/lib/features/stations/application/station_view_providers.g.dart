// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_view_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Station tide data re-evaluated every minute so countdowns and the "now" line move.

@ProviderFor(stationView)
final stationViewProvider = StationViewFamily._();

/// Station tide data re-evaluated every minute so countdowns and the "now" line move.

final class StationViewProvider
    extends $FunctionalProvider<AsyncValue<StationView>, StationView, FutureOr<StationView>>
    with $FutureModifier<StationView>, $FutureProvider<StationView> {
  /// Station tide data re-evaluated every minute so countdowns and the "now" line move.
  StationViewProvider._({required StationViewFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'stationViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationViewHash();

  @override
  String toString() {
    return r'stationViewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StationView> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StationView> create(Ref ref) {
    final argument = this.argument as String;
    return stationView(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationViewHash() => r'406f88ee27b2211ecd712d4f945ce3485e6c5f30';

/// Station tide data re-evaluated every minute so countdowns and the "now" line move.

final class StationViewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StationView>, String> {
  StationViewFamily._()
    : super(
        retry: null,
        name: r'stationViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Station tide data re-evaluated every minute so countdowns and the "now" line move.

  StationViewProvider call(String id) => StationViewProvider._(argument: id, from: this);

  @override
  String toString() => r'stationViewProvider';
}
