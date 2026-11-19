import 'package:rivertide/core/social/social_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reports around a place in the last few hours (counts only).
typedef BiteSummary = ({int bites, int misses, DateTime? latest});

/// Area results over 60 days for one water state ('rising'/'falling'/'slack').
typedef BitePattern = ({String tideState, int bites, int misses});

/// "Có dính không?" on Supabase (P2-37, 0004_bite_reports.sql). The server
/// snaps the position to a ~2 km grid and stores only a hash of the device.
class BiteRepository {
  BiteRepository(this._db, this._secret);

  final SupabaseClient _db;
  final Future<String> Function() _secret;

  Future<void> report({
    required double lat,
    required double lon,
    required bool bite,
    String? tideState,
    int? localHour,
    double? appScore,
  }) => guardSocial(() async {
    await _db.rpc<bool>(
      'report_bite',
      params: {
        'p_lat': lat,
        'p_lon': lon,
        'p_bite': bite,
        'p_tide_state': tideState,
        'p_local_hour': localHour,
        'p_app_score': appScore,
        'p_secret': await _secret(),
      },
    );
  });

  Future<BiteSummary> summary(double lat, double lon) => guardSocial(() async {
    final rows = await _db.rpc<List<dynamic>>(
      'bite_summary',
      params: {'p_lat': lat, 'p_lon': lon, 'p_radius_km': 15, 'p_hours': 3},
    );
    final r = rows.firstOrNull;
    if (r is! Map<String, Object?>) return (bites: 0, misses: 0, latest: null);
    return (bites: _count(r['bites']), misses: _count(r['misses']), latest: rowTime(r['latest']));
  });

  Future<List<BitePattern>> patterns(double lat, double lon) => guardSocial(() async {
    final rows = await _db.rpc<List<dynamic>>(
      'bite_patterns',
      params: {'p_lat': lat, 'p_lon': lon, 'p_radius_km': 30},
    );
    final out = <BitePattern>[];
    for (final r in rows) {
      if (r is! Map<String, Object?>) continue;
      final t = r['tide_state'];
      if (t is String && const {'rising', 'falling', 'slack'}.contains(t)) {
        out.add((tideState: t, bites: _count(r['bites']), misses: _count(r['misses'])));
      }
    }
    return out;
  });

  static int _count(Object? v) => v is int && v >= 0 ? v : 0;
}
