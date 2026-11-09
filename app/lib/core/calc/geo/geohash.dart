const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Standard geohash (base32, longitude bit first).
///
/// Throws [ArgumentError] for out-of-range coordinates or precision ∉ 1..12.
String geohashEncode(double lat, double lon, {int precision = 5}) {
  if (lat.isNaN || lat < -90 || lat > 90) {
    throw ArgumentError.value(lat, 'lat', 'must be within -90..90');
  }
  if (lon.isNaN || lon < -180 || lon > 180) {
    throw ArgumentError.value(lon, 'lon', 'must be within -180..180');
  }
  if (precision < 1 || precision > 12) {
    throw ArgumentError.value(precision, 'precision', 'must be within 1..12');
  }
  var latMin = -90.0;
  var latMax = 90.0;
  var lonMin = -180.0;
  var lonMax = 180.0;
  final buffer = StringBuffer();
  var isLonBit = true;
  var bitCount = 0;
  var charIndex = 0;
  while (buffer.length < precision) {
    if (isLonBit) {
      final mid = (lonMin + lonMax) / 2;
      if (lon >= mid) {
        charIndex = charIndex << 1 | 1;
        lonMin = mid;
      } else {
        charIndex = charIndex << 1;
        lonMax = mid;
      }
    } else {
      final mid = (latMin + latMax) / 2;
      if (lat >= mid) {
        charIndex = charIndex << 1 | 1;
        latMin = mid;
      } else {
        charIndex = charIndex << 1;
        latMax = mid;
      }
    }
    isLonBit = !isLonBit;
    bitCount++;
    if (bitCount == 5) {
      buffer.write(_base32[charIndex]);
      bitCount = 0;
      charIndex = 0;
    }
  }
  return buffer.toString();
}
