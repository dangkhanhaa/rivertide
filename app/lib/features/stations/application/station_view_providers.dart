import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/features/stations/application/station_now.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

part 'station_view_providers.g.dart';

typedef StationView = ({Cached<StationTide> tide, StationNow now, DateTime nowUtc});

/// Station tide data re-evaluated every minute so countdowns and the "now" line move.
@riverpod
Future<StationView> stationView(Ref ref, String id) async {
  final tick = ref.watch(minuteTickerProvider).value;
  final clock = ref.watch(clockProvider);
  final tide = await ref.watch(stationTideProvider(id).future);
  final nowUtc = tick ?? clock();
  return (tide: tide, now: computeStationNow(tide.data, nowUtc), nowUtc: nowUtc);
}
