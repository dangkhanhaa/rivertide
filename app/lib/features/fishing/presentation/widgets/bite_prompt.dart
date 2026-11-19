import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/features/checkin/checkin.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Ask "Có dính không?" while a golden window runs and for this long after.
const Duration biteAskAfter = Duration(hours: 2);

/// Feeds the spot's real state (position, water, score) to the bite card and
/// decides whether to ask: only around golden hours, so it never nags.
class BitePrompt extends ConsumerWidget {
  const BitePrompt({required this.spotId, super.key});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Env.communityEnabled) return const SizedBox.shrink();
    final view = ref.watch(stationViewProvider(spotId)).value;
    final fishing = ref.watch(stationFishingProvider(spotId)).value;
    if (view == null || fishing == null) return const SizedBox.shrink();
    final now = view.nowUtc;
    final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
    final recent = fishing.hours
        .where((h) => !h.hourUtc.isBefore(hour.subtract(const Duration(hours: 4))))
        .take(8)
        .toList();
    final ask = goldenWindows(recent)
        .any((w) => !now.isBefore(w.startUtc) && now.isBefore(w.endUtc.add(biteAskAfter)));
    final st = view.tide.data.station;
    final state = view.now.state;
    return BiteCard(
      lat: st.lat,
      lon: st.lon,
      ask: ask,
      tideState: switch (state) {
        null => null,
        TideState.slack => 'slack',
        final s when isRising(s) => 'rising',
        _ => 'falling',
      },
      localHour: TimeFormat.toVn(now).hour,
      appScore: fishing.hours.firstWhereOrNull((h) => h.hourUtc == hour)?.score,
    );
  }
}
