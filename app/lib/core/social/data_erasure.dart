import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// "Xoá dữ liệu của tôi" on the server (P2-60): everything linked to this
/// device's secret is deleted, or anonymised where others depend on it
/// (supabase/migrations/0007_delete_my_data.sql).
class DataErasureService {
  DataErasureService(this._db, this._storedSecret);

  final SupabaseClient _db;
  final Future<String?> Function() _storedSecret;

  /// How many server rows were removed or anonymised; 0 when this device
  /// never talked to the server (no secret yet: nothing to ask for).
  Future<int> eraseServerData() async {
    final secret = await _storedSecret();
    if (secret == null) return 0;
    final counts = await guardSocial(
      () => _db.rpc<Object?>('delete_my_data', params: {'p_secret': secret}),
    );
    // Server answers are untrusted: a map of small counts, nothing else.
    if (counts is! Map) throw const ParseException('delete_my_data: not a map');
    return counts.values.whereType<int>().where((n) => n >= 0).fold<int>(0, (a, b) => a + b);
  }
}

/// Null when no community backend is configured (nothing on any server).
final Provider<DataErasureService?> dataErasureServiceProvider = Provider((ref) {
  final db = ref.watch(socialClientProvider);
  return db == null
      ? null
      : DataErasureService(db, () => storedDeviceSecret(ref.read(appDatabaseProvider)));
});
