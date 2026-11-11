// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stationRepository)
final stationRepositoryProvider = StationRepositoryProvider._();

final class StationRepositoryProvider
    extends $FunctionalProvider<StationRepository, StationRepository, StationRepository>
    with $Provider<StationRepository> {
  StationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationRepositoryHash();

  @$internal
  @override
  $ProviderElement<StationRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StationRepository create(Ref ref) {
    return stationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StationRepository>(value),
    );
  }
}

String _$stationRepositoryHash() => r'feadf4f8b51bbc1b03dc2b56386848d0f7dbb03a';

@ProviderFor(stationList)
final stationListProvider = StationListProvider._();

final class StationListProvider
    extends $FunctionalProvider<AsyncValue<List<Station>>, List<Station>, FutureOr<List<Station>>>
    with $FutureModifier<List<Station>>, $FutureProvider<List<Station>> {
  StationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationListHash();

  @$internal
  @override
  $FutureProviderElement<List<Station>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Station>> create(Ref ref) {
    return stationList(ref);
  }
}

String _$stationListHash() => r'edcfa0d214f0d8407b30fd48566fd3a77c72271f';

@ProviderFor(riverLines)
final riverLinesProvider = RiverLinesProvider._();

final class RiverLinesProvider
    extends
        $FunctionalProvider<AsyncValue<List<RiverLine>>, List<RiverLine>, FutureOr<List<RiverLine>>>
    with $FutureModifier<List<RiverLine>>, $FutureProvider<List<RiverLine>> {
  RiverLinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'riverLinesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$riverLinesHash();

  @$internal
  @override
  $FutureProviderElement<List<RiverLine>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<RiverLine>> create(Ref ref) {
    return riverLines(ref);
  }
}

String _$riverLinesHash() => r'f59dafb51b86354c14baad256f3db910335624af';

@ProviderFor(stationById)
final stationByIdProvider = StationByIdFamily._();

final class StationByIdProvider
    extends $FunctionalProvider<AsyncValue<Station>, Station, FutureOr<Station>>
    with $FutureModifier<Station>, $FutureProvider<Station> {
  StationByIdProvider._({required StationByIdFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'stationByIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationByIdHash();

  @override
  String toString() {
    return r'stationByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Station> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Station> create(Ref ref) {
    final argument = this.argument as String;
    return stationById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationByIdHash() => r'9b4821d65ba09f243abf366b7367e2a0b9975ca4';

final class StationByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Station>, String> {
  StationByIdFamily._()
    : super(
        retry: null,
        name: r'stationByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationByIdProvider call(String id) => StationByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'stationByIdProvider';
}

@ProviderFor(stationTide)
final stationTideProvider = StationTideFamily._();

final class StationTideProvider
    extends
        $FunctionalProvider<
          AsyncValue<Cached<StationTide>>,
          Cached<StationTide>,
          FutureOr<Cached<StationTide>>
        >
    with $FutureModifier<Cached<StationTide>>, $FutureProvider<Cached<StationTide>> {
  StationTideProvider._({required StationTideFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'stationTideProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationTideHash();

  @override
  String toString() {
    return r'stationTideProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Cached<StationTide>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Cached<StationTide>> create(Ref ref) {
    final argument = this.argument as String;
    return stationTide(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationTideProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationTideHash() => r'3cc4a291cf555638127739ceaa1627a666f096f6';

final class StationTideFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Cached<StationTide>>, String> {
  StationTideFamily._()
    : super(
        retry: null,
        name: r'stationTideProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationTideProvider call(String id) => StationTideProvider._(argument: id, from: this);

  @override
  String toString() => r'stationTideProvider';
}

@ProviderFor(stationWeather)
final stationWeatherProvider = StationWeatherFamily._();

final class StationWeatherProvider
    extends
        $FunctionalProvider<
          AsyncValue<Cached<List<WeatherHour>>>,
          Cached<List<WeatherHour>>,
          FutureOr<Cached<List<WeatherHour>>>
        >
    with $FutureModifier<Cached<List<WeatherHour>>>, $FutureProvider<Cached<List<WeatherHour>>> {
  StationWeatherProvider._({
    required StationWeatherFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stationWeatherProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationWeatherHash();

  @override
  String toString() {
    return r'stationWeatherProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Cached<List<WeatherHour>>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Cached<List<WeatherHour>>> create(Ref ref) {
    final argument = this.argument as String;
    return stationWeather(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationWeatherProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationWeatherHash() => r'1b85bd02c3402af6af40488b7f0709e1a0c355b4';

final class StationWeatherFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Cached<List<WeatherHour>>>, String> {
  StationWeatherFamily._()
    : super(
        retry: null,
        name: r'stationWeatherProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationWeatherProvider call(String id) => StationWeatherProvider._(argument: id, from: this);

  @override
  String toString() => r'stationWeatherProvider';
}

@ProviderFor(stationFlow)
final stationFlowProvider = StationFlowFamily._();

final class StationFlowProvider
    extends
        $FunctionalProvider<
          AsyncValue<Cached<RiverFlow?>>,
          Cached<RiverFlow?>,
          FutureOr<Cached<RiverFlow?>>
        >
    with $FutureModifier<Cached<RiverFlow?>>, $FutureProvider<Cached<RiverFlow?>> {
  StationFlowProvider._({required StationFlowFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'stationFlowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationFlowHash();

  @override
  String toString() {
    return r'stationFlowProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Cached<RiverFlow?>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Cached<RiverFlow?>> create(Ref ref) {
    final argument = this.argument as String;
    return stationFlow(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationFlowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationFlowHash() => r'c3552274bb4adf9b833ddf3e7d89cdd54bff90a7';

final class StationFlowFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Cached<RiverFlow?>>, String> {
  StationFlowFamily._()
    : super(
        retry: null,
        name: r'stationFlowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationFlowProvider call(String id) => StationFlowProvider._(argument: id, from: this);

  @override
  String toString() => r'stationFlowProvider';
}

@ProviderFor(favoriteIds)
final favoriteIdsProvider = FavoriteIdsProvider._();

final class FavoriteIdsProvider
    extends $FunctionalProvider<AsyncValue<List<String>>, List<String>, Stream<List<String>>>
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  FavoriteIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteIdsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return favoriteIds(ref);
  }
}

String _$favoriteIdsHash() => r'080280b68bb83c201ca5f0c62a7c9b2b73a5ee77';

/// Saved places with the user's name, note and group.

@ProviderFor(favorites)
final favoritesProvider = FavoritesProvider._();

/// Saved places with the user's name, note and group.

final class FavoritesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedPlace>>,
          List<SavedPlace>,
          Stream<List<SavedPlace>>
        >
    with $FutureModifier<List<SavedPlace>>, $StreamProvider<List<SavedPlace>> {
  /// Saved places with the user's name, note and group.
  FavoritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesHash();

  @$internal
  @override
  $StreamProviderElement<List<SavedPlace>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<SavedPlace>> create(Ref ref) {
    return favorites(ref);
  }
}

String _$favoritesHash() => r'c13c821c6f58faad7519fe2af654b87b51394bb8';
