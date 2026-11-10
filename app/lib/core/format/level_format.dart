/// Vietnamese number formatting for water levels (docs/rules/02 §9).
abstract final class LevelFormat {
  /// 285 → "2,85 m". Values are cm in code, metres only for display (CLAUDE.md 3.3).
  static String meters(num levelCm) => '${_decimal(levelCm / 100, 2)} m';

  /// Unitless metres, e.g. for chart axes: "2,85".
  static String metersShort(num levelCm, {int digits = 1}) => _decimal(levelCm / 100, digits);

  /// 6.4 → "+6 cm/giờ", -12 → "−12 cm/giờ".
  static String rate(double rateCmPerH) {
    final rounded = rateCmPerH.round();
    final sign = rounded > 0 ? '+' : (rounded < 0 ? '−' : '');
    return '$sign${rounded.abs()} cm/giờ';
  }

  /// Signed centimetres: "+18 cm".
  static String signedCm(num cm) {
    final rounded = cm.round();
    final sign = rounded > 0 ? '+' : (rounded < 0 ? '−' : '');
    return '$sign${rounded.abs()} cm';
  }

  /// One decimal with comma: 7.25 → "7,3".
  static String decimal1(double value) => _decimal(value, 1);

  /// "1.790" — Vietnamese thousands separator.
  static String thousands(num value) {
    final digits = value.round().abs().toString();
    final buf = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  /// "5,8 km" below 10 km, "37 km" above.
  static String km(double km) => km < 10 ? '${_decimal(km, 1)} km' : '${km.round()} km';

  static String _decimal(double value, int digits) {
    final s = value.toStringAsFixed(digits).replaceAll('.', ',');
    return s.startsWith('-') ? '−${s.substring(1)}' : s;
  }
}
