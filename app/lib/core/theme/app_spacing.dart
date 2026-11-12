/// Spacing scale (multiples of 4) and radii — docs/rules/06 §1.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Minimum touch target (a11y).
  static const double minTouch = 48;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;

  /// Pills: buttons, chips, the search bar.
  static const double pill = 999;
}

/// Icon sizes.
abstract final class AppIconSize {
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 32;
}
