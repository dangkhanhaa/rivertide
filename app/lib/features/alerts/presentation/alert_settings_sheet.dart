import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/alerts/application/alert_scheduler.dart';
import 'package:rivertide/features/alerts/application/alert_settings.dart';
import 'package:rivertide/features/alerts/data/alert_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

/// ⚙ in the watch list's app bar: what rings and how early (P2-22). On the
/// web it explains that alarms need the Android app and links to it.
class AlertSettingsButton extends StatelessWidget {
  const AlertSettingsButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.alert_settings,
    icon: const Icon(Icons.notifications_active_outlined),
    onPressed: () => unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _AlertSettingsSheet(),
      ),
    ),
  );
}

class _AlertSettingsSheet extends ConsumerWidget {
  const _AlertSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final options = ref.watch(alertOptionsProvider).value ?? const AlertOptions();
    Future<void> save(AlertOptions next) async {
      await ref.read(alertOptionsProvider.notifier).save(next);
      await rescheduleAlerts(ref);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            Text(l10n.alert_settings, style: context.text.title),
            if (!AlertNotifier.supported) ...[
              Text(l10n.alert_webOnly, style: context.text.body),
              FilledButton.icon(
                icon: const Icon(Icons.android_rounded),
                label: Text(l10n.alert_getApk),
                onPressed: () => unawaited(launchUrl(Uri.parse(Env.apkUrl))),
              ),
            ] else ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.alert_golden, style: context.text.bodyStrong),
                subtitle: Text(l10n.alert_goldenHint, style: context.text.caption),
                value: options.golden,
                onChanged: (v) => unawaited(save(options.copyWith(golden: v))),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.alert_tides, style: context.text.bodyStrong),
                value: options.tides,
                onChanged: (v) => unawaited(save(options.copyWith(tides: v))),
              ),
              Text(l10n.alert_lead, style: context.text.label),
              SegmentedButton<int>(
                segments: [
                  for (final m in alertLeadChoicesMin)
                    ButtonSegment(value: m, label: Text(l10n.alert_leadMin(m))),
                ],
                selected: {options.leadMinutes},
                showSelectedIcon: false,
                onSelectionChanged: (s) => unawaited(save(options.copyWith(leadMinutes: s.first))),
              ),
              Text(l10n.alert_howTo, style: context.text.caption),
            ],
          ],
        ),
      ),
    );
  }
}
