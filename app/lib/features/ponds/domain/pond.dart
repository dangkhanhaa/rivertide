import 'package:rivertide/core/calc/ponds/release_parse.dart';
import 'package:rivertide/core/social/social_backend.dart';

/// A fishing pond ("hồ câu dịch vụ", P2-28).
class Pond {
  const Pond({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.approxLocation,
    required this.phone,
    required this.price,
    required this.hours,
    required this.species,
    required this.note,
    required this.photoPaths,
    required this.photoUrls,
    required this.fromWeb,
    required this.sourceUrls,
    required this.verified,
    required this.hasOwner,
    required this.mineOwner,
    required this.confirmedByMe,
    required this.confirmations,
    required this.reviewCount,
    this.rating,
    this.nextReleaseAt,
    this.nextReleaseKg,
    this.nextReleaseByOwner = false,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;

  /// Placed from the address only: the position may be off.
  final bool approxLocation;
  final String phone;
  final String price;
  final String hours;
  final List<String> species;
  final String note;
  final List<String> photoPaths;
  final List<String> photoUrls;

  /// Listed from public web pages (seed), not by a user.
  final bool fromWeb;
  final List<String> sourceUrls;

  /// Owner approved, or confirmed by 3 devices.
  final bool verified;
  final bool hasOwner;

  /// This device is the approved owner.
  final bool mineOwner;
  final bool confirmedByMe;
  final int confirmations;
  final double? rating;
  final int reviewCount;
  final DateTime? nextReleaseAt;
  final int? nextReleaseKg;
  final bool nextReleaseByOwner;
  final double? distanceKm;

  static final RegExp _photoPath = RegExp(r'^[0-9a-f-]{36}/[0-9a-z_]{1,40}\.jpg$');

  /// Server rows are untrusted: wrong types or ranges drop the row.
  static Pond? fromRow(Map<String, Object?> r, String Function(String path) photoUrl) {
    if (r
        case {
          'id': final String id,
          'name': final String name,
          'lat': final num lat,
          'lon': final num lon,
        }
        when lat.abs() <= 90 && lon.abs() <= 180 && name.isNotEmpty) {
      final paths = [
        for (final p in _strings(r['photos'], 3, 80))
          if (_photoPath.hasMatch(p)) p,
      ];
      return Pond(
        id: id,
        name: rowText(name, 100),
        address: rowText(r['address'], 200),
        lat: lat.toDouble(),
        lon: lon.toDouble(),
        approxLocation: r['approx_location'] == true,
        phone: rowText(r['phone'], 30),
        price: rowText(r['price_note'], 120),
        hours: rowText(r['hours_note'], 80),
        species: _strings(r['species'], 12, 30),
        note: rowText(r['note'], 500),
        photoPaths: paths,
        photoUrls: [for (final p in paths) photoUrl(p)],
        fromWeb: r['source'] == 'seed',
        sourceUrls: [
          for (final u in _strings(r['source_urls'], 5, 300))
            if (u.startsWith('https://')) u,
        ],
        verified: r['verified'] == true,
        hasOwner: r['has_owner'] == true,
        mineOwner: r['mine_owner'] == true,
        confirmedByMe: r['confirmed_by_me'] == true,
        confirmations: _int(r['confirmations']) ?? 0,
        rating: switch (r['rating']) {
          final num v when v >= 1 && v <= 5 => v.toDouble(),
          _ => null,
        },
        reviewCount: _int(r['review_count']) ?? 0,
        nextReleaseAt: rowTime(r['next_release_at']),
        nextReleaseKg: _int(r['next_release_kg']),
        nextReleaseByOwner: r['next_release_by_owner'] == true,
        distanceKm: switch (r['distance_km']) {
          final num d when d >= 0 => d.toDouble(),
          _ => null,
        },
      );
    }
    return null;
  }
}

List<String> _strings(Object? v, int count, int max) => [
  if (v is List)
    for (final s in v.take(count))
      if (s is String && s.isNotEmpty) rowText(s, max),
];

int? _int(Object? v) => v is int && v >= 0 ? v : null;

/// One "xả cá" announcement.
class PondRelease {
  const PondRelease({
    required this.id,
    required this.pondId,
    required this.startsAt,
    required this.fish,
    required this.note,
    required this.sourceText,
    required this.byOwner,
    required this.cancelled,
    required this.mine,
    this.totalKg,
  });

  final String id;
  final String pondId;
  final DateTime startsAt;
  final List<ReleaseFish> fish;
  final int? totalKg;
  final String note;

  /// The post it was read from, so anyone can check the numbers.
  final String sourceText;

  /// Posted by the approved owner ("chính thức"), else relayed by an angler.
  final bool byOwner;
  final bool cancelled;
  final bool mine;

  static PondRelease? fromRow(Map<String, Object?> r) {
    if (r case {'id': final String id, 'pond_id': final String pondId}) {
      final at = rowTime(r['starts_at']);
      if (at == null) return null;
      final fish = r['fish'];
      return PondRelease(
        id: id,
        pondId: pondId,
        startsAt: at,
        fish: [
          if (fish is List)
            for (final f in fish.take(10))
              if (f case {'species': final String s} when s.isNotEmpty)
                (species: rowText(s, 30), kg: _int(f['kg'])),
        ],
        totalKg: _int(r['total_kg']),
        note: rowText(r['note'], 300),
        sourceText: rowText(r['source_text'], 1000),
        byOwner: r['by_owner'] == true,
        cancelled: r['cancelled'] == true,
        mine: r['mine'] == true,
      );
    }
    return null;
  }
}

class PondReview {
  const PondReview({
    required this.authorName,
    required this.rating,
    required this.body,
    required this.at,
    required this.mine,
  });

  final String authorName;
  final int rating;
  final String body;
  final DateTime at;
  final bool mine;

  static PondReview? fromRow(Map<String, Object?> r) {
    final at = rowTime(r['updated_at']) ?? rowTime(r['created_at']);
    final rating = _int(r['rating']);
    if (at == null || rating == null || rating < 1 || rating > 5) return null;
    return PondReview(
      authorName: rowText(r['author_name'], displayNameMax),
      rating: rating,
      body: rowText(r['body'], 300),
      at: at,
      mine: r['mine'] == true,
    );
  }
}

/// Quick on-site reports of the last 6 hours.
enum PulseKind { busy, quiet, biting, released }

typedef PondPulse = Map<PulseKind, int>;

/// What a pond form sends.
class PondDraft {
  const PondDraft({
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.phone,
    required this.price,
    required this.hours,
    required this.species,
    required this.note,
  });

  final String name;
  final String address;
  final double lat;
  final double lon;
  final String phone;
  final String price;
  final String hours;
  final List<String> species;
  final String note;
}

/// Server answer to "Tôi là chủ hồ".
enum ClaimResult { sent, pending, owned, yours }
