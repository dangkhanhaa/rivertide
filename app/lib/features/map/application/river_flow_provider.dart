import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/map/domain/river_flow_geojson.dart';
import 'package:rivertide/features/stations/stations.dart';

/// How often the coloured river state is recomputed.
const Duration riverFlowRefresh = Duration(minutes: 10);

/// River segments coloured by rising / falling water now (map flow layer).
/// Each segment takes the nearest station on its river that has a tide model.
final FutureProvider<Map<String, Object?>> riverFlowProvider = FutureProvider((ref) async {
  final timer = Timer(riverFlowRefresh, ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  final rivers = await ref.watch(riverLinesProvider.future);
  final repo = ref.read(stationRepositoryProvider);
  final now = ref.read(clockProvider)();
  final rates = <String, SegmentRates>{};
  for (final r in rivers) {
    final mids = [
      for (var i = 0; i < r.points.length - 1; i++) (r.points[i].km + r.points[i + 1].km) / 2,
    ];
    final best = <int, ({double rate, double dist})>{};
    for (final MapEntry(key: id, value: stationKm) in r.stationKm.entries) {
      try {
        final station = await repo.getById(id);
        final list = await repo.reachRates(
          station,
          stationKm: stationKm,
          pointKms: mids,
          atUtc: now,
        );
        for (var i = 0; i < list.length; i++) {
          final v = list[i];
          if (v == null) continue;
          final d = (mids[i] - stationKm).abs();
          final cur = best[i];
          if (cur == null || d < cur.dist) best[i] = (rate: v, dist: d);
        }
      } on AppException catch (e) {
        log.info('river flow: station skipped', {'error': e.debugMessage});
      }
    }
    rates[r.id] = {for (final e in best.entries) e.key: e.value.rate};
  }
  return riverFlowGeoJson(rivers, rates);
});
