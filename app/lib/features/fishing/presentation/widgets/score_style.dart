import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';

/// Score bands; colour is always paired with the word (docs/rules/06 §3).
extension ScoreStyle on BuildContext {
  String scoreLabel(double score) => score >= 7
      ? l10n.fishing_levelGood
      : (score >= 5 ? l10n.fishing_levelFair : l10n.fishing_levelPoor);

  Color scoreColor(double score) =>
      score >= 7 ? colors.fishHigh : (score >= 5 ? colors.alarm1 : colors.stale);

  String factorName(FishingFactor f) => switch (f) {
    FishingFactor.tide => l10n.fishing_factor_tide,
    FishingFactor.flow => l10n.fishing_factor_flow,
    FishingFactor.solunar => l10n.fishing_factor_solunar,
    FishingFactor.pressure => l10n.fishing_factor_pressure,
    FishingFactor.daytime => l10n.fishing_factor_daytime,
    FishingFactor.weather => l10n.fishing_factor_weather,
    FishingFactor.season => l10n.fishing_factor_season,
  };
}
