import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hours ahead the map's fish pins and the "Cá ăn" card show (0 = this hour).
/// In core so the map and stations features share it without importing each other.
const int fishTimeMaxHours = 47;

class FishTimeNotifier extends Notifier<int> {
  @override
  int build() => 0;

  int get hoursAhead => state;
  set hoursAhead(int value) => state = value.clamp(0, fishTimeMaxHours);
}

final NotifierProvider<FishTimeNotifier, int> fishTimeProvider = NotifierProvider(
  FishTimeNotifier.new,
);

/// Start of the hour [hoursAhead] after the hour containing [nowUtc].
DateTime fishHourUtc(DateTime nowUtc, int hoursAhead) => DateTime.utc(
  nowUtc.year,
  nowUtc.month,
  nowUtc.day,
  nowUtc.hour,
).add(Duration(hours: hoursAhead));
