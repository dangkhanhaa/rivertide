import 'package:flutter/widgets.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';

/// Word and colour of a fish activity band; the word always goes with the colour.
extension FishActivityStyle on BuildContext {
  String fishActivityName(FishActivity a) => switch (a) {
    FishActivity.low => l10n.fishAct_low,
    FishActivity.fair => l10n.fishAct_fair,
    FishActivity.high => l10n.fishAct_high,
    FishActivity.peak => l10n.fishAct_peak,
  };

  Color fishActivityColor(FishActivity a) => switch (a) {
    FishActivity.low => colors.fishLow,
    FishActivity.fair => colors.fishFair,
    FishActivity.high => colors.fishGood,
    FishActivity.peak => colors.fishPeak,
  };

  /// "Bây giờ" / "Hôm nay 17:00" / "Ngày mai 05:00" / "Ngày kia 05:00" (Vietnam days).
  String fishTimeLabel(DateTime nowUtc, DateTime hourUtc) {
    final thisHour = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, nowUtc.hour);
    if (!hourUtc.isAfter(thisHour)) return l10n.fishTime_now;
    final days = TimeFormat.vnDayStartUtc(hourUtc)
        .difference(TimeFormat.vnDayStartUtc(nowUtc))
        .inDays;
    final time = TimeFormat.hm(hourUtc);
    return switch (days) {
      0 => l10n.fishTime_today(time),
      1 => l10n.fishTime_tomorrow(time),
      2 => l10n.fishTime_dayAfter(time),
      _ => '${TimeFormat.dayShort(hourUtc)} $time',
    };
  }
}
