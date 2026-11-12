import 'dart:math';
import 'dart:typed_data';

import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _bucket = 'spot-photos';

/// Community spots on Supabase (schema: supabase/migrations/0001_public_spots.sql).
/// Users are signed in anonymously on first write, so they can edit and
/// delete their own spots without an account.
class CommunityRepository {
  CommunityRepository(this._db);

  final SupabaseClient _db;

  String? get currentUserId => _db.auth.currentUser?.id;

  String _photoUrl(String path) => _db.storage.from(_bucket).getPublicUrl(path);

  Future<List<PublicSpot>> nearby(double lat, double lon, {required double radiusKm}) =>
      _guard(() async {
        final rows = await _db.rpc<List<dynamic>>(
          'nearby_spots',
          params: {'lat': lat, 'lon': lon, 'radius_km': radiusKm},
        );
        return [
          for (final r in rows)
            if (r is Map<String, Object?>) ?PublicSpot.fromRow(r, _photoUrl),
        ];
      });

  Future<void> publish(NewSpot spot, List<Uint8List> photos) => _guard(() async {
    final uid = await _ensureUser();
    final paths = <String>[];
    for (final (i, bytes) in photos.take(3).indexed) {
      final path = '$uid/${_randomName()}_$i.jpg';
      await _db.storage
          .from(_bucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
      paths.add(path);
    }
    await _db.from('public_spots').insert({
      'title': spot.title,
      'note': spot.note,
      'species': spot.species,
      // EWKT: PostGIS reads it straight into the geography column (lon lat order).
      'location': 'SRID=4326;POINT(${spot.lon} ${spot.lat})',
      'photos': paths,
    });
  });

  Future<void> delete(PublicSpot spot) => _guard(() async {
    await _db.from('public_spots').delete().eq('id', spot.id);
    final prefix = '${spot.userId}/';
    final paths = [
      for (final u in spot.photoUrls)
        if (u.contains('/$_bucket/$prefix'))
          u.substring(u.indexOf('/$_bucket/') + _bucket.length + 2),
    ];
    if (paths.isNotEmpty) await _db.storage.from(_bucket).remove(paths);
  });

  Future<void> report(PublicSpot spot, String reason) => _guard(() async {
    await _ensureUser();
    await _db.from('spot_reports').insert({'spot_id': spot.id, 'reason': reason});
  });

  Future<String> _ensureUser() async {
    final existing = _db.auth.currentUser?.id;
    if (existing != null) return existing;
    final res = await _db.auth.signInAnonymously();
    final id = res.user?.id;
    if (id == null) throw const PermissionDeniedException('anonymous sign-in returned no user');
    return id;
  }

  /// Supabase/network errors → AppException (docs/rules/01 §5); no user data in messages.
  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AuthException catch (e) {
      throw PermissionDeniedException('auth: ${e.statusCode}');
    } on PostgrestException catch (e) {
      // 23505: already reported this spot.
      throw ServerException('postgrest ${e.code}', code: e.code);
    } on StorageException catch (e) {
      throw ServerException('storage ${e.statusCode}', code: e.statusCode);
    } on Exception catch (e) {
      throw NetworkException('community: ${e.runtimeType}');
    }
  }

  /// 16 random hex chars: unique file names without reading the clock here.
  static String _randomName() {
    final r = Random.secure();
    return List.generate(16, (_) => r.nextInt(16).toRadixString(16)).join();
  }
}
