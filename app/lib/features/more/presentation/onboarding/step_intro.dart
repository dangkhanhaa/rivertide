import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/core/widgets/fish_scene.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/more/application/appearance_provider.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_parts.dart';

/// Step 1: what the app does, in three lines over a calm underwater scene.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      children: [
        const _Hero(),
        const SizedBox(height: AppSpacing.xl),
        Semantics(header: true, child: Text(l10n.onb_welcomeTitle, style: context.text.headline)),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.onb_welcomeBody, style: context.text.body.copyWith(color: c.onSurfaceMuted)),
        const SizedBox(height: AppSpacing.lg),
        _Point(icon: Icons.waves_rounded, color: c.water, text: l10n.onb_welcomeTide),
        _Point(icon: Icons.wb_twilight_rounded, color: c.fishGood, text: l10n.onb_welcomeGolden),
        _Point(icon: Icons.groups_rounded, color: c.spot, text: l10n.onb_welcomeCommunity),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.onb_welcomeTime, style: context.text.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  static const double _height = 196;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Text on deep water must be light in both modes.
    final light = dark ? c.onSurface : c.surface;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: SizedBox(
        height: _height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FishScene(
              fishes: 5,
              energy: 0.5,
              water: c.deepWater,
              fish: Color.lerp(c.primary, light, 0.45) ?? light,
              height: _height,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [c.primary.withValues(alpha: 0.35), c.deepWater.withValues(alpha: 0)],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.sm,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [c.primary, accentPartner(c.primary)]),
                      boxShadow: [
                        BoxShadow(color: c.primary.withValues(alpha: 0.45), blurRadius: 24),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Icon(Icons.phishing_rounded, size: AppIconSize.lg, color: light),
                    ),
                  ),
                  Text(context.l10n.appTitle, style: context.text.headline.copyWith(color: light)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      spacing: AppSpacing.md,
      children: [
        IconBadge(icon: icon, color: color, size: AppSpacing.xxl + AppSpacing.xs),
        Expanded(child: Text(text, style: context.text.bodyStrong)),
      ],
    ),
  );
}

/// Step 2: language, applied at once so the next steps read in it.
class LanguageStep extends ConsumerWidget {
  const LanguageStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(appearanceSettingsProvider).value?.language ?? AppLanguage.vi;
    void pick(AppLanguage v) => unawaited(
      ref.read(appearanceSettingsProvider.notifier).change((l) => l.copyWith(language: v)),
    );
    return OnbStep(
      title: l10n.onb_langTitle,
      body: l10n.onb_langBody,
      children: [
        for (final (v, label) in [
          (AppLanguage.vi, l10n.lang_vi),
          (AppLanguage.en, l10n.lang_en),
          (AppLanguage.zh, l10n.lang_zh),
          (AppLanguage.ko, l10n.lang_ko),
          (AppLanguage.ja, l10n.lang_ja),
          (AppLanguage.system, l10n.lang_system),
        ])
          ChoiceTile(
            radio: true,
            title: label,
            selected: current == v,
            leading: _LangBadge(code: v.code),
            onTap: () => pick(v),
          ),
      ],
    );
  }
}

/// Language code in a soft circle; the phone icon for "follow the phone".
class _LangBadge extends StatelessWidget {
  const _LangBadge({required this.code});

  final String? code;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: Container(
        width: AppSpacing.xxl + AppSpacing.sm,
        height: AppSpacing.xxl + AppSpacing.sm,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: switch (code) {
          final s? => Text(s.toUpperCase(), style: context.text.label.copyWith(color: c.primary)),
          null => Icon(Icons.smartphone_rounded, size: AppIconSize.sm, color: c.primary),
        },
      ),
    );
  }
}
