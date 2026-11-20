import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/legal/legal.dart';

part 'terms_provider.g.dart';

const String _versionKey = 'terms_version';
const String _atKey = 'terms_accepted_at';

/// Whether this device accepted the current terms ([termsVersion]) (P2-57).
/// Stored locally only: the version and the UTC time of acceptance.
@Riverpod(keepAlive: true)
class TermsAcceptance extends _$TermsAcceptance {
  @override
  Future<bool> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_versionKey);
    return (int.tryParse(raw ?? '') ?? 0) >= termsVersion;
  }

  Future<void> accept() async {
    final db = ref.read(appDatabaseProvider);
    final now = ref.read(clockProvider)();
    await db.writeSetting(_atKey, now.toUtc().toIso8601String());
    await db.writeSetting(_versionKey, '$termsVersion');
    state = const AsyncData(true);
  }
}
