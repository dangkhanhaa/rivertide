import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/legal/legal.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/more/application/terms_provider.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_bars.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_parts.dart';

/// The terms step (P2-57): what the app keeps and where, community rules,
/// the safety disclaimer, the full texts, and a required "I agree". There
/// is no way into the app without it.
class TermsStep extends StatelessWidget {
  const TermsStep({
    required this.agreed,
    required this.onAgreed,
    this.standalone = false,
    super.key,
  });

  final bool agreed;
  final ValueChanged<bool> onAgreed;

  /// Shown alone (not inside the welcome flow): asks to agree to go on.
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return OnbStep(
      title: l10n.onb_termsTitle,
      body: standalone ? l10n.onb_termsUpdatedBody : l10n.onb_termsBody,
      children: [
        _Point(icon: Icons.smartphone_rounded, color: c.ok, text: l10n.onb_termsDevice),
        _Point(icon: Icons.cloud_outlined, color: c.water, text: l10n.onb_termsServer),
        _Point(icon: Icons.my_location_rounded, color: c.trip, text: l10n.onb_termsLocation),
        _Point(icon: Icons.groups_rounded, color: c.spot, text: l10n.onb_termsCommunity),
        _Point(icon: Icons.health_and_safety_rounded, color: c.alarm2, text: l10n.onb_termsSafety),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final (label, url) in [
              (l10n.legal_terms, termsUrl),
              (l10n.legal_privacy, privacyUrl),
            ])
              TextButton.icon(
                onPressed: () => unawaited(openLegalLink(url)),
                icon: const Icon(Icons.open_in_new_rounded, size: AppIconSize.sm),
                label: Text(label),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          clipBehavior: Clip.antiAlias,
          child: CheckboxListTile(
            value: agreed,
            onChanged: (v) => onAgreed(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(l10n.onb_termsAgree, style: context.text.bodyStrong),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.onb_termsRequired, style: context.text.caption),
        // Declining means leaving: on Android the app can close itself; a web
        // page just stays here.
        if (!kIsWeb)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => unawaited(SystemNavigator.pop()),
              icon: const Icon(Icons.logout_rounded, size: AppIconSize.sm),
              label: Text(l10n.onb_exitApp),
            ),
          ),
      ],
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
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        Icon(icon, color: color, size: AppIconSize.md),
        Expanded(child: Text(text, style: context.text.body)),
      ],
    ),
  );
}

/// Shown alone when the onboarding is done but the current terms were never
/// accepted (installs from before P2-57, or [termsVersion] went up). A link
/// the app was opened with waits in the router and opens right after.
class TermsOnlyScreen extends ConsumerStatefulWidget {
  const TermsOnlyScreen({super.key});

  @override
  ConsumerState<TermsOnlyScreen> createState() => _TermsOnlyScreenState();
}

class _TermsOnlyScreenState extends ConsumerState<TermsOnlyScreen> {
  bool _agreed = false;
  bool _busy = false;

  Future<void> _accept() async {
    setState(() => _busy = true);
    await ref.read(termsAcceptanceProvider.notifier).accept();
  }

  @override
  Widget build(BuildContext context) => OnbScaffold(
    body: TermsStep(
      standalone: true,
      agreed: _agreed,
      onAgreed: (v) => setState(() => _agreed = v),
    ),
    bottom: OnbBottomBar(
      label: context.l10n.onb_termsContinue,
      busy: _busy || !_agreed,
      onPressed: () => unawaited(_accept()),
    ),
  );
}
