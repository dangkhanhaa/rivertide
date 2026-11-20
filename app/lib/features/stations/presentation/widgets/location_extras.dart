import 'package:flutter/material.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/presentation/widgets/sun_moon_lines.dart';

/// Sunrise/sunset and moon for the place; the weather itself is in
/// ForecastSection right above (P2-55).
class Conditions extends StatelessWidget {
  const Conditions({required this.view, super.key});

  final StationView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = view.tide.data.station;
    final now = view.nowUtc;
    return _Section(
      icon: Icons.wb_twilight_rounded,
      title: l10n.cond_title,
      children: [
        SunMoonLines(
          lat: st.lat,
          lon: st.lon,
          dayStartUtc: TimeFormat.vnDayStartUtc(now),
          nowUtc: now,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children});

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Row(
            children: [
              Icon(icon, size: AppIconSize.sm),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: context.text.label)),
            ],
          ),
          ...children,
        ],
      ),
    ),
  );
}
