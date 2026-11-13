import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/ponds/application/ponds_providers.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';
import 'package:rivertide/features/ponds/presentation/pond_actions.dart';
import 'package:rivertide/features/ponds/presentation/widgets/pond_card.dart';
import 'package:rivertide/features/ponds/presentation/widgets/pond_pulse_row.dart';
import 'package:rivertide/features/ponds/presentation/widgets/pond_releases.dart';
import 'package:rivertide/features/ponds/presentation/widgets/pond_reviews.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Everything about one pond, release schedule first (P2-28). Used in the map
/// side sheet and as a page from the Hồ câu tab.
class PondDetail extends ConsumerWidget {
  const PondDetail({required this.pond, super.key});

  final Pond pond;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final p = pond;
    final km = p.distanceKm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        Row(
          children: [
            Icon(Icons.waves_rounded, size: AppIconSize.sm, color: c.pond),
            const SizedBox(width: AppSpacing.xs),
            Text(l10n.pond_tag, style: context.text.label.copyWith(color: c.pond)),
            const Spacer(),
            PondBadge(pond: p),
          ],
        ),
        Text(p.name, style: context.text.headline),
        Text(
          [
            if (p.address.isNotEmpty) p.address,
            if (km != null) l10n.pond_distance(LevelFormat.km(km)),
            if (p.rating case final r?) l10n.pond_rating(LevelFormat.decimal1(r), p.reviewCount),
          ].join(' · '),
          style: context.text.caption,
        ),
        if (p.photoUrls.isNotEmpty) _Photos(urls: p.photoUrls),
        if (p.fromWeb && !p.verified) _Note(text: l10n.pond_fromWeb),
        if (p.approxLocation) _Note(text: l10n.pond_approx),
        _MainActions(pond: p),
        PondReleases(pond: p),
        PondPulseRow(pondId: p.id),
        _Info(pond: p),
        const Divider(),
        PondReviews(pondId: p.id),
        const Divider(),
        PondFooterActions(pond: p),
      ],
    );
  }
}

class _MainActions extends ConsumerWidget {
  const _MainActions({required this.pond});

  final Pond pond;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final followed = ref.watch(followedPondsProvider).value?.contains(pond.id) ?? false;
    final phone = pond.phone.replaceAll(RegExp(r'[^\d+]'), '');
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        DirectionsButton(lat: pond.lat, lon: pond.lon),
        if (phone.length >= 8)
          OutlinedButton.icon(
            onPressed: () => unawaited(launchUrl(Uri(scheme: 'tel', path: phone))),
            icon: const Icon(Icons.call_rounded),
            label: Text(l10n.pond_call),
          ),
        Tooltip(
          message: l10n.pond_followHint,
          child: followed
              ? FilledButton.icon(
                  onPressed: () =>
                      unawaited(ref.read(followedPondsProvider.notifier).toggle(pond.id)),
                  icon: const Icon(Icons.notifications_active_rounded),
                  label: Text(l10n.pond_following),
                )
              : OutlinedButton.icon(
                  onPressed: () =>
                      unawaited(ref.read(followedPondsProvider.notifier).toggle(pond.id)),
                  icon: const Icon(Icons.notifications_none_rounded),
                  label: Text(l10n.pond_follow),
                ),
        ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.pond});

  final Pond pond;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = pond;
    Widget row(IconData icon, String label, String value) => ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon),
      title: Text(label, style: context.text.caption),
      subtitle: Text(value, style: context.text.body),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (p.price.isNotEmpty) row(Icons.payments_outlined, l10n.pond_price, p.price),
        if (p.hours.isNotEmpty) row(Icons.schedule_rounded, l10n.pond_hours, p.hours),
        if (p.species.isNotEmpty)
          row(Icons.set_meal_outlined, l10n.pond_species, p.species.join(', ')),
        if (p.phone.isNotEmpty) row(Icons.phone_outlined, l10n.pond_phone, p.phone),
        if (p.note.isNotEmpty) row(Icons.notes_rounded, l10n.pond_note, p.note),
        if (p.sourceUrls.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(l10n.pond_sources, style: context.text.caption),
            children: [
              for (final u in p.sourceUrls)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(Uri.tryParse(u)?.host ?? u, style: context.text.caption),
                  onTap: () =>
                      unawaited(launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication)),
                ),
            ],
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.alarm1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(text, style: context.text.caption),
    );
  }
}

class _Photos extends StatelessWidget {
  const _Photos({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppSpacing.xxl * 5,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: urls.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (_, i) => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.network(
            urls[i],
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(),
          ),
        ),
      ),
    ),
  );
}

/// Full page around [PondDetail] (from the Hồ câu tab).
class PondPage extends StatelessWidget {
  const PondPage({required this.pond, super.key});

  final Pond pond;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(pond.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
    body: ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [PondDetail(pond: pond)],
    ),
  );
}
