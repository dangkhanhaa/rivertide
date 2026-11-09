import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
      primary: c.primary,
      surface: c.surface,
      onSurface: c.onSurface,
      error: c.alarm3,
    );
    final text = AppText.from(c.onSurface, c.onSurfaceMuted);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceAlt,
      extensions: [c, text],
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        elevation: 0,
        titleTextStyle: text.title,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
