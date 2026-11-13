import 'dart:math';
import 'dart:typed_data';

import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _bucket = 'spot-photos';

/// Community spots and their comments on Supabase (schema:
/// supabase/migrations/0001_public_spots.sql, 0002_social.sql). No login:
/// the device secret proves ownership; the server stores only its hash.
class CommunityRepository {
  CommunityRepository(this._db, this._secret);

  final SupabaseClient _db;

  /// This device's secret, 64 hex chars (see core/social).
  final Future<String> Function() _secret;

  String _photoUrl(String path) => _db.storage.from(_bucket).getPublicUrl(path);

  Future<List<PublicSpot>> nearby(double lat, double lon, {required double radiusKm}) =>
      guardSocial(() async {
        final rows = await _db.rpc<List<dynamic>>(
          'nearby_spots',
          params: {'lat': lat, 'lon': lon, 'radius_km': radiusKm, 'owner_secret': await _secret()},
        );
        return [
          for (final r in rows)
            if (r is Map<String, Object?>) ?PublicSpot.fromRow(r, _photoUrl),
        ];
      });

  Future<void> publish(NewSpot spot, List<Uint8List> photos) => guardSocial(() async {
    final paths = await _upload(photos);
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

  /// Owner only: new texts, [keep] of the old photo paths plus [added] photos.
  Future<bool> update(PublicSpot spot, NewSpot edit, List<String> keep, List<Uint8List> added) =>
      guardSocial(() async {
        final room = (3 - keep.length).clamp(0, 3);
        final paths = [...keep.take(3), ...await _upload(added.take(room).toList())];
        return await _db.rpc<bool>(
          'update_spot',
          params: {
            'p_spot_id': spot.id,
            'p_title': edit.title,
            'p_note': edit.note,
            'p_species': edit.species,
            'p_photos': paths,
            'p_owner_secret': await _secret(),
          },
        );
      });

  Future<List<String>> _upload(List<Uint8List> photos) async {
    if (photos.isEmpty) return const [];
    final folder = _uuidV4();
    final paths = <String>[];
    for (final (i, bytes) in photos.take(3).indexed) {
      final path = '$folder/p_$i.jpg';
      await _db.storage
          .from(_bucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
      paths.add(path);
    }
    return paths;
  }

  /// True when the spot was this device's and is now gone.
  Future<bool> delete(PublicSpot spot) => guardSocial(() async {
    final secret = await _secret();
    return await _db.rpc<bool>('delete_spot', params: {'spot_id': spot.id, 'owner_secret': secret});
  });

  /// False when this device had already reported the spot.
  Future<bool> report(PublicSpot spot) => guardSocial(() async {
    final secret = await _secret();
    return await _db.rpc<bool>(
      'report_spot',
      params: {'spot_id': spot.id, 'reporter_secret': secret},
    );
  });

  Future<List<SpotComment>> comments(String spotId) => guardSocial(() async {
    final rows = await _db.rpc<List<dynamic>>(
      'list_comments',
      params: {'p_spot_id': spotId, 'p_secret': await _secret()},
    );
    return [
      for (final r in rows)
        if (r is Map<String, Object?>) ?SpotComment.fromRow(r),
    ];
  });

  Future<void> addComment(String spotId, String body, String name) => guardSocial(() async {
    await _db.rpc<Object?>(
      'add_comment',
      params: {
        'p_spot_id': spotId,
        'p_body': body,
        'p_author_name': name,
        'p_secret': await _secret(),
      },
    );
  });

  Future<bool> editComment(String commentId, String body) => guardSocial(() async {
    return await _db.rpc<bool>(
      'edit_comment',
      params: {'p_comment_id': commentId, 'p_body': body, 'p_secret': await _secret()},
    );
  });

  Future<bool> deleteComment(String commentId) => guardSocial(() async {
    return await _db.rpc<bool>(
      'delete_comment',
      params: {'p_comment_id': commentId, 'p_secret': await _secret()},
    );
  });

  /// False when already reported from this device (or it is its own).
  Future<bool> reportComment(String commentId) => guardSocial(() async {
    return await _db.rpc<bool>(
      'report_comment',
      params: {'p_comment_id': commentId, 'p_secret': await _secret()},
    );
  });

  /// Random v4 UUID for a photo folder (the server checks the format).
  static String _uuidV4() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
