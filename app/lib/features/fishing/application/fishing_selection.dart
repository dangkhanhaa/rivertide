import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fishing_selection.g.dart';

/// Station currently chosen on the fishing tab (defaults to the Vũng Tàu gauge).
@Riverpod(keepAlive: true)
class FishingStation extends _$FishingStation {
  @override
  String build() => 'ioc-vung';

  String get stationId => state;

  set stationId(String id) => state = id;
}
