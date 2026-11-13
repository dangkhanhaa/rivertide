import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/fishing/presentation/trip_planner_screen.dart';
import 'package:rivertide/features/fishing/presentation/widgets/advice_card.dart';
import 'package:rivertide/features/fishing/presentation/widgets/fishing_hero.dart';
import 'package:rivertide/features/fishing/presentation/widgets/golden_list.dart';
import 'package:rivertide/features/fishing/presentation/widgets/safety_banner.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_bars.dart';
import 'package:rivertide/features/fishing/presentation/widgets/spot_card.dart'
    show unawaitedLocate;
import 'package:rivertide/features/fishing/presentation/widgets/week_strip.dart';
import 'package:rivertide/features/journal/journal.dart';
import 'package:rivertide/features/stations/stations.dart';

/// S06 fishing for the spot the user picks (their position, a map point or a
/// saved place): today's score up top, shortcuts, advice, golden hours, 24 h
/// bars, 7 days, safety.
class FishingScreen extends ConsumerStatefulWidget {
  const FishingScreen({super.key});

  @override
  ConsumerState<FishingScreen> createState() => _FishingScreenState();
}

class _FishingScreenState extends ConsumerState<FishingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaitedLocate(ref));
  }

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final spot = ref.watch(fishingSpotProvider);
    final fishing = ref.watch(stationFishingProvider(spot.id));
    final today = fishing.value?.hours.take(24).toList() ?? const <FishingHourScore>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fishing_title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
        children: [
          FishingHero(today: today, hasWarning: SafetyBanner.worstOf(today) != SafetyLevel.none),
          const SizedBox(height: AppSpacing.md),
          QuickActionRow(
            actions: [
              QuickAction(
                icon: Icons.explore_rounded,
                color: c.fishGood,
                label: l10n.where_short,
                onTap: () => unawaited(context.push(whereRoute)),
              ),
              QuickAction(
                icon: Icons.event_available_rounded,
                color: c.primary,
                label: l10n.fishing_plan,
                onTap: () => _push(const TripPlannerScreen()),
              ),
              QuickAction(
                icon: Icons.menu_book_rounded,
                color: c.spot,
                label: l10n.journal_open,
                onTap: () => _push(const JournalScreen()),
              ),
              QuickAction(
                icon: Icons.waves_rounded,
                color: c.pond,
                label: l10n.nav_ponds,
                onTap: () => context.go(pondsRoute),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AsyncValueView(
            value: fishing,
            onRetry: () => ref.invalidate(stationFishingProvider(spot.id)),
            isEmpty: (f) => f.hours.isEmpty,
            emptyMessage: l10n.common_empty,
            data: (f) => _FishingBody(fishing: f, spotId: spot.id),
          ),
        ],
      ),
    );
  }
}

class _FishingBody extends StatelessWidget {
  const _FishingBody({required this.fishing, required this.spotId});

  final StationFishing fishing;
  final String spotId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = fishing.hours.take(24).toList();
    final worst = SafetyBanner.worstOf(today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (worst != SafetyLevel.none) ...[
          SafetyBanner(hours: today),
          const SizedBox(height: AppSpacing.md),
        ],
        AdviceCard(spotId: spotId),
        SectionTitle(title: l10n.fishing_golden, icon: Icons.star_rounded),
        GoldenList(windows: goldenWindows(today)),
        SectionTitle(title: l10n.fishing_hourly, icon: Icons.bar_chart_rounded),
        ScoreBars(hours: today),
        SectionTitle(title: l10n.fishing_next7, icon: Icons.calendar_view_week_rounded),
        WeekStrip(hours: fishing.hours),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.fishing_reference, style: context.text.caption),
      ],
    );
  }
}
