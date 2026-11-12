import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/calc/fishing/catch_patterns.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/calc/geo/haversine.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/geo/admin_provider.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/community/community.dart';
import 'package:rivertide/features/journal/journal.dart';
import 'package:rivertide/features/stations/stations.dart';

/// "Hôm nay đi đâu?" (P2-21): places near the user ranked by their best
/// fishing window in the next 24 hours.

enum WhereKind { here, station, saved, community }

/// At most this many places are scored (each costs a weather request).
const int whereMaxPlaces = 8;

/// Two candidates closer than this are the same spot (the better kind wins).
const double _sameSpotKm = 0.3;

/// The ranking looks this far ahead from the current hour.
const Duration whereLookahead = Duration(hours: 24);

const List<int> whereRadiiKm = [10, 30, 50];

class WhereCandidate {
  const WhereCandidate({
    required this.id,
    required this.name,
    required this.kind,
    required this.lat,
    required this.lon,
    required this.km,
  });

  /// Station id or map-point id: what the fishing score is computed for.
  final String id;

  /// Empty for [WhereKind.here] and unnamed points (the UI names them).
  final String name;
  final WhereKind kind;
  final double lat;
  final double lon;
  final double km;
}

typedef WhereQuery = ({double lat, double lon, int radiusKm});

/// Nearby stations, saved places and community spots, plus where the user
/// stands, nearest first, duplicates merged, capped at [whereMaxPlaces].
final FutureProviderFamily<List<WhereCandidate>, WhereQuery> whereCandidatesProvider =
    FutureProvider.autoDispose.family<List<WhereCandidate>, WhereQuery>((ref, q) async {
      final stations = await ref.watch(stationListProvider.future);
      final saved = await ref.watch(favoritesProvider.future);
      final spots = await _spots(ref, q);
      final admin = ref.watch(adminIndexProvider).value;
      double km(double lat, double lon) => haversineKm(q.lat, q.lon, lat, lon);
      String placeName(double lat, double lon) => admin?.lookup(lat, lon).commune ?? '';
      final found = <WhereCandidate>[
        for (final s in stations)
          if (km(s.lat, s.lon) <= q.radiusKm)
            WhereCandidate(
              id: s.id,
              name: s.name,
              kind: WhereKind.station,
              lat: s.lat,
              lon: s.lon,
              km: km(s.lat, s.lon),
            ),
        for (final f in saved)
          if (_where(f.stationId, stations) case final p? when km(p.lat, p.lon) <= q.radiusKm)
            WhereCandidate(
              id: f.stationId,
              name: f.label ?? p.name ?? placeName(p.lat, p.lon),
              kind: WhereKind.saved,
              lat: p.lat,
              lon: p.lon,
              km: km(p.lat, p.lon),
            ),
        for (final s in spots)
          if (km(s.lat, s.lon) <= q.radiusKm)
            WhereCandidate(
              id: PointId.encode(s.lat, s.lon),
              name: s.title,
              kind: WhereKind.community,
              lat: s.lat,
              lon: s.lon,
              km: km(s.lat, s.lon),
            ),
      ];
      return _pick(q, found, placeName(q.lat, q.lon));
    });

({double lat, double lon, String? name})? _where(String id, List<Station> stations) {
  if (stations.firstWhereOrNull((s) => s.id == id) case final s?) {
    return (lat: s.lat, lon: s.lon, name: s.name);
  }
  final p = PointId.decode(id);
  return p == null ? null : (lat: p.lat, lon: p.lon, name: null);
}

Future<List<PublicSpot>> _spots(Ref ref, WhereQuery q) async {
  if (!Env.communityEnabled) return const [];
  try {
    return await ref.watch(
      nearbySpotsProvider(nearbyKey(q.lat, q.lon, radiusKm: q.radiusKm.toDouble())).future,
    );
  } on AppException catch (e) {
    // Offline or server down: rank the other places anyway.
    log.info('where: community spots skipped', {'error': e.debugMessage});
    return const [];
  }
}

List<WhereCandidate> _pick(WhereQuery q, List<WhereCandidate> found, String hereName) {
  final here = WhereCandidate(
    id: PointId.encode(q.lat, q.lon),
    name: hereName,
    kind: WhereKind.here,
    lat: q.lat,
    lon: q.lon,
    km: 0,
  );
  // Stations first (measured data), then the user's own places, then shared.
  final byPriority = [...found]
    ..sort((a, b) {
      final k = a.kind.index.compareTo(b.kind.index);
      return k != 0 ? k : a.km.compareTo(b.km);
    });
  final kept = <WhereCandidate>[];
  for (final c in byPriority) {
    final dup = kept.any((k) => haversineKm(k.lat, k.lon, c.lat, c.lon) < _sameSpotKm);
    if (!dup) kept.add(c);
  }
  kept.sortBy<num>((c) => c.km);
  final nearHere = kept.any((k) => k.km < _sameSpotKm);
  return [if (!nearHere) here, ...kept].take(whereMaxPlaces).toList();
}

/// Best moment at one place in the next [whereLookahead].
class WhereScore {
  const WhereScore({
    required this.score,
    required this.fromUtc,
    required this.toUtc,
    required this.golden,
    required this.unsafe,
    required this.likeYours,
  });

  /// Peak score of the best window (or of the best single hour).
  final double score;
  final DateTime fromUtc;
  final DateTime toUtc;

  /// True for a golden window (≥ 7), false for "the best hour there is".
  final bool golden;

  /// A weather warning falls inside that window.
  final bool unsafe;

  /// That moment matches the user's own catch patterns (P2-23).
  final bool likeYours;
}

final FutureProviderFamily<WhereScore?, String> whereScoreProvider = FutureProvider.autoDispose
    .family<WhereScore?, String>((ref, id) async {
      final fishing = await ref.watch(stationFishingProvider(id).future);
      final now = ref.watch(clockProvider)();
      final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
      final ahead = [
        for (final h in fishing.hours)
          if (!h.hourUtc.isBefore(hour) && h.hourUtc.isBefore(hour.add(whereLookahead))) h,
      ];
      final best = bestMoment(ahead);
      if (best == null) return null;
      final report = await ref.watch(catchPatternsProvider.future);
      var likeYours = false;
      if (report.patterns.length >= 2) {
        final tide = (await ref.watch(stationTideProvider(id).future)).data;
        likeYours = looksLikeYourCatches(
          report,
          placeConditionsAt(tide, fishing.weather, best.fromUtc),
        );
      }
      return WhereScore(
        score: best.score,
        fromUtc: best.fromUtc,
        toUtc: best.toUtc,
        golden: best.golden,
        unsafe: best.unsafe,
        likeYours: likeYours,
      );
    });

typedef Moment = ({double score, DateTime fromUtc, DateTime toUtc, bool golden, bool unsafe});

/// Best safe golden window; else the best golden window (flagged unsafe);
/// else the best safe hour; null without scores.
Moment? bestMoment(List<FishingHourScore> hours) {
  if (hours.isEmpty) return null;
  bool unsafeIn(DateTime from, DateTime to) => hours.any(
    (h) => h.safety != SafetyLevel.none && !h.hourUtc.isBefore(from) && h.hourUtc.isBefore(to),
  );
  final windows = goldenWindows(hours);
  final safe = windows.where((w) => !unsafeIn(w.startUtc, w.endUtc));
  final w = maxBy(safe, (w) => w.peakScore) ?? maxBy(windows, (w) => w.peakScore);
  if (w != null) {
    return (
      score: w.peakScore,
      fromUtc: w.startUtc,
      toUtc: w.endUtc,
      golden: true,
      unsafe: unsafeIn(w.startUtc, w.endUtc),
    );
  }
  final safeHours = hours.where((h) => h.safety == SafetyLevel.none);
  final h = maxBy(safeHours.isEmpty ? hours : safeHours, (h) => h.score);
  if (h == null) return null;
  final end = h.hourUtc.add(const Duration(hours: 1));
  return (
    score: h.score,
    fromUtc: h.hourUtc,
    toUtc: end,
    golden: false,
    unsafe: h.safety != SafetyLevel.none,
  );
}
