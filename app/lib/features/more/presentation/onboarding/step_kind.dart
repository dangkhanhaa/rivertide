import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/features/more/application/onboarding_provider.dart';
import 'package:rivertide/features/more/domain/user_profile.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_parts.dart';

/// Step 4: "Bạn là ai?" — one or more kinds; they pick the start tab and
/// the map layers when the flow ends (see `profile_defaults.dart`).
class KindStep extends ConsumerWidget {
  const KindStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final kinds = ref.watch(userProfileSettingsProvider).value?.kinds ?? const <UserKind>{};
    void toggle(UserKind k) =>
        unawaited(ref.read(userProfileSettingsProvider.notifier).change((p) => p.toggleKind(k)));
    return OnbStep(
      title: l10n.onb_kindTitle,
      body: l10n.onb_kindBody,
      children: [
        for (final (k, icon, color, title, hint) in [
          (
            UserKind.weekend,
            Icons.wb_sunny_rounded,
            c.alarm2,
            l10n.onb_kindWeekend,
            l10n.onb_kindWeekendHint,
          ),
          (
            UserKind.pro,
            Icons.phishing_rounded,
            c.fishGood,
            l10n.onb_kindPro,
            l10n.onb_kindProHint,
          ),
          (UserKind.pond, Icons.waves_rounded, c.pond, l10n.onb_kindPond, l10n.onb_kindPondHint),
          (
            UserKind.pondOwner,
            Icons.storefront_rounded,
            c.spot,
            l10n.onb_kindOwner,
            l10n.onb_kindOwnerHint,
          ),
          (
            UserKind.boater,
            Icons.sailing_rounded,
            c.water,
            l10n.onb_kindBoater,
            l10n.onb_kindBoaterHint,
          ),
          (
            UserKind.tideOnly,
            Icons.show_chart_rounded,
            c.tidePred,
            l10n.onb_kindTide,
            l10n.onb_kindTideHint,
          ),
        ])
          ChoiceTile(
            icon: icon,
            color: color,
            title: title,
            subtitle: hint,
            selected: kinds.contains(k),
            onTap: () => toggle(k),
          ),
      ],
    );
  }
}
