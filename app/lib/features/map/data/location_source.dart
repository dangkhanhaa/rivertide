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
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      // Position itself is never logged (CLAUDE.md 3.1).
      return Located(pos.latitude, pos.longitude);
    } on Exception catch (e) {
      log.warn('locate failed', {'type': e.runtimeType.toString()});
      return const LocationFailed();
    }
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
