part of 'map_screen.dart';

/// Same object while the river list is unchanged (the map syncs on identity).
final _reaches = RiverReachGeoCache();

extension _BuildMap on _MapScreenState {
  Widget _buildMap(BuildContext context, List<MapMarker> shown) {
    final l10n = context.l10n;
    final layer = ref.watch(baseLayerChoiceProvider).value ?? BaseLayer.standard;
    final style = ref.watch(mapStyleProvider(Theme.of(context).brightness, layer));
    // Keep showing the previous style while a new one loads: replacing the map
    // with a spinner would recreate it and lose the camera position.
    if (style.value case final s?) _lastStyle = s;
    final shownStyle = style.value ?? _lastStyle;
    final buildMap = ref.watch(baseMapBuilderProvider);
    // Local read (a few ms): start at the last known position, not all of Vietnam.
    final start = ref.watch(lastPositionProvider);
    return switch (style) {
      _ when shownStyle != null && !start.isLoading => buildMap(
        BaseMapConfig(
          styleString: shownStyle,
          markers: shown,
          palette: markerPalette(context.colors),
          riverReaches: _reaches.of(ref.watch(riverLinesProvider).value),
          riverFlow: ref.watch(riverFlowProvider).value ?? emptyFlowGeoJson,
          weather: ref.watch(weatherLayerGeoJsonProvider),
          onCameraIdle: reportCamera(ref),
          overlays: _overlays(),
          fixedLabels: [
            (lat: 17.5, lon: 112, text: l10n.map_hoangSa),
            (lat: 10, lon: 112.8, text: l10n.map_truongSa),
          ],
          onStationTap: _openStation,
          onReady: _onReady,
          onMapTap: _openPoint,
          blocksTapAt: _blocksTapAt,
          gesturesEnabled: !sheetBusy,
          userPosition: _me,
          pin: _pin,
          initialCenter: start.value,
        ),
      ),
      AsyncError(:final error) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(mapStyleProvider),
      ),
      _ => const LoadingView(),
    };
  }

  /// Search button, shortcuts and status lines; only as tall as its content.
  Widget _buildTop(BuildContext context, double rightInset) {
    final l10n = context.l10n;
    final markers = ref.watch(mapMarkersProvider);
    final filter = ref.watch(mapFilterStateProvider);
    final stationList = ref.watch(stationListProvider);
    final shown = markers.value ?? const <MapMarker>[];
    final actions = _socialActions();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md).copyWith(right: AppSpacing.md + rightInset),
          child: Column(
            key: _topKey,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MapShortcuts(
                search: MapSearchBar(
                  stations: stationList.value ?? const [],
                  onSelected: (s) => _openStation(s.id, zoom: 11),
                  onCoordinates: (lat, lon) => _openPoint(lat, lon, PointSurface.unknown, zoom: 14),
                  onPlace: (p) =>
                      _openPoint(p.lat, p.lon, PointSurface.unknown, zoom: 13, title: p.name),
                ),
                actions: actions,
                onMore: () => _openShortcuts(actions),
              ),
              // Riverpod retries failed providers: show the error, not a spinner, meanwhile.
              if (stationList.hasError && !stationList.hasValue)
                MapInlineError(onRetry: () => ref.invalidate(stationListProvider))
              else if (markers.isLoading)
                const LinearProgressIndicator(minHeight: 2),
              if (markers.hasValue && shown.isEmpty && filter.isActive)
                MapNote(text: l10n.map_filterNone),
            ],
          ),
        ),
      ),
    );
  }
}
