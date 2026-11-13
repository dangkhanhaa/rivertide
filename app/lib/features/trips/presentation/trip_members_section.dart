import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/trips/application/trips_providers.dart';
import 'package:rivertide/features/trips/domain/trip.dart';
import 'package:url_launcher/url_launcher.dart';

/// Chat refresh while the trip is open (no push channel: polling, cheap RPC).
const Duration _chatPoll = Duration(seconds: 20);

/// Contact, who is going and the group chat: members only (P2-26).
class TripMembersSection extends ConsumerStatefulWidget {
  const TripMembersSection({required this.tripId, super.key});

  final String tripId;

  @override
  ConsumerState<TripMembersSection> createState() => _TripMembersSectionState();
}

class _TripMembersSectionState extends ConsumerState<TripMembersSection> {
  final _input = TextEditingController();
  Timer? _poll;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(_chatPoll, (_) {
      if (mounted) ref.invalidate(tripMessagesProvider(widget.tripId));
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await postTripMessage(ref, widget.tripId, body);
      _input.clear();
    } on AppException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e is RateLimitedException ? l10n.cmt_tooFast : l10n.trip_error)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final private = ref.watch(tripPrivateProvider(widget.tripId)).value;
    final messages = ref.watch(tripMessagesProvider(widget.tripId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        if (private != null) ...[
          if (private.contact.isNotEmpty) _Contact(contact: private.contact),
          Text(l10n.trip_memberList, style: context.text.label),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final n in private.memberNames)
                Chip(
                  avatar: const Icon(Icons.person_rounded, size: AppIconSize.sm),
                  label: Text(n.isEmpty ? l10n.cmt_anon : n),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
        Row(
          children: [
            Expanded(child: Text(l10n.trip_chat, style: context.text.title)),
            IconButton(
              tooltip: l10n.trip_refresh,
              onPressed: () => ref.invalidate(tripMessagesProvider(widget.tripId)),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        switch (messages) {
          AsyncData(:final value) when value.isEmpty => Text(
            l10n.trip_chatEmpty,
            style: context.text.caption,
          ),
          AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.xs,
            children: [for (final m in value) _Bubble(message: m)],
          ),
          AsyncError() => Text(l10n.trip_loadError, style: context.text.caption),
          _ => const Center(child: CircularProgressIndicator()),
        },
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                maxLength: 300,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(hintText: l10n.trip_chatHint, counterText: ''),
              ),
            ),
            IconButton.filled(
              tooltip: l10n.trip_send,
              onPressed: _sending ? null : () => unawaited(_send()),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _Contact extends StatelessWidget {
  const _Contact({required this.contact});

  final String contact;

  /// https links open as they are; phone-like text dials.
  Uri? get _uri {
    final t = contact.trim();
    if (t.startsWith('https://')) return Uri.tryParse(t);
    final digits = t.replaceAll(RegExp(r'[\s.\-()]'), '');
    return RegExp(r'^\+?\d{8,15}$').hasMatch(digits) ? Uri(scheme: 'tel', path: digits) : null;
  }

  @override
  Widget build(BuildContext context) {
    final uri = _uri;
    return Card(
      color: context.colors.trip.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(Icons.contact_phone_rounded, color: context.colors.trip),
        title: Text(context.l10n.trip_contactLabel, style: context.text.label),
        subtitle: SelectableText(contact, style: context.text.bodyStrong),
        trailing: uri == null
            ? null
            : TextButton(
                onPressed: () => unawaited(launchUrl(uri, mode: LaunchMode.externalApplication)),
                child: Text(context.l10n.trip_openContact),
              ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final TripMessage message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final m = message;
    final name = m.authorName.isEmpty ? context.l10n.cmt_anon : m.authorName;
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: m.mine ? c.primary.withValues(alpha: 0.15) : c.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!m.mine) Text(name, style: context.text.label.copyWith(color: c.trip)),
              Text(m.body, style: context.text.body),
              Text(TimeFormat.hm(m.createdAt), style: context.text.caption),
            ],
          ),
        ),
      ),
    );
  }
}
