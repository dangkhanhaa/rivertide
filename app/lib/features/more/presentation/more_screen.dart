import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/more/application/theme_mode_provider.dart';

/// S13 (V0 subset): theme, data sources, about.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  static const String _version = '0.1.0 (V0)';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.more_title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
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
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.more_sources, style: context.text.title),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.more_sourcesBody, style: context.text.body),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.more_about, style: context.text.title),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.more_aboutBody, style: context.text.body),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.more_version(_version), style: context.text.caption),
        ],
      ),
    );
  }
}
