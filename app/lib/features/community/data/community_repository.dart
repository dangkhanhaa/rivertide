import 'dart:typed_data';

import 'package:rivertide/core/social/photo_upload.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Community spots and their comments on Supabase (schema:
/// supabase/migrations/0001_public_spots.sql, 0002_social.sql). No login:
/// the device secret proves ownership; the server stores only its hash.
class CommunityRepository {
  CommunityRepository(this._db, this._secret);

  final SupabaseClient _db;

  /// This device's secret, 64 hex chars (see core/social).
  final Future<String> Function() _secret;

  String _photoUrl(String path) => socialPhotoUrl(_db, path);

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

  Future<List<String>> _upload(List<Uint8List> photos) => uploadSocialPhotos(_db, photos);

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
}
