import 'package:rivertide/core/calc/tide/tide_state.dart';

/// Part of the day an hour falls in, from that day's sunrise/sunset.
enum DayPart { dawn, day, dusk, night }

/// Sunrise −1 h … +1.5 h = dawn; sunset −1.5 h … +1 h = dusk.
DayPart dayPartOf(DateTime t, DateTime? sunrise, DateTime? sunset) {
  if (sunrise == null || sunset == null) return DayPart.day;
  if (!t.isBefore(sunrise.subtract(const Duration(hours: 1))) &&
      t.isBefore(sunrise.add(const Duration(minutes: 90)))) {
    return DayPart.dawn;
  }
  if (!t.isBefore(sunset.subtract(const Duration(minutes: 90))) &&
      t.isBefore(sunset.add(const Duration(hours: 1)))) {
    return DayPart.dusk;
  }
  if (t.isBefore(sunrise) || !t.isBefore(sunset)) return DayPart.night;
  return DayPart.day;
}

/// One scored hour ahead, with its part of the day.
typedef ScoredHour = ({DateTime hourUtc, double score, DayPart part});

/// Everything the species guide and "Cá không ăn?" look at, for one place
/// now (P2-32). Built by the stations feature from real tide and weather.
class SpotConditions {
  const SpotConditions({
    required this.nowUtc,
    required this.ahead,
    this.tide,
    this.nextTurnUtc,
    this.rain24hMm,
    this.tempC,
    this.tempDrop24h,
    this.pressureDelta24h,
    this.windKmh,
    this.cloudPct,
    this.nowPart = DayPart.day,
  });

  final DateTime nowUtc;

  /// The next 24 hourly scores (current hour first).
  final List<ScoredHour> ahead;
  final TideState? tide;

  /// Next high/low water; null for non-tidal places.
  final DateTime? nextTurnUtc;

  /// Rain over the last 24 h (mm): heavy rain clouds the water.
  final double? rain24hMm;
  final double? tempC;

  /// Degrees colder than the same hour yesterday (positive = colder).
  final double? tempDrop24h;

  /// Pressure now minus the same hour yesterday (hPa).
  final double? pressureDelta24h;
  final double? windKmh;
  final double? cloudPct;
  final DayPart nowPart;

  bool get isSlack => tide == TideState.slack;
  bool get murky => (rain24hMm ?? 0) >= 15;
  bool get coldSnap => (tempDrop24h ?? 0) >= 3 || (tempC ?? 25) < 18;
  bool get hot => (tempC ?? 0) >= 32 && nowPart == DayPart.day;
  bool get pressureFalling => (pressureDelta24h ?? 0) <= -3;
  bool get pressureRising => (pressureDelta24h ?? 0) >= 4;
  bool get windy => (windKmh ?? 0) >= 20;
  bool get harshSun => nowPart == DayPart.day && (cloudPct ?? 0) < 50;
}
