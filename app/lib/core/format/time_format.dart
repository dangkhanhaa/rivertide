/// Vietnam display time. Vietnam has used UTC+7 without DST since 1975, so a fixed
/// offset is exact for all dates this app shows.
const Duration vnOffset = Duration(hours: 7);
const double vnOffsetHours = 7;

abstract final class TimeFormat {
  /// UTC → wall-clock fields in Vietnam (returned as a UTC-flagged DateTime holding local fields).
  static DateTime toVn(DateTime utc) => utc.toUtc().add(vnOffset);

  /// "14:40"
  static String hm(DateTime utc) {
    final t = toVn(utc);
    return '${_two(t.hour)}:${_two(t.minute)}';
  }

  /// "06/11"
  static String dm(DateTime utc) {
    final t = toVn(utc);
    return '${_two(t.day)}/${_two(t.month)}';
  }

  /// "T5" style weekday; Sunday is "CN".
  static String weekday(DateTime utc) {
    final wd = toVn(utc).weekday; // 1 = Monday
    return wd == DateTime.sunday ? 'CN' : 'T${wd + 1}';
  }

  /// "T5, 06/11"
  static String dayShort(DateTime utc) => '${weekday(utc)}, ${dm(utc)}';

  /// Same Vietnam calendar day?
  static bool sameVnDay(DateTime a, DateTime b) {
    final x = toVn(a);
    final y = toVn(b);
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }

  /// Start of the Vietnam calendar day containing [utc], as a UTC instant.
  static DateTime vnDayStartUtc(DateTime utc) {
    final t = toVn(utc);
    return DateTime.utc(t.year, t.month, t.day).subtract(vnOffset);
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
