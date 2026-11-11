import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';

/// One suggested outing: a good window at one place.
class TripOption {
  const TripOption({required this.placeId, required this.window});

  final String placeId;
  final GoldenWindow window;
}

/// Most suggestions shown.
const int tripMaxOptions = 8;

/// Best fishing windows over the coming days across [hoursByPlace] (each list
/// starts at a day start and holds consecutive hourly scores). Windows that
/// already ended or that touch a red safety hour are left out; best peak
/// first, earlier first on ties.
List<TripOption> bestTrips(
  Map<String, List<FishingHourScore>> hoursByPlace,
  DateTime nowUtc, {
  int max = tripMaxOptions,
}) {
  final out = <TripOption>[];
  for (final MapEntry(key: id, value: hours) in hoursByPlace.entries) {
    for (var d = 0; d * 24 < hours.length; d++) {
      final day = hours.skip(d * 24).take(24).toList();
      for (final w in goldenWindows(day)) {
        if (!w.endUtc.isAfter(nowUtc)) continue;
        final unsafe = day.any(
          (h) =>
              h.safety == SafetyLevel.red &&
              !h.hourUtc.isBefore(w.startUtc) &&
              h.hourUtc.isBefore(w.endUtc),
        );
        if (!unsafe) out.add(TripOption(placeId: id, window: w));
      }
    }
  }
  out.sort((a, b) {
    final byPeak = b.window.peakScore.compareTo(a.window.peakScore);
    return byPeak != 0 ? byPeak : a.window.startUtc.compareTo(b.window.startUtc);
  });
  return out.take(max).toList();
}
