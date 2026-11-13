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
import 'package:rivertide/features/ponds/application/ponds_providers.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';

/// Stars + short text, one review per device (editable), newest first.
class PondReviews extends ConsumerStatefulWidget {
  const PondReviews({required this.pondId, super.key});

  final String pondId;

  @override
  ConsumerState<PondReviews> createState() => _PondReviewsState();
}

class _PondReviewsState extends ConsumerState<PondReviews> {
  final _text = TextEditingController();
  int _stars = 0;
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_stars == 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pond_noStars)));
      return;
    }
    setState(() => _sending = true);
    try {
      await reviewPond(ref, widget.pondId, _stars, _text.text.trim());
      _text.clear();
      setState(() => _stars = 0);
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pond_error)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reviews = ref.watch(pondReviewsProvider(widget.pondId));
    final name = ref.watch(displayNameProvider).value ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Text(l10n.pond_reviews, style: context.text.title),
        _StarPicker(value: _stars, onChanged: (v) => setState(() => _stars = v)),
        TextField(
          controller: _text,
          maxLength: 300,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.pond_reviewHint, counterText: ''),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => unawaited(editDisplayName(context, ref)),
                icon: const Icon(Icons.badge_outlined, size: AppIconSize.sm),
                label: Text(name.isEmpty ? l10n.cmt_asAnon : l10n.cmt_asName(name)),
              ),
            ),
            FilledButton(
              onPressed: _sending ? null : () => unawaited(_send()),
              child: Text(l10n.pond_reviewSend),
            ),
          ],
        ),
        switch (reviews) {
          AsyncData(:final value) when value.isEmpty => Text(
            l10n.pond_reviewEmpty,
            style: context.text.caption,
          ),
          AsyncData(:final value) => Column(
            children: [for (final r in value) _ReviewTile(pondId: widget.pondId, review: r)],
          ),
          AsyncError() => Text(l10n.pond_loadError, style: context.text.caption),
          _ => const LinearProgressIndicator(),
        },
      ],
    );
  }
}

class _StarPicker extends StatelessWidget {
  const _StarPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 1; i <= 5; i++)
        IconButton(
          tooltip: '$i ★',
          onPressed: () => onChanged(i),
          icon: Icon(
            i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
            color: context.colors.alarm1,
          ),
        ),
    ],
  );
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile({required this.pondId, required this.review});

  final String pondId;
  final PondReview review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = review;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        '${'★' * r.rating}${'☆' * (5 - r.rating)}  ${r.authorName.isEmpty ? l10n.cmt_anon : r.authorName}',
        style: context.text.bodyStrong,
      ),
      subtitle: Text(
        [if (r.body.isNotEmpty) r.body, TimeFormat.dayShort(r.at)].join('\n'),
        style: context.text.body,
      ),
      trailing: r.mine
          ? IconButton(
              tooltip: l10n.pond_deleteReview,
              onPressed: () => unawaited(deleteReview(ref, pondId)),
              icon: const Icon(Icons.delete_outline_rounded),
            )
          : null,
    );
  }
}
