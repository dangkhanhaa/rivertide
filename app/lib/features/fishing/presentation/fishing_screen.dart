import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/fishing/application/fishing_selection.dart';
import 'package:rivertide/features/fishing/presentation/widgets/day_score_card.dart';
import 'package:rivertide/features/fishing/presentation/widgets/golden_list.dart';
import 'package:rivertide/features/fishing/presentation/widgets/safety_banner.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_bars.dart';
import 'package:rivertide/features/fishing/presentation/widgets/station_picker.dart';
import 'package:rivertide/features/fishing/presentation/widgets/week_strip.dart';
import 'package:rivertide/features/stations/stations.dart';

/// S06 fishing: day score, golden hours, 24 h bars, 7-day strip, safety banner.
class FishingScreen extends ConsumerWidget {
  const FishingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationId = ref.watch(fishingStationProvider);
    final fishing = ref.watch(stationFishingProvider(stationId));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.fishing_title)),
      body: Column(
        children: [
          const StationPicker(),
          Expanded(
            child: AsyncValueView(
              value: fishing,
              onRetry: () => ref.invalidate(stationFishingProvider(stationId)),
              isEmpty: (f) => f.hours.isEmpty,
              emptyMessage: context.l10n.common_empty,
              data: (f) => _FishingBody(fishing: f),
            ),
          ),
        ],
      ),
    );
  }
}

class _FishingBody extends StatelessWidget {
  const _FishingBody({required this.fishing});

  final StationFishing fishing;

  @override
  Widget build(BuildContext context) {
    final today = fishing.hours.take(24).toList();
    final worst = SafetyBanner.worstOf(today);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
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
        SourceAttribution(source: context.l10n.fishing_weatherSource),
      ],
    );
  }
}
