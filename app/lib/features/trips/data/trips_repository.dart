import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/trips/domain/trip.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Trips ("kèo câu") on Supabase (schema: supabase/migrations/0002_social.sql).
/// Contact, member names and chat are returned only to members.
class TripsRepository {
  TripsRepository(this._db, this._secret);

  final SupabaseClient _db;
  final Future<String> Function() _secret;

  Future<List<Trip>> nearby(double lat, double lon, {required double radiusKm}) => guardSocial(
    () async {
      final rows = await _db.rpc<List<dynamic>>(
        'nearby_trips',
        params: {'p_lat': lat, 'p_lon': lon, 'p_radius_km': radiusKm, 'p_secret': await _secret()},
      );
      return [
        for (final r in rows)
          if (r is Map<String, Object?>) ?Trip.fromRow(r),
      ];
    },
  );

  /// Null when this device is not a member.
  Future<TripPrivate?> private(String tripId) => guardSocial(() async {
    final rows = await _db.rpc<List<dynamic>>(
      'trip_private',
      params: {'p_trip_id': tripId, 'p_secret': await _secret()},
    );
    final r = rows.firstOrNull;
    if (r is! Map<String, Object?>) return null;
    final names = r['member_names'];
    return TripPrivate(
      contact: rowText(r['contact'], 120),
      memberNames: [
        if (names is List)
          for (final n in names.take(30)) rowText(n, displayNameMax),
      ],
    );
  });

  Future<String> create(TripDraft d, String name) => guardSocial(() async {
    return await _db.rpc<String>(
      'create_trip',
      params: {
        'p_title': d.title,
        'p_note': d.note,
        'p_place_name': d.placeName,
        'p_lat': d.lat,
        'p_lon': d.lon,
        'p_starts_at': d.startsAt.toUtc().toIso8601String(),
        'p_ends_at': d.endsAt.toUtc().toIso8601String(),
        'p_max_people': d.maxPeople,
        'p_contact': d.contact,
        'p_owner_name': name,
        'p_secret': await _secret(),
      },
    );
  });

  Future<bool> update(String tripId, TripDraft d) => guardSocial(() async {
    return await _db.rpc<bool>(
      'update_trip',
      params: {
        'p_trip_id': tripId,
        'p_title': d.title,
        'p_note': d.note,
        'p_starts_at': d.startsAt.toUtc().toIso8601String(),
        'p_ends_at': d.endsAt.toUtc().toIso8601String(),
        'p_max_people': d.maxPeople,
        'p_contact': d.contact,
        'p_secret': await _secret(),
      },
    );
  });

  Future<bool> cancel(String tripId) => _bool('cancel_trip', tripId);

  Future<bool> leave(String tripId) => _bool('leave_trip', tripId);

  Future<bool> report(String tripId) => _bool('report_trip', tripId);

  Future<JoinResult> join(String tripId, String name) => guardSocial(() async {
    final r = await _db.rpc<String>(
      'join_trip',
      params: {'p_trip_id': tripId, 'p_name': name, 'p_secret': await _secret()},
    );
    return JoinResult.values.where((v) => v.name == r).firstOrNull ?? JoinResult.closed;
  });

  Future<List<TripMessage>> messages(String tripId) => guardSocial(() async {
    final rows = await _db.rpc<List<dynamic>>(
      'trip_messages_for',
      params: {'p_trip_id': tripId, 'p_secret': await _secret()},
    );
    return [
      for (final r in rows)
        if (r is Map<String, Object?>) ?TripMessage.fromRow(r),
    ];
  });

  Future<void> post(String tripId, String body, String name) => guardSocial(() async {
    await _db.rpc<Object?>(
      'post_trip_message',
      params: {'p_trip_id': tripId, 'p_body': body, 'p_name': name, 'p_secret': await _secret()},
    );
  });

  Future<bool> _bool(String fn, String tripId) => guardSocial(() async {
    return await _db.rpc<bool>(fn, params: {'p_trip_id': tripId, 'p_secret': await _secret()});
  });
}
