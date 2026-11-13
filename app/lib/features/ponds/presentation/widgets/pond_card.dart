import 'package:flutter/material.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';
import 'package:rivertide/features/ponds/presentation/pond_format.dart';

/// One pond in the list: photo, name, trust badge, distance, rating, price and
/// the next release (the thing anglers look for first).
class PondCard extends StatelessWidget {
  const PondCard({required this.pond, required this.onTap, super.key});

  final Pond pond;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final p = pond;
    final km = p.distanceKm;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.md,
            children: [
              _Thumb(pond: p),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(p.name, style: context.text.bodyStrong, maxLines: 2),
                    PondBadge(pond: p),
                    Text(
                      [
                        if (km != null) l10n.pond_distance(LevelFormat.km(km)),
                        if (p.rating case final r?)
                          l10n.pond_rating(LevelFormat.decimal1(r), p.reviewCount),
                        if (p.price.isNotEmpty) p.price,
                      ].join(' · '),
                      style: context.text.caption,
                      maxLines: 2,
                    ),
                    if (p.nextReleaseAt case final at?)
                      _ReleaseChip(at: at, kg: p.nextReleaseKg, official: p.nextReleaseByOwner),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.stale),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.pond});

  final Pond pond;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const size = AppSpacing.xxl * 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox.square(
        dimension: size,
        child: pond.photoUrls.isEmpty
            ? ColoredBox(
                color: c.pond.withValues(alpha: 0.15),
                child: Icon(Icons.waves_rounded, color: c.pond, size: AppIconSize.lg),
              )
            : Image.network(
                pond.photoUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(Icons.waves_rounded, color: c.pond),
              ),
      ),
    );
  }
}

/// ✓ owner / ✓ verified / "Chưa xác minh": words, not colour alone.
class PondBadge extends StatelessWidget {
  const PondBadge({required this.pond, super.key});

  final Pond pond;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final (icon, text, color) = pond.hasOwner
        ? (Icons.verified_rounded, l10n.pond_owner, c.fishGood)
        : pond.verified
        ? (Icons.check_circle_rounded, l10n.pond_verified, c.fishGood)
        : (Icons.help_outline_rounded, l10n.pond_unverified, c.onSurfaceMuted);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSize.sm - 4, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: context.text.caption.copyWith(color: color)),
      ],
    );
  }
}

class _ReleaseChip extends StatelessWidget {
  const _ReleaseChip({required this.at, required this.kg, required this.official});

  final DateTime at;
  final int? kg;
  final bool official;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final when = pondWhen(at);
    final amount = kg;
    final text = amount == null
        ? when
        : context.l10n.pond_releaseKg(when, pondAmount(context, amount));
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: c.alarm2.withValues(alpha: official ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        context.l10n.pond_releaseChip(text),
        style: context.text.label.copyWith(color: c.alarm2),
      ),
    );
  }
}
