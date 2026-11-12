import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/features/community/data/community_repository.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Null when no Supabase project is configured: the feature stays hidden.
final Provider<CommunityRepository?> communityRepositoryProvider = Provider(
  (ref) => Env.communityEnabled ? CommunityRepository(Supabase.instance.client) : null,
);

/// Search radius around the map centre / user.
const double nearbyRadiusKm = 30;

/// Spots are refetched at most this often for the same area.
const Duration nearbyTtl = Duration(minutes: 5);

/// Area key: centre snapped to 0.05° (~5 km) so small pans reuse the result.
String nearbyKey(double lat, double lon) =>
    '${(lat / 0.05).round() * 0.05},${(lon / 0.05).round() * 0.05}';

/// Visible spots within [nearbyRadiusKm] of the area `key`, nearest first.
final FutureProviderFamily<List<PublicSpot>, String> nearbySpotsProvider = FutureProvider
    .autoDispose
    .family<List<PublicSpot>, String>((ref, key) async {
      final repo = ref.watch(communityRepositoryProvider);
      if (repo == null) return const [];
      final link = ref.keepAlive();
      final timer = Timer(nearbyTtl, link.close);
      ref.onDispose(timer.cancel);
      final [lat, lon] = key.split(',').map(double.parse).toList();
      return await repo.nearby(lat, lon, radiusKm: nearbyRadiusKm);
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

Future<void> reportSpot(WidgetRef ref, PublicSpot spot, String reason) async =>
    await ref.read(communityRepositoryProvider)?.report(spot, reason);
