import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/features/fishing/presentation/trip_planner_screen.dart';
import 'package:rivertide/features/fishing/presentation/widgets/advice_card.dart';
import 'package:rivertide/features/fishing/presentation/widgets/day_score_card.dart';
import 'package:rivertide/features/fishing/presentation/widgets/golden_list.dart';
import 'package:rivertide/features/fishing/presentation/widgets/safety_banner.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_bars.dart';
import 'package:rivertide/features/fishing/presentation/widgets/spot_card.dart';
import 'package:rivertide/features/fishing/presentation/widgets/week_strip.dart';
import 'package:rivertide/features/fishing/presentation/widgets/where_entry_card.dart';
import 'package:rivertide/features/journal/journal.dart';
import 'package:rivertide/features/stations/stations.dart';

/// S06 fishing for the spot the user picks (their position, a map point or a
/// saved place): advice, day score, golden hours, 24 h bars, 7 days, safety.
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

  @override
  Widget build(BuildContext context) {
    final spot = ref.watch(fishingSpotProvider);
    final fishing = ref.watch(stationFishingProvider(spot.id));
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.fishing_title),
        actions: [
          IconButton(
            tooltip: context.l10n.trip_open,
            icon: const Icon(Icons.event_available_rounded),
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const TripPlannerScreen())),
          ),
          IconButton(
            tooltip: context.l10n.journal_open,
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const JournalScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const WhereEntryCard(),
          const SizedBox(height: AppSpacing.md),
          const SpotCard(),
          const SizedBox(height: AppSpacing.md),
          AsyncValueView(
            value: fishing,
            onRetry: () => ref.invalidate(stationFishingProvider(spot.id)),
            isEmpty: (f) => f.hours.isEmpty,
            emptyMessage: context.l10n.common_empty,
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
    final today = fishing.hours.take(24).toList();
    final worst = SafetyBanner.worstOf(today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdviceCard(spotId: spotId),
        const SizedBox(height: AppSpacing.md),
        if (worst != SafetyLevel.none) ...[
          SafetyBanner(hours: today),
          const SizedBox(height: AppSpacing.md),
        ],
        DayScoreCard(
          score: dayScore(today),
          dayStartUtc: today.first.hourUtc,
          hasWarning: worst != SafetyLevel.none,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.fishing_golden, style: context.text.title),
        const SizedBox(height: AppSpacing.sm),
        GoldenList(windows: goldenWindows(today)),
        const SizedBox(height: AppSpacing.lg),
        ScoreBars(hours: today),
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.fishing_next7, style: context.text.title),
        const SizedBox(height: AppSpacing.sm),
        WeekStrip(hours: fishing.hours),
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.fishing_reference, style: context.text.caption),
      ],
    );
  }
}
