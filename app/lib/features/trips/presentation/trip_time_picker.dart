import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/features/trips/presentation/trip_widgets.dart';

const Duration _vn = Duration(hours: 7);
const List<int> _durations = [2, 4, 6, 8, 12];

/// Start (UTC) and length of a trip; edited in Vietnam time.
class TripTime {
  const TripTime({required this.startUtc, required this.hours});

  /// Next whole hour + 1, for 4 hours.
  factory TripTime.defaultFrom(DateTime nowUtc) => TripTime(
    startUtc: DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, nowUtc.hour + 2),
    hours: 4,
  );

  final DateTime startUtc;

  /// 1–24 (the server allows up to 24 h).
  final int hours;

  DateTime get endUtc => startUtc.add(Duration(hours: hours.clamp(1, 24)));

  /// Same window the server accepts.
  bool validAt(DateTime nowUtc) =>
      !startUtc.isBefore(nowUtc.subtract(const Duration(hours: 1))) &&
      startUtc.isBefore(nowUtc.add(const Duration(days: 30)));
}

/// Date, start time, length; plus one-tap golden windows of the place.
class TripTimePicker extends ConsumerWidget {
  const TripTimePicker({
    required this.pointId,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String pointId;
  final TripTime value;
  final ValueChanged<TripTime> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final local = value.startUtc.add(_vn);
    final hours = {..._durations, value.hours}.sorted((a, b) => a - b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text(l10n.trip_when, style: context.text.label),
        _Golden(pointId: pointId, onPick: onChanged),
        Row(
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(context, ref),
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(TimeFormat.dayShort(value.startUtc)),
              ),
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickTime(context, local),
                icon: const Icon(Icons.schedule_rounded),
                label: Text(TimeFormat.hm(value.startUtc)),
              ),
            ),
          ],
        ),
        Text(l10n.trip_duration, style: context.text.caption),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final h in hours)
              ChoiceChip(
                label: Text(l10n.trip_hours(h)),
                selected: value.hours == h,
                onSelected: (_) => onChanged(TripTime(startUtc: value.startUtc, hours: h)),
              ),
          ],
        ),
        Text(tripRange(value.startUtc, value.endUtc), style: context.text.bodyStrong),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = ref.read(clockProvider)().add(_vn);
    final local = value.startUtc.add(_vn);
    final picked = await showDatePicker(
      context: context,
      initialDate: local,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year, now.month, now.day + 29),
    );
    if (picked == null) return;
    final start = DateTime.utc(picked.year, picked.month, picked.day, local.hour, local.minute);
    onChanged(TripTime(startUtc: start.subtract(_vn), hours: value.hours));
  }

  Future<void> _pickTime(BuildContext context, DateTime local) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: local.hour, minute: local.minute),
    );
    if (picked == null) return;
    final start = DateTime.utc(local.year, local.month, local.day, picked.hour, picked.minute);
    onChanged(TripTime(startUtc: start.subtract(_vn), hours: value.hours));
  }
}

/// Upcoming golden windows (next 3 days) at the trip's place as quick picks.
class _Golden extends ConsumerWidget {
  const _Golden({required this.pointId, required this.onPick});

  final String pointId;
  final ValueChanged<TripTime> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fishing = ref.watch(stationFishingProvider(pointId)).value;
    if (fishing == null) return const SizedBox.shrink();
    final now = ref.watch(clockProvider)();
    final windows = [for (final day in fishing.hours.slices(24).take(4)) ...goldenWindows(day)]
        .where((w) => w.startUtc.isAfter(now))
        .take(4)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text(windows.isEmpty ? l10n.trip_noGolden : l10n.trip_golden, style: context.text.caption),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final w in windows)
              ActionChip(
                avatar: Icon(Icons.star_rounded, color: context.colors.fishGood),
                label: Text(
                  l10n.trip_goldenChip(
                    tripRange(w.startUtc, w.endUtc),
                    LevelFormat.decimal1(w.peakScore),
                  ),
                ),
                onPressed: () => onPick(
                  TripTime(startUtc: w.startUtc, hours: w.endUtc.difference(w.startUtc).inHours),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
