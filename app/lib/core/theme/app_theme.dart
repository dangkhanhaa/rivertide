import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/theme/appearance.dart';

abstract final class AppTheme {
  static ThemeData light([Appearance a = const Appearance()]) =>
      _build(_personal(AppColors.light, a, dark: false), Brightness.light, a.font.family);
  static ThemeData dark([Appearance a = const Appearance()]) =>
      _build(_personal(AppColors.dark, a, dark: true), Brightness.dark, a.font.family);

  /// High contrast for full sun; cards get a solid outline instead of a tint.
  /// Ignores accent and backdrop on purpose: contrast comes first outside.
  static ThemeData outdoor([Appearance a = const Appearance()]) =>
      _build(AppColors.outdoor, Brightness.light, a.font.family, outlined: true);

  static AppColors _personal(AppColors base, Appearance a, {required bool dark}) {
    final accent = dark ? a.accent.dark : a.accent.light;
    final bg = backdropColors(a.backdrop, accent, dark: dark);
    return base.copyWith(primary: accent, surface: bg.card, surfaceAlt: bg.page);
  }

  static ThemeData _build(
    AppColors c,
    Brightness brightness,
    String? fontFamily, {
    bool outlined = false,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
      primary: c.primary,
      surface: c.surface,
      onSurface: c.onSurface,
      error: c.alarm3,
    );
    final text = AppText.from(c.onSurface, c.onSurfaceMuted, family: fontFamily);
    const pill = StadiumBorder();
    const buttonSize = Size(AppSpacing.minTouch, AppSpacing.minTouch);
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceAlt,
      extensions: [c, text],
      // Material widgets (list tiles, chips, inputs, menus) use the same
      // compact scale as our own text, not Material's larger defaults.
      textTheme: TextTheme(
        titleLarge: text.title,
        titleMedium: text.bodyStrong,
        titleSmall: text.label,
        bodyLarge: text.body,
        bodyMedium: text.body,
        bodySmall: text.caption,
        labelLarge: text.label,
        labelMedium: text.label,
        labelSmall: text.caption,
      ),
      // Soft UI (P2-41): flat cards with a hairline edge on a tinted page
      // instead of grey drop shadows; outdoor mode keeps a solid outline.
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: outlined
              ? BorderSide(color: c.onSurface, width: 1.5)
              : BorderSide(color: c.onSurface.withValues(alpha: 0.06)),
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
        side: BorderSide(color: c.onSurface.withValues(alpha: 0.08)),
        backgroundColor: c.surface,
        selectedColor: c.primary.withValues(alpha: 0.14),
        labelStyle: text.label,
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: c.onSurface.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: c.onSurface.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: c.primary, width: 1.5),
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
      // Back swipe follows the finger (Android 14 predictive back; iOS edge
      // swipe) instead of a fixed zoom, so going back feels native and smooth.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
