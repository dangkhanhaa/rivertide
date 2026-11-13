import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/community/data/community_repository.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';

/// Null when no Supabase project is configured: the feature stays hidden.
final Provider<CommunityRepository?> communityRepositoryProvider = Provider((ref) {
  final client = ref.watch(socialClientProvider);
  return client == null ? null : CommunityRepository(client, () => deviceSecret(ref));
});

/// Search radius around the map centre / user.
const double nearbyRadiusKm = 30;

/// Spots are refetched at most this often for the same area.
const Duration nearbyTtl = Duration(minutes: 5);

/// Area key: centre snapped to 0.05° (~5 km) so small pans reuse the result,
/// plus the search radius in whole km.
String nearbyKey(double lat, double lon, {double radiusKm = nearbyRadiusKm}) =>
    '${(lat / 0.05).round() * 0.05},${(lon / 0.05).round() * 0.05},${radiusKm.round()}';

/// (lat, lon, radius km) of an area key from [nearbyKey].
({double lat, double lon, double radiusKm}) parseNearbyKey(String key) {
  final parts = key.split(',').map(double.parse).toList();
  return (lat: parts[0], lon: parts[1], radiusKm: parts.length > 2 ? parts[2] : nearbyRadiusKm);
}

/// Visible spots within the radius of the area `key`, nearest first.
final FutureProviderFamily<List<PublicSpot>, String> nearbySpotsProvider = FutureProvider
    .autoDispose
    .family<List<PublicSpot>, String>((ref, key) async {
      final repo = ref.watch(communityRepositoryProvider);
      if (repo == null) return const [];
      final link = ref.keepAlive();
      final timer = Timer(nearbyTtl, link.close);
      ref.onDispose(timer.cancel);
      final k = parseNearbyKey(key);
      return await repo.nearby(k.lat, k.lon, radiusKm: k.radiusKm);
    });

/// Publishes and refreshes every cached area so the new pin shows at once.
Future<void> publishSpot(WidgetRef ref, NewSpot spot, List<Uint8List> photos) async {
  final repo = ref.read(communityRepositoryProvider);
  if (repo == null) return;
  await repo.publish(spot, photos);
  ref.invalidate(nearbySpotsProvider);
}

/// Owner edit (P2-25); false when the spot is not this device's.
Future<bool> updateSpot(
  WidgetRef ref,
  PublicSpot spot,
  NewSpot edit,
  List<String> keep,
  List<Uint8List> added,
) async {
  final ok = await ref.read(communityRepositoryProvider)?.update(spot, edit, keep, added) ?? false;
  ref.invalidate(nearbySpotsProvider);
  return ok;
}

Future<void> deleteSpot(WidgetRef ref, PublicSpot spot) async {
  await ref.read(communityRepositoryProvider)?.delete(spot);
  ref.invalidate(nearbySpotsProvider);
}

/// False when this device had already reported it.
Future<bool> reportSpot(WidgetRef ref, PublicSpot spot) async =>
    await ref.read(communityRepositoryProvider)?.report(spot) ?? false;

/// Comments of one spot, newest first (P2-25).
final FutureProviderFamily<List<SpotComment>, String> spotCommentsProvider = FutureProvider
    .autoDispose
    .family<List<SpotComment>, String>((ref, spotId) async {
      final repo = ref.watch(communityRepositoryProvider);
      return repo == null ? const [] : await repo.comments(spotId);
    });

Future<void> addComment(WidgetRef ref, String spotId, String body) async {
  final repo = ref.read(communityRepositoryProvider);
  if (repo == null) return;
  final name = await ref.read(displayNameProvider.future);
  await repo.addComment(spotId, body, name);
  ref
    ..invalidate(spotCommentsProvider(spotId))
    ..invalidate(nearbySpotsProvider);
}

Future<bool> editComment(WidgetRef ref, String spotId, String commentId, String body) async {
  final ok = await ref.read(communityRepositoryProvider)?.editComment(commentId, body) ?? false;
  ref.invalidate(spotCommentsProvider(spotId));
  return ok;
}

Future<bool> deleteComment(WidgetRef ref, String spotId, String commentId) async {
  final ok = await ref.read(communityRepositoryProvider)?.deleteComment(commentId) ?? false;
  ref
    ..invalidate(spotCommentsProvider(spotId))
    ..invalidate(nearbySpotsProvider);
  return ok;
}

Future<bool> reportComment(WidgetRef ref, String spotId, String commentId) async {
  final ok = await ref.read(communityRepositoryProvider)?.reportComment(commentId) ?? false;
  ref.invalidate(spotCommentsProvider(spotId));
  return ok;
}
