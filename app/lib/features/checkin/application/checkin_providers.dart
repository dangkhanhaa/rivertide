import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/checkin/data/checkin_repository.dart';
import 'package:rivertide/features/community/community.dart';

final Provider<CheckinRepository?> checkinRepositoryProvider = Provider((ref) {
  final client = ref.watch(socialClientProvider);
  return client == null ? null : CheckinRepository(client, () => deviceSecret(ref));
});

/// Who is fishing changes quickly: refetch after a minute.
const Duration _ttl = Duration(minutes: 1);

/// People fishing around an area key (see `nearbyKey`), busiest cell first.
final FutureProviderFamily<List<CheckinCell>, String> nearbyCheckinsProvider = FutureProvider
    .autoDispose
    .family<List<CheckinCell>, String>((ref, key) async {
      final repo = ref.watch(checkinRepositoryProvider);
      if (repo == null) return const [];
      final link = ref.keepAlive();
      final timer = Timer(_ttl, link.close);
      ref.onDispose(timer.cancel);
      final k = parseNearbyKey(key);
      return await repo.nearby(k.lat, k.lon, radiusKm: k.radiusKm);
    });

typedef MyCheckinState = ({DateTime until, bool biting});

const String _key = 'checkin_state';

/// This device's own check-in, remembered on the device so the "Đang câu"
/// pill survives a restart; null when off or expired.
class MyCheckin extends AsyncNotifier<MyCheckinState?> {
  @override
  Future<MyCheckinState?> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_key);
    final parts = raw?.split('|');
    final until = parts == null || parts.length != 2 ? null : DateTime.tryParse(parts[0]);
    if (until == null || !until.isAfter(ref.read(clockProvider)())) return null;
    return (until: until.toUtc(), biting: parts?[1] == '1');
  }

  Future<void> start(double lat, double lon, {required bool biting}) async {
    final repo = ref.read(checkinRepositoryProvider);
    if (repo == null) return;
    final until = await repo.checkIn(lat, lon, biting: biting);
    await _save((until: until, biting: biting));
  }

  Future<void> stop() async {
    await ref.read(checkinRepositoryProvider)?.checkOut();
    await _save(null);
  }

  Future<void> _save(MyCheckinState? s) async {
    state = AsyncData(s);
    await ref
        .read(appDatabaseProvider)
        .writeSetting(_key, s == null ? '' : '${s.until.toIso8601String()}|${s.biting ? 1 : 0}');
    ref.invalidate(nearbyCheckinsProvider);
  }
}

final AsyncNotifierProvider<MyCheckin, MyCheckinState?> myCheckinProvider = AsyncNotifierProvider(
  MyCheckin.new,
);
