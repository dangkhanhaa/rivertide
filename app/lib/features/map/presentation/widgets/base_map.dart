import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';
import 'package:rivertide/features/map/presentation/widgets/maplibre_station_map.dart';

/// Camera commands the screen can send to whichever map is mounted.
abstract interface class BaseMapHandle {
  /// Moves the camera so ([lat], [lon]) ends up [offset] (logical px) left of /
  /// above the view centre; [zoom] null keeps the current zoom.
  Future<void> flyTo(double lat, double lon, {double? zoom, Offset offset});
}

/// A fixed text label drawn on the map (e.g. the Vietnamese archipelagos).
typedef MapLabel = ({double lat, double lon, String text});

/// Colours the map layers need, resolved from theme tokens by the screen.
typedef MarkerPalette = ({
  Map<MarkerStatus, Color> status,
  Color stroke,
  Color label,
  Color labelHalo,
  Color me,
  Color pin,
  Color river,
  Color flowRising,
  Color flowFalling,
  Color flowSlack,
  Color community,
});

class BaseMapConfig {
  const BaseMapConfig({
    required this.styleString,
    required this.markers,
    required this.palette,
    required this.fixedLabels,
    required this.onStationTap,
    required this.onReady,
    required this.onMapTap,
    this.riverReaches = const {'type': 'FeatureCollection', 'features': <Object>[]},
    this.riverFlow = const {'type': 'FeatureCollection', 'features': <Object>[]},
    this.weather = const {'type': 'FeatureCollection', 'features': <Object>[]},
    this.onCameraIdle,
    this.community = const {'type': 'FeatureCollection', 'features': <Object>[]},
    this.onCommunityTap,
    this.blocksTapAt,
    this.gesturesEnabled = true,
    this.userPosition,
    this.pin,
  });

  final String styleString;
  final List<MapMarker> markers;
  final MarkerPalette palette;
  final List<MapLabel> fixedLabels;

  /// River segments with along-river estimates (`conf` 0-1), GeoJSON.
  final Map<String, Object?> riverReaches;

  /// River segments by water state now (`state`), drawn towards the sea.
  final Map<String, Object?> riverFlow;

  /// Rain/wind grid points (`rain`, `wind`, `toDeg`), GeoJSON.
  final Map<String, Object?> weather;

  /// Community fishing spots (feature `id` = index, `title`), GeoJSON.
  final Map<String, Object?> community;

  /// A community pin was tapped (its feature id).
  final ValueChanged<int>? onCommunityTap;

  /// Centre and zoom whenever the camera stops moving.
  final void Function(double lat, double lon, double zoom)? onCameraIdle;
  final ValueChanged<String> onStationTap;
  final ValueChanged<BaseMapHandle> onReady;
  final ({double lat, double lon})? userPosition;

  /// Tap or long-press on the map outside a marker (F-MAP-03).
  /// `surface` says whether the base map draws water at that spot.
  final void Function(double lat, double lon, PointSurface surface) onMapTap;

  /// True when a click at this global position belongs to Flutter UI drawn over
  /// the map. On web the platform map also receives clicks on buttons and
  /// panels above it, which must not count as map taps.
  final bool Function(Offset global)? blocksTapAt;

  /// False while a sheet covers the map: pan/zoom off so drags on the sheet do
  /// not move the platform map underneath (web).
  final bool gesturesEnabled;

  /// Temporary pin for the last tapped point; one at a time.
  final ({double lat, double lon})? pin;
}

/// Overridden in widget tests: platform map views cannot render there.
final baseMapBuilderProvider = Provider<Widget Function(BaseMapConfig config)>(
  (ref) =>
      (config) => MapLibreStationMap(config: config),
);
