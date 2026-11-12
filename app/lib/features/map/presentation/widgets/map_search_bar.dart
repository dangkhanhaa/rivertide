import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/geo/coord_parse.dart';
import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/text_fold.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/map/application/place_index.dart';
import 'package:rivertide/features/map/application/recent_places.dart';
import 'package:rivertide/features/map/application/weather_layer.dart';
import 'package:rivertide/features/map/domain/place.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Stations and place names (bridges, wharves, wards, towns) in one search;
/// accent-insensitive, on the device (F-MAP-04, AC-MAP04-1).
class MapSearchBar extends ConsumerWidget {
  const MapSearchBar({
    required this.stations,
    required this.onSelected,
    required this.onPlace,
    required this.onCoordinates,
    super.key,
  });

  /// A typed/pasted coordinate pair was chosen.
  final void Function(double lat, double lon) onCoordinates;

  final List<Station> stations;
  final ValueChanged<Station> onSelected;
  final ValueChanged<Place> onPlace;

  static List<Station> filter(List<Station> stations, String query) => query.trim().isEmpty
      ? stations
      : stations
            .where((s) => TextFold.matches('${s.name} ${s.river ?? ''} ${s.region}', query))
            .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) => SearchAnchor.bar(
    barHintText: context.l10n.map_searchHint,
    viewHintText: context.l10n.map_searchHint,
    barLeading: const Icon(Icons.search_rounded),
    suggestionsBuilder: (context, controller) => _suggestions(context, ref, controller),
  );

  Future<List<Widget>> _suggestions(
    BuildContext context,
    WidgetRef ref,
    SearchController controller,
  ) async {
    final query = controller.text;
    if (query.trim().isEmpty) return await _recent(context, ref, controller);
    // Typed or pasted coordinates: go straight there (no name to look up).
    if (parseCoordinates(query) case final c?) return [_coordTile(context, controller, c)];
    // Nearer to the area on screen first (once zoomed in on a region).
    final cam = ref.read(mapCameraProvider);
    final near = cam != null && cam.zoom >= 7 ? (lat: cam.lat, lon: cam.lon) : null;
    double? kmTo(Station s) => near == null ? null : haversineKm(near.lat, near.lon, s.lat, s.lon);
    final hits = filter(stations, query);
    // Loads the bundled list on the first search only.
    final all = query.trim().length < 2
        ? const <Place>[]
        : await ref.read(placeIndexProvider.future);
    final places = searchPlaces(all, query, near: near);
    if (!context.mounted) return const [];
    if (hits.isEmpty && places.isEmpty) return [ListTile(title: Text(context.l10n.map_searchNone))];
    final rows = <(double, Widget)>[
      for (final s in hits) (kmTo(s) ?? 0, _stationTile(context, controller, s, kmTo(s))),
      for (final (i, p) in places.indexed)
        (
          near == null ? 1e9 + i : distanceKm(p, near),
          _placeTile(context, ref, controller, p, all, near),
        ),
    ];
    // Stations and places mixed, nearest first, like a map app.
    if (near != null) rows.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final r in rows) r.$2];
  }

  Widget _stationTile(BuildContext context, SearchController controller, Station s, double? km) =>
      ListTile(
        leading: Icon(stationKindIcon(s.kind)),
        title: Text(s.name),
        subtitle: Text(
          [
            s.river ?? s.region,
            if (s.river != null) s.region,
            if (km != null) LevelFormat.km(km),
          ].join(' · '),
        ),
        onTap: () {
          controller.closeView(s.name);
          onSelected(s);
        },
      );

  Widget _placeTile(
    BuildContext context,
    WidgetRef ref,
    SearchController controller,
    Place p,
    List<Place> all,
    ({double lat, double lon})? near,
  ) => ListTile(
    leading: Icon(_icon(p.kind)),
    title: Text(p.name),
    subtitle: Text(
      [
        switch (nearestTown(all, p)) {
          _ when p.area != null => context.l10n.place_in(_kind(context, p.kind), p.area ?? ''),
          _ when p.kind == PlaceKind.province => _kind(context, p.kind),
          final t? when p.kind != PlaceKind.city => context.l10n.place_near(
            _kind(context, p.kind),
            t.name,
          ),
          _ => _kind(context, p.kind),
        },
        if (near != null) LevelFormat.km(distanceKm(p, near)),
      ].join(' · '),
    ),
    onTap: () => _choose(ref, controller, p),
  );

  Widget _coordTile(
    BuildContext context,
    SearchController controller,
    ({double lat, double lon}) c,
  ) {
    final text = '${c.lat.toStringAsFixed(5)}, ${c.lon.toStringAsFixed(5)}';
    return ListTile(
      leading: const Icon(Icons.my_location_rounded),
      title: Text(context.l10n.search_coords(text)),
      subtitle: Text(context.l10n.search_coordsHint),
      onTap: () {
        controller.closeView(text);
        onCoordinates(c.lat, c.lon);
      },
    );
  }

  void _choose(WidgetRef ref, SearchController controller, Place p) {
    controller.closeView(p.name);
    unawaited(ref.read(recentPlacesProvider.notifier).remember(p));
    onPlace(p);
  }

  /// Empty box: the last places searched, like a map app.
  Future<List<Widget>> _recent(
    BuildContext context,
    WidgetRef ref,
    SearchController controller,
  ) async {
    final recent = await ref.read(recentPlacesProvider.future);
    if (!context.mounted || recent.isEmpty) return const [];
    return [
      ListTile(dense: true, title: Text(context.l10n.search_recent, style: context.text.label)),
      for (final p in recent)
        ListTile(
          leading: const Icon(Icons.history_rounded),
          title: Text(p.name),
          subtitle: Text(_kind(context, p.kind)),
          onTap: () => _choose(ref, controller, p),
        ),
    ];
  }

  static IconData _icon(PlaceKind k) => switch (k) {
    PlaceKind.province => Icons.map_outlined,
    PlaceKind.commune => Icons.account_balance_outlined,
    PlaceKind.city => Icons.location_city_rounded,
    PlaceKind.ward => Icons.home_work_outlined,
    PlaceKind.bridge => Icons.linear_scale_rounded,
    PlaceKind.ferry => Icons.directions_boat_rounded,
    PlaceKind.wharf => Icons.anchor_rounded,
  };

  static String _kind(BuildContext context, PlaceKind k) => switch (k) {
    PlaceKind.province => context.l10n.place_province,
    PlaceKind.commune => context.l10n.place_commune,
    PlaceKind.city => context.l10n.place_city,
    PlaceKind.ward => context.l10n.place_ward,
    PlaceKind.bridge => context.l10n.place_bridge,
    PlaceKind.ferry => context.l10n.place_ferry,
    PlaceKind.wharf => context.l10n.place_wharf,
  };
}
