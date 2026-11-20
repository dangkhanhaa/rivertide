// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether this device accepted the current terms ([termsVersion]) (P2-57).
/// Stored locally only: the version and the UTC time of acceptance.

@ProviderFor(TermsAcceptance)
final termsAcceptanceProvider = TermsAcceptanceProvider._();

/// Whether this device accepted the current terms ([termsVersion]) (P2-57).
/// Stored locally only: the version and the UTC time of acceptance.
final class TermsAcceptanceProvider extends $AsyncNotifierProvider<TermsAcceptance, bool> {
  /// Whether this device accepted the current terms ([termsVersion]) (P2-57).
  /// Stored locally only: the version and the UTC time of acceptance.
  TermsAcceptanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'termsAcceptanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$termsAcceptanceHash();

  @$internal
  @override
  TermsAcceptance create() => TermsAcceptance();
}

String _$termsAcceptanceHash() => r'90c20749f9047020139dccae94e086955332b105';

/// Whether this device accepted the current terms ([termsVersion]) (P2-57).
/// Stored locally only: the version and the UTC time of acceptance.

abstract class _$TermsAcceptance extends $AsyncNotifier<bool> {
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
