import 'package:flutter/material.dart';

/// Colour tokens from PROJECT.md 10.3 (light + dark). Use via `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.water,
    required this.tidePred,
    required this.ok,
    required this.alarm1,
    required this.alarm2,
    required this.alarm3,
    required this.stale,
    required this.fishHigh,
    required this.surface,
    required this.surfaceAlt,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.estimateHatch,
    required this.fishLow,
    required this.fishFair,
    required this.fishGood,
    required this.fishPeak,
    required this.spot,
    required this.deepWater,
    required this.trip,
    required this.pond,
  });

  static const light = AppColors(
    primary: Color(0xFF0A7CC1),
    water: Color(0xFF1E88E5),
    tidePred: Color(0xFF7E57C2),
    ok: Color(0xFF2E7D32),
    alarm1: Color(0xFFF9A825),
    alarm2: Color(0xFFEF6C00),
    alarm3: Color(0xFFC62828),
    stale: Color(0xFF9E9E9E),
    fishHigh: Color(0xFF00897B),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF2F6F9),
    onSurface: Color(0xFF14212B),
    onSurfaceMuted: Color(0xFF52606D),
    estimateHatch: Color(0x337E57C2),
    fishLow: Color(0xFF8796A5),
    fishFair: Color(0xFF2F8FE0),
    fishGood: Color(0xFF16A874),
    fishPeak: Color(0xFF3CCB5A),
    spot: Color(0xFFFF7A2F),
    deepWater: Color(0xFF0C3B5E),
    trip: Color(0xFF7B5CD6),
    pond: Color(0xFF00A59B),
  );

  /// "Chế độ ngoài trời": black on white, darker accents, readable in full sun
  /// (contrast well above WCAG AAA for text).
  static const outdoor = AppColors(
    primary: Color(0xFF00405C),
    water: Color(0xFF0D47A1),
    tidePred: Color(0xFF4A148C),
    ok: Color(0xFF1B5E20),
    alarm1: Color(0xFFB26A00),
    alarm2: Color(0xFFBF360C),
    alarm3: Color(0xFFB71C1C),
    stale: Color(0xFF424242),
    fishHigh: Color(0xFF00695C),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    onSurfaceMuted: Color(0xFF212121),
    estimateHatch: Color(0x554A148C),
    fishLow: Color(0xFF424242),
    fishFair: Color(0xFF0D47A1),
    fishGood: Color(0xFF00695C),
    fishPeak: Color(0xFF1B5E20),
    spot: Color(0xFFBF360C),
    deepWater: Color(0xFF00283F),
    trip: Color(0xFF4A148C),
    pond: Color(0xFF00695C),
  );

  static const dark = AppColors(
    primary: Color(0xFF5CC4FF),
    water: Color(0xFF64B5F6),
    tidePred: Color(0xFFB39DDB),
    ok: Color(0xFF81C784),
    alarm1: Color(0xFFFFD54F),
    alarm2: Color(0xFFFFB74D),
    alarm3: Color(0xFFE57373),
    stale: Color(0xFF757575),
    fishHigh: Color(0xFF4DB6AC),
    surface: Color(0xFF111A23),
    surfaceAlt: Color(0xFF0A1118),
    onSurface: Color(0xFFE6EDF2),
    onSurfaceMuted: Color(0xFFA9B6C2),
    estimateHatch: Color(0x40B39DDB),
    fishLow: Color(0xFF7D8B98),
    fishFair: Color(0xFF4FA8F5),
    fishGood: Color(0xFF2FD08F),
    fishPeak: Color(0xFF7CF06A),
    spot: Color(0xFFFF9A57),
    deepWater: Color(0xFF071F33),
    trip: Color(0xFFB39DFF),
    pond: Color(0xFF4DD6CB),
  );

  final Color primary;
  final Color water;
  final Color tidePred;
  final Color ok;
  final Color alarm1;
  final Color alarm2;
  final Color alarm3;
  final Color stale;
  final Color fishHigh;
  final Color surface;
  final Color surfaceAlt;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color estimateHatch;

  /// Fish activity bands (P2-20), weakest to strongest; always shown with a word.
  final Color fishLow;
  final Color fishFair;
  final Color fishGood;
  final Color fishPeak;

  /// Community fishing spots.
  final Color spot;

  /// Background of the "underwater" fish activity scene.
  final Color deepWater;

  /// Fishing trips ("kèo câu").
  final Color trip;

  /// Fishing ponds ("hồ câu dịch vụ").
  final Color pond;

  @override
  AppColors copyWith({Color? primary}) => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
