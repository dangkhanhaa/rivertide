import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/features/community/data/community_repository.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Null when no Supabase project is configured: the feature stays hidden.
final Provider<CommunityRepository?> communityRepositoryProvider = Provider(
  (ref) => Env.communityEnabled
      ? CommunityRepository(Supabase.instance.client, () => _deviceSecret(ref))
      : null,
);

const String _secretKey = 'community_secret';

/// This device's secret for its own spots: created once with a secure RNG,
/// kept in the local settings, never logged (the server stores its hash).
Future<String> _deviceSecret(Ref ref) async {
  final db = ref.read(appDatabaseProvider);
  final stored = await db.readSetting(_secretKey);
  if (stored != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(stored)) return stored;
  final r = Random.secure();
  final fresh = List.generate(32, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  await db.writeSetting(_secretKey, fresh);
  return fresh;
}

/// Search radius around the map centre / user.
const double nearbyRadiusKm = 30;

/// Spots are refetched at most this often for the same area.
const Duration nearbyTtl = Duration(minutes: 5);

/// Area key: centre snapped to 0.05° (~5 km) so small pans reuse the result,
/// plus the search radius in whole km.
String nearbyKey(double lat, double lon, {double radiusKm = nearbyRadiusKm}) =>
    '${(lat / 0.05).round() * 0.05},${(lon / 0.05).round() * 0.05},${radiusKm.round()}';

/// Visible spots within the radius of the area `key`, nearest first.
final FutureProviderFamily<List<PublicSpot>, String> nearbySpotsProvider = FutureProvider
    .autoDispose
    .family<List<PublicSpot>, String>((ref, key) async {
      final repo = ref.watch(communityRepositoryProvider);
      if (repo == null) return const [];
      final link = ref.keepAlive();
      final timer = Timer(nearbyTtl, link.close);
      ref.onDispose(timer.cancel);
      final parts = key.split(',').map(double.parse).toList();
      final radius = parts.length > 2 ? parts[2] : nearbyRadiusKm;
      return await repo.nearby(parts[0], parts[1], radiusKm: radius);
    });

/// Publishes and refreshes every cached area so the new pin shows at once.
Future<void> publishSpot(WidgetRef ref, NewSpot spot, List<Uint8List> photos) async {
  final repo = ref.read(communityRepositoryProvider);
  if (repo == null) return;
  await repo.publish(spot, photos);
  ref.invalidate(nearbySpotsProvider);
}

Future<void> deleteSpot(WidgetRef ref, PublicSpot spot) async {
  await ref.read(communityRepositoryProvider)?.delete(spot);
  ref.invalidate(nearbySpotsProvider);
}

/// False when this device had already reported it.
Future<bool> reportSpot(WidgetRef ref, PublicSpot spot) async =>
    await ref.read(communityRepositoryProvider)?.report(spot) ?? false;
