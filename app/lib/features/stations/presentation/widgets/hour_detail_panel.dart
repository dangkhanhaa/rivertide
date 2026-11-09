import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/tide/hourly_timeline.dart';
import 'package:rivertide/core/calc/tide/tide_queries.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';

/// Detail box for a tapped hour (AC-TIDE09-3): kind · level · rate/state · time to next
/// turn · fishing score · weather · observed − forecast.
class HourDetailPanel extends ConsumerWidget {
  const HourDetailPanel({
    required this.entry,
    required this.view,
    required this.onClose,
    super.key,
  });

  final HourEntry entry;
  final StationView view;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = entry.state;
    final rate = entry.rateCmPerH;
    final next = view.tide.data.prediction?.nextExtreme(entry.timeUtc);
    final delta = entry.observedMinusPredictedCm;
    final extras = ref.watch(hourExtrasProvider(view.tide.data.station.id, entry.timeUtc)).value;
    final weather = extras?.weather;
    final score = extras?.fishingScore;
    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.hourly_detailTitle(TimeFormat.hm(entry.timeUtc)),
                    style: context.text.title,
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose,
                ),
              ],
            ),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DataKindBadge(kind: entry.kind),
                Text(LevelFormat.meters(entry.levelCm), style: context.text.bodyStrong),
                if (state != null) TrendLabel(state: state, compact: true),
                if (rate != null) Text(LevelFormat.rate(rate), style: context.text.body),
              ],
            ),
            if (next != null)
              Text(
                l10n.hourly_untilNext(
                  context.extremeName(next.kind),
                  context.durationText(next.timeUtc.difference(entry.timeUtc)),
                ),
                style: context.text.body,
              ),
            if (score != null)
              Text(l10n.hourly_fishScore(LevelFormat.decimal1(score)), style: context.text.body),
            if (weather != null)
              Text(
                l10n.hourly_weather(
                  weather.temperatureC?.round().toString() ?? '—',
                  weather.windKmh?.round().toString() ?? '—',
                  weather.precipitationMm == null
                      ? '—'
                      : LevelFormat.decimal1(weather.precipitationMm ?? 0),
                ),
                style: context.text.body,
              ),
            if (delta != null)
              Text(l10n.hourly_obsMinusPred(LevelFormat.signedCm(delta)), style: context.text.body),
          ],
        ),
      ),
    );
  }
}
