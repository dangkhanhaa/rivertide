import 'package:flutter/material.dart';
import 'package:rivertide/core/format/text_fold.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Local, instant station search; accent-insensitive (F-MAP-04, AC-MAP04-1).
class MapSearchBar extends StatelessWidget {
  const MapSearchBar({required this.stations, required this.onSelected, super.key});

  final List<Station> stations;
  final ValueChanged<Station> onSelected;

  static List<Station> filter(List<Station> stations, String query) => query.trim().isEmpty
      ? stations
      : stations
            .where((s) => TextFold.matches('${s.name} ${s.river ?? ''} ${s.region}', query))
            .toList();

  @override
  Widget build(BuildContext context) => SearchAnchor.bar(
    barHintText: context.l10n.map_searchHint,
    viewHintText: context.l10n.map_searchHint,
    barLeading: const Icon(Icons.search_rounded),
    suggestionsBuilder: (context, controller) {
      final hits = filter(stations, controller.text);
      if (hits.isEmpty) {
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
      ];
    },
  );
}
