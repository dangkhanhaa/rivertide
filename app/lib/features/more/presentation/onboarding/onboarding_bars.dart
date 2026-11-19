import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/features/more/application/onboarding_provider.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_parts.dart';

/// Back · step dots · "Bỏ qua" (P2-53).
class OnbTopBar extends StatelessWidget {
  const OnbTopBar({required this.step, required this.onBack, required this.onSkip, super.key});

  final int step;

  /// Null on the first step (the button fades out but keeps its place).
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.sm, 0),
      child: Row(
        children: [
          AnimatedOpacity(
            duration: onbMotion,
            opacity: onBack == null ? 0 : 1,
            child: IconButton(
              tooltip: l10n.onb_back,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Expanded(
            child: Center(
              child: OnbProgress(step: step, count: onboardingSteps),
            ),
          ),
          TextButton(onPressed: onSkip, child: Text(l10n.onb_skip)),
        ],
      ),
    );
  }
}

/// The main button, in thumb reach; its label cross-fades between steps.
class OnbBottomBar extends StatelessWidget {
  const OnbBottomBar({required this.label, required this.busy, required this.onPressed, super.key});

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.lg),
    child: FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpacing.minTouch + AppSpacing.xs),
      ),
      onPressed: busy ? null : onPressed,
      child: AnimatedSwitcher(
        duration: onbMotion,
        child: Row(
          key: ValueKey(label),
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm,
          children: [
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.arrow_forward_rounded, size: AppIconSize.sm),
          ],
        ),
      ),
    ),
  );
}
