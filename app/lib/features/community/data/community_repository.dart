import 'dart:math';
import 'dart:typed_data';

import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _bucket = 'spot-photos';

/// Community spots on Supabase (schema: supabase/migrations/0001_public_spots.sql).
/// No login: each device has a random secret (kept on the device; the server
/// stores only its hash) that proves ownership for deleting and marks "mine".
class CommunityRepository {
  CommunityRepository(this._db, this._secret);

  final SupabaseClient _db;

  /// This device's secret, 64 hex chars (created once, see providers).
  final Future<String> Function() _secret;

  String _photoUrl(String path) => _db.storage.from(_bucket).getPublicUrl(path);

  Future<List<PublicSpot>> nearby(double lat, double lon, {required double radiusKm}) =>
      _guard(() async {
        final rows = await _db.rpc<List<dynamic>>(
          'nearby_spots',
          params: {'lat': lat, 'lon': lon, 'radius_km': radiusKm, 'owner_secret': await _secret()},
        );
        return [
          for (final r in rows)
            if (r is Map<String, Object?>) ?PublicSpot.fromRow(r, _photoUrl),
        ];
      });

  Future<void> publish(NewSpot spot, List<Uint8List> photos) => _guard(() async {
    final folder = _uuidV4();
    final paths = <String>[];
    for (final (i, bytes) in photos.take(3).indexed) {
      final path = '$folder/p_$i.jpg';
      await _db.storage
          .from(_bucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
      paths.add(path);
    }
    await _db.rpc<Object?>(
      'publish_spot',
      params: {
        'title': spot.title,
        'note': spot.note,
        'species': spot.species,
        'lat': spot.lat,
        'lon': spot.lon,
        'photos': paths,
        'owner_secret': await _secret(),
      },
    );
  });

  /// True when the spot was this device's and is now gone.
  Future<bool> delete(PublicSpot spot) => _guard(() async {
    final secret = await _secret();
    return await _db.rpc<bool>('delete_spot', params: {'spot_id': spot.id, 'owner_secret': secret});
  });

  /// False when this device had already reported the spot.
  Future<bool> report(PublicSpot spot) => _guard(() async {
    final secret = await _secret();
    return await _db.rpc<bool>(
      'report_spot',
      params: {'spot_id': spot.id, 'reporter_secret': secret},
    );
  });

  /// Random v4 UUID for a spot's photo folder (the server checks the format).
  static String _uuidV4() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  /// Supabase/network errors -> AppException (docs/rules/01 §5); no user data in messages.
  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on PostgrestException catch (e) {
      throw ServerException('postgrest ${e.code}', code: e.code);
    } on StorageException catch (e) {
      throw ServerException('storage ${e.statusCode}', code: e.statusCode);
    } on Exception catch (e) {
      throw NetworkException('community: ${e.runtimeType}');
    }
  }
}
