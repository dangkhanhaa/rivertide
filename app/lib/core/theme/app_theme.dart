import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  /// High contrast for full sun; cards get a solid outline instead of a tint.
  static ThemeData outdoor() => _build(AppColors.outdoor, Brightness.light, outlined: true);

  static ThemeData _build(AppColors c, Brightness brightness, {bool outlined = false}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
      primary: c.primary,
      surface: c.surface,
      onSurface: c.onSurface,
      error: c.alarm3,
    );
    final text = AppText.from(c.onSurface, c.onSurfaceMuted);
    const pill = StadiumBorder();
    const buttonSize = Size(AppSpacing.minTouch, AppSpacing.minTouch);
    return ThemeData(
      useMaterial3: true,
      fontFamily: appFontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceAlt,
      extensions: [c, text],
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: outlined ? BorderSide(color: c.onSurface, width: 1.5) : BorderSide.none,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surfaceAlt,
        foregroundColor: c.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.title,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize, shape: pill, textStyle: text.label),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: pill,
          textStyle: text.label,
          side: BorderSide(color: c.primary.withValues(alpha: 0.5)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: buttonSize, shape: pill),
      ),
      chipTheme: ChipThemeData(
        shape: pill,
        side: BorderSide(color: c.stale.withValues(alpha: 0.4)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.surface,
        foregroundColor: c.primary,
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        smallSizeConstraints: const BoxConstraints.tightFor(
          width: AppSpacing.minTouch,
          height: AppSpacing.minTouch,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        elevation: 0,
        height: 68,
        indicatorColor: c.primary.withValues(alpha: 0.16),
        indicatorShape: pill,
        labelTextStyle: WidgetStatePropertyAll(text.caption.copyWith(color: c.onSurface)),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) =>
              IconThemeData(color: s.contains(WidgetState.selected) ? c.primary : c.onSurfaceMuted),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceAlt,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.stale.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.stale.withValues(alpha: 0.4)),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(c.surface),
        elevation: const WidgetStatePropertyAll(4),
        shadowColor: WidgetStatePropertyAll(c.onSurface.withValues(alpha: 0.35)),
        shape: const WidgetStatePropertyAll(pill),
        constraints: const BoxConstraints(minHeight: 52),
        hintStyle: WidgetStatePropertyAll(text.body.copyWith(color: c.onSurfaceMuted)),
        textStyle: WidgetStatePropertyAll(text.body),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        thumbColor: c.primary,
        inactiveTrackColor: c.primary.withValues(alpha: 0.2),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
