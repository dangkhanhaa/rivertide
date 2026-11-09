// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The only place allowed to read the wall clock (docs/rules/02 §6).

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// The only place allowed to read the wall clock (docs/rules/02 §6).

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock> with $Provider<Clock> {
  /// The only place allowed to read the wall clock (docs/rules/02 §6).
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Clock>(value));
  }
}

String _$clockHash() => r'6d3442c2a0d9d789958160b396d6ca169d2baffe';

/// Emits the current UTC time now and then at the start of every minute.

@ProviderFor(minuteTicker)
final minuteTickerProvider = MinuteTickerProvider._();

/// Emits the current UTC time now and then at the start of every minute.

final class MinuteTickerProvider
    extends $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// Emits the current UTC time now and then at the start of every minute.
  MinuteTickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'minuteTickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$minuteTickerHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return minuteTicker(ref);
  }
}

String _$minuteTickerHash() => r'b64a20533d4644506ac70a2b0556d24cf03b7443';
