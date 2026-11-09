import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/network/dio_client.dart';
import 'package:rivertide/features/map/data/location_source.dart';
import 'package:rivertide/features/map/data/map_style_source.dart';
import 'package:rivertide/features/map/data/satellite_style.dart';
import 'package:rivertide/features/map/domain/base_layer.dart';
import 'package:rivertide/features/map/domain/location_service.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';
import 'package:rivertide/features/stations/stations.dart';

part 'map_providers.g.dart';

/// Base-map style (JSON text or URL) for the current brightness and layer.
@Riverpod(keepAlive: true)
Future<String> mapStyle(Ref ref, Brightness brightness, BaseLayer layer) async {
  final dio = ref.watch(dioProvider);
  final source = MapStyleSource(
    fetch: (uri) => getText(dio, uri),
    db: ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
  );
  if (layer == BaseLayer.satellite) {
    final vector = await source.load(openFreeMapLight);
    try {
      return satelliteStyle(vector);
    } on ParseException {
      return vector; // URL fallback (offline, never fetched): plain map instead
    }
  }
  return await source.load(brightness == Brightness.dark ? openFreeMapDark : openFreeMapLight);
}

/// Normal map or satellite imagery, remembered across launches.
@Riverpod(keepAlive: true)
class BaseLayerChoice extends _$BaseLayerChoice {
  static const _key = 'map_base_layer';

  @override
  Future<BaseLayer> build() async {
    final stored = await ref.watch(appDatabaseProvider).readSetting(_key);
    return BaseLayer.values.firstWhere((l) => l.name == stored, orElse: () => BaseLayer.standard);
  }

  Future<void> choose(BaseLayer layer) async {
    state = AsyncData(layer);
    await ref.read(appDatabaseProvider).writeSetting(_key, layer.name);
  }
}

@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) => const GeolocatorLocationService();

/// Ask for location once on first open (S02: map opens where the user is);
/// afterwards only the ◎ button asks.
class LocationPromptStore {
  const LocationPromptStore(this._db);

  final AppDatabase _db;
  static const _key = 'location_prompt_shown';

  Future<bool> wasShown() async => (await _db.readSetting(_key)) == '1';

  Future<void> markShown() => _db.writeSetting(_key, '1');
}

@Riverpod(keepAlive: true)
LocationPromptStore locationPromptStore(Ref ref) =>
    LocationPromptStore(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
class MapFilterState extends _$MapFilterState {
  @override
  MapFilter build() => const MapFilter();

  MapFilter get filter => state;

  set filter(MapFilter value) => state = value;
}

/// One marker per station; markers appear as soon as the station list is
/// known and gain colour/trend as each station's data arrives.
@riverpod
AsyncValue<List<MapMarker>> mapMarkers(Ref ref) {
  final stations = ref.watch(stationListProvider);
  final filter = ref.watch(mapFilterStateProvider);
  return stations.whenData(
    (list) => [for (final s in list) _marker(ref, s)].where(filter.accepts).toList(),
  );
}

MapMarker _marker(Ref ref, Station s) {
  final async = ref.watch(stationViewProvider(s.id));
  final view = async.value;
  final status = switch (view) {
    final v? => markerStatus(
      isGauge: s.kind == StationKind.gauge || s.kind == StationKind.river,
      hasData: v.now.levelCm != null || v.tide.data.dailyExtremes != null,
      lastObservationUtc: v.now.lastObservationUtc,
      nowUtc: v.nowUtc,
      staleAfter: s.kind == StationKind.river ? riverMarkerStaleAfter : markerStaleAfter,
    ),
    // Failed with nothing cached → "lost data"; still loading → neutral.
    null when async.hasError => MarkerStatus.stale,
    null => MarkerStatus.normal,
  };
  return MapMarker(
    id: s.id,
    name: s.name,
    lat: s.lat,
    lon: s.lon,
    status: status,
    trend: markerTrend(view?.now.state),
    // Every V0 station has a tide curve (harmonic or model); unknown until loaded.
    hasTide: s.tidal || s.kind == StationKind.gauge || s.kind == StationKind.model,
  );
}
