import 'package:flutter/material.dart';

/// Bundled in pubspec.yaml (Be Vietnam Pro, SIL OFL).
const String appFontFamily = 'BeVietnamPro';

/// Size of the map licence line: as small as a credit can be while the
/// letters still render (P2-46, owner's request).
const double creditFontSize = 6.5;

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

  /// [family] null = the device font (P2-31 lets people pick).
  factory AppText.from(Color onSurface, Color muted, {String? family = appFontFamily}) {
    const tabular = [FontFeature.tabularFigures()];
    return AppText(
      displayLevel: TextStyle(
        fontFamily: family,
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: onSurface,
        fontFeatures: tabular,
      ),
      // Sizes tuned down in P2-32 after feedback that text looked big and
      // heavy, then again in P2-44 ("chữ bé hơn nữa"): 13.5 sp body.
      headline: TextStyle(
        fontFamily: family,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      title: TextStyle(
        fontFamily: family,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.1,
        color: onSurface,
      ),
      body: TextStyle(
        fontFamily: family,
        fontSize: 13.5,
        height: 1.4,
        color: onSurface,
        fontFeatures: tabular,
      ),
      bodyStrong: TextStyle(
        fontFamily: family,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: onSurface,
        fontFeatures: tabular,
      ),
      label: TextStyle(
        fontFamily: family,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      caption: TextStyle(fontFamily: family, fontSize: 11.5, height: 1.35, color: muted),
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
