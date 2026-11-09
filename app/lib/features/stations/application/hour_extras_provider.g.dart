// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hour_extras_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 7 days of hourly fishing scores from today (Vietnam day) for one station.

@ProviderFor(stationFishing)
final stationFishingProvider = StationFishingFamily._();

/// 7 days of hourly fishing scores from today (Vietnam day) for one station.

final class StationFishingProvider
    extends
        $FunctionalProvider<AsyncValue<StationFishing>, StationFishing, FutureOr<StationFishing>>
    with $FutureModifier<StationFishing>, $FutureProvider<StationFishing> {
  /// 7 days of hourly fishing scores from today (Vietnam day) for one station.
  StationFishingProvider._({
    required StationFishingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stationFishingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationFishingHash();

  @override
  String toString() {
    return r'stationFishingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StationFishing> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StationFishing> create(Ref ref) {
    final argument = this.argument as String;
    return stationFishing(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationFishingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationFishingHash() => r'b64fba344566c4533852713a6e82d63b0cd2da7a';

/// 7 days of hourly fishing scores from today (Vietnam day) for one station.

final class StationFishingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StationFishing>, String> {
  StationFishingFamily._()
    : super(
        retry: null,
        name: r'stationFishingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 7 days of hourly fishing scores from today (Vietnam day) for one station.

  StationFishingProvider call(String id) => StationFishingProvider._(argument: id, from: this);

  @override
  String toString() => r'stationFishingProvider';
}

/// Weather + fishing score for one hour, for the F-TIDE-09 detail panel.

@ProviderFor(hourExtras)
final hourExtrasProvider = HourExtrasFamily._();

/// Weather + fishing score for one hour, for the F-TIDE-09 detail panel.

final class HourExtrasProvider
    extends $FunctionalProvider<AsyncValue<HourExtras>, HourExtras, FutureOr<HourExtras>>
    with $FutureModifier<HourExtras>, $FutureProvider<HourExtras> {
  /// Weather + fishing score for one hour, for the F-TIDE-09 detail panel.
  HourExtrasProvider._({
    required HourExtrasFamily super.from,
    required (String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'hourExtrasProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hourExtrasHash();

  @override
  String toString() {
    return r'hourExtrasProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HourExtras> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HourExtras> create(Ref ref) {
    final argument = this.argument as (String, DateTime);
    return hourExtras(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is HourExtrasProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hourExtrasHash() => r'66b9b2c978fba970b30c51e39b624c4fc2b4e9cd';

/// Weather + fishing score for one hour, for the F-TIDE-09 detail panel.

final class HourExtrasFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HourExtras>, (String, DateTime)> {
  HourExtrasFamily._()
    : super(
        retry: null,
        name: r'hourExtrasProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Weather + fishing score for one hour, for the F-TIDE-09 detail panel.

  HourExtrasProvider call(String id, DateTime hourUtc) =>
      HourExtrasProvider._(argument: (id, hourUtc), from: this);

  @override
  String toString() => r'hourExtrasProvider';
}
