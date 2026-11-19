import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/core/widgets/floating_nav_bar.dart';
import 'package:rivertide/features/more/application/appearance_provider.dart';
import 'package:rivertide/features/more/application/theme_mode_provider.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_parts.dart';
import 'package:rivertide/features/more/presentation/settings_pickers.dart';

/// Step 6: accent, light/dark and tab bar style, with the real tab bar as a
/// live preview (same pickers as Settings).
class LookStep extends ConsumerWidget {
  const LookStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final look = ref.watch(appearanceSettingsProvider).value ?? const Appearance();
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    final dark = Theme.of(context).brightness == Brightness.dark;
    void set(Appearance Function(Appearance) edit) =>
        unawaited(ref.read(appearanceSettingsProvider.notifier).change(edit));
    return OnbStep(
      title: l10n.onb_lookTitle,
      body: l10n.onb_lookBody,
      children: [
        const LookPreview(),
        _NavPreview(style: look.navStyle),
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
        _Label(l10n.set_navStyle),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (st, icon) in [
              (NavStyle.notch, Icons.radio_button_checked_rounded),
              (NavStyle.arc, Icons.gesture_rounded),
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
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
    child: Text(text, style: context.text.label),
  );
}

/// The app's own floating tab bar; tapping it moves the indicator, so the
/// chosen style can be felt before it is kept.
class _NavPreview extends StatefulWidget {
  const _NavPreview({required this.style});

  final NavStyle style;

  @override
  State<_NavPreview> createState() => _NavPreviewState();
}

class _NavPreviewState extends State<_NavPreview> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      // The real bar pads for the home indicator; not needed mid-page.
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: FloatingNavBar(
          index: _index,
          style: widget.style,
          onTap: (i) => setState(() => _index = i),
          items: [
            (icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: l10n.nav_map),
            (icon: Icons.waves_outlined, selectedIcon: Icons.waves_rounded, label: l10n.nav_ponds),
            (
              icon: Icons.star_outline_rounded,
              selectedIcon: Icons.star_rounded,
              label: l10n.nav_watch,
            ),
            (
              icon: Icons.phishing_outlined,
              selectedIcon: Icons.phishing_rounded,
              label: l10n.nav_fishing,
            ),
            (icon: Icons.menu_rounded, selectedIcon: Icons.menu_open_rounded, label: l10n.nav_more),
          ],
        ),
      ),
    );
  }
}
