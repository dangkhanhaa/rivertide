import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';

/// Pieces of the settings screen (P2-31). Every choice shows its name, so
/// colour is never the only cue (docs/rules/06).

extension AppearanceNames on BuildContext {
  String accentName(AppAccent a) => switch (a) {
    AppAccent.ocean => l10n.accent_ocean,
    AppAccent.jade => l10n.accent_jade,
    AppAccent.leaf => l10n.accent_leaf,
    AppAccent.sunset => l10n.accent_sunset,
    AppAccent.coral => l10n.accent_coral,
    AppAccent.violet => l10n.accent_violet,
    AppAccent.slate => l10n.accent_slate,
    AppAccent.gold => l10n.accent_gold,
  };

  String backdropName(AppBackdrop b) => switch (b) {
    AppBackdrop.mist => l10n.backdrop_mist,
    AppBackdrop.warm => l10n.backdrop_warm,
    AppBackdrop.pure => l10n.backdrop_pure,
    AppBackdrop.tinted => l10n.backdrop_tinted,
  };

  String fontName(AppFont f) => switch (f) {
    AppFont.beVietnam => l10n.font_beVietnam,
    AppFont.nunito => l10n.font_nunito,
    AppFont.quicksand => l10n.font_quicksand,
    AppFont.system => l10n.font_system,
  };

  String navStyleName(NavStyle s) => switch (s) {
    NavStyle.bubble => l10n.nav_styleBubble,
    NavStyle.dot => l10n.nav_styleDot,
    NavStyle.glow => l10n.nav_styleGlow,
  };

  String textSizeName(AppTextSize s) => switch (s) {
    AppTextSize.small => l10n.size_small,
    AppTextSize.normal => l10n.size_normal,
    AppTextSize.large => l10n.size_large,
    AppTextSize.huge => l10n.size_huge,
  };
}

/// Live sample of the current look: gradient header, a chip and a button.
class LookPreview extends StatelessWidget {
  const LookPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return HeroPanel(
      child: Row(
        spacing: AppSpacing.md,
        children: [
          CircleAvatar(
            radius: AppSpacing.xl,
            backgroundColor: c.surface.withValues(alpha: 0.22),
            child: Icon(Icons.phishing_rounded, color: c.surface),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.set_previewTitle, style: context.text.title.copyWith(color: c.surface)),
                Text(
                  l10n.set_previewBody,
                  style: context.text.caption.copyWith(color: c.surface.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Eight round swatches; the chosen one gets a ring and a tick.
class AccentPicker extends StatelessWidget {
  const AccentPicker({required this.value, required this.dark, required this.onPick, super.key});

  final AppAccent value;
  final bool dark;
  final ValueChanged<AppAccent> onPick;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final a in AppAccent.values)
        Semantics(
          button: true,
          selected: a == value,
          label: context.accentName(a),
          excludeSemantics: true,
          child: InkWell(
            onTap: () => onPick(a),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 72,
              child: Column(
                spacing: AppSpacing.xs,
                children: [
                  _Swatch(color: dark ? a.dark : a.light, selected: a == value),
                  Text(
                    context.accentName(a),
                    style: context.text.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    width: AppSpacing.minTouch,
    height: AppSpacing.minTouch,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color.withValues(alpha: selected ? 1 : 0), width: 2.5),
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [color, accentPartner(color)]),
      ),
      child: selected
          ? Icon(Icons.check_rounded, color: context.colors.surface, size: AppIconSize.sm)
          : null,
    ),
  );
}

/// "Aa" in each typeface, so people see the font before choosing it.
class FontPicker extends StatelessWidget {
  const FontPicker({required this.value, required this.onPick, super.key});

  final AppFont value;
  final ValueChanged<AppFont> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      spacing: AppSpacing.sm,
      children: [
        for (final f in AppFont.values)
          Expanded(
            child: Semantics(
              button: true,
              selected: f == value,
              label: context.fontName(f),
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onPick(f),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: f == value ? c.primary.withValues(alpha: 0.1) : c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: f == value ? c.primary : c.stale.withValues(alpha: 0.35),
                      width: f == value ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('Aa', style: context.text.headline.copyWith(fontFamily: f.family)),
                      Text(
                        context.fontName(f),
                        style: context.text.caption.copyWith(fontFamily: f.family),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Four-step slider between a small and a large "A".
class TextSizePicker extends StatelessWidget {
  const TextSizePicker({required this.value, required this.onPick, super.key});

  final AppTextSize value;
  final ValueChanged<AppTextSize> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const steps = AppTextSize.values;
    return Row(
      children: [
        Text('A', style: context.text.caption.copyWith(color: c.onSurfaceMuted)),
        Expanded(
          child: Slider(
            value: value.index.toDouble(),
            max: (steps.length - 1).toDouble(),
            divisions: steps.length - 1,
            label: context.textSizeName(value),
            semanticFormatterCallback: (v) => context.textSizeName(steps[v.round()]),
            onChanged: (v) => onPick(steps[v.round()]),
          ),
        ),
        Text('A', style: context.text.headline.copyWith(color: c.onSurfaceMuted)),
      ],
    );
  }
}
