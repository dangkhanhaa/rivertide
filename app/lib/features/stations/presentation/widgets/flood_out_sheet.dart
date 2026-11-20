import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/tide/flood_out.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/notify/flood_alarm.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/hour_extras_provider.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';

/// "Mấy giờ nước ngập lối về?" (P2-33) for a tidal place.
void showFloodOutSheet(BuildContext context, StationView view, String placeName) => unawaited(
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FloodOutSheet(view: view, placeName: placeName),
  ),
);

class FloodOutSheet extends ConsumerStatefulWidget {
  const FloodOutSheet({required this.view, required this.placeName, super.key});

  final StationView view;
  final String placeName;

  @override
  ConsumerState<FloodOutSheet> createState() => _FloodOutSheetState();
}

class _FloodOutSheetState extends ConsumerState<FloodOutSheet> {
  int _margin = 50;
  DateTime? _alarm;

  String get _id => widget.view.tide.data.station.id;

  @override
  void initState() {
    super.initState();
    unawaited(
      FloodAlarm.pendingFor(ref.read(appDatabaseProvider), _id, widget.view.nowUtc).then((a) {
        if (mounted) setState(() => _alarm = a);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final series = widget.view.tide.data.prediction;
    final now = widget.view.nowUtc;
    final hour = DateTime.utc(now.year, now.month, now.day, now.hour);
    final weather = ref.watch(stationFishingProvider(_id)).value?.weather;
    final w = weather?.firstWhereOrNull((x) => x.timeUtc == hour);
    final wind = [w?.windKmh, w?.gustKmh].nonNulls.fold<double>(0, (a, b) => a > b ? a : b);
    final windy = wind >= floodWindKmh;
    final result = series == null
        ? null
        : floodOut(series, now, marginCm: _margin, windExtraCm: windy ? windSetupCm : 0);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            Text(l10n.flood_title, style: context.text.title),
            Text(l10n.flood_ask, style: context.text.body),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _margin.toDouble(),
                    min: 10,
                    max: 200,
                    divisions: 19,
                    label: l10n.flood_margin(_margin),
                    onChanged: (v) => setState(() => _margin = v.round()),
                  ),
                ),
                Text(l10n.flood_margin(_margin), style: context.text.bodyStrong),
              ],
            ),
            if (result == null)
              Text(l10n.flood_noTide, style: context.text.body)
            else
              _Result(result: result, nowUtc: now),
            if (windy) _Warn(text: l10n.flood_windy),
            if (result != null) _alarmRow(context, result),
            Text(l10n.flood_note, style: context.text.caption),
            Text(l10n.legal_disclaimerShort, style: context.text.caption),
          ],
        ),
      ),
    );
  }

  Widget _alarmRow(BuildContext context, FloodOut r) {
    final l10n = context.l10n;
    final flood = r.floodUtc;
    final now = widget.view.nowUtc;
    final alarm = _alarm;
    if (alarm != null) {
      return OutlinedButton.icon(
        onPressed: () async {
          await FloodAlarm.cancel(ref.read(appDatabaseProvider));
          if (mounted) setState(() => _alarm = null);
        },
        icon: const Icon(Icons.alarm_off_rounded),
        label: Text(l10n.flood_alarmSet(TimeFormat.hm(alarm))),
      );
    }
    final at = flood?.subtract(floodLeaveBefore);
    if (flood == null || at == null || !at.isAfter(now)) return const SizedBox.shrink();
    if (!FloodAlarm.supported) return Text(l10n.flood_alarmApk, style: context.text.caption);
    return FilledButton.icon(
      onPressed: () async {
        final ok = await FloodAlarm.set(
          ref.read(appDatabaseProvider),
          atUtc: at,
          spotId: _id,
          title: l10n.flood_alarmTitle(widget.placeName),
          body: l10n.flood_alarmBody(TimeFormat.hm(flood)),
          channelName: l10n.flood_channel,
        );
        if (!mounted) return;
        if (ok) setState(() => _alarm = at);
      },
      icon: const Icon(Icons.alarm_add_rounded),
      label: Text(l10n.flood_alarmButton(TimeFormat.hm(at))),
    );
  }
}

/// The answer in big type: when the water arrives, when to leave, when it
/// drops again; or that it stays below for the next 24 hours.
class _Result extends StatelessWidget {
  const _Result({required this.result, required this.nowUtc});

  final FloodOut result;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final flood = result.floodUtc;
    final safe = flood == null;
    final color = safe ? c.ok : c.alarm3;
    final recede = result.recedeUtc;
    final peak = result.peakUtc;
    final peakCm = result.peakCm;
    final lines = <String>[
      if (flood != null && !flood.isAfter(nowUtc)) l10n.flood_already,
      if (flood != null && flood.isAfter(nowUtc)) ...[
        l10n.flood_leave(TimeFormat.hm(flood.subtract(floodLeaveBefore))),
        l10n.flood_in(_duration(context, flood.difference(nowUtc))),
      ],
      if (recede != null) l10n.flood_recede(TimeFormat.hm(recede)),
      if (peak != null && peakCm != null)
        l10n.flood_peak(TimeFormat.hm(peak), LevelFormat.meters(peakCm.round())),
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Row(
            spacing: AppSpacing.sm,
            children: [
              Icon(safe ? Icons.verified_rounded : Icons.water_rounded, color: color),
              Expanded(
                child: Text(
                  safe ? l10n.flood_safe : l10n.flood_at(TimeFormat.hm(flood)),
                  style: context.text.headline,
                ),
              ),
            ],
          ),
          for (final t in lines) Text(t, style: context.text.body),
        ],
      ),
    );
  }

  static String _duration(BuildContext context, Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h == 0 ? context.l10n.flood_minutes(m) : context.l10n.flood_hoursMinutes(h, m);
  }
}

class _Warn extends StatelessWidget {
  const _Warn({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.sm,
    children: [
      Icon(Icons.air_rounded, color: context.colors.alarm2, size: AppIconSize.sm),
      Expanded(child: Text(text, style: context.text.body)),
    ],
  );
}
