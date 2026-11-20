import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/map/domain/location_service.dart';

/// geolocator-backed [LocationService].
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocateResult> locate({void Function(double lat, double lon)? onRefined}) async {
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
      final pos = await _RefiningFix(onRefined).first();
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

/// GPS-level fix without making anyone wait (P2-46 accuracy, P2-56 speed):
/// [first] completes with the first reading (often a coarse Wi-Fi/cell
/// guess); the stream then stays open up to [_settle] and reports each
/// reading at least [_minGainM] more accurate, stopping once within
/// [_goodEnoughM].
class _RefiningFix {
  _RefiningFix(this._onRefined);

  final void Function(double lat, double lon)? _onRefined;

  static const double _goodEnoughM = 20;
  static const double _minGainM = 10;
  static const Duration _settle = Duration(seconds: 10);
  static const Duration _firstTimeout = Duration(seconds: 15);
  static const LocationSettings _best = LocationSettings(); // accuracy: best

  final Completer<Position> _first = Completer<Position>();
  StreamSubscription<Position>? _sub;
  Timer? _stop;
  Position? _bestSoFar;

  Future<Position> first() {
    _sub = Geolocator.getPositionStream(locationSettings: _best).listen(_onFix, onError: _onError);
    _stop = Timer(_settle, _close);
    return _first.future.timeout(
      _firstTimeout,
      onTimeout: () {
        _close();
        throw TimeoutException('no location fix', _firstTimeout);
      },
    );
  }

  void _onFix(Position p) {
    final best = _bestSoFar;
    if (best == null) {
      _bestSoFar = p;
      _first.complete(p);
    } else if (p.accuracy <= best.accuracy - _minGainM) {
      _bestSoFar = p;
      _onRefined?.call(p.latitude, p.longitude);
    }
    if (p.accuracy <= _goodEnoughM) _close();
  }

  void _onError(Object e) {
    // Before the first fix this is the answer; afterwards the first fix stands.
    if (!_first.isCompleted) _first.completeError(e);
    log.info('location refine stopped', {'type': e.runtimeType.toString()});
    _close();
  }

  void _close() {
    _stop?.cancel();
    unawaited(_sub?.cancel());
    _sub = null;
  }
}
