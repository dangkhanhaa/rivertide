import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fish_time.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/fish_activity_style.dart';
import 'package:rivertide/core/widgets/fish_scene.dart';

/// "Cá ăn lúc …" pill over the map (P2-20): tap to open an hour slider for the
/// next two days and the colour legend; the fish pins follow the chosen hour.
class FishTimeBar extends ConsumerStatefulWidget {
  const FishTimeBar({super.key});

  @override
  ConsumerState<FishTimeBar> createState() => _FishTimeBarState();
}

class _FishTimeBarState extends ConsumerState<FishTimeBar> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final ahead = ref.watch(fishTimeProvider);
    final now = ref.watch(minuteTickerProvider).value ?? ref.watch(clockProvider)();
    final label = context.fishTimeLabel(now, fishHourUtc(now, ahead));
    return Material(
      color: c.surface,
      elevation: 4,
      shadowColor: c.onSurface.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Head(
              label: label,
              open: _open,
              moved: ahead > 0,
              onToggle: () => setState(() => _open = !_open),
              onReset: () => ref.read(fishTimeProvider.notifier).hoursAhead = 0,
            ),
            if (_open) ...[
              Slider(
                value: ahead.toDouble(),
                max: fishTimeMaxHours.toDouble(),
                divisions: fishTimeMaxHours,
                label: label,
                semanticFormatterCallback: (_) => label,
                onChanged: (v) => ref.read(fishTimeProvider.notifier).hoursAhead = v.round(),
              ),
              const _Legend(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Text(l10n.fishTime_legendNote, style: context.text.caption),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({
    required this.label,
    required this.open,
    required this.moved,
    required this.onToggle,
    required this.onReset,
  });

  final String label;
  final bool open;
  final bool moved;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return InkWell(
      onTap: onToggle,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Row(
            children: [
              FishGlyph(color: c.fishGood, eye: c.surface),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${l10n.fishTime_title} ', style: context.text.caption),
                      TextSpan(text: label, style: context.text.bodyStrong),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (moved)
                IconButton(
                  tooltip: l10n.fishTime_reset,
                  onPressed: onReset,
                  icon: const Icon(Icons.restore_rounded),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  open ? Icons.expand_more_rounded : Icons.expand_less_rounded,
                  semanticLabel: open ? l10n.fishTime_collapse : l10n.fishTime_expand,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colour + word for each band (never colour alone).
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final a in FishActivity.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FishGlyph(color: context.fishActivityColor(a), size: AppIconSize.sm),
              const SizedBox(width: AppSpacing.xs),
              Text(context.fishActivityName(a), style: context.text.label),
            ],
          ),
      ],
    ),
  );
}
