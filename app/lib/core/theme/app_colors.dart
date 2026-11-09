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
  });

  static const light = AppColors(
    primary: Color(0xFF0B6E99),
    water: Color(0xFF1E88E5),
    tidePred: Color(0xFF7E57C2),
    ok: Color(0xFF2E7D32),
    alarm1: Color(0xFFF9A825),
    alarm2: Color(0xFFEF6C00),
    alarm3: Color(0xFFC62828),
    stale: Color(0xFF9E9E9E),
    fishHigh: Color(0xFF00897B),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F5F8),
    onSurface: Color(0xFF14212B),
    onSurfaceMuted: Color(0xFF52606D),
    estimateHatch: Color(0x337E57C2),
  );

  static const dark = AppColors(
    primary: Color(0xFF4FB3E0),
    water: Color(0xFF64B5F6),
    tidePred: Color(0xFFB39DDB),
    ok: Color(0xFF81C784),
    alarm1: Color(0xFFFFD54F),
    alarm2: Color(0xFFFFB74D),
    alarm3: Color(0xFFE57373),
    stale: Color(0xFF757575),
    fishHigh: Color(0xFF4DB6AC),
    surface: Color(0xFF12191F),
    surfaceAlt: Color(0xFF1C252D),
    onSurface: Color(0xFFE6EDF2),
    onSurfaceMuted: Color(0xFFA9B6C2),
    estimateHatch: Color(0x40B39DDB),
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

  @override
  AppColors copyWith({Color? primary}) => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
