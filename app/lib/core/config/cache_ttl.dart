/// Cache lifetimes (docs/rules/01 §4). Do not scatter durations elsewhere.
abstract final class CacheTtl {
  static const Duration observations = Duration(minutes: 15);
  static const Duration weather = Duration(minutes: 60);
  static const Duration marine = Duration(hours: 3);

  /// KTTV bulletin is issued once a day (~10:30); re-check every 3 h.
  static const Duration kttv = Duration(hours: 3);
}
