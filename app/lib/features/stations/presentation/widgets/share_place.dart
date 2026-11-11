import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/capture.dart';
import 'package:rivertide/core/widgets/data_labels.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_chart.dart';
import 'package:rivertide/features/stations/presentation/widgets/tide_text.dart';
import 'package:share_plus/share_plus.dart';

const Size _cardSize = Size(360, 420);

/// Share button: a picture of the place (level, trend, next turn, 24 h
/// curve, fishing score) plus a link that opens the same place in the app.
class SharePlaceButton extends ConsumerWidget {
  const SharePlaceButton({required this.stationId, required this.title, super.key});

  final String stationId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: context.l10n.share_action,
    icon: const Icon(Icons.share_rounded),
    onPressed: () => unawaited(_share(context, ref)),
  );

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final view = ref.read(stationViewProvider(stationId)).value;
    if (view == null) return;
    final fishing = ref.read(stationFishingProvider(stationId)).value;
    final now = view.nowUtc;
    final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
    final score = fishing?.hours.firstWhereOrNull((h) => h.hourUtc == hour)?.score;
    final link = '${Env.webAppUrl}#/station/$stationId';
    final l10n = context.l10n;
    final text = [
      l10n.share_text(title),
      if (view.now.levelCm case final lv?) l10n.share_level(LevelFormat.meters(lv)),
      if (score != null) l10n.share_score(LevelFormat.decimal1(score)),
      link,
    ].join('\n');
    final messenger = ScaffoldMessenger.of(context);
    final png = await captureWidget(
      context,
      _ShareCard(view: view, title: title, score: score),
      size: _cardSize,
    );
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: png == null
              ? null
              : [XFile.fromData(png, mimeType: 'image/png', name: 'con-nuoc.png')],
        ),
      );
    } on Exception catch (e) {
      // Browsers without the share sheet: the link goes to the clipboard.
      log.info('share sheet unavailable', {'error': '$e'});
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(SnackBar(content: Text(l10n.share_copied)));
    }
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.view, required this.title, required this.score});

  final StationView view;
  final String title;
  final double? score;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final now = view.now;
    final level = now.levelCm ?? now.lastKnown?.levelCm;
    final next = now.nextExtreme;
    final hour = DateTime.utc(
      view.nowUtc.year,
      view.nowUtc.month,
      view.nowUtc.day,
      view.nowUtc.hour,
    );
    return ColoredBox(
      color: c.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            Text(l10n.appTitle, style: context.text.label.copyWith(color: c.primary)),
            Text(title, style: context.text.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(
              '${TimeFormat.dayShort(view.nowUtc)} ${TimeFormat.hm(view.nowUtc)}',
              style: context.text.caption,
            ),
            if (level != null) Text(LevelFormat.meters(level), style: context.text.displayLevel),
            if (now.state case final s?) TrendLabel(state: s),
            if (next != null)
              Text(
                '${context.extremeName(next.kind)} ${TimeFormat.hm(next.timeUtc)} · '
                '${LevelFormat.meters(next.levelCm)}',
                style: context.text.body,
              ),
            if (view.tide.data.prediction case final p?)
              TideChart(
                height: 120,
                fromUtc: hour.subtract(const Duration(hours: 6)),
                toUtc: hour.add(const Duration(hours: 18)),
                nowUtc: view.nowUtc,
                // Same curve as the place's page: readings + corrected forecast.
                observed: {for (final o in view.tide.data.observations) o.timeUtc: o.levelCm},
                prediction: p,
                latestObservation: view.tide.data.anchor,
              ),
            if (score case final s?)
              Text(l10n.share_score(LevelFormat.decimal1(s)), style: context.text.bodyStrong),
            const Spacer(),
            Text(l10n.share_footer, style: context.text.caption),
          ],
        ),
      ),
    );
  }
}
