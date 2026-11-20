// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recomputed when the weather is refreshed or the clock enters a new hour —
/// not every minute, so the hourly strip does not rebuild needlessly.

@ProviderFor(stationForecast)
final stationForecastProvider = StationForecastFamily._();

/// Recomputed when the weather is refreshed or the clock enters a new hour —
/// not every minute, so the hourly strip does not rebuild needlessly.

final class StationForecastProvider
    extends
        $FunctionalProvider<AsyncValue<StationForecast>, StationForecast, FutureOr<StationForecast>>
    with $FutureModifier<StationForecast>, $FutureProvider<StationForecast> {
  /// Recomputed when the weather is refreshed or the clock enters a new hour —
  /// not every minute, so the hourly strip does not rebuild needlessly.
  StationForecastProvider._({
    required StationForecastFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stationForecastProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationForecastHash();

  @override
  String toString() {
    return r'stationForecastProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StationForecast> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StationForecast> create(Ref ref) {
    final argument = this.argument as String;
    return stationForecast(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationForecastProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationForecastHash() => r'd8c60be8569cce141065c22decb2380e914c8602';

/// Recomputed when the weather is refreshed or the clock enters a new hour —
/// not every minute, so the hourly strip does not rebuild needlessly.

final class StationForecastFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StationForecast>, String> {
  StationForecastFamily._()
    : super(
        retry: null,
        name: r'stationForecastProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Recomputed when the weather is refreshed or the clock enters a new hour —
  /// not every minute, so the hourly strip does not rebuild needlessly.

  StationForecastProvider call(String id) => StationForecastProvider._(argument: id, from: this);

  @override
  String toString() => r'stationForecastProvider';
}
