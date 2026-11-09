import 'dart:async';

import 'package:rivertide/core/cache/cached.dart';
import 'package:rivertide/core/calc/river/river_curve.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/calc/tide/observation.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/config/cache_ttl.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/features/stations/data/cached_fetcher.dart';
import 'package:rivertide/features/stations/data/kttv_parser.dart';
import 'package:rivertide/features/stations/data/open_meteo_parser.dart';
import 'package:rivertide/features/stations/data/remote_sources.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

const _bulletinAsset = 'assets/data/kttv_tvhn.json';

/// A bulletin older than this is flagged stale (one is issued every day).
const Duration kttvStaleAfter = Duration(hours: 30);

/// Observations before the newest one that feed the fit (backtest window).
const Duration riverFitWindow = Duration(hours: 48);

/// Measured in tools/nchmf/river_backtest.py (real-time mode, 6-hourly points).
const Map<String, double> riverBacktestMaeCm = {'HàNội': 11.7, 'NamĐàn': 11.4};

/// KTTV river stations: bulletin points → hourly curve (core/calc/river).
class RiverTideSource {
  RiverTideSource({
    required this._remote,
    required this._fetcher,
    required this._loadAsset,
    required this._clock,
  });

  final RemoteSources _remote;
  final CachedFetcher _fetcher;
  final AssetLoader _loadAsset;
  final Clock _clock;

  /// One load shared by every river station on screen (38 markers ask at once).
  Future<Cached<KttvBulletin>>? _inFlight;
  DateTime? _loadedAt;

  /// Published bulletin when reachable, else the copy bundled with the app;
  /// whichever was issued later wins.
  Future<Cached<KttvBulletin>> bulletin({bool forceRefresh = false}) {
    final loadedAt = _loadedAt;
    final fresh = loadedAt != null && _clock().difference(loadedAt) < const Duration(minutes: 5);
    if (!forceRefresh && fresh) {
      if (_inFlight case final f?) return f;
    }
    _loadedAt = _clock();
    final f = _loadBulletin(forceRefresh);
    _inFlight = f;
    // A failed load must not be reused; callers still see the error via [f].
    unawaited(f.then<void>((_) {}, onError: (_) => _loadedAt = null));
    return f;
  }

  Future<Cached<KttvBulletin>> _loadBulletin(bool forceRefresh) async {
    Cached<KttvBulletin>? remote;
    try {
      final c = await _fetcher.get(
        'kttv:tvhn',
        CacheTtl.kttv,
        _remote.fetchKttv,
        forceRefresh: forceRefresh,
      );
      remote = Cached(
        data: parseKttvBulletin(c.data),
        fetchedAtUtc: c.fetchedAtUtc,
        isStale: c.isStale,
      );
    } on AppException catch (e) {
      log.warn('kttv remote unavailable, using bundled copy', {'error': e.debugMessage});
    }
    final body = await _loadAsset(_bulletinAsset);
    final bundled = body == null ? null : parseKttvBulletin(body);
    final best = switch ((remote, bundled)) {
      (final r?, final b?) when b.issuedUtc.isAfter(r.data.issuedUtc) => b,
      (final r?, _) => r.data,
      (null, final b?) => b,
      (null, null) => throw const OfflineNoCacheException('kttv'),
    };
    final stale = _clock().difference(best.issuedUtc) > kttvStaleAfter;
    return Cached(data: best, fetchedAtUtc: best.issuedUtc, isStale: stale);
  }

  Future<Cached<StationTide>> tide(Station station, {bool forceRefresh = false}) async {
    final b = await bulletin(forceRefresh: forceRefresh);
    final key = station.kttvKey;
    if (key == null) throw ParseException('station ${station.id} has no kttv_key');
    if (station.kind == StationKind.riverDaily) {
      return Cached(
        data: StationTide(
          station: station,
          observations: const [],
          predictionKind: LevelDataKind.forecast,
          dailyExtremes: b.data.daily[key],
          model: _model(station, fitted: false),
        ),
        fetchedAtUtc: b.fetchedAtUtc,
        isStale: b.isStale,
      );
    }
    final all = b.data.series[key];
    if (all == null || all.isEmpty) throw NotFoundException('kttv $key');
    final points = _fitWindow(all);
    final sea = station.tidal ? await _sea(station, forceRefresh) : null;
    final built = buildRiverSeries(points: points, tidal: station.tidal, sea: sea);
    return Cached(
      data: StationTide(
        station: station,
        observations: [
          for (final p in all)
            if (p.observed) WaterObservation(timeUtc: p.timeUtc, levelCm: p.levelCm),
        ],
        prediction: built?.series,
        predictionKind: LevelDataKind.estimate,
        model: _model(station, fitted: built?.fit != null),
        correctWithObservations: false,
      ),
      fetchedAtUtc: b.fetchedAtUtc,
      isStale: b.isStale,
    );
  }

  List<RiverPoint> _fitWindow(List<RiverPoint> all) {
    final lastObs = all.lastWhere((p) => p.observed, orElse: () => all.first).timeUtc;
    final from = lastObs.subtract(riverFitWindow);
    return [
      for (final p in all)
        if (!p.timeUtc.isBefore(from)) p,
    ];
  }

  /// Sea tide at the river mouth; a failure only downgrades to plain interpolation.
  Future<HourlySignal?> _sea(Station station, bool forceRefresh) async {
    final (lat, lon) = (station.seaRefLat, station.seaRefLon);
    if (lat == null || lon == null) return null;
    try {
      final c = await _fetcher.get(
        'marine:ref:$lat,$lon',
        CacheTtl.marine,
        () => _remote.fetchMarine(lat, lon),
        forceRefresh: forceRefresh,
      );
      final hourly = parseMarineSeaLevel(c.data);
      if (hourly.isEmpty) return null;
      return HourlySignal(startUtc: hourly.first.$1, values: [for (final h in hourly) h.$2]);
    } on AppException catch (e) {
      log.warn('sea reference unavailable', {'station': station.id, 'error': e.debugMessage});
      return null;
    }
  }

  TideModelInfo _model(Station station, {required bool fitted}) {
    final mae = riverBacktestMaeCm[station.kttvKey];
    return TideModelInfo(
      sourceName: fitted ? 'KTTV + triều Open-Meteo' : 'KTTV',
      confidence: mae != null && fitted ? TideConfidence.medium : TideConfidence.low,
      rmseCm: fitted ? mae : null,
    );
  }
}
