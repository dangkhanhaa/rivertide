import 'package:rivertide/core/calc/geo/vietnam_bounds.dart';

/// Ids for arbitrary map points ("pt-210456-1058612" = 21.0456, 105.8612), so a
/// point opens in the same screens as a station and survives a deep link.
abstract final class PointId {
  static const String prefix = 'pt-';
  static final RegExp _re = RegExp(r'^pt-(\d{4,7})-(\d{5,7})$');

  /// 4 decimals ≈ 11 m: precise enough to tap a river bank.
  static String encode(double lat, double lon) =>
      '$prefix${(lat * 1e4).round()}-${(lon * 1e4).round()}';

  /// Null when [id] is not a point id or lies outside the supported area.
  static ({double lat, double lon})? decode(String id) {
    final m = _re.firstMatch(id);
    if (m == null) return null;
    final lat = int.parse(m.group(1) ?? '') / 1e4;
    final lon = int.parse(m.group(2) ?? '') / 1e4;
    return isInVietnamBounds(lat, lon) ? (lat: lat, lon: lon) : null;
  }
}
