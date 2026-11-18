import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/calc/fishing/spot_conditions.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Real conditions at the chosen fishing spot now (P2-32); null until the
/// spot's tide and fishing scores are loaded.
final FutureProviderFamily<SpotConditions?, String> spotConditionsProvider =
    FutureProvider.family<SpotConditions?, String>((ref, spotId) async {
      final view = await ref.watch(stationViewProvider(spotId).future);
      final fishing = await ref.watch(stationFishingProvider(spotId).future);
      return fishing.hours.isEmpty ? null : spotConditionsNow(view, fishing);
    });

/// Local month (1–12) for the season checks.
int localMonth(DateTime nowUtc) => TimeFormat.toVn(nowUtc).month;
