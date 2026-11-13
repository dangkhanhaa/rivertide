import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared by the community features (spots, comments, trips, check-ins):
/// the Supabase client, this device's secret and the user's display name.
/// No login: the secret proves "this is mine"; the server keeps only its hash.

/// Null when no Supabase project is configured: social features stay hidden.
final Provider<SupabaseClient?> socialClientProvider = Provider(
  (ref) => Env.communityEnabled ? Supabase.instance.client : null,
);

/// Setting key kept from P2-19 so existing spots stay "mine".
const String _secretKey = 'community_secret';
const String _nameKey = 'community_name';
final RegExp _secretShape = RegExp(r'^[0-9a-f]{64}$');

/// This device's secret: created once with a secure RNG, kept in the local
/// settings, never logged.
Future<String> deviceSecret(Ref ref) async {
  final db = ref.read(appDatabaseProvider);
  final stored = await db.readSetting(_secretKey);
  if (stored != null && _secretShape.hasMatch(stored)) return stored;
  final r = Random.secure();
  final fresh = List.generate(32, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  await db.writeSetting(_secretKey, fresh);
  return fresh;
}

/// Longest display name the server keeps.
const int displayNameMax = 30;

/// The name shown on comments, trips and chat ("" = anonymous).
class DisplayName extends AsyncNotifier<String> {
  @override
  Future<String> build() async => await ref.watch(appDatabaseProvider).readSetting(_nameKey) ?? '';

  Future<void> save(String name) async {
    final clean = name.trim();
    final v = clean.length > displayNameMax ? clean.substring(0, displayNameMax) : clean;
    state = AsyncData(v);
    await ref.read(appDatabaseProvider).writeSetting(_nameKey, v);
  }
}

final AsyncNotifierProvider<DisplayName, String> displayNameProvider = AsyncNotifierProvider(
  DisplayName.new,
);

/// Supabase errors → AppException (docs/rules/01 §5); no user data in messages.
/// The server's spam limits (hint `rate_limit`) become [RateLimitedException].
Future<T> guardSocial<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on PostgrestException catch (e) {
    if (e.hint == 'rate_limit') throw RateLimitedException('social ${e.message}');
    if (e.hint == 'duplicate') {
      final id = e.details;
      throw DuplicateException('social duplicate', existingId: id is String ? id : null);
    }
    throw ServerException('postgrest ${e.code}', code: e.code);
  } on StorageException catch (e) {
    throw ServerException('storage ${e.statusCode}', code: e.statusCode);
  } on Exception catch (e) {
    throw NetworkException('social: ${e.runtimeType}');
  }
}

/// Server rows are untrusted: a string field cut to [max] chars, '' otherwise.
String rowText(Object? v, int max) => v is String ? (v.length > max ? v.substring(0, max) : v) : '';

/// A timestamp field as UTC, or null when missing/malformed.
DateTime? rowTime(Object? v) => v is String ? DateTime.tryParse(v)?.toUtc() : null;
