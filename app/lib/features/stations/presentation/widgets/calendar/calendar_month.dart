import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/lunar/lunar_calendar.dart';
import 'package:rivertide/core/calc/tide/spring_neap.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';
import 'package:rivertide/core/format/time_format.dart';

/// One cell of the month grid (F-TIDE-04): a Vietnam calendar day.
class CalendarDay {
  const CalendarDay({
    required this.dayStartUtc,
    required this.solarDay,
    required this.inMonth,
    required this.lunar,
    required this.moon,
    this.springNeap,
    this.rangeCm,
    this.extremes = const [],
  });

  /// 00:00 Vietnam time of the day, as a UTC instant.
  final DateTime dayStartUtc;
  final int solarDay;

  /// False for the leading/trailing days of the neighbour months.
  final bool inMonth;
  final LunarDate lunar;

  /// Moon at local noon, so the phase matches what the day "is".
  final MoonIllumination moon;
  final SpringNeap? springNeap;
  final int? rangeCm;
  final List<TideExtreme> extremes;

  bool get hasTide => extremes.isNotEmpty;
}

/// A month of Vietnam days, laid out Monday-first in whole weeks.
class CalendarMonth {
  CalendarMonth._(this.year, this.month, this.days);

  /// [prediction] null (no tide here): days still carry lunar date and moon.
  factory CalendarMonth.build(int year, int month, TideSeries? prediction) {
    final first = DateTime.utc(year, month);
    final lead = first.weekday - DateTime.monday; // 0 when the 1st is a Monday
    final daysInMonth = DateTime.utc(year, month + 1, 0).day;
    final cells = ((lead + daysInMonth) / 7).ceil() * 7;
    final days = <CalendarDay>[
      for (var i = 0; i < cells; i++) _day(first.add(Duration(days: i - lead)), month, prediction),
    ];
    return CalendarMonth._(year, month, days);
  }

  final int year;
  final int month;
  final List<CalendarDay> days;

  /// Largest daily range of the month, to scale the range bars.
  int? get maxRangeCm {
    final ranges = [
      for (final d in days)
        if (d.inMonth && d.rangeCm != null) d.rangeCm ?? 0,
    ];
    return ranges.isEmpty ? null : ranges.reduce((a, b) => a > b ? a : b);
  }

  bool get hasTide => days.any((d) => d.inMonth && d.hasTide);

  static CalendarDay _day(DateTime civil, int month, TideSeries? p) {
    // civil holds Vietnam wall-clock fields; its 00:00 VN as a UTC instant:
    final start = civil.subtract(vnOffset);
    return CalendarDay(
      dayStartUtc: start,
      solarDay: civil.day,
      inMonth: civil.month == month,
      lunar: solarToLunar(civil.year, civil.month, civil.day),
      moon: moonIllumination(start.add(const Duration(hours: 12))),
      springNeap: p?.springNeapAt(start),
      rangeCm: p?.dailyRangeCm(start),
      extremes: p?.extremesBetween(start, start.add(const Duration(days: 1))) ?? const [],
    );
  }
}

/// Months the calendar pages through: last month to 12 months ahead (F-TIDE-04).
List<(int, int)> calendarMonths(DateTime nowUtc) {
  final vn = TimeFormat.toVn(nowUtc);
  return [
    for (var i = -1; i <= 12; i++)
      (DateTime.utc(vn.year, vn.month + i).year, DateTime.utc(vn.year, vn.month + i).month),
  ];
}
