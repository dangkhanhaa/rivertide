import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/domain/point_id.dart';
import 'package:rivertide/features/stations/domain/point_water.dart';

part 'water_providers.g.dart';

/// Remembered water kind of a point id; the point's tide depends on it, so a
/// new hint recomputes the tide wherever the point is shown (P2-47).
@riverpod
Future<WaterHint?> waterHint(Ref ref, String id) =>
    ref.watch(stationRepositoryProvider).waterHint(id);

/// OpenStreetMap around a map point (P2-52). Asked only when a screen shows
/// the point (a user action), cached 30 days. A better water kind than the
/// remembered one is saved, which recomputes the point's tide.
@riverpod
Future<PointSurroundings?> pointSurroundings(Ref ref, String id) async {
  final station = PointId.toStation(id);
  if (station == null) return null;
  final repo = ref.watch(stationRepositoryProvider);
  final found = await repo.surroundings(station);
  if (found == null) return null;
  final current = await repo.waterHint(id);
  final merged = mergeOsmHint(current, found.water);
  if (merged != null && !merged.sameAs(current)) {
    await repo.saveWaterHint(id, merged);
    ref.invalidate(waterHintProvider(id));
  }
  return found;
}

/// What the base map showed under a tap, remembered for the point id.
Future<void> recordWaterHint(WidgetRef ref, String id, WaterHint hint) async {
  await ref.read(stationRepositoryProvider).saveWaterHint(id, hint);
  ref.invalidate(waterHintProvider(id));
}
