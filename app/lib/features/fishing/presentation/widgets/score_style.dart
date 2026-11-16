import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/widgets/fish_activity_style.dart';

/// Score bands = the map's "Cá ăn" bands (Thấp · Vừa · Cao · Rất cao), so a
/// colour means the same everywhere; always paired with the word
/// (docs/rules/06 §3).
extension ScoreStyle on BuildContext {
  String scoreLabel(double score) => fishActivityName(fishActivity(score));

  Color scoreColor(double score) => fishActivityColor(fishActivity(score));

  String factorName(FishingFactor f) => switch (f) {
    FishingFactor.tide => l10n.fishing_factor_tide,
    FishingFactor.flow => l10n.fishing_factor_flow,
    FishingFactor.solunar => l10n.fishing_factor_solunar,
    FishingFactor.pressure => l10n.fishing_factor_pressure,
    FishingFactor.daytime => l10n.fishing_factor_daytime,
    FishingFactor.temperature => l10n.fishing_factor_temperature,
    FishingFactor.weather => l10n.fishing_factor_weather,
    FishingFactor.season => l10n.fishing_factor_season,
  };
}
