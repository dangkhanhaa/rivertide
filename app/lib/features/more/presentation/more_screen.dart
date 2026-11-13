import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/social/display_name_dialog.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/journal/journal.dart';
import 'package:rivertide/features/more/application/outdoor_mode_provider.dart';
import 'package:rivertide/features/more/application/theme_mode_provider.dart';
import 'package:rivertide/features/more/application/update_provider.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:url_launcher/url_launcher.dart';

/// S13: settings only; version and data sources sit behind the ⓘ button.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    final update = ref.watch(updateAvailableProvider).value ?? false;
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.more_title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
        children: [
          const _ProfileHeader(),
          if (update) ...[
            const SizedBox(height: AppSpacing.md),
            ActionGroup(
              children: [
                ActionRow(
                  icon: Icons.system_update_rounded,
                  color: c.primary,
                  title: l10n.more_update,
                ),
              ],
            ),
          ],
          SectionTitle(title: l10n.more_explore),
          ActionGroup(
            children: [
              ActionRow(
                icon: Icons.explore_rounded,
                color: c.fishGood,
                title: l10n.where_title,
                subtitle: l10n.where_entryHint,
                onTap: () => unawaited(context.push(whereRoute)),
              ),
              ActionRow(
                icon: Icons.menu_book_rounded,
                color: c.spot,
                title: l10n.journal_title,
                subtitle: l10n.more_journalHint,
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => const JournalScreen())),
              ),
              ActionRow(
                icon: Icons.water_rounded,
                color: c.water,
                title: l10n.stations_menu,
                subtitle: l10n.stations_menuHint,
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => const StationsScreen())),
              ),
            ],
          ),
          SectionTitle(title: l10n.more_theme),
          ActionGroup(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(value: ThemeMode.system, label: Text(l10n.more_themeSystem)),
                    ButtonSegment(value: ThemeMode.light, label: Text(l10n.more_themeLight)),
                    ButtonSegment(value: ThemeMode.dark, label: Text(l10n.more_themeDark)),
                  ],
                  selected: {mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => ref.read(appThemeModeProvider.notifier).set(s.first),
                ),
              ),
              ActionRow(
                icon: Icons.wb_sunny_rounded,
                color: c.alarm1,
                title: l10n.more_outdoor,
                subtitle: l10n.more_outdoorHint,
                trailing: Switch(
                  value: ref.watch(outdoorModeProvider).value ?? false,
                  onChanged: (v) => ref.read(outdoorModeProvider.notifier).set(on: v),
                ),
              ),
            ],
          ),
          SectionTitle(title: l10n.more_app),
          ActionGroup(
            children: [
              if (kIsWeb) ...[
                ActionRow(
                  icon: Icons.install_mobile_rounded,
                  color: c.primary,
                  title: l10n.more_install,
                  subtitle: l10n.more_installHow,
                ),
                ActionRow(
                  icon: Icons.android_rounded,
                  color: c.fishGood,
                  title: l10n.more_apk,
                  subtitle: l10n.more_apkHint,
                  trailing: const Icon(Icons.download_rounded),
                  onTap: () => unawaited(launchUrl(Uri.parse(Env.apkUrl))),
                ),
              ],
              ActionRow(
                icon: Icons.info_outline_rounded,
                color: c.onSurfaceMuted,
                title: l10n.more_info,
                subtitle: l10n.more_version(Env.version),
                onTap: () => unawaited(
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _AppInfo(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Avatar with the display name used on comments, trips and reviews.
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final name = ref.watch(displayNameProvider).value ?? '';
    final shown = name.isEmpty ? l10n.cmt_anon : name;
    return HeroPanel(
      child: Row(
        spacing: AppSpacing.md,
        children: [
          CircleAvatar(
            radius: AppSpacing.xxl,
            backgroundColor: c.surface.withValues(alpha: 0.25),
            child: Text(
              shown.characters.first.toUpperCase(),
              style: context.text.headline.copyWith(color: c.surface),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shown, style: context.text.title.copyWith(color: c.surface)),
                Text(
                  l10n.more_profileHint,
                  style: context.text.caption.copyWith(color: c.surface.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: c.surface.withValues(alpha: 0.2),
              foregroundColor: c.surface,
            ),
            onPressed: () => unawaited(editDisplayName(context, ref)),
            child: Text(l10n.more_editName),
          ),
        ],
      ),
    );
  }
}

class _AppInfo extends ConsumerWidget {
  const _AppInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final update = ref.watch(updateAvailableProvider).value ?? false;
    const sha = Env.buildSha;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Text(l10n.more_appName, style: context.text.headline),
            Text(l10n.more_version(Env.version), style: context.text.body),
            if (sha.isNotEmpty)
              Text(
                l10n.more_build(sha.substring(0, sha.length < 7 ? sha.length : 7)),
                style: context.text.caption,
              ),
            if (update) Text(l10n.more_update, style: context.text.bodyStrong),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.more_sources, style: context.text.label),
              children: [Text(l10n.more_sourcesBody, style: context.text.caption)],
            ),
          ],
        ),
      ),
    );
  }
}
