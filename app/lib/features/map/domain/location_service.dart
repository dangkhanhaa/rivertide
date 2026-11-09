/// Outcome of asking for the current position (F-MAP-04).
sealed class LocateResult {
  const LocateResult();
}

final class Located extends LocateResult {
  const Located(this.lat, this.lon);

  final double lat;
  final double lon;
}

final class LocationServiceOff extends LocateResult {
  const LocationServiceOff();
}

final class LocationDenied extends LocateResult {
  const LocationDenied({required this.forever});

  /// Permanently denied: only the system settings can re-enable it (AC-MAP04-3).
  final bool forever;
}

final class LocationFailed extends LocateResult {
  const LocationFailed();
}

/// Device position access; the map is tested with a fake.
abstract interface class LocationService {
  Future<LocateResult> locate();

  /// True when permission is already granted (no explanation dialog needed).
  Future<bool> hasPermission();

  Future<bool> openSettings();
}
