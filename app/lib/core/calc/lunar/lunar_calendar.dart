// Vietnamese lunisolar calendar conversion (PROJECT.md 9.2).
//
// Algorithm: Hồ Ngọc Đức (public domain description at
// https://www.informatik.uni-leipzig.de/~duc/amlich/), new moons and sun
// longitude via simplified Meeus formulas. The Vietnamese calendar is
// defined for UTC+7; [tzOffsetHours] exists for testing other conventions.

import 'package:rivertide/core/calc/lunar/lunar_math.dart';

/// A date in the Vietnamese lunar calendar.
///
/// No `==` override on purpose: the lint set forbids it without `@immutable`
/// (package:meta is not allowed in core/calc). Use [isSameAs] instead.
class LunarDate {
  const LunarDate({
    required this.day,
    required this.month,
    required this.year,
    this.isLeapMonth = false,
  });

  /// Day of the lunar month, 1..30.
  final int day;

  /// Lunar month number, 1..12.
  final int month;

  /// Lunar year (the solar year in which its month 1 mostly falls).
  final int year;

  /// True when [month] is the intercalary (nhuận) month.
  final bool isLeapMonth;

  /// Field-by-field comparison.
  bool isSameAs(LunarDate other) =>
      other.day == day &&
      other.month == month &&
      other.year == year &&
      other.isLeapMonth == isLeapMonth;

  @override
  String toString() => 'LunarDate($day/$month${isLeapMonth ? 'L' : ''}/$year)';
}

/// Converts a solar (Gregorian) calendar date to the lunar calendar.
LunarDate solarToLunar(int year, int month, int day, {double tzOffsetHours = 7}) {
  final dayNumber = jdFromDate(day, month, year);
  final k = ((dayNumber - newMoonEpochJd) / synodicMonthDays).floor();
  var monthStart = newMoonDay(k + 1, tzOffsetHours);
  if (monthStart > dayNumber) {
    monthStart = newMoonDay(k, tzOffsetHours);
  }
  var a11 = lunarMonth11Start(year, tzOffsetHours);
  var b11 = a11;
  int lunarYear;
  if (a11 >= monthStart) {
    lunarYear = year;
    a11 = lunarMonth11Start(year - 1, tzOffsetHours);
  } else {
    lunarYear = year + 1;
    b11 = lunarMonth11Start(year + 1, tzOffsetHours);
  }
  final lunarDay = dayNumber - monthStart + 1;
  final diff = (monthStart - a11) ~/ 29;
  var isLeap = false;
  var lunarMonth = diff + 11;
  // A 13-month year (between two month-11 starts) has a leap month.
  if (b11 - a11 > 365) {
    final leapDiff = leapMonthOffset(a11, tzOffsetHours);
    if (diff >= leapDiff) {
      lunarMonth = diff + 10;
      isLeap = diff == leapDiff;
    }
  }
  if (lunarMonth > 12) lunarMonth -= 12;
  if (lunarMonth >= 11 && diff < 4) lunarYear -= 1;
  return LunarDate(day: lunarDay, month: lunarMonth, year: lunarYear, isLeapMonth: isLeap);
}

/// Converts a lunar date to the solar (Gregorian) calendar.
///
/// Throws [ArgumentError] when [lunar] marks a leap month that does not
/// exist in that lunar year, or when the day/month is out of range
/// (including day 30 of a 29-day month).
({int year, int month, int day}) lunarToSolar(LunarDate lunar, {double tzOffsetHours = 7}) {
  if (lunar.month < 1 || lunar.month > 12 || lunar.day < 1 || lunar.day > 30) {
    throw ArgumentError.value(lunar, 'lunar', 'day/month out of range');
  }
  int a11;
  int b11;
  if (lunar.month < 11) {
    a11 = lunarMonth11Start(lunar.year - 1, tzOffsetHours);
    b11 = lunarMonth11Start(lunar.year, tzOffsetHours);
  } else {
    a11 = lunarMonth11Start(lunar.year, tzOffsetHours);
    b11 = lunarMonth11Start(lunar.year + 1, tzOffsetHours);
  }
  final k = (0.5 + (a11 - newMoonEpochJd) / synodicMonthDays).floor();
  var off = lunar.month - 11;
  if (off < 0) off += 12;
  if (b11 - a11 > 365) {
    final leapOff = leapMonthOffset(a11, tzOffsetHours);
    var leapMonth = leapOff - 2;
    if (leapMonth < 0) leapMonth += 12;
    if (lunar.isLeapMonth && lunar.month != leapMonth) {
      throw ArgumentError.value(lunar, 'lunar', 'leap month does not exist');
    }
    if (lunar.isLeapMonth || off >= leapOff) off += 1;
  } else if (lunar.isLeapMonth) {
    throw ArgumentError.value(lunar, 'lunar', 'year has no leap month');
  }
  final monthStart = newMoonDay(k + off, tzOffsetHours);
  if (monthStart + lunar.day - 1 >= newMoonDay(k + off + 1, tzOffsetHours)) {
    throw ArgumentError.value(lunar, 'lunar', 'day 30 in a 29-day month');
  }
  return jdToDate(monthStart + lunar.day - 1);
}
