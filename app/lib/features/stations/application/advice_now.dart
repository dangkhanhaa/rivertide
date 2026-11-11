import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/astro/sun.dart';
import 'package:rivertide/core/calc/fishing/fishing_advice.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/river_flow.dart';

/// Discharge rising more than this from today to tomorrow counts as "fast".
const double floodRiseShare = 0.15;

/// Advice for this place right now, most important first (shared by the
/// fishing tab and the "Lúc này ở đây" summary so both say the same).
List<AdviceKind> adviceNow(StationView view, StationFishing fishing, RiverFlow? flow) {
  final now = view.nowUtc;
  final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
  final weather = fishing.weather.firstWhereOrNull((w) => w.timeUtc == hour);
  final today = flow?.on(now);
  final tomorrow = flow?.on(now.add(const Duration(days: 1)));
  final st = view.tide.data.station;
  final vn = TimeFormat.toVn(now);
  final sun = sunTimes(year: vn.year, month: vn.month, day: vn.day, lat: st.lat, lon: st.lon);
  return fishingAdvice(
    AdviceInput(
      nowUtc: now,
      score: fishing.hours.firstWhereOrNull((h) => h.hourUtc == hour),
      state: view.now.state,
      isTurning: view.now.isTurning,
      nextTurnUtc: view.now.nextExtreme?.timeUtc,
      windKmh: weather?.windKmh,
      gustKmh: weather?.gustKmh,
      rainProbPct: weather?.precipProbPct,
      flowRisingFast:
          today != null &&
          tomorrow != null &&
          today > 0 &&
          (tomorrow - today) / today > floodRiseShare,
      sunriseUtc: sun.sunrise,
      sunsetUtc: sun.sunset,
    ),
  );
}
