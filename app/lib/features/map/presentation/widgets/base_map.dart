import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';
import 'package:rivertide/features/map/presentation/widgets/maplibre_station_map.dart';

/// Camera commands the screen can send to whichever map is mounted.
abstract interface class BaseMapHandle {
  Future<void> flyTo(double lat, double lon, {double zoom});
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
    this.userPosition,
    this.pin,
  });

  final String styleString;
  final List<MapMarker> markers;
  final MarkerPalette palette;
  final List<MapLabel> fixedLabels;
  final ValueChanged<String> onStationTap;
  final ValueChanged<BaseMapHandle> onReady;
  final ({double lat, double lon})? userPosition;

  /// Tap or long-press on the map outside a marker (F-MAP-03).
  /// `surface` says whether the base map draws water at that spot.
  final void Function(double lat, double lon, PointSurface surface) onMapTap;

  /// Temporary pin for the last tapped point; one at a time.
  final ({double lat, double lon})? pin;
}

/// Overridden in widget tests: platform map views cannot render there.
final baseMapBuilderProvider = Provider<Widget Function(BaseMapConfig config)>(
  (ref) =>
      (config) => MapLibreStationMap(config: config),
);
