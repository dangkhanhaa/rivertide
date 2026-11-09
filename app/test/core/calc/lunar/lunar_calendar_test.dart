// Reference values: Tết dates and leap months are from the official
// Vietnamese calendar (as given in the task spec / Hồ Ngọc Đức's tables):
// 2023 leap month 2 starts 2023-03-22, 2025 leap month 6 starts 2025-07-25.
//
// Tết 2030: the task spec listed 2030-02-03, but that is the Chinese (UTC+8)
// date. The new moon is 2030-02-02 ~16:09 UTC = 23:09 UTC+7, so the
// Vietnamese (UTC+7) Tết is 2030-02-02 (Hồ Ngọc Đức notes this difference).
// Both are asserted below.

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/lunar/lunar_calendar.dart';

Matcher isLunar(LunarDate expected) =>
    predicate<LunarDate>((actual) => actual.isSameAs(expected), 'is $expected');

void main() {
  group('solarToLunar', () {
    const tet = <int, (int, int)>{
      2020: (1, 25),
      2021: (2, 12),
      2022: (2, 1),
      2023: (1, 22),
      2024: (2, 10),
      2025: (1, 29),
      2026: (2, 17),
      2027: (2, 6),
      2028: (1, 26),
      2029: (2, 13),
      2030: (2, 2),
    };

    for (final entry in tet.entries) {
      final year = entry.key;
      final (month, day) = entry.value;
      test('Tết $year falls on $year-$month-$day', () {
        expect(solarToLunar(year, month, day), isLunar(LunarDate(day: 1, month: 1, year: year)));
        expect(lunarToSolar(LunarDate(day: 1, month: 1, year: year)), (
          year: year,
          month: month,
          day: day,
        ));
      });
    }

    test('Tết 2030 is 02-02 at UTC+7 but 02-03 at UTC+8 (China)', () {
      const tet2030 = LunarDate(day: 1, month: 1, year: 2030);
      expect(lunarToSolar(tet2030), (year: 2030, month: 2, day: 2));
      expect(lunarToSolar(tet2030, tzOffsetHours: 8), (year: 2030, month: 2, day: 3));
    });

    test('day before Tết 2026 is the last day of month 12 of 2025', () {
      final lunar = solarToLunar(2026, 2, 16);
      expect(lunar.month, 12);
      expect(lunar.year, 2025);
      expect(lunar.isLeapMonth, isFalse);
    });

    test('2023 leap month 2 starts on 2023-03-22', () {
      expect(
        solarToLunar(2023, 3, 22),
        isLunar(const LunarDate(day: 1, month: 2, year: 2023, isLeapMonth: true)),
      );
      final dayBefore = solarToLunar(2023, 3, 21);
      expect(dayBefore.month, 2);
      expect(dayBefore.isLeapMonth, isFalse);
    });

    test('2023 leap month 2 ends the day before lunar month 3 starts', () {
      final month3 = lunarToSolar(const LunarDate(day: 1, month: 3, year: 2023));
      final lastLeap = DateTime.utc(month3.year, month3.month, month3.day - 1);
      final lunar = solarToLunar(lastLeap.year, lastLeap.month, lastLeap.day);
      expect(lunar.month, 2);
      expect(lunar.isLeapMonth, isTrue);
      expect(lunar.day, inInclusiveRange(29, 30));
    });

    test('2025 leap month 6 starts on 2025-07-25', () {
      expect(
        solarToLunar(2025, 7, 25),
        isLunar(const LunarDate(day: 1, month: 6, year: 2025, isLeapMonth: true)),
      );
      expect(solarToLunar(2025, 7, 24).isLeapMonth, isFalse);
    });

    test('31/12 → 1/1 advances exactly one lunar day', () {
      final dec31 = solarToLunar(2025, 12, 31);
      final jan1 = solarToLunar(2026, 1, 1);
      expect(jan1.year, dec31.year);
      expect(jan1.day == dec31.day + 1 || jan1.day == 1, isTrue);
    });
  });

  group('lunarToSolar', () {
    test('round-trips every day of 2024–2027', () {
      var date = DateTime.utc(2024);
      final end = DateTime.utc(2028);
      while (date.isBefore(end)) {
        final lunar = solarToLunar(date.year, date.month, date.day);
        expect(lunarToSolar(lunar), (
          year: date.year,
          month: date.month,
          day: date.day,
        ), reason: '$date → $lunar');
        date = date.add(const Duration(days: 1));
      }
    });

    test('maps 2025 leap month 6 day 1 back to 2025-07-25', () {
      expect(lunarToSolar(const LunarDate(day: 1, month: 6, year: 2025, isLeapMonth: true)), (
        year: 2025,
        month: 7,
        day: 25,
      ));
    });

    test('rejects a leap month that does not exist', () {
      expect(
        () => lunarToSolar(const LunarDate(day: 1, month: 3, year: 2025, isLeapMonth: true)),
        throwsArgumentError,
      );
      expect(
        () => lunarToSolar(const LunarDate(day: 1, month: 3, year: 2024, isLeapMonth: true)),
        throwsArgumentError,
      );
    });

    test('rejects out-of-range day or month', () {
      expect(
        () => lunarToSolar(const LunarDate(day: 0, month: 1, year: 2025)),
        throwsArgumentError,
      );
      expect(
        () => lunarToSolar(const LunarDate(day: 1, month: 13, year: 2025)),
        throwsArgumentError,
      );
    });

    test('rejects day 30 of a 29-day month', () {
      // Find a 29-day month in 2026 and ask for its day 30.
      for (var m = 1; m <= 12; m++) {
        final start = lunarToSolar(LunarDate(day: 1, month: m, year: 2026));
        final next = m == 12
            ? lunarToSolar(const LunarDate(day: 1, month: 1, year: 2027))
            : lunarToSolar(LunarDate(day: 1, month: m + 1, year: 2026));
        final length = DateTime.utc(
          next.year,
          next.month,
          next.day,
        ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;
        if (length == 29) {
          expect(() => lunarToSolar(LunarDate(day: 30, month: m, year: 2026)), throwsArgumentError);
          return;
        }
      }
      fail('no 29-day month found in 2026');
    });
  });

  group('LunarDate', () {
    test('isSameAs compares all fields', () {
      const a = LunarDate(day: 15, month: 8, year: 2026);
      expect(a.isSameAs(const LunarDate(day: 15, month: 8, year: 2026)), isTrue);
      expect(
        a.isSameAs(const LunarDate(day: 15, month: 8, year: 2026, isLeapMonth: true)),
        isFalse,
      );
      expect(a.toString(), contains('15/8/2026'));
    });
  });
}
