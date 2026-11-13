import 'package:rivertide/core/social/social_backend.dart';

/// A fishing spot someone made public (P2-19), editable by its owner (P2-25).
class PublicSpot {
  const PublicSpot({
    required this.id,
    required this.mine,
    required this.title,
    required this.note,
    required this.species,
    required this.lat,
    required this.lon,
    required this.photoPaths,
    required this.photoUrls,
    required this.createdAt,
    this.updatedAt,
    this.commentCount = 0,
    this.distanceKm,
  });

  final String id;

  /// Posted from this device (only this device can edit or delete it).
  final bool mine;
  final String title;
  final String note;
  final String species;
  final double lat;
  final double lon;

  /// Storage paths (kept when the owner edits), and their public URLs.
  final List<String> photoPaths;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int commentCount;

  /// From the point the list was asked for.
  final double? distanceKm;

  static final RegExp _photoPath = RegExp(r'^[0-9a-f-]{36}/[0-9a-z_]{1,40}\.jpg$');

  /// Server rows are untrusted: wrong types or ranges drop the row.
  static PublicSpot? fromRow(Map<String, Object?> r, String Function(String path) photoUrl) {
    if (r
        case {
          'id': final String id,
          'title': final String title,
          'lat': final num lat,
          'lon': final num lon,
          'created_at': final String created,
        }
        when title.length <= 80 && lat.abs() <= 90 && lon.abs() <= 180) {
      final when = DateTime.tryParse(created);
      if (when == null) return null;
      final photos = r['photos'];
      final paths = [
        if (photos is List)
          for (final p in photos.take(3))
            if (p is String && _photoPath.hasMatch(p)) p,
      ];
      return PublicSpot(
        id: id,
        mine: r['mine'] == true,
        title: title,
        note: rowText(r['note'], 500),
        species: rowText(r['species'], 100),
        lat: lat.toDouble(),
        lon: lon.toDouble(),
        photoPaths: paths,
        photoUrls: [for (final p in paths) photoUrl(p)],
        createdAt: when.toUtc(),
        updatedAt: rowTime(r['updated_at']),
        commentCount: switch (r['comment_count']) {
          final int n when n >= 0 => n,
          _ => 0,
        },
        distanceKm: switch (r['distance_km']) {
          final num d when d >= 0 => d.toDouble(),
          _ => null,
        },
      );
    }
    return null;
  }
}

/// What the user fills in to publish or edit a spot.
class NewSpot {
  const NewSpot({
    required this.title,
    required this.note,
    required this.species,
    required this.lat,
    required this.lon,
  });

  final String title;
  final String note;
  final String species;
  final double lat;
  final double lon;
}

/// One comment under a spot (P2-25).
class SpotComment {
  const SpotComment({
    required this.id,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.mine,
    this.updatedAt,
  });

  final String id;

  /// "" = anonymous.
  final String authorName;
  final String body;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Written from this device: only these can be edited or deleted here.
  final bool mine;

  static SpotComment? fromRow(Map<String, Object?> r) {
    if (r case {'id': final String id, 'body': final String body}) {
      final at = rowTime(r['created_at']);
      if (at == null || body.isEmpty) return null;
      return SpotComment(
        id: id,
        authorName: rowText(r['author_name'], displayNameMax),
        body: rowText(body, 300),
        createdAt: at,
        updatedAt: rowTime(r['updated_at']),
        mine: r['mine'] == true,
      );
    }
    return null;
  }
}
