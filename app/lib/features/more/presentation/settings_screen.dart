import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/alerts/alerts.dart';
import 'package:rivertide/features/more/application/appearance_provider.dart';
import 'package:rivertide/features/more/application/outdoor_mode_provider.dart';
import 'package:rivertide/features/more/application/theme_mode_provider.dart';
import 'package:rivertide/features/more/presentation/settings_backdrop.dart';
import 'package:rivertide/features/more/presentation/settings_pickers.dart';

/// Thêm → Cài đặt (P2-31): live preview on top, every change applies at once.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final look = ref.watch(appearanceSettingsProvider).value ?? const Appearance();
    final settings = ref.read(appearanceSettingsProvider.notifier);
    void set(Appearance Function(Appearance) change) => unawaited(settings.change(change));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.set_title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
        children: [
          const LookPreview(),
          _LookSection(look: look, set: set),
          _GeneralSection(look: look, set: set),
          const _DataSection(),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await settings.reset();
                if (context.mounted) _toast(context, l10n.set_resetDone);
              },
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(l10n.set_reset),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _Set = void Function(Appearance Function(Appearance) change);

void _toast(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// A titled card holding one group of settings.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(title: title),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.sm,
            children: children,
          ),
        ),
      ),
    ],
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xs),
    child: Text(text, style: context.text.label),
  );
}

class _LookSection extends ConsumerWidget {
  const _LookSection({required this.look, required this.set});

  final Appearance look;
  final _Set set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? look.accent.dark : look.accent.light;
    return _Group(
      title: l10n.set_look,
      children: [
        _Label(l10n.set_mode),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(value: ThemeMode.system, label: Text(l10n.more_themeSystem)),
            ButtonSegment(value: ThemeMode.light, label: Text(l10n.more_themeLight)),
            ButtonSegment(value: ThemeMode.dark, label: Text(l10n.more_themeDark)),
          ],
          selected: {mode},
          showSelectedIcon: false,
          onSelectionChanged: (s) =>
              unawaited(ref.read(appThemeModeProvider.notifier).set(s.first)),
        ),
        _Label(l10n.set_accent),
        AccentPicker(
          value: look.accent,
          dark: dark,
          onPick: (a) => set((l) => l.copyWith(accent: a)),
        ),
        _Label(l10n.set_backdrop),
        BackdropPicker(
          value: look.backdrop,
          accent: accent,
          dark: dark,
          onPick: (b) => set((l) => l.copyWith(backdrop: b)),
        ),
        _Label(l10n.set_navStyle),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final (st, icon) in [
              (NavStyle.arc, Icons.gesture_rounded),
              (NavStyle.notch, Icons.radio_button_checked_rounded),
              (NavStyle.glass, Icons.blur_on_rounded),
              (NavStyle.dot, Icons.more_horiz_rounded),
            ])
              ChoiceChip(
                avatar: Icon(icon, size: AppIconSize.sm),
                label: Text(context.navStyleName(st)),
                selected: look.navStyle == st,
                onSelected: (_) => set((l) => l.copyWith(navStyle: st)),
              ),
          ],
        ),
        _Label(l10n.set_font),
        FontPicker(
          value: look.font,
          onPick: (f) => set((l) => l.copyWith(font: f)),
        ),
        _Label('${l10n.set_textSize}: ${context.textSizeName(look.textSize)}'),
        TextSizePicker(
          value: look.textSize,
          onPick: (s) => set((l) => l.copyWith(textSize: s)),
        ),
      ],
    );
  }
}

class _GeneralSection extends ConsumerWidget {
  const _GeneralSection({required this.look, required this.set});

  final Appearance look;
  final _Set set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    Widget chips<T>(List<(T, String)> options, T value, ValueChanged<T> pick) => Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        for (final (v, label) in options)
          ChoiceChip(label: Text(label), selected: v == value, onSelected: (_) => pick(v)),
      ],
    );
    return _Group(
      title: l10n.set_general,
      children: [
        _Label(l10n.set_language),
        // A full list in one picker (P2-44), easier than a wall of chips.
        DropdownButtonFormField<AppLanguage>(
          initialValue: look.language,
          isExpanded: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.translate_rounded)),
          items: [
            for (final (v, label) in [
              (AppLanguage.system, l10n.lang_system),
              (AppLanguage.vi, l10n.lang_vi),
              (AppLanguage.en, l10n.lang_en),
              (AppLanguage.zh, l10n.lang_zh),
              (AppLanguage.ko, l10n.lang_ko),
              (AppLanguage.ja, l10n.lang_ja),
            ])
              DropdownMenuItem(value: v, child: Text(label)),
          ],
          onChanged: (v) {
            if (v != null) set((l) => l.copyWith(language: v));
          },
        ),
        _Label(l10n.set_start),
        chips(
          [
            (StartTab.map, l10n.nav_map),
            (StartTab.ponds, l10n.nav_ponds),
            (StartTab.fishing, l10n.nav_fishing),
          ],
          look.startTab,
          (v) => set((l) => l.copyWith(startTab: v)),
        ),
        const Divider(),
        ActionRow(
          icon: Icons.notifications_active_rounded,
          color: c.alarm2,
          title: l10n.set_notifications,
          subtitle: l10n.set_notificationsHint,
          onTap: () => unawaited(showAlertSettings(context)),
        ),
        ActionRow(
          icon: Icons.wb_sunny_rounded,
          color: c.alarm1,
          title: l10n.more_outdoor,
          subtitle: l10n.more_outdoorHint,
          trailing: Switch(
            value: ref.watch(outdoorModeProvider).value ?? false,
            onChanged: (v) => unawaited(ref.read(outdoorModeProvider.notifier).set(on: v)),
          ),
        ),
        ActionRow(
          icon: Icons.motion_photos_off_rounded,
          color: c.trip,
          title: l10n.set_motion,
          subtitle: l10n.set_motionHint,
          trailing: Switch(
            value: look.reduceMotion,
            onChanged: (v) => set((l) => l.copyWith(reduceMotion: v)),
          ),
        ),
      ],
    );
  }
}

/// Cache size and a clear button; journal, favourites and settings stay.
class _DataSection extends ConsumerStatefulWidget {
  const _DataSection();

  @override
  ConsumerState<_DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends ConsumerState<_DataSection> {
  late Future<int> _bytes = ref.read(appDatabaseProvider).cacheBytes();

  Future<void> _clear() async {
    await ref.read(appDatabaseProvider).clearCache();
    if (!mounted) return;
    setState(() => _bytes = ref.read(appDatabaseProvider).cacheBytes());
    _toast(context, context.l10n.set_cacheCleared);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Group(
      title: l10n.set_data,
      children: [
        FutureBuilder<int>(
          future: _bytes,
          builder: (context, snap) => ActionRow(
            icon: Icons.cleaning_services_rounded,
            color: context.colors.water,
            title: l10n.set_cache(_mb(snap.data)),
            subtitle: l10n.set_cacheHint,
            trailing: TextButton(
              onPressed: () => unawaited(_clear()),
              child: Text(l10n.set_cacheClear),
            ),
          ),
        ),
      ],
    );
  }

  static String _mb(int? bytes) => bytes == null ? '…' : (bytes / (1024 * 1024)).toStringAsFixed(1);
}
