import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/display_name_dialog.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/confirm_dialog.dart';
import 'package:rivertide/features/community/application/community_providers.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';

/// Comments under a community spot (P2-25): anyone writes; only the author
/// edits or deletes; everyone else can only report.
class SpotComments extends ConsumerStatefulWidget {
  const SpotComments({required this.spotId, super.key});

  final String spotId;

  @override
  ConsumerState<SpotComments> createState() => _SpotCommentsState();
}

class _SpotCommentsState extends ConsumerState<SpotComments> {
  final _input = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _sending = true);
    try {
      await addComment(ref, widget.spotId, body);
      _input.clear();
    } on AppException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e is RateLimitedException ? l10n.cmt_tooFast : l10n.cmt_error)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final comments = ref.watch(spotCommentsProvider(widget.spotId));
    final count = comments.value?.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Text(count == null ? l10n.cmt_title : l10n.cmt_count(count), style: context.text.title),
        _Composer(controller: _input, sending: _sending, onSend: () => unawaited(_send())),
        switch (comments) {
          AsyncData(:final value) when value.isEmpty => Text(
            l10n.cmt_empty,
            style: context.text.caption,
          ),
          AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final c in value) _CommentTile(spotId: widget.spotId, comment: c)],
          ),
          AsyncError() => Row(
            children: [
              Expanded(child: Text(l10n.cmt_loadError, style: context.text.caption)),
              TextButton(
                onPressed: () => ref.invalidate(spotCommentsProvider(widget.spotId)),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}

class _Composer extends ConsumerWidget {
  const _Composer({required this.controller, required this.sending, required this.onSend});

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = ref.watch(displayNameProvider).value ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLength: 300,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(hintText: l10n.cmt_hint, counterText: ''),
              ),
            ),
            IconButton.filled(
              tooltip: l10n.cmt_send,
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox.square(
                      dimension: AppIconSize.sm,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => unawaited(editDisplayName(context, ref)),
          icon: const Icon(Icons.badge_outlined, size: AppIconSize.sm),
          label: Text(name.isEmpty ? l10n.cmt_asAnon : l10n.cmt_asName(name)),
        ),
      ],
    );
  }
}

enum _Action { edit, delete, report }

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.spotId, required this.comment});

  final String spotId;
  final SpotComment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final cm = comment;
    final name = cm.authorName.isEmpty ? l10n.cmt_anon : cm.authorName;
    final when = '${TimeFormat.dayShort(cm.createdAt)} ${TimeFormat.hm(cm.createdAt)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: AppIconSize.md / 2 + AppSpacing.xs,
            backgroundColor: (cm.mine ? c.primary : c.spot).withValues(alpha: 0.15),
            child: Text(
              name.characters.first.toUpperCase(),
              style: context.text.bodyStrong.copyWith(color: cm.mine ? c.primary : c.spot),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: name, style: context.text.bodyStrong),
                      if (cm.mine)
                        TextSpan(text: ' · ${l10n.cmt_mine}', style: context.text.caption),
                    ],
                  ),
                ),
                Text(cm.body, style: context.text.body),
                Text(
                  cm.updatedAt == null ? when : '$when · ${l10n.cmt_edited}',
                  style: context.text.caption,
                ),
              ],
            ),
          ),
          PopupMenuButton<_Action>(
            tooltip: l10n.cmt_more,
            onSelected: (a) => unawaited(_act(context, ref, a)),
            itemBuilder: (_) => [
              if (cm.mine) ...[
                PopupMenuItem(value: _Action.edit, child: Text(l10n.cmt_edit)),
                PopupMenuItem(value: _Action.delete, child: Text(l10n.cmt_delete)),
              ] else
                PopupMenuItem(value: _Action.report, child: Text(l10n.cmt_report)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _act(BuildContext context, WidgetRef ref, _Action a) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      switch (a) {
        case _Action.edit:
          final text = await _editText(context, comment.body);
          if (text != null && text.trim().isNotEmpty && text.trim() != comment.body) {
            await editComment(ref, spotId, comment.id, text.trim());
          }
        case _Action.delete:
          if (await confirmDialog(context, title: l10n.cmt_deleteTitle, ok: l10n.cmt_delete)) {
            await deleteComment(ref, spotId, comment.id);
          }
        case _Action.report:
          if (await confirmDialog(
            context,
            title: l10n.cmt_reportTitle,
            body: l10n.cmt_reportHint,
            ok: l10n.cmt_report,
          )) {
            final counted = await reportComment(ref, spotId, comment.id);
            messenger.showSnackBar(
              SnackBar(content: Text(counted ? l10n.spot_reportDone : l10n.spot_reportTwice)),
            );
          }
      }
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.cmt_error)));
    }
  }

  static Future<String?> _editText(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    final out = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.cmt_edit),
        content: TextField(controller: controller, autofocus: true, maxLength: 300, maxLines: 5),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(ctx.l10n.common_cancel)),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(ctx.l10n.social_save),
          ),
        ],
      ),
    );
    controller.dispose();
    return out;
  }
}
