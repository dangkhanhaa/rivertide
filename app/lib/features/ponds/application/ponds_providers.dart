import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/calc/ponds/release_parse.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/community/community.dart';
import 'package:rivertide/features/ponds/data/ponds_repository.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';

final Provider<PondsRepository?> pondsRepositoryProvider = Provider((ref) {
  final client = ref.watch(socialClientProvider);
  return client == null ? null : PondsRepository(client, () => deviceSecret(ref));
});

/// Ponds tab and map look this far around the user / map centre.
const double pondsRadiusKm = 40;

String pondsAreaKey(double lat, double lon) => nearbyKey(lat, lon, radiusKm: pondsRadiusKm);

const Duration _ttl = Duration(minutes: 3);

/// Ponds around an area key (see [pondsAreaKey]), nearest first.
final FutureProviderFamily<List<Pond>, String> nearbyPondsProvider = FutureProvider.autoDispose
    .family<List<Pond>, String>((ref, key) async {
      final repo = ref.watch(pondsRepositoryProvider);
      if (repo == null) return const [];
      final link = ref.keepAlive();
      final timer = Timer(_ttl, link.close);
      ref.onDispose(timer.cancel);
      final k = parseNearbyKey(key);
      return await repo.nearby(k.lat, k.lon, radiusKm: k.radiusKm);
    });

final FutureProviderFamily<List<PondRelease>, String> pondReleasesProvider = FutureProvider
    .autoDispose
    .family<List<PondRelease>, String>((ref, id) async {
      final repo = ref.watch(pondsRepositoryProvider);
      return repo == null ? const [] : await repo.releases([id]);
    });

final FutureProviderFamily<List<PondReview>, String> pondReviewsProvider = FutureProvider
    .autoDispose
    .family<List<PondReview>, String>((ref, id) async {
      final repo = ref.watch(pondsRepositoryProvider);
      return repo == null ? const [] : await repo.reviews(id);
    });

final FutureProviderFamily<PondPulse, String> pondPulseProvider = FutureProvider.autoDispose
    .family<PondPulse, String>((ref, id) async {
      final repo = ref.watch(pondsRepositoryProvider);
      return repo == null ? const {} : await repo.pulse(id);
    });

const String _followKey = 'pond_follows';

/// Ponds the user follows (kept on the device): their releases are shown first
/// and, in the Android app, ring a reminder.
class FollowedPonds extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_followKey);
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw);
      return list is List ? list.whereType<String>().take(50).toSet() : {};
    } on FormatException {
      return {};
    }
  }

  /// [name] is remembered so release alarms can say which pond (P2-39).
  Future<void> toggle(String id, {String? name}) async {
    final next = {...state.value ?? const <String>{}};
    if (!next.remove(id)) next.add(id);
    state = AsyncData(next);
    final db = ref.read(appDatabaseProvider);
    await db.writeSetting(_followKey, jsonEncode(next.toList()));
    final names = await followedPondNames(db);
    names.removeWhere((k, _) => !next.contains(k));
    if (name != null && next.contains(id)) {
      names[id] = name.length > 80 ? name.substring(0, 80) : name;
    }
    await db.writeSetting(_namesKey, jsonEncode(names));
  }
}

const String _namesKey = 'pond_follow_names';

/// Names of followed ponds (id → name), as saved when following.
Future<Map<String, String>> followedPondNames(AppDatabase db) async {
  final raw = await db.readSetting(_namesKey);
  if (raw == null || raw.length > 20000) return {};
  try {
    final m = jsonDecode(raw);
    if (m is! Map<String, Object?>) return {};
    return {
      for (final e in m.entries)
        if (e.value case final String v) e.key: v,
    };
  } on FormatException {
    return {};
  }
}

/// Releases of followed ponds in the next 7 days with the pond's name, for
/// the Android release alarms (P2-39). Empty without the backend.
Future<List<(PondRelease, String?)>> upcomingFollowedReleases(
  WidgetRef ref,
  DateTime nowUtc,
) async {
  final repo = ref.read(pondsRepositoryProvider);
  final ids = await ref.read(followedPondsProvider.future);
  if (repo == null || ids.isEmpty) return const [];
  final names = await followedPondNames(ref.read(appDatabaseProvider));
  final all = await repo.releases(ids.toList());
  final until = nowUtc.add(const Duration(days: 7));
  return [
    for (final r in all)
      if (!r.cancelled && r.startsAt.isAfter(nowUtc) && r.startsAt.isBefore(until))
        (r, names[r.pondId]),
  ];
}

final AsyncNotifierProvider<FollowedPonds, Set<String>> followedPondsProvider =
    AsyncNotifierProvider(FollowedPonds.new);

/// Upcoming releases of followed ponds (for the tab header and reminders).
final FutureProvider<List<PondRelease>> followedReleasesProvider = FutureProvider.autoDispose((
  ref,
) async {
  final repo = ref.watch(pondsRepositoryProvider);
  final ids = await ref.watch(followedPondsProvider.future);
  if (repo == null || ids.isEmpty) return const [];
  return await repo.releases(ids.toList());
});

PondsRepository _repo(WidgetRef ref) {
  final repo = ref.read(pondsRepositoryProvider);
  // The UI offers ponds only when the backend is configured.
  if (repo == null) throw StateError('ponds backend not configured');
  return repo;
}

void _refreshPond(WidgetRef ref, String id) => ref
  ..invalidate(nearbyPondsProvider)
  ..invalidate(pondReleasesProvider(id))
  ..invalidate(followedReleasesProvider);

Future<String> addPond(WidgetRef ref, PondDraft d, List<Uint8List> photos) async {
  final id = await _repo(ref).add(d, photos);
  ref.invalidate(nearbyPondsProvider);
  return id;
}

Future<bool> updatePond(
  WidgetRef ref,
  Pond p,
  PondDraft d,
  List<String> keep,
  List<Uint8List> added,
) async {
  final ok = await _repo(ref).update(p, d, keep, added);
  ref.invalidate(nearbyPondsProvider);
  return ok;
}

Future<bool> confirmPond(WidgetRef ref, String id) async {
  final ok = await _repo(ref).confirm(id);
  ref.invalidate(nearbyPondsProvider);
  return ok;
}

Future<bool> reportPond(WidgetRef ref, String id) => _repo(ref).report(id);

Future<void> postRelease(
  WidgetRef ref,
  String pondId,
  DateTime startUtc,
  List<ReleaseFish> fish,
  String source,
) async {
  await _repo(ref).postRelease(pondId, startUtc, fish, source);
  _refreshPond(ref, pondId);
}

Future<bool> cancelRelease(WidgetRef ref, PondRelease r) async {
  final ok = await _repo(ref).cancelRelease(r.id);
  _refreshPond(ref, r.pondId);
  return ok;
}

Future<bool> reportRelease(WidgetRef ref, PondRelease r) async {
  final ok = await _repo(ref).reportRelease(r.id);
  _refreshPond(ref, r.pondId);
  return ok;
}

Future<void> reviewPond(WidgetRef ref, String id, int rating, String body) async {
  await _repo(ref).review(id, rating, body, await ref.read(displayNameProvider.future));
  ref
    ..invalidate(pondReviewsProvider(id))
    ..invalidate(nearbyPondsProvider);
}

Future<void> deleteReview(WidgetRef ref, String id) async {
  await _repo(ref).deleteReview(id);
  ref
    ..invalidate(pondReviewsProvider(id))
    ..invalidate(nearbyPondsProvider);
}

Future<void> sendPulse(WidgetRef ref, String id, PulseKind kind) async {
  await _repo(ref).sendPulse(id, kind);
  ref.invalidate(pondPulseProvider(id));
}

Future<ClaimResult> claimPond(WidgetRef ref, String id, String contact, String note) =>
    _repo(ref).claim(id, contact, note);
