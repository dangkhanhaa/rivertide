// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// True when the published web build (build.json next to the app, written by
/// CI) differs from the running one. False on mobile, in local builds and on
/// any error — the "new version" notice is shown only when it is certain.

@ProviderFor(updateAvailable)
final updateAvailableProvider = UpdateAvailableProvider._();

/// True when the published web build (build.json next to the app, written by
/// CI) differs from the running one. False on mobile, in local builds and on
/// any error — the "new version" notice is shown only when it is certain.

final class UpdateAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// True when the published web build (build.json next to the app, written by
  /// CI) differs from the running one. False on mobile, in local builds and on
  /// any error — the "new version" notice is shown only when it is certain.
  UpdateAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return updateAvailable(ref);
  }
}

String _$updateAvailableHash() => r'b7ff81cbe23410c4fdec209fc170b290da8ce044';
