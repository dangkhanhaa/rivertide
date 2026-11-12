import 'package:flutter/material.dart';

/// Bundled in pubspec.yaml (Be Vietnam Pro, SIL OFL).
const String appFontFamily = 'BeVietnamPro';

/// Text styles. Use via `context.text`.
@immutable
class AppText extends ThemeExtension<AppText> {
  const AppText({
    required this.displayLevel,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.caption,
  });

  factory AppText.from(Color onSurface, Color muted) {
    const tabular = [FontFeature.tabularFigures()];
    return AppText(
      displayLevel: TextStyle(
        fontFamily: appFontFamily,
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: onSurface,
        fontFeatures: tabular,
      ),
      headline: TextStyle(
        fontFamily: appFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      title: TextStyle(
        fontFamily: appFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      body: TextStyle(
        fontFamily: appFontFamily,
        fontSize: 16,
        color: onSurface,
        fontFeatures: tabular,
      ),
      bodyStrong: TextStyle(
        fontFamily: appFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: onSurface,
        fontFeatures: tabular,
      ),
      label: TextStyle(
        fontFamily: appFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      caption: TextStyle(fontFamily: appFontFamily, fontSize: 13, color: muted),
    );
  }

  final TextStyle displayLevel;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle label;
  final TextStyle caption;

  @override
  AppText copyWith({TextStyle? body}) => this;

  @override
  AppText lerp(AppText? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppTextX on BuildContext {
  AppText get text =>
      Theme.of(this).extension<AppText>() ?? AppText.from(Colors.black, Colors.black54);
}
