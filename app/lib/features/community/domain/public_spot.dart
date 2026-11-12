/// A fishing spot someone made public (P2-19).
class PublicSpot {
  const PublicSpot({
    required this.id,
    required this.userId,
    required this.title,
    required this.note,
    required this.species,
    required this.lat,
    required this.lon,
    required this.photoUrls,
    required this.createdAt,
    this.distanceKm,
  });

  final String id;
  final String userId;
  final String title;
  final String note;
  final String species;
  final double lat;
  final double lon;
  final List<String> photoUrls;
  final DateTime createdAt;

  /// From the point the list was asked for.
  final double? distanceKm;

  /// Server rows are untrusted: wrong types or ranges drop the row.
  static PublicSpot? fromRow(Map<String, Object?> r, String Function(String path) photoUrl) {
    if (r
        case {
          'id': final String id,
          'user_id': final String userId,
          'title': final String title,
          'lat': final num lat,
          'lon': final num lon,
          'created_at': final String created,
        }
        when title.length <= 80 && lat.abs() <= 90 && lon.abs() <= 180) {
      final when = DateTime.tryParse(created);
      if (when == null) return null;
      final photos = r['photos'];
      return PublicSpot(
        id: id,
        userId: userId,
        title: title,
        note: _text(r['note'], 500),
        species: _text(r['species'], 100),
        lat: lat.toDouble(),
        lon: lon.toDouble(),
        photoUrls: [
          if (photos is List)
            for (final p in photos.take(3))
              if (p is String && p.length < 200) photoUrl(p),
        ],
        createdAt: when.toUtc(),
        distanceKm: switch (r['distance_km']) {
          final num d when d >= 0 => d.toDouble(),
          _ => null,
        },
      );
    }
    return null;
  }

  static String _text(Object? v, int max) =>
      v is String ? (v.length > max ? v.substring(0, max) : v) : '';
}

/// What the user fills in to publish a spot.
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
