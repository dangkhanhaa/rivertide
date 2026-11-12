/// Reads coordinates typed or pasted into the search box, the ways people
/// copy them in Vietnam:
///
/// * decimal "21.0285, 105.8542", "21.0285 105.8542", "21.0285;105.8542"
/// * degrees-minutes-seconds "21°01'42.6"N 105°51'15.1"E" (also with spaces)
/// * a Google Maps link "…/@21.0285,105.8542,15z" or "…?q=21.0285,105.8542"
///
/// Returns null when the text is not a coordinate pair or is out of range.
/// A pair given as lon, lat (first value > 90) is swapped.
({double lat, double lon})? parseCoordinates(String input) {
  final text = input.trim();
  if (text.isEmpty || text.length > 200) return null;
  return _fromUrl(text) ?? _fromDms(text) ?? _fromDecimal(text);
}

final RegExp _urlPair = RegExp(r'(?:@|[?&](?:q|query|ll)=)(-?\d{1,3}\.\d+),\s*(-?\d{1,3}\.\d+)');

({double lat, double lon})? _fromUrl(String s) {
  final m = _urlPair.firstMatch(s);
  if (m == null) return null;
  return _check(double.parse(m.group(1) ?? ''), double.parse(m.group(2) ?? ''));
}

final RegExp _decimalPair = RegExp(r'^(-?\d{1,3}(?:\.\d+)?)\s*[,;\s]\s*(-?\d{1,3}(?:\.\d+)?)$');

({double lat, double lon})? _fromDecimal(String s) {
  final m = _decimalPair.firstMatch(s);
  if (m == null) return null;
  final a = double.tryParse(m.group(1) ?? '');
  final b = double.tryParse(m.group(2) ?? '');
  if (a == null || b == null) return null;
  // "21 105" is more likely a typo than a place: require decimals on both.
  if (!(m.group(1) ?? '').contains('.') || !(m.group(2) ?? '').contains('.')) return null;
  return _check(a, b);
}

/// One DMS value: degrees, optional minutes/seconds, hemisphere letter.
final RegExp _dmsValue = RegExp(
  r'''(\d{1,3}(?:\.\d+)?)\s*[°º]\s*(?:(\d{1,2}(?:\.\d+)?)\s*['′]\s*)?(?:(\d{1,2}(?:\.\d+)?)\s*(?:"|″|'')\s*)?([NSEWnsew])''',
);

({double lat, double lon})? _fromDms(String s) {
  final values = _dmsValue.allMatches(s).toList();
  if (values.length != 2) return null;
  double? lat;
  double? lon;
  for (final m in values) {
    final deg = double.parse(m.group(1) ?? '0');
    final min = double.tryParse(m.group(2) ?? '') ?? 0;
    final sec = double.tryParse(m.group(3) ?? '') ?? 0;
    if (min >= 60 || sec >= 60) return null;
    final hemi = (m.group(4) ?? '').toUpperCase();
    final v = (deg + min / 60 + sec / 3600) * (hemi == 'S' || hemi == 'W' ? -1 : 1);
    if (hemi == 'N' || hemi == 'S') {
      lat = v;
    } else {
      lon = v;
    }
  }
  if (lat == null || lon == null) return null;
  return _check(lat, lon);
}

({double lat, double lon})? _check(double a, double b) {
  // Pasted as lon, lat (e.g. GeoJSON order): Vietnam's longitudes are > 90.
  final (lat, lon) = a.abs() > 90 && b.abs() <= 90 ? (b, a) : (a, b);
  if (lat.abs() > 90 || lon.abs() > 180) return null;
  return (lat: lat, lon: lon);
}
