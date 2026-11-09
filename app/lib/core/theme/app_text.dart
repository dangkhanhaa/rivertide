import 'package:flutter/material.dart';

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
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: onSurface,
        fontFeatures: tabular,
      ),
      headline: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface),
      title: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      body: TextStyle(fontSize: 16, color: onSurface, fontFeatures: tabular),
      bodyStrong: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: onSurface,
        fontFeatures: tabular,
      ),
      label: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
      caption: TextStyle(fontSize: 13, color: muted),
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
