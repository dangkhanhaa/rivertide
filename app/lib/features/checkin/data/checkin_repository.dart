import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// People fishing in one ~200 m cell right now (counts only, no identities).
class CheckinCell {
  const CheckinCell({
    required this.lat,
    required this.lon,
    required this.people,
    required this.biting,
    required this.latest,
    required this.mine,
    this.myExpiresAt,
  });

  final double lat;
  final double lon;
  final int people;

  /// How many of them said "đang dính".
  final int biting;

  /// When the most recent person arrived.
  final DateTime latest;

  /// This device is one of them.
  final bool mine;
  final DateTime? myExpiresAt;

  static CheckinCell? fromRow(Map<String, Object?> r) {
    if (r
        case {
          'lat': final num lat,
          'lon': final num lon,
          'people': final int people,
          'biting': final int biting,
        }
        when lat.abs() <= 90 && lon.abs() <= 180 && people > 0 && biting >= 0) {
      final latest = rowTime(r['latest']);
      if (latest == null) return null;
      return CheckinCell(
        lat: lat.toDouble(),
        lon: lon.toDouble(),
        people: people,
        biting: biting.clamp(0, people),
        latest: latest,
        mine: r['mine'] == true,
        myExpiresAt: rowTime(r['my_expires_at']),
      );
    }
    return null;
  }
}

/// "Đang câu ở đây" on Supabase (P2-27, 0002_social.sql). The server snaps
/// positions to a ~200 m grid before storing them.
class CheckinRepository {
  CheckinRepository(this._db, this._secret);

  final SupabaseClient _db;
  final Future<String> Function() _secret;

  Future<List<CheckinCell>> nearby(double lat, double lon, {required double radiusKm}) =>
      guardSocial(() async {
        final rows = await _db.rpc<List<dynamic>>(
          'nearby_checkins',
          params: {
            'p_lat': lat,
            'p_lon': lon,
            'p_radius_km': radiusKm,
            'p_secret': await _secret(),
          },
        );
        return [
          for (final r in rows)
            if (r is Map<String, Object?>) ?CheckinCell.fromRow(r),
        ];
      });

  /// Returns when it expires (4 h from now).
  Future<DateTime> checkIn(double lat, double lon, {required bool biting}) => guardSocial(() async {
    final until = await _db.rpc<String>(
      'check_in',
      params: {'p_lat': lat, 'p_lon': lon, 'p_biting': biting, 'p_secret': await _secret()},
    );
    return rowTime(until) ?? (throw const ParseException('check_in: no expiry'));
  });

  Future<void> checkOut() => guardSocial(() async {
    await _db.rpc<bool>('check_out', params: {'p_secret': await _secret()});
  });
}
