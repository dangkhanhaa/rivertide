import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/legal/legal.dart';
import 'package:rivertide/core/social/block_author.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';

/// Thêm → Pháp lý (P2-57): full terms and privacy policy, the disclaimer,
/// where to report abuse, and undoing blocks.
class LegalSection extends ConsumerWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final community = ref.watch(socialClientProvider) != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: l10n.legal_section),
        ActionGroup(
          children: [
            ActionRow(
              icon: Icons.gavel_rounded,
              color: c.primary,
              title: l10n.legal_terms,
              trailing: Icon(Icons.open_in_new_rounded, color: c.stale),
              onTap: () => unawaited(openLegalLink(termsUrl)),
            ),
            ActionRow(
              icon: Icons.privacy_tip_rounded,
              color: c.ok,
              title: l10n.legal_privacy,
              trailing: Icon(Icons.open_in_new_rounded, color: c.stale),
              onTap: () => unawaited(openLegalLink(privacyUrl)),
            ),
            ActionRow(
              icon: Icons.health_and_safety_rounded,
              color: c.alarm2,
              title: l10n.legal_disclaimer,
              onTap: () => unawaited(_showDisclaimer(context)),
            ),
            ActionRow(
              icon: Icons.flag_rounded,
              color: c.alarm3,
              title: l10n.legal_contact,
              subtitle: l10n.legal_contactHint,
              trailing: Icon(Icons.open_in_new_rounded, color: c.stale),
              onTap: () => unawaited(openLegalLink(contactUrl)),
            ),
            if (community)
              ActionRow(
                icon: Icons.person_off_rounded,
                color: c.onSurfaceMuted,
                title: l10n.block_unblockAll,
                subtitle: l10n.block_unblockHint,
                onTap: () => unawaited(unblockEveryone(context, ref)),
              ),
          ],
        ),
      ],
    );
  }

  static Future<void> _showDisclaimer(BuildContext context) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.l10n.legal_disclaimer),
      content: SingleChildScrollView(child: Text(ctx.l10n.legal_disclaimerText)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
        ),
      ],
    ),
  );
}
