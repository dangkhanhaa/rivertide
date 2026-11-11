import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/format/text_fold.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/map/application/place_index.dart';
import 'package:rivertide/features/map/domain/place.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Stations and place names (bridges, wharves, wards, towns) in one search;
/// accent-insensitive, on the device (F-MAP-04, AC-MAP04-1).
class MapSearchBar extends ConsumerWidget {
  const MapSearchBar({
    required this.stations,
    required this.onSelected,
    required this.onPlace,
    super.key,
  });

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
    suggestionsBuilder: (context, controller) async {
      final hits = filter(stations, controller.text);
      final query = controller.text;
      // Loads the bundled list on the first search only.
      final all = query.trim().length < 2
          ? const <Place>[]
          : await ref.read(placeIndexProvider.future);
      final places = searchPlaces(all, query);
      if (!context.mounted) return const [];
      if (hits.isEmpty && places.isEmpty) {
        return [ListTile(title: Text(context.l10n.map_searchNone))];
      }
      return [
        for (final s in hits)
          ListTile(
            leading: Icon(stationKindIcon(s.kind)),
            title: Text(s.name),
            subtitle: Text(s.river == null ? s.region : '${s.river} · ${s.region}'),
            onTap: () {
              controller.closeView(s.name);
              onSelected(s);
            },
          ),
        for (final p in places)
          ListTile(
            leading: Icon(_icon(p.kind)),
            title: Text(p.name),
            subtitle: Text(switch (nearestTown(all, p)) {
              final t? when p.kind != PlaceKind.city => context.l10n.place_near(
                _kind(context, p.kind),
                t.name,
              ),
              _ => _kind(context, p.kind),
            }),
            onTap: () {
              controller.closeView(p.name);
              onPlace(p);
            },
          ),
      ];
    },
  );

  static IconData _icon(PlaceKind k) => switch (k) {
    PlaceKind.city => Icons.location_city_rounded,
    PlaceKind.ward => Icons.home_work_outlined,
    PlaceKind.bridge => Icons.linear_scale_rounded,
    PlaceKind.ferry => Icons.directions_boat_rounded,
    PlaceKind.wharf => Icons.anchor_rounded,
  };

  static String _kind(BuildContext context, PlaceKind k) => switch (k) {
    PlaceKind.city => context.l10n.place_city,
    PlaceKind.ward => context.l10n.place_ward,
    PlaceKind.bridge => context.l10n.place_bridge,
    PlaceKind.ferry => context.l10n.place_ferry,
    PlaceKind.wharf => context.l10n.place_wharf,
  };
}
