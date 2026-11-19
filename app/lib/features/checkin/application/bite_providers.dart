import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/checkin/data/bite_repository.dart';

final Provider<BiteRepository?> biteRepositoryProvider = Provider((ref) {
  final client = ref.watch(socialClientProvider);
  return client == null ? null : BiteRepository(client, () => deviceSecret(ref));
});

/// Area key: position rounded to ~2 km, so nearby spots share one request.
String biteKey(double lat, double lon) => '${(lat * 50).round() / 50},${(lon * 50).round() / 50}';

(double, double) _parse(String key) {
  final p = key.split(',');
  return (double.tryParse(p.first) ?? 0, double.tryParse(p.last) ?? 0);
}

/// Last 3 hours around the area; refreshed every 2 minutes while shown.
final FutureProviderFamily<BiteSummary?, String> biteSummaryProvider = FutureProvider.autoDispose
    .family<BiteSummary?, String>((ref, key) async {
      final repo = ref.watch(biteRepositoryProvider);
      if (repo == null) return null;
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 2), link.close);
      ref.onDispose(timer.cancel);
      final (lat, lon) = _parse(key);
      return await repo.summary(lat, lon);
    });

/// What worked in the area over 60 days, per water state.
final FutureProviderFamily<List<BitePattern>, String> bitePatternsProvider = FutureProvider
    .autoDispose
    .family<List<BitePattern>, String>((ref, key) async {
      final repo = ref.watch(biteRepositoryProvider);
      if (repo == null) return const [];
      final (lat, lon) = _parse(key);
      return await repo.patterns(lat, lon);
    });

const String _lastKey = 'bite_last_report';

/// Don't ask again for this long after answering (matches the server limit).
const Duration biteAskPause = Duration(minutes: 30);

/// When this device last answered "Có dính không?" (stored on the device).
class LastBiteReport extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() async =>
      DateTime.tryParse(await ref.watch(appDatabaseProvider).readSetting(_lastKey) ?? '');

  Future<void> report({
    required double lat,
    required double lon,
    required bool bite,
    String? tideState,
    int? localHour,
    double? appScore,
  }) async {
    final repo = ref.read(biteRepositoryProvider);
    if (repo == null) return;
    await repo.report(
      lat: lat,
      lon: lon,
      bite: bite,
      tideState: tideState,
      localHour: localHour,
      appScore: appScore,
    );
    final now = ref.read(clockProvider)();
    state = AsyncData(now);
    await ref.read(appDatabaseProvider).writeSetting(_lastKey, now.toIso8601String());
    ref
      ..invalidate(biteSummaryProvider(biteKey(lat, lon)))
      ..invalidate(bitePatternsProvider(biteKey(lat, lon)));
  }
}

final AsyncNotifierProvider<LastBiteReport, DateTime?> lastBiteReportProvider =
    AsyncNotifierProvider(LastBiteReport.new);
