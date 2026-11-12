import 'package:collection/collection.dart';
import 'package:rivertide/core/calc/fishing/catch_patterns.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';
import 'package:rivertide/features/stations/domain/weather.dart';

/// Conditions at a place for one hour (P2-23), in the same terms the fishing
/// log stores: water direction from the curve, wind from the forecast.
CatchConditions placeConditionsAt(StationTide tide, List<WeatherHour> weather, DateTime hourUtc) {
  // Middle of the hour: when someone fishing "at 6h" is there.
  final mid = hourUtc.add(const Duration(minutes: 30));
  final rate = tide.prediction?.rateCmPerHAt(mid);
  return conditionsAt(
    utc: mid,
    lat: tide.station.lat,
    lon: tide.station.lon,
    tideState: rate == null ? null : classifyRate(rate).name,
    windKmh: weather.firstWhereOrNull((w) => w.timeUtc == hourUtc)?.windKmh,
  );
}
