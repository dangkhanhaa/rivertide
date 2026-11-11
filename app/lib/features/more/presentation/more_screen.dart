import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/more/application/outdoor_mode_provider.dart';
import 'package:rivertide/features/more/application/theme_mode_provider.dart';
import 'package:rivertide/features/more/application/update_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// S13: settings only; version and data sources sit behind the ⓘ button.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    final update = ref.watch(updateAvailableProvider).value ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.more_title),
        actions: [
          IconButton(
            tooltip: l10n.more_info,
            icon: Badge(isLabelVisible: update, child: const Icon(Icons.info_outline_rounded)),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => const _AppInfo(),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (update) ...[
            Card(
              color: context.colors.primary.withValues(alpha: 0.12),
              child: ListTile(
                leading: const Icon(Icons.system_update_rounded),
                title: Text(l10n.more_update),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(l10n.more_theme, style: context.text.title),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l10n.more_themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(l10n.more_themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l10n.more_themeDark)),
            ],
            selected: {mode},
            onSelectionChanged: (s) => ref.read(appThemeModeProvider.notifier).set(s.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.wb_sunny_rounded),
            title: Text(l10n.more_outdoor),
            subtitle: Text(l10n.more_outdoorHint),
            value: ref.watch(outdoorModeProvider).value ?? false,
            onChanged: (v) => ref.read(outdoorModeProvider.notifier).set(on: v),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: ListTile(
                leading: const Icon(Icons.install_mobile_rounded),
                title: Text(l10n.more_install),
                subtitle: Text(l10n.more_installHow),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ListTile(
                leading: const Icon(Icons.android_rounded),
                title: Text(l10n.more_apk),
                subtitle: Text(l10n.more_apkHint),
                trailing: const Icon(Icons.download_rounded),
                onTap: () => launchUrl(Uri.parse(Env.apkUrl)),
              ),
            ),
          ],
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
