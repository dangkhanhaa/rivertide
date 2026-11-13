import 'dart:typed_data';

import 'package:rivertide/core/calc/ponds/release_parse.dart';
import 'package:rivertide/core/social/photo_upload.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Ponds on Supabase (schema: supabase/migrations/0003_ponds.sql).
class PondsRepository {
  PondsRepository(this._db, this._secret);

  final SupabaseClient _db;
  final Future<String> Function() _secret;

  Future<List<Pond>> nearby(double lat, double lon, {required double radiusKm}) => guardSocial(
    () async {
      final rows = await _db.rpc<List<dynamic>>(
        'nearby_ponds',
        params: {'p_lat': lat, 'p_lon': lon, 'p_radius_km': radiusKm, 'p_secret': await _secret()},
      );
      return [
        for (final r in rows)
          if (r is Map<String, Object?>) ?Pond.fromRow(r, (p) => socialPhotoUrl(_db, p)),
      ];
    },
  );

  /// Throws `DuplicateException` (with the existing pond's id) when a pond is
  /// already listed within 80 m.
  Future<String> add(PondDraft d, List<Uint8List> photos) => guardSocial(() async {
    final paths = await uploadSocialPhotos(_db, photos);
    return await _db.rpc<String>(
      'add_pond',
      params: {..._fields(d), 'p_photos': paths, 'p_secret': await _secret()},
    );
  });

  Future<bool> update(
    Pond pond,
    PondDraft d,
    List<String> keep,
    List<Uint8List> added,
  ) => guardSocial(() async {
    final room = (3 - keep.length).clamp(0, 3);
    final paths = [...keep.take(3), ...await uploadSocialPhotos(_db, added.take(room).toList())];
    return await _db.rpc<bool>(
      'update_pond',
      params: {'p_pond_id': pond.id, ..._fields(d), 'p_photos': paths, 'p_secret': await _secret()},
    );
  });

  Map<String, Object> _fields(PondDraft d) => {
    'p_name': d.name,
    'p_address': d.address,
    'p_lat': d.lat,
    'p_lon': d.lon,
    'p_phone': d.phone,
    'p_price': d.price,
    'p_hours': d.hours,
    'p_species': d.species,
    'p_note': d.note,
  };

  Future<bool> confirm(String pondId) => _bool('confirm_pond', {'p_pond_id': pondId});

  Future<bool> report(String pondId) => _bool('report_pond', {'p_pond_id': pondId});

  Future<List<PondRelease>> releases(List<String> pondIds) => guardSocial(() async {
    if (pondIds.isEmpty) return const <PondRelease>[];
    final rows = await _db.rpc<List<dynamic>>(
      'releases_for',
      params: {'p_pond_ids': pondIds.take(50).toList(), 'p_secret': await _secret()},
    );
    return [
      for (final r in rows)
        if (r is Map<String, Object?>) ?PondRelease.fromRow(r),
    ];
  });

  Future<void> postRelease(
    String pondId,
    DateTime startUtc,
    List<ReleaseFish> fish,
    String source,
  ) => guardSocial(() async {
    await _db.rpc<Object?>(
      'post_release',
      params: {
        'p_pond_id': pondId,
        'p_starts_at': startUtc.toUtc().toIso8601String(),
        'p_fish': [
          for (final f in fish) {'species': f.species, 'kg': f.kg},
        ],
        'p_note': '',
        'p_source_text': source,
        'p_secret': await _secret(),
      },
    );
  });

  Future<bool> cancelRelease(String id) => _bool('cancel_release', {'p_release_id': id});

  Future<bool> reportRelease(String id) => _bool('report_release', {'p_release_id': id});

  Future<List<PondReview>> reviews(String pondId) => guardSocial(() async {
    final rows = await _db.rpc<List<dynamic>>(
      'reviews_for',
      params: {'p_pond_id': pondId, 'p_secret': await _secret()},
    );
    return [
      for (final r in rows)
        if (r is Map<String, Object?>) ?PondReview.fromRow(r),
    ];
  });

  Future<bool> review(String pondId, int rating, String body, String name) => _bool('review_pond', {
    'p_pond_id': pondId,
    'p_rating': rating,
    'p_body': body,
    'p_name': name,
  });

  Future<bool> deleteReview(String pondId) => _bool('delete_review', {'p_pond_id': pondId});

  Future<PondPulse> pulse(String pondId) => guardSocial(() async {
    final rows = await _db.rpc<List<dynamic>>('pond_pulse', params: {'p_pond_id': pondId});
    final out = <PulseKind, int>{};
    for (final r in rows) {
      if (r case {'kind': final String k, 'people': final int n}) {
        final kind = PulseKind.values.where((p) => p.name == k).firstOrNull;
        if (kind != null) out[kind] = n;
      }
    }
    return out;
  });

  Future<bool> sendPulse(String pondId, PulseKind kind) =>
      _bool('pulse_pond', {'p_pond_id': pondId, 'p_kind': kind.name});

  Future<ClaimResult> claim(String pondId, String contact, String note) => guardSocial(() async {
    final r = await _db.rpc<String>(
      'claim_pond',
      params: {
        'p_pond_id': pondId,
        'p_contact': contact,
        'p_note': note,
        'p_secret': await _secret(),
      },
    );
    return ClaimResult.values.where((v) => v.name == r).firstOrNull ?? ClaimResult.pending;
  });

  Future<bool> _bool(String fn, Map<String, Object> params) => guardSocial(() async {
    return await _db.rpc<bool>(fn, params: {...params, 'p_secret': await _secret()});
  });
}
