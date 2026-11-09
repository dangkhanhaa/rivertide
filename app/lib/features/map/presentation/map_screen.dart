import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/geo/vietnam_bounds.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/map_focus.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/map/application/map_providers.dart';
import 'package:rivertide/features/map/domain/base_layer.dart';
import 'package:rivertide/features/map/domain/location_service.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';
import 'package:rivertide/features/map/domain/water_layers.dart';
import 'package:rivertide/features/map/presentation/locate_action.dart';
import 'package:rivertide/features/map/presentation/map_detail_presenter.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/map_controls.dart';
import 'package:rivertide/features/map/presentation/widgets/map_notes.dart';
import 'package:rivertide/features/map/presentation/widgets/map_search_bar.dart';
import 'package:rivertide/features/stations/stations.dart';

/// S02 — station map on free OpenFreeMap tiles (FEATURES.md F-MAP-01 → 04).
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with MapDetailPresenter<MapScreen> {
  BaseMapHandle? _map;
  ({double lat, double lon})? _me;
  ({double lat, double lon})? _pin;
  bool _started = false;
  bool _hintDismissed = false;
  String? _lastStyle;

  /// Flutter UI drawn over the map (see [BaseMapConfig.blocksTapAt]).
  final GlobalKey _topKey = GlobalKey();
  final GlobalKey _controlsKey = GlobalKey();

  bool _blocksTapAt(Offset global) {
    // A sheet or dialog is open above the map: the click was meant for it.
    if (!(ModalRoute.of(context)?.isCurrent ?? true) || sheetBusy) return true;
    for (final key in [_topKey, _controlsKey]) {
      final box = key.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize) {
        final rect = box.localToGlobal(Offset.zero) & box.size;
        if (rect.contains(global)) return true;
      }
    }
    return isOverSidePanel(global);
  }

  @override
  void onDetailClosed() {
    if (mounted) setState(() => _pin = null);
  }

  void _onReady(BaseMapHandle h) {
    _map = h;
    if (_started) return;
    _started = true;
    // After the first frame: dialogs need a laid-out navigator.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A list asked for a station before the map existed: that wins over "my position".
      if (ref.read(mapFocusProvider) case final id?) {
        unawaited(_focusStation(id));
      } else {
        unawaited(_autoLocate());
      }
    });
  }

  /// Opens on the user's position: silently when permission exists, otherwise
  /// one explained request on the very first open.
  Future<void> _autoLocate() async {
    final service = ref.read(locationServiceProvider);
    final prompts = ref.read(locationPromptStoreProvider);
    if (await service.hasPermission()) {
      if (await service.locate() case Located(:final lat, :final lon) when mounted) {
        setState(() => _me = (lat: lat, lon: lon));
        await _map?.flyTo(lat, lon, zoom: 11);
      }
      return;
    }
    if (await prompts.wasShown() || !mounted) return;
    await prompts.markShown();
    if (mounted) await _locate();
  }

  /// "Show on map" from the station or watch list: zoom in and open its details.
  Future<void> _focusStation(String id) async {
    ref.read(mapFocusProvider.notifier).stationId = null;
    // A saved map point (from the watch list): fly there and reopen it.
    if (PointId.decode(id) case final p?) {
      await _map?.flyTo(p.lat, p.lon, zoom: 12);
      if (mounted) await _openPoint(p.lat, p.lon, PointSurface.unknown);
      return;
    }
    final stations = await ref.read(stationListProvider.future);
    final s = stations.where((x) => x.id == id).firstOrNull;
    if (s == null || !mounted) return;
    await _map?.flyTo(s.lat, s.lon, zoom: 11);
    if (mounted) await _openStation(s.id);
  }

  Future<void> _openPoint(double lat, double lon, PointSurface surface) async {
    if (sheetBusy) return;
    if (!isInVietnamBounds(lat, lon)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.map_outsideVn)));
      return;
    }
    setState(() {
      _pin = (lat: lat, lon: lon);
      _hintDismissed = true;
    });
    await showDetail(
      PointSheet(
        key: ValueKey('$lat,$lon'),
        lat: lat,
        lon: lon,
        onWater: switch (surface) {
          PointSurface.water => true,
          PointSurface.land => false,
          PointSurface.unknown => null,
        },
      ),
    );
  }

  Future<void> _openStation(String id) async {
    if (sheetBusy) return;
    final station = ref.read(stationListProvider).value?.where((s) => s.id == id).firstOrNull;
    if (station == null) return;
    setState(() => _pin = null);
    await showDetail(StationSheet(key: ValueKey(id), station: station));
  }

  Future<void> _selectStation(Station s) async {
    await _map?.flyTo(s.lat, s.lon, zoom: 11);
    await _openStation(s.id);
  }

  Future<void> _locate() async {
    final p = await runLocateFlow(context, ref.read(locationServiceProvider));
    if (p == null || !mounted) return;
    setState(() => _me = p);
    await _map?.flyTo(p.lat, p.lon, zoom: 11);
  }

  MarkerPalette _palette(AppColors c) => (
    status: {
      MarkerStatus.stale: c.stale,
      MarkerStatus.normal: c.ok,
      MarkerStatus.alarm1: c.alarm1,
      MarkerStatus.alarm2: c.alarm2,
      MarkerStatus.alarm3: c.alarm3,
    },
    stroke: c.surface,
    label: c.onSurface,
    labelHalo: c.surface,
    me: c.water,
    pin: c.alarm2,
  );

  Widget _buildMap(BuildContext context, List<MapMarker> shown) {
    final l10n = context.l10n;
    final layer = ref.watch(baseLayerChoiceProvider).value ?? BaseLayer.standard;
    final style = ref.watch(mapStyleProvider(Theme.of(context).brightness, layer));
    // Keep showing the previous style while a new one loads: replacing the map
    // with a spinner would recreate it and lose the camera position.
    if (style.value case final s?) _lastStyle = s;
    final shownStyle = style.value ?? _lastStyle;
    final buildMap = ref.watch(baseMapBuilderProvider);
    return switch (style) {
      _ when shownStyle != null => buildMap(
        BaseMapConfig(
          styleString: shownStyle,
          markers: shown,
          palette: _palette(context.colors),
          fixedLabels: [
            (lat: 17.5, lon: 112, text: l10n.map_hoangSa),
            (lat: 10, lon: 112.8, text: l10n.map_truongSa),
          ],
          onStationTap: _openStation,
          onReady: _onReady,
          onMapTap: _openPoint,
          blocksTapAt: _blocksTapAt,
          userPosition: _me,
          pin: _pin,
        ),
      ),
      AsyncError(:final error) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(mapStyleProvider),
      ),
      _ => const LoadingView(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final markers = ref.watch(mapMarkersProvider);
    final filter = ref.watch(mapFilterStateProvider);
    final stationList = ref.watch(stationListProvider);
    final shown = markers.value ?? const <MapMarker>[];
    ref.listen(mapFocusProvider, (_, id) {
      if (id != null && _map != null) unawaited(_focusStation(id));
    });
    // On wide screens the controls move left of the side panel.
    final rightInset = isWide && sidePanel != null ? sidePanelWidth : 0.0;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildMap(context, shown)),
          // Positioned so the top overlay is only as tall as its content.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md)
                    .copyWith(right: AppSpacing.md + rightInset),
                child: Column(
                  key: _topKey,
                  // Only as tall as its content, so the rest of the map stays tappable.
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MapSearchBar(
                      stations: stationList.value ?? const [],
                      onSelected: _selectStation,
                    ),
                    // Riverpod retries failed providers: show the error, not a spinner, meanwhile.
                    if (stationList.hasError && !stationList.hasValue)
                      MapInlineError(onRetry: () => ref.invalidate(stationListProvider))
                    else if (markers.isLoading)
                      const LinearProgressIndicator(minHeight: 2),
                    if (markers.hasValue && shown.isEmpty && filter.isActive)
                      MapNote(text: l10n.map_filterNone)
                    else if (!_hintDismissed)
                      MapNote(text: l10n.point_tapHint),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.md + rightInset,
            bottom: AppSpacing.xxl,
            child: MapControls(
              key: _controlsKey,
              onLocate: _locate,
              openSheet: (b) => unawaited(showGuardedSheet(b)),
            ),
          ),
          buildSidePanel(context),
        ],
      ),
    );
  }
}
