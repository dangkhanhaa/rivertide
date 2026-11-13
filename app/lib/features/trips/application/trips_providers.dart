import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/community/community.dart';
import 'package:rivertide/features/trips/data/trips_repository.dart';
import 'package:rivertide/features/trips/domain/trip.dart';

final Provider<TripsRepository?> tripsRepositoryProvider = Provider((ref) {
  final client = ref.watch(socialClientProvider);
  return client == null ? null : TripsRepository(client, () => deviceSecret(ref));
});

/// Area key for trips around a point (same grid as community spots).
String tripAreaKey(double lat, double lon) => nearbyKey(lat, lon);

/// Trips change faster than spots (people join): refetch after a minute.
const Duration _tripsTtl = Duration(minutes: 1);

/// Upcoming and running trips around an area key (see `nearbyKey`), soonest first.
final FutureProviderFamily<List<Trip>, String> nearbyTripsProvider = FutureProvider.autoDispose
    .family<List<Trip>, String>((ref, key) async {
      final repo = ref.watch(tripsRepositoryProvider);
      if (repo == null) return const [];
      final link = ref.keepAlive();
      final timer = Timer(_tripsTtl, link.close);
      ref.onDispose(timer.cancel);
      final k = parseNearbyKey(key);
      return await repo.nearby(k.lat, k.lon, radiusKm: k.radiusKm);
    });

final FutureProviderFamily<TripPrivate?, String> tripPrivateProvider = FutureProvider.autoDispose
    .family<TripPrivate?, String>((ref, id) async {
      final repo = ref.watch(tripsRepositoryProvider);
      return repo == null ? null : await repo.private(id);
    });

final FutureProviderFamily<List<TripMessage>, String> tripMessagesProvider = FutureProvider
    .autoDispose
    .family<List<TripMessage>, String>((ref, id) async {
      final repo = ref.watch(tripsRepositoryProvider);
      return repo == null ? const [] : await repo.messages(id);
    });

void _refresh(WidgetRef ref, String id) => ref
  ..invalidate(nearbyTripsProvider)
  ..invalidate(tripPrivateProvider(id))
  ..invalidate(tripMessagesProvider(id));

TripsRepository _repo(WidgetRef ref) {
  final repo = ref.read(tripsRepositoryProvider);
  // UI only offers trips when the backend is configured.
  if (repo == null) throw StateError('trips backend not configured');
  return repo;
}

Future<String> createTrip(WidgetRef ref, TripDraft d) async {
  final id = await _repo(ref).create(d, await ref.read(displayNameProvider.future));
  _refresh(ref, id);
  return id;
}

Future<bool> updateTrip(WidgetRef ref, String id, TripDraft d) async {
  final ok = await _repo(ref).update(id, d);
  _refresh(ref, id);
  return ok;
}

Future<bool> cancelTrip(WidgetRef ref, String id) async {
  final ok = await _repo(ref).cancel(id);
  _refresh(ref, id);
  return ok;
}

Future<JoinResult> joinTrip(WidgetRef ref, String id) async {
  final r = await _repo(ref).join(id, await ref.read(displayNameProvider.future));
  _refresh(ref, id);
  return r;
}

Future<bool> leaveTrip(WidgetRef ref, String id) async {
  final ok = await _repo(ref).leave(id);
  _refresh(ref, id);
  return ok;
}

Future<bool> reportTrip(WidgetRef ref, String id) async => await _repo(ref).report(id);

Future<void> postTripMessage(WidgetRef ref, String id, String body) async {
  await _repo(ref).post(id, body, await ref.read(displayNameProvider.future));
  ref.invalidate(tripMessagesProvider(id));
}
