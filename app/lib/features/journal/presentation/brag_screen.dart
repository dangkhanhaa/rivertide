import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/capture.dart';
import 'package:rivertide/features/journal/presentation/brag_card.dart';
import 'package:share_plus/share_plus.dart';

/// "Khoe cá" (P2-36): preview the card, choose whether the place shows, share
/// the picture (Zalo, Facebook, Messenger…) with a link to the app.
class BragScreen extends StatefulWidget {
  const BragScreen({required this.entry, super.key});

  final CatchEntry entry;

  @override
  State<BragScreen> createState() => _BragScreenState();
}

class _BragScreenState extends State<BragScreen> {
  /// Off by default: a good spot is often a secret.
  bool _showPlace = false;
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final text = l10n.brag_text(widget.entry.species, Env.webAppUrl);
    final png = await captureWidget(
      context,
      BragCard(entry: widget.entry, showPlace: _showPlace),
      size: bragCardSize,
    );
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: png == null
              ? null
              : [XFile.fromData(png, mimeType: 'image/png', name: 'con-nuoc-ca.png')],
        ),
      );
    } on Exception catch (e) {
      log.info('share sheet unavailable', {'error': '$e'});
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(SnackBar(content: Text(l10n.share_copied)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.brag_title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
        children: [
          Center(
            child: FittedBox(
              child: BragCard(entry: widget.entry, showPlace: _showPlace),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.brag_showPlace, style: context.text.bodyStrong),
            subtitle: Text(l10n.brag_showPlaceHint, style: context.text.caption),
            value: _showPlace,
            onChanged: (v) => setState(() => _showPlace = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: _busy ? null : () => unawaited(_share()),
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(l10n.brag_share),
          ),
        ],
      ),
    );
  }
}
