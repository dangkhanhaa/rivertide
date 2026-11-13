import 'package:flutter/material.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/trips/domain/trip.dart';

/// "T7, 15/11 05:00–09:00" (end date added when the trip runs past midnight).
String tripWhen(Trip t) => tripRange(t.startsAt, t.endsAt);

String tripRange(DateTime startUtc, DateTime endUtc) {
  final sameDay = TimeFormat.vnDayStartUtc(startUtc) == TimeFormat.vnDayStartUtc(endUtc);
  final end = sameDay
      ? TimeFormat.hm(endUtc)
      : '${TimeFormat.dayShort(endUtc)} ${TimeFormat.hm(endUtc)}';
  return '${TimeFormat.dayShort(startUtc)} ${TimeFormat.hm(startUtc)}–$end';
}

/// Status pill: running / cancelled / full / places left (word + colour).
class TripStatusChip extends StatelessWidget {
  const TripStatusChip({required this.trip, required this.nowUtc, super.key});

  final Trip trip;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final t = trip;
    final (text, color) = switch (t) {
      _ when t.cancelled => (l10n.trip_cancelled, c.alarm3),
      _ when t.runningAt(nowUtc) => (l10n.trip_running, c.fishGood),
      _ when t.full => (l10n.trip_full, c.stale),
      _ => (l10n.trip_left(t.maxPeople - t.memberCount), c.trip),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(text, style: context.text.label.copyWith(color: color)),
    );
  }
}

/// Icon + text line used in trip cards and the sheet.
class TripLine extends StatelessWidget {
  const TripLine({required this.icon, required this.text, this.strong = false, super.key});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: AppIconSize.sm, color: context.colors.onSurfaceMuted),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(text, style: strong ? context.text.bodyStrong : context.text.body)),
    ],
  );
}
