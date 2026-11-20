import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/social/social_errors.dart';
import 'package:rivertide/core/widgets/confirm_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// "Chặn người này" (P2-57, App Store 1.2 / Google Play UGC): hides every
/// spot, comment, trip, trip message and pond review of one author from this
/// device. The server finds the author from the item (author hashes never
/// reach the app) and filters the lists (supabase/migrations/0006_block_user.sql).
enum BlockKind {
  spot('spot'),
  comment('comment'),
  trip('trip'),
  tripMessage('trip_msg'),

  /// Pond reviews have no id: the pond id plus the review's creation time.
  review('review');

  BlockKind(this.server);

  final String server;
}

class BlockService {
  BlockService(this._db, this._secret);

  final SupabaseClient _db;
  final Future<String> Function() _secret;

  /// False when nothing was blocked (own or missing item).
  Future<bool> block(BlockKind kind, String itemId, {DateTime? createdAtUtc}) =>
      guardSocial(() async {
        return await _db.rpc<bool>(
          'block_author',
          params: {
            'p_kind': kind.server,
            'p_item_id': itemId,
            'p_secret': await _secret(),
            'p_at': createdAtUtc?.toUtc().toIso8601String(),
          },
        );
      });

  /// How many people were unblocked.
  Future<int> unblockAll() => guardSocial(() async {
    return await _db.rpc<int>('unblock_all', params: {'p_secret': await _secret()});
  });
}

/// Null when no community backend is configured.
final Provider<BlockService?> blockServiceProvider = Provider((ref) {
  final db = ref.watch(socialClientProvider);
  return db == null ? null : BlockService(db, () => deviceSecret(ref));
});

/// Asks first, then blocks the author of one item; [onBlocked] reloads the
/// lists that showed it.
Future<void> askBlockAuthor(
  BuildContext context,
  WidgetRef ref, {
  required BlockKind kind,
  required String itemId,
  required VoidCallback onBlocked,
  DateTime? createdAtUtc,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final service = ref.read(blockServiceProvider);
  if (service == null) return;
  final sure = await confirmDialog(
    context,
    title: l10n.block_title,
    body: l10n.block_body,
    ok: l10n.block_action,
  );
  if (!sure) return;
  try {
    final ok = await service.block(kind, itemId, createdAtUtc: createdAtUtc);
    messenger.showSnackBar(SnackBar(content: Text(ok ? l10n.block_done : l10n.block_failed)));
    if (ok) onBlocked();
  } on AppException catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(socialErrorText(l10n, e, fallback: l10n.block_failed))),
    );
  }
}

/// Thêm → Pháp lý → "Bỏ chặn tất cả". Lists reload on their next fetch.
Future<void> unblockEveryone(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final service = ref.read(blockServiceProvider);
  if (service == null) return;
  try {
    final count = await service.unblockAll();
    messenger.showSnackBar(SnackBar(content: Text(l10n.block_unblockDone(count))));
  } on AppException catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(socialErrorText(l10n, e, fallback: l10n.block_failed))),
    );
  }
}
