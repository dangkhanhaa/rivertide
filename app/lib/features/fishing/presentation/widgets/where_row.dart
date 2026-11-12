import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/navigation/map_focus.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/fish_activity_style.dart';
import 'package:rivertide/features/fishing/application/where_to_go.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Candidates ranked by score as each one's numbers arrive; places still
/// loading or without data go last.
class RankedList extends ConsumerWidget {
  const RankedList({required this.candidates, super.key});

  final List<WhereCandidate> candidates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = [for (final c in candidates) (c: c, s: ref.watch(whereScoreProvider(c.id)))];
    // Higher score first; on a tie the sooner window, then the nearer place.
    int byRank(WhereCandidate ca, WhereScore? a, WhereCandidate cb, WhereScore? b) {
      if (a == null || b == null) return a == null ? (b == null ? 0 : 1) : -1;
      final s = b.score.compareTo(a.score);
      if (s != 0) return s;
      final t = a.fromUtc.compareTo(b.fromUtc);
      return t != 0 ? t : ca.km.compareTo(cb.km);
    }

    rows.sort((x, y) => byRank(x.c, x.s.value, y.c, y.s.value));
    var rank = 0;
    final onlyHere = candidates.every((c) => c.kind == WhereKind.here);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        if (onlyHere) Text(context.l10n.where_onlyHere, style: context.text.body),
        for (final r in rows)
          WhereRow(
            candidate: r.c,
            score: r.s,
            rank: r.s.value == null ? null : ++rank,
            onRetry: () => ref.invalidate(stationFishingProvider(r.c.id)),
          ),
      ],
    );
  }
}

class WhereRow extends ConsumerWidget {
  const WhereRow({
    required this.candidate,
    required this.score,
    required this.rank,
    required this.onRetry,
    super.key,
  });

  final WhereCandidate candidate;
  final AsyncValue<WhereScore?> score;
  final int? rank;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = candidate;
    final s = score.value;
    final color = s == null
        ? context.colors.stale
        : context.fishActivityColor(fishActivity(s.score));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Row(
              children: [
                _RankBadge(rank: rank, color: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _Title(candidate: c)),
                if (s != null) _ScoreBlock(score: s.score, color: color),
              ],
            ),
            switch (score) {
              AsyncData(value: final v?) => _MomentLines(score: v),
              AsyncData() || AsyncError() => Row(
                children: [
                  Expanded(child: Text(l10n.where_failed, style: context.text.caption)),
                  TextButton(onPressed: onRetry, child: Text(l10n.common_retry)),
                ],
              ),
              _ => Text(l10n.where_loading, style: context.text.caption),
            },
            _Actions(candidate: c),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.color});

  final int? rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final r = rank;
    return Semantics(
      label: r == null ? null : context.l10n.where_rank(r),
      excludeSemantics: true,
      child: Container(
        width: AppSpacing.minTouch - AppSpacing.sm,
        height: AppSpacing.minTouch - AppSpacing.sm,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: r == null
            ? SizedBox.square(
                dimension: AppIconSize.sm,
                child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.surface),
              )
            : Text('$r', style: context.text.title.copyWith(color: context.colors.surface)),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.candidate});

  final WhereCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = candidate;
    final (kind, icon) = switch (c.kind) {
      WhereKind.here => (l10n.where_kindHere, Icons.my_location_rounded),
      WhereKind.station => (l10n.where_kindStation, Icons.water_rounded),
      WhereKind.saved => (l10n.where_kindSaved, Icons.star_rounded),
      WhereKind.community => (l10n.where_kindCommunity, Icons.groups_rounded),
    };
    final name = c.name.isEmpty ? kind : c.name;
    // "Chỗ bạn đứng" already names the place when it has no ward name.
    final showKind = c.name.isNotEmpty || c.kind != WhereKind.here;
    final dist = c.kind == WhereKind.here
        ? ''
        : ' · ${l10n.where_distance(LevelFormat.decimal1(c.km))}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: context.text.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (showKind)
          Row(
            children: [
              Icon(icon, size: AppIconSize.sm - 4, color: context.colors.onSurfaceMuted),
              const SizedBox(width: AppSpacing.xs),
              Flexible(child: Text('$kind$dist', style: context.text.caption)),
            ],
          ),
      ],
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.score, required this.color});

  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(LevelFormat.decimal1(score), style: context.text.headline.copyWith(color: color)),
      Text(context.fishActivityName(fishActivity(score)), style: context.text.label),
    ],
  );
}

class _MomentLines extends ConsumerWidget {
  const _MomentLines({required this.score});

  final WhereScore score;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final now = ref.watch(clockProvider)();
    final when = '${context.fishTimeLabel(now, score.fromUtc)}–${TimeFormat.hm(score.toUtc)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text(
          score.golden ? l10n.where_golden(when) : l10n.where_bestHour(when),
          style: context.text.body,
        ),
        if (score.likeYours)
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: AppIconSize.sm, color: c.fishGood),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  l10n.habit_match,
                  style: context.text.label.copyWith(color: c.fishGood),
                ),
              ),
            ],
          ),
        if (score.unsafe)
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: AppIconSize.sm, color: c.alarm3),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(l10n.where_unsafe, style: context.text.label.copyWith(color: c.alarm3)),
              ),
            ],
          ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.candidate});

  final WhereCandidate candidate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = candidate;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        if (c.kind != WhereKind.here) DirectionsButton(lat: c.lat, lon: c.lon),
        OutlinedButton.icon(
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.where_onMap),
          onPressed: () {
            ref.read(mapFocusProvider.notifier).stationId = c.id;
            context.go(mapRoute);
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.phishing_rounded),
          label: Text(l10n.where_fishHere),
          onPressed: () {
            ref.read(fishingSpotProvider.notifier).choose(c.id, mine: c.kind == WhereKind.here);
            context.go(fishingRoute);
          },
        ),
      ],
    );
  }
}
