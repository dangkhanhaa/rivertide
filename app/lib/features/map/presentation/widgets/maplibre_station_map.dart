import 'dart:async';
import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/core/calc/geo/camera_offset.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/marker_icons.dart';
import 'package:rivertide/features/map/presentation/widgets/river_flow_layer.dart';
import 'package:rivertide/features/map/presentation/widgets/station_layers.dart';
import 'package:rivertide/features/map/presentation/widgets/weather_map_layer.dart';

/// Whole Vietnam incl. Hoàng Sa and Trường Sa on a phone screen.
const _vnCenter = LatLng(15.8, 108.2);
const double _vnZoom = 4.3;

/// MapLibre map over OpenFreeMap tiles with clustered station markers.
class MapLibreStationMap extends StatefulWidget {
  const MapLibreStationMap({required this.config, super.key});

  final BaseMapConfig config;

  @override
  State<MapLibreStationMap> createState() => _MapLibreStationMapState();
}

class _MapLibreStationMapState extends State<MapLibreStationMap> implements BaseMapHandle {
  MapLibreMapController? _controller;
  bool _styleReady = false;

  /// Markers currently in the source; feature ids index into this list.
  List<MapMarker> _shown = const [];

  @override
  void didUpdateWidget(MapLibreStationMap old) {
    super.didUpdateWidget(old);
    if (old.config.styleString != widget.config.styleString) {
      _styleReady = false;
      _water = waterLayerIds(widget.config.styleString);
    }
    if (!_styleReady) return;
    if (!identical(old.config.markers, widget.config.markers)) unawaited(_syncMarkers());
    if (!identical(old.config.weather, widget.config.weather)) unawaited(_syncWeather());
    if (!identical(old.config.riverReaches, widget.config.riverReaches) ||
        !identical(old.config.riverFlow, widget.config.riverFlow)) {
      unawaited(_syncRivers());
    }
    if (old.config.userPosition != widget.config.userPosition ||
        old.config.pin != widget.config.pin) {
      unawaited(_syncMe());
    }
  }

  /// Water layers of the current style (river lines are thin: look ±4 px).
  late List<String> _water = waterLayerIds(widget.config.styleString);

  bool _blocked(Point<double> p) {
    final box = context.findRenderObject();
    final check = widget.config.blocksTapAt;
    if (check == null || box is! RenderBox || !box.hasSize) return false;
    return check(box.localToGlobal(Offset(p.x, p.y)));
  }

  Future<void> _tapped(Point<double> p, LatLng at) async {
    if (_blocked(p)) return;
    var surface = PointSurface.unknown;
    final c = _controller;
    if (c != null && _water.isNotEmpty) {
      try {
        final hits = await c.queryRenderedFeaturesInRect(
          Rect.fromCenter(center: Offset(p.x, p.y), width: 8, height: 8),
          _water,
          null,
        );
        surface = hits.isEmpty ? PointSurface.land : PointSurface.water;
      } on Exception catch (e) {
        log.warn('water query failed', {'type': e.runtimeType.toString()});
      }
    }
    widget.config.onMapTap(at.latitude, at.longitude, surface);
  }

  @override
  Future<void> flyTo(double lat, double lon, {double? zoom, Offset offset = Offset.zero}) async {
    final c = _controller;
    if (c == null) return;
    final z = zoom ?? c.cameraPosition?.zoom ?? _vnZoom;
    final center = cameraCenterFor(lat: lat, lon: lon, zoom: z, dxPx: offset.dx, dyPx: offset.dy);
    await c.animateCamera(CameraUpdate.newLatLngZoom(LatLng(center.lat, center.lon), z));
  }

  void _onCreated(MapLibreMapController c) {
    _controller = c;
    c.onFeatureTapped.add(_onFeatureTap);
    widget.config.onReady(this);
  }

  Future<void> _onStyleLoaded() async {
    final c = _controller;
    if (c == null || !mounted) return;
    try {
      await _addImages(c);
      await addStationOverlay(c, widget.config.palette, widget.config.fixedLabels);
      _styleReady = true;
      await _syncMarkers();
      await _syncRivers();
      await _syncWeather();
      await _syncMe();
    } on Exception catch (e) {
      // A failed overlay must not take the base map down; the list tab still works.
      log.error('map overlay setup failed', error: e);
    }
  }

  Future<void> _addImages(MapLibreMapController c) async {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final color = widget.config.palette.stroke;
    for (final t in MarkerTrend.values) {
      await c.addImage('arrow-${t.name}', await arrowPng(t, color, ratio), false, ratio);
    }
    final p = widget.config.palette;
    for (var i = 0; i < windArrowDirections; i++) {
      final png = await windArrowPng(i * 360 / windArrowDirections, p.label, p.labelHalo, ratio);
      await c.addImage(windArrowName(i), png, false, ratio);
    }
  }

  Future<void> _syncMarkers() async {
    final c = _controller;
    if (c == null || !_styleReady) return;
    _shown = widget.config.markers;
    await c.setGeoJsonSource(stationSourceId, markersToGeoJson(_shown));
  }

  Future<void> _syncRivers() async {
    final c = _controller;
    if (c == null || !_styleReady) return;
    await c.setGeoJsonSource(riverReachSourceId, widget.config.riverReaches);
    await c.setGeoJsonSource(riverFlowSourceId, widget.config.riverFlow);
    _startFlowAnimation();
  }

  Timer? _flowTimer;
  int _flowFrame = 0;
  bool _flowBusy = false;
  bool _flowErrorLogged = false;

  @override
  void dispose() {
    _flowTimer?.cancel();
    super.dispose();
  }

  /// Steps the dash frames while the map is shown; off with reduced motion.
  void _startFlowAnimation() {
    if (_flowTimer != null || MediaQuery.disableAnimationsOf(context)) return;
    _flowTimer = Timer.periodic(const Duration(milliseconds: 120), (_) async {
      final c = _controller;
      // Skip while hidden (other tab) or while the last update is in flight.
      if (c == null || !_styleReady || _flowBusy || !TickerMode.valuesOf(context).enabled) return;
      _flowBusy = true;
      _flowFrame = (_flowFrame + 1) % flowDashFrames.length;
      try {
        await c.setLayerProperties(
          riverFlowLayerId,
          riverFlowProps(widget.config.palette, flowDashFrames[_flowFrame]),
        );
      } on Exception catch (e) {
        // Expected while a new base style loads (layer re-added afterwards):
        // skip the frame, log only the first failure.
        if (!_flowErrorLogged) log.info('flow frame skipped', {'error': '$e'});
        _flowErrorLogged = true;
      } finally {
        _flowBusy = false;
      }
    });
  }

  Future<void> _syncWeather() async {
    final c = _controller;
    if (c == null || !_styleReady) return;
    await c.setGeoJsonSource(weatherSourceId, widget.config.weather);
  }

  Future<void> _syncMe() async {
    final c = _controller;
    if (c == null || !_styleReady) return;
    await c.setGeoJsonSource(meSourceId, meGeoJson(widget.config.userPosition));
    await c.setGeoJsonSource(pinSourceId, meGeoJson(widget.config.pin));
  }

  void _onFeatureTap(Point<double> point, LatLng latLng, String id, String layerId, Annotation? _) {
    if (_blocked(point)) return;
    final n = int.tryParse(id);
    if (n == null) return;
    if (layerId == stationDotsLayerId && n >= 0 && n < _shown.length) {
      widget.config.onStationTap(_shown[n].id);
    } else if (layerId == clusterLayerId) {
      unawaited(_zoomIntoCluster(n, latLng));
    }
  }

  Future<void> _zoomIntoCluster(int clusterId, LatLng at) async {
    final c = _controller;
    if (c == null) return;
    final zoom = await c.getClusterExpansionZoom(stationSourceId, clusterId);
    await c.animateCamera(CameraUpdate.newLatLngZoom(at, zoom.toDouble()));
  }

  @override
  Widget build(BuildContext context) => MapLibreMap(
    styleString: widget.config.styleString,
    initialCameraPosition: const CameraPosition(target: _vnCenter, zoom: _vnZoom),
    minMaxZoomPreference: const MinMaxZoomPreference(3, 17),
    rotateGesturesEnabled: false,
    // All gesture flags are sent together; web applies them only as a group.
    scrollGesturesEnabled: widget.config.gesturesEnabled,
    zoomGesturesEnabled: widget.config.gesturesEnabled,
    doubleClickZoomEnabled: widget.config.gesturesEnabled,
    // Needed for cameraPosition (current zoom) when re-centring on a tap.
    trackCameraPosition: true,
    // The screen draws its own one-line credit (licences need it visible) so the
    // long built-in attribution bar does not cover the map.
    attributionEnabled: false,
    tiltGesturesEnabled: false,
    onMapCreated: _onCreated,
    onStyleLoadedCallback: () => unawaited(_onStyleLoaded()),
    onMapClick: (p, at) => unawaited(_tapped(p, at)),
    onMapLongClick: (p, at) => unawaited(_tapped(p, at)),
    onCameraIdle: () {
      final cam = _controller?.cameraPosition;
      if (cam != null) {
        widget.config.onCameraIdle?.call(cam.target.latitude, cam.target.longitude, cam.zoom);
      }
    },
  );
}
