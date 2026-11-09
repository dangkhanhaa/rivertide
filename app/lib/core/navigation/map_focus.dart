import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_focus.g.dart';

/// Map tab route, shared so features need not import the router.
const String mapRoute = '/map';

/// "Show this station on the map": set by lists, consumed once by the map screen.
/// Lives in core so the stations feature need not import the map feature.
@Riverpod(keepAlive: true)
class MapFocus extends _$MapFocus {
  @override
  String? build() => null;

  String? get stationId => state;

  set stationId(String? id) => state = id;
}
