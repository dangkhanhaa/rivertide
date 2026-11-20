import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/alerts/alerts.dart';
import 'package:rivertide/features/map/map.dart';
import 'package:rivertide/features/more/application/onboarding_provider.dart';
import 'package:rivertide/features/more/domain/user_profile.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_parts.dart';

/// Step 5: favourite waters, notifications and location. Everything here is
/// optional and nothing blocks moving on.
class PrefsStep extends ConsumerWidget {
  const PrefsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final waters = ref.watch(userProfileSettingsProvider).value?.waters ?? const <FishingWater>{};
    void toggle(FishingWater w) =>
        unawaited(ref.read(userProfileSettingsProvider.notifier).change((p) => p.toggleWater(w)));
    return OnbStep(
      title: l10n.onb_prefsTitle,
      body: l10n.onb_prefsBody,
      children: [
        OnbCard(
          icon: Icons.phishing_rounded,
          title: l10n.onb_waterTitle,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final (w, icon, label) in [
                  (FishingWater.river, Icons.water_rounded, l10n.onb_waterRiver),
                  (FishingWater.sea, Icons.sailing_rounded, l10n.onb_waterSea),
                  (FishingWater.lake, Icons.water_drop_rounded, l10n.onb_waterLake),
                ])
                  FilterChip(
                    avatar: Icon(icon, size: AppIconSize.sm),
                    label: Text(label),
                    selected: waters.contains(w),
                    onSelected: (_) => toggle(w),
                  ),
              ],
            ),
          ],
        ),
        const _NotifyCard(),
        const _LocationCard(),
      ],
    );
  }
}

/// Two switches on Android; on the web a plain note (a closed tab cannot ring).
class _NotifyCard extends ConsumerStatefulWidget {
  const _NotifyCard();

  @override
  ConsumerState<_NotifyCard> createState() => _NotifyCardState();
}

class _NotifyCardState extends ConsumerState<_NotifyCard> {
  bool _denied = false;

  Future<void> _set({bool? evening, bool? alarms}) async {
    final ok = await setAlertChoices(context, ref, evening: evening, alarms: alarms);
    if (mounted) setState(() => _denied = !ok);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!alertsSupported) {
      return OnbCard(
        icon: Icons.notifications_active_rounded,
        title: l10n.onb_notifyTitle,
        children: [
          Text(
            Env.showsApkLinks ? l10n.alert_webOnly : l10n.alert_unsupported,
            style: context.text.body,
          ),
        ],
      );
    }
    final on = watchAlertChoices(ref);
    return OnbCard(
      icon: Icons.notifications_active_rounded,
      title: l10n.onb_notifyTitle,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.alert_evening, style: context.text.bodyStrong),
          subtitle: Text(l10n.alert_eveningHint, style: context.text.caption),
          value: on.evening,
          onChanged: (v) => unawaited(_set(evening: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.onb_notifyAlarms, style: context.text.bodyStrong),
          subtitle: Text(l10n.onb_notifyAlarmsHint, style: context.text.caption),
          value: on.alarms,
          onChanged: (v) => unawaited(_set(alarms: v)),
        ),
        if (_denied) _Note(text: l10n.onb_notifyDenied),
      ],
    );
  }
}

/// Explains why, then asks. Every refusal ends in a short note (and a way
/// to the system settings when blocked for good); it never stops the flow.
class _LocationCard extends ConsumerStatefulWidget {
  const _LocationCard();

  @override
  ConsumerState<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends ConsumerState<_LocationCard> {
  bool _granted = false;
  bool _busy = false;
  LocateResult? _result;

  @override
  void initState() {
    super.initState();
    unawaited(_check());
  }

  Future<void> _check() async {
    final ok = await ref.read(locationServiceProvider).hasPermission();
    if (mounted && ok) setState(() => _granted = true);
  }

  Future<void> _allow() async {
    setState(() => _busy = true);
    final prompts = ref.read(locationPromptStoreProvider);
    // The explanation was just shown: the map must not show it again.
    await prompts.markShown();
    final result = await ref.read(locationServiceProvider).locate();
    if (result case Located(:final lat, :final lon)) {
      await prompts.saveLastPosition(lat, lon);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = result;
      _granted = result is Located;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return OnbCard(
      icon: Icons.my_location_rounded,
      title: l10n.onb_locTitle,
      children: [
        Text(l10n.map_locRationaleBody, style: context.text.body),
        if (_granted)
          Row(
            spacing: AppSpacing.sm,
            children: [
              Icon(Icons.check_circle_rounded, color: c.ok, size: AppIconSize.sm),
              Expanded(child: Text(l10n.onb_locOn, style: context.text.bodyStrong)),
            ],
          )
        else
          FilledButton.tonalIcon(
            onPressed: _busy ? null : () => unawaited(_allow()),
            icon: const Icon(Icons.my_location_rounded),
            label: Text(l10n.onb_locAllow),
          ),
        ..._failure(context),
      ],
    );
  }

  List<Widget> _failure(BuildContext context) {
    final l10n = context.l10n;
    return switch (_result) {
      LocationServiceOff() => [_Note(text: l10n.map_locServiceOff)],
      LocationDenied(forever: false) => [_Note(text: l10n.map_locDenied)],
      LocationDenied(forever: true) => [
        _Note(text: l10n.map_locDeniedForeverBody),
        TextButton.icon(
          onPressed: () => unawaited(ref.read(locationServiceProvider).openSettings()),
          icon: const Icon(Icons.settings_rounded),
          label: Text(l10n.map_openSettings),
        ),
      ],
      LocationFailed() => [_Note(text: l10n.map_locFailed)],
      Located() || null => const [],
    };
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.sm,
    children: [
      Icon(Icons.info_outline_rounded, size: AppIconSize.sm, color: context.colors.alarm2),
      Expanded(child: Text(text, style: context.text.caption)),
    ],
  );
}
