import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/golden_window.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/fishing/presentation/widgets/score_style.dart';

/// Up to 3 golden windows with the reasons behind them.
class GoldenList extends StatelessWidget {
  const GoldenList({required this.windows, super.key});

  final List<GoldenWindow> windows;

  @override
  Widget build(BuildContext context) {
    if (windows.isEmpty) return Text(context.l10n.fishing_noGolden, style: context.text.body);
    return Column(
      children: [
        for (final w in windows)
          Card(
            child: ListTile(
              leading: Icon(Icons.star_rounded, color: context.colors.fishHigh),
              title: Text(
                '${TimeFormat.hm(w.startUtc)} – ${TimeFormat.hm(w.endUtc)} · '
                '${LevelFormat.decimal1(w.peakScore)}/10',
                style: context.text.bodyStrong,
              ),
              subtitle: Text(
                w.reasons.map(context.factorName).join(' + '),
                style: context.text.caption,
              ),
            ),
          ),
      ].expand((w) => [w, const SizedBox(height: AppSpacing.sm)]).toList(),
    );
  }
}
