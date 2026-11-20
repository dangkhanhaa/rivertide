import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// Curated mode (P2-61, Decree 147/2024): new public posts wait for the
/// owner's approval and are shown only to their author until then
/// (supabase/migrations/0008_curated_mode.sql). The list RPCs keep their old
/// shape; this device's pending/rejected items come from `my_pending`.
enum ModKind {
  spot('spot'),
  comment('comment'),
  trip('trip'),
  pond('pond'),
  release('release'),

  /// Keyed by the pond id (one review per device and pond).
  review('review');

  ModKind(this.server);

  final String server;
}

enum ModStatus { pending, rejected, editPending, editRejected }

ModStatus? _status(Object? v) => switch (v) {
  'pending' => ModStatus.pending,
  'rejected' => ModStatus.rejected,
  'edit_pending' => ModStatus.editPending,
  'edit_rejected' => ModStatus.editRejected,
  _ => null,
};

String _key(ModKind kind, String id) => '${kind.server}:$id';

final RegExp _uuid = RegExp(r'^[0-9a-f-]{36}$');

/// This device's items that are not plainly public, by kind and id.
class MyPending {
  const MyPending(this._byKey);

  /// Server rows are untrusted: unknown kinds, ids or statuses are skipped.
  factory MyPending.fromRows(List<Object?> rows) {
    final kinds = {for (final k in ModKind.values) k.server: k};
    final out = <String, ModStatus>{};
    for (final row in rows.take(500)) {
      if (row is! Map<String, Object?>) continue;
      final kind = kinds[row['kind']];
      final id = row['item_id'];
      final status = _status(row['status']);
      if (kind == null || id is! String || !_uuid.hasMatch(id) || status == null) continue;
      out[_key(kind, id)] = status;
    }
    return MyPending(out);
  }

  static const MyPending none = MyPending({});

  final Map<String, ModStatus> _byKey;

  ModStatus? of(ModKind kind, String id) => _byKey[_key(kind, id)];
}

/// Empty without a community backend. A server without 0008 answers with an
/// error: the badges then stay hidden (AsyncError is shown as "no badge").
final FutureProvider<MyPending> myPendingProvider = FutureProvider((ref) async {
  final db = ref.watch(socialClientProvider);
  if (db == null) return MyPending.none;
  return await guardSocial(() async {
    final rows = await db.rpc<List<Object?>>(
      'my_pending',
      params: {'p_secret': await deviceSecret(ref)},
    );
    return MyPending.fromRows(rows);
  });
});

/// "Đang chờ duyệt" / "Không được duyệt" next to the author's own item;
/// nothing when the item is public (or the status is unknown).
class ModBadge extends ConsumerWidget {
  const ModBadge({required this.kind, required this.id, super.key});

  final ModKind kind;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(myPendingProvider).value?.of(kind, id);
    if (status == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final c = context.colors;
    final rejected = status == ModStatus.rejected || status == ModStatus.editRejected;
    final text = switch (status) {
      ModStatus.pending => l10n.mod_pending,
      ModStatus.rejected => l10n.mod_rejected,
      ModStatus.editPending => l10n.mod_editPending,
      ModStatus.editRejected => l10n.mod_editRejected,
    };
    final color = rejected ? c.alarm2 : c.onSurfaceMuted;
    return Semantics(
      label: rejected ? text : '$text. ${l10n.mod_onlyYou}',
      excludeSemantics: true,
      child: Tooltip(
        message: rejected ? text : l10n.mod_onlyYou,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs,
            children: [
              Icon(
                rejected ? Icons.block_rounded : Icons.hourglass_top_rounded,
                size: AppIconSize.sm,
                color: color,
              ),
              Flexible(
                child: Text(text, style: context.text.label.copyWith(color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// After a post or edit that waits for review: tell the author when it shows
/// up, and refresh the badges.
void showSentForReview(ScaffoldMessengerState messenger, WidgetRef ref, String text) {
  ref.invalidate(myPendingProvider);
  messenger.showSnackBar(SnackBar(content: Text(text)));
}
