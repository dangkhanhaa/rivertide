import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/map/domain/location_service.dart';

/// geolocator-backed [LocationService].
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocateResult> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return const LocationServiceOff();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      switch (permission) {
        case LocationPermission.denied:
          return const LocationDenied(forever: false);
        case LocationPermission.deniedForever:
          return const LocationDenied(forever: true);
        case LocationPermission.whileInUse ||
            LocationPermission.always ||
            LocationPermission.unableToDetermine:
          break;
      }
      final pos = await _bestFix();
      // Position itself is never logged (CLAUDE.md 3.1).
      return Located(pos.latitude, pos.longitude);
    } on Exception catch (e) {
      log.warn('locate failed', {'type': e.runtimeType.toString()});
      return const LocationFailed();
    }
  }

  /// GPS-level fix (P2-46, "định vị cần thật chuẩn"). The first reading is
  /// often a coarse Wi-Fi/cell guess (hundreds of metres), so watch the
  /// position for a few seconds and keep the most accurate one, stopping
  /// early once it is within [_goodEnoughM].
  static const double _goodEnoughM = 20;
  static const Duration _settle = Duration(seconds: 8);
  static const LocationSettings _best = LocationSettings(); // accuracy: best

  Future<Position> _bestFix() async {
    Position? best;
    final watch = Stopwatch()..start();
    try {
      await for (final p in Geolocator.getPositionStream(
        locationSettings: _best,
      ).timeout(_settle)) {
        if (best == null || p.accuracy < best.accuracy) best = p;
        if (p.accuracy <= _goodEnoughM || watch.elapsed >= _settle) break;
      }
    } on TimeoutException {
      // No new reading within the settle time: use the best one so far.
      log.info('location settle timeout', {'hasFix': best != null});
    }
    return best ??
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(timeLimit: Duration(seconds: 15)),
        );
  }

  @override
  Future<bool> openSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> hasPermission() async {
    try {
      final p = await Geolocator.checkPermission();
      return p == LocationPermission.whileInUse || p == LocationPermission.always;
    } on Exception catch (e) {
      log.warn('permission check failed', {'type': e.runtimeType.toString()});
      return false;
    }
  }

  @override
  Future<bool> isBlocked() async {
    try {
      return await Geolocator.checkPermission() == LocationPermission.deniedForever;
    } on Exception catch (e) {
      log.warn('permission check failed', {'type': e.runtimeType.toString()});
      return true;
    }
  }
}
