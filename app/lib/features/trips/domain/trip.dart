import 'package:rivertide/core/social/social_backend.dart';

/// A fishing trip others can join ("kèo câu", P2-26).
class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.note,
    required this.placeName,
    required this.lat,
    required this.lon,
    required this.startsAt,
    required this.endsAt,
    required this.maxPeople,
    required this.memberCount,
    required this.ownerName,
    required this.mine,
    required this.joined,
    required this.cancelled,
    this.distanceKm,
  });

  final String id;
  final String title;
  final String note;
  final String placeName;
  final double lat;
  final double lon;
  final DateTime startsAt;
  final DateTime endsAt;
  final int maxPeople;
  final int memberCount;

  /// "" = anonymous.
  final String ownerName;

  /// Created on this device (can edit / cancel).
  final bool mine;

  /// This device is a member (the owner always is).
  final bool joined;
  final bool cancelled;
  final double? distanceKm;

  bool get full => memberCount >= maxPeople;

  bool runningAt(DateTime nowUtc) => !nowUtc.isBefore(startsAt) && nowUtc.isBefore(endsAt);

  /// Server rows are untrusted: wrong types or ranges drop the row.
  static Trip? fromRow(Map<String, Object?> r) {
    if (r
        case {
          'id': final String id,
          'title': final String title,
          'lat': final num lat,
          'lon': final num lon,
          'max_people': final int maxPeople,
          'member_count': final int members,
        }
        when lat.abs() <= 90 && lon.abs() <= 180 && maxPeople >= 2 && members >= 0) {
      final start = rowTime(r['starts_at']);
      final end = rowTime(r['ends_at']);
      if (start == null || end == null || !end.isAfter(start)) return null;
      return Trip(
        id: id,
        title: rowText(title, 80),
        note: rowText(r['note'], 500),
        placeName: rowText(r['place_name'], 80),
        lat: lat.toDouble(),
        lon: lon.toDouble(),
        startsAt: start,
        endsAt: end,
        maxPeople: maxPeople,
        memberCount: members,
        ownerName: rowText(r['owner_name'], displayNameMax),
        mine: r['mine'] == true,
        joined: r['joined'] == true,
        cancelled: r['cancelled'] == true,
        distanceKm: switch (r['distance_km']) {
          final num d when d >= 0 => d.toDouble(),
          _ => null,
        },
      );
    }
    return null;
  }
}

/// What only the owner and members see.
class TripPrivate {
  const TripPrivate({required this.contact, required this.memberNames});

  final String contact;

  /// In joining order; "" = anonymous.
  final List<String> memberNames;
}

class TripMessage {
  const TripMessage({
    required this.id,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.mine,
  });

  final String id;
  final String authorName;
  final String body;
  final DateTime createdAt;
  final bool mine;

  static TripMessage? fromRow(Map<String, Object?> r) {
    if (r case {'id': final String id, 'body': final String body}) {
      final at = rowTime(r['created_at']);
      if (at == null || body.isEmpty) return null;
      return TripMessage(
        id: id,
        authorName: rowText(r['author_name'], displayNameMax),
        body: rowText(body, 300),
        createdAt: at,
        mine: r['mine'] == true,
      );
    }
    return null;
  }
}

/// Server answer to "Tham gia".
enum JoinResult { joined, already, full, closed }

/// Form contents for a new or edited trip.
class TripDraft {
  const TripDraft({
    required this.title,
    required this.note,
    required this.placeName,
    required this.lat,
    required this.lon,
    required this.startsAt,
    required this.endsAt,
    required this.maxPeople,
    required this.contact,
  });

  final String title;
  final String note;
  final String placeName;
  final double lat;
  final double lon;
  final DateTime startsAt;
  final DateTime endsAt;
  final int maxPeople;
  final String contact;
}
