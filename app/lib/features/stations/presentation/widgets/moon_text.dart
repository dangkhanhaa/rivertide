import 'package:flutter/widgets.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';

extension MoonText on BuildContext {
  String moonPhaseName(MoonPhaseName p) => switch (p) {
    MoonPhaseName.newMoon => l10n.moon_newMoon,
    MoonPhaseName.waxingCrescent => l10n.moon_waxingCrescent,
    MoonPhaseName.firstQuarter => l10n.moon_firstQuarter,
    MoonPhaseName.waxingGibbous => l10n.moon_waxingGibbous,
    MoonPhaseName.fullMoon => l10n.moon_fullMoon,
    MoonPhaseName.waningGibbous => l10n.moon_waningGibbous,
    MoonPhaseName.lastQuarter => l10n.moon_lastQuarter,
    MoonPhaseName.waningCrescent => l10n.moon_waningCrescent,
  };
}
