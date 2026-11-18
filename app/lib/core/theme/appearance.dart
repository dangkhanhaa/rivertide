import 'dart:convert';

import 'package:flutter/material.dart';

/// Personal look of the app (P2-31, "Giao diện của tôi"). Stored as JSON in
/// the local settings table; unknown or broken values fall back to defaults.

/// Accent colour; light / dark variants keep text contrast in both modes.
enum AppAccent {
  ocean(Color(0xFF0A7CC1), Color(0xFF5CC4FF)),
  jade(Color(0xFF00897B), Color(0xFF4DD6CB)),
  leaf(Color(0xFF2E7D32), Color(0xFF81C784)),
  sunset(Color(0xFFE0590B), Color(0xFFFFA25C)),
  coral(Color(0xFFD81B60), Color(0xFFFF7EB0)),
  violet(Color(0xFF6A4BC4), Color(0xFFB39DFF)),
  slate(Color(0xFF3E5566), Color(0xFFB0C4D2)),
  gold(Color(0xFFA86F00), Color(0xFFFFD166));

  AppAccent(this.light, this.dark);

  final Color light;
  final Color dark;
}

/// Page background style behind cards.
enum AppBackdrop {
  /// Pale blue-grey (light) / deep night blue (dark): the original look.
  mist,

  /// Warm paper (light) / warm brown-black (dark), easy on the eyes.
  warm,

  /// Pure white (light) / true black AMOLED (dark), saves battery on OLED.
  pure,

  /// Tinted with the accent colour.
  tinted,
}

/// Bundled typefaces (SIL OFL) or the device's own.
enum AppFont {
  beVietnam('BeVietnamPro'),
  nunito('Nunito'),
  system(null);

  AppFont(this.family);

  /// Null = platform default font.
  final String? family;
}

/// Text size steps, multiplied with the system setting (capped at ×1.6).
enum AppTextSize {
  small(0.9),
  normal(1),
  large(1.12),
  huge(1.25);

  AppTextSize(this.factor);

  final double factor;
}

/// App language; [system] follows the phone (Vietnamese if unsupported).
/// Default is Vietnamese: many Vietnamese phones are set to English.
enum AppLanguage {
  system(null),
  vi('vi'),
  en('en');

  AppLanguage(this.code);

  final String? code;
}

/// Tab opened at launch.
enum StartTab { map, ponds, fishing }

@immutable
class Appearance {
  const Appearance({
    this.accent = AppAccent.ocean,
    this.backdrop = AppBackdrop.mist,
    this.font = AppFont.beVietnam,
    this.textSize = AppTextSize.normal,
    this.language = AppLanguage.vi,
    this.reduceMotion = false,
    this.startTab = StartTab.map,
  });

  /// Parses stored JSON; anything invalid becomes the default for that field.
  factory Appearance.fromJson(String? raw) {
    if (raw == null || raw.length > 2000) return const Appearance();
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const Appearance();
    }
    if (decoded is! Map<String, Object?>) return const Appearance();
    final map = decoded;
    T pick<T extends Enum>(List<T> values, String key, T fallback) =>
        values.where((v) => v.name == map[key]).firstOrNull ?? fallback;
    return Appearance(
      accent: pick(AppAccent.values, 'accent', AppAccent.ocean),
      backdrop: pick(AppBackdrop.values, 'backdrop', AppBackdrop.mist),
      font: pick(AppFont.values, 'font', AppFont.beVietnam),
      textSize: pick(AppTextSize.values, 'textSize', AppTextSize.normal),
      language: pick(AppLanguage.values, 'language', AppLanguage.vi),
      reduceMotion: map['reduceMotion'] == true,
      startTab: pick(StartTab.values, 'startTab', StartTab.map),
    );
  }

  final AppAccent accent;
  final AppBackdrop backdrop;
  final AppFont font;
  final AppTextSize textSize;
  final AppLanguage language;
  final bool reduceMotion;
  final StartTab startTab;

  String toJson() => jsonEncode({
    'accent': accent.name,
    'backdrop': backdrop.name,
    'font': font.name,
    'textSize': textSize.name,
    'language': language.name,
    'reduceMotion': reduceMotion,
    'startTab': startTab.name,
  });

  Appearance copyWith({
    AppAccent? accent,
    AppBackdrop? backdrop,
    AppFont? font,
    AppTextSize? textSize,
    AppLanguage? language,
    bool? reduceMotion,
    StartTab? startTab,
  }) => Appearance(
    accent: accent ?? this.accent,
    backdrop: backdrop ?? this.backdrop,
    font: font ?? this.font,
    textSize: textSize ?? this.textSize,
    language: language ?? this.language,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    startTab: startTab ?? this.startTab,
  );

  @override
  bool operator ==(Object other) => other is Appearance && other.toJson() == toJson();

  @override
  int get hashCode => toJson().hashCode;
}

/// Page background and card colour for [backdrop] in the given brightness.
({Color page, Color card}) backdropColors(
  AppBackdrop backdrop,
  Color accent, {
  required bool dark,
}) => switch ((backdrop, dark)) {
  (AppBackdrop.mist, false) => (page: const Color(0xFFF2F6F9), card: const Color(0xFFFFFFFF)),
  (AppBackdrop.mist, true) => (page: const Color(0xFF0A1118), card: const Color(0xFF111A23)),
  (AppBackdrop.warm, false) => (page: const Color(0xFFF7F2E8), card: const Color(0xFFFFFDF8)),
  (AppBackdrop.warm, true) => (page: const Color(0xFF14110D), card: const Color(0xFF201B15)),
  (AppBackdrop.pure, false) => (page: const Color(0xFFFFFFFF), card: const Color(0xFFF7F8FA)),
  (AppBackdrop.pure, true) => (page: const Color(0xFF000000), card: const Color(0xFF101114)),
  (AppBackdrop.tinted, false) => (
    page: Color.alphaBlend(accent.withValues(alpha: 0.08), const Color(0xFFFFFFFF)),
    card: const Color(0xFFFFFFFF),
  ),
  (AppBackdrop.tinted, true) => (
    page: Color.alphaBlend(accent.withValues(alpha: 0.10), const Color(0xFF05080B)),
    card: Color.alphaBlend(accent.withValues(alpha: 0.08), const Color(0xFF10151B)),
  ),
};
