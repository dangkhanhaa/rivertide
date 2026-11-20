import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/social_errors.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/checkin/application/bite_providers.dart';
import 'package:rivertide/features/checkin/data/bite_repository.dart';

/// Minimum answers before an area pattern is shown.
const int bitePatternMin = 8;

/// "Có dính không? 👍/👎" (P2-37): one tap during/after a golden window, the
/// last 3 hours of answers around here, and what worked in this area.
class BiteCard extends ConsumerStatefulWidget {
  const BiteCard({
    required this.lat,
    required this.lon,
    required this.ask,
    this.tideState,
    this.localHour,
    this.appScore,
    super.key,
  });

  final double lat;
  final double lon;

  /// Show the question (around a golden window); otherwise results only.
  final bool ask;

  /// 'rising' / 'falling' / 'slack' now.
  final String? tideState;
  final int? localHour;
  final double? appScore;

  @override
  ConsumerState<BiteCard> createState() => _BiteCardState();
}

class _BiteCardState extends ConsumerState<BiteCard> {
  bool _sending = false;

  Future<void> _answer(bool bite) async {
    setState(() => _sending = true);
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(lastBiteReportProvider.notifier)
          .report(
            lat: widget.lat,
            lon: widget.lon,
            bite: bite,
            tideState: widget.tideState,
            localHour: widget.localHour,
            appScore: widget.appScore,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.bite_thanks)));
    } on AppException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            socialErrorText(l10n, e, fallback: l10n.bite_failed, limit: l10n.bite_tooSoon),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = biteKey(widget.lat, widget.lon);
    final summary = ref.watch(biteSummaryProvider(key)).value;
    final patterns = ref.watch(bitePatternsProvider(key)).value ?? const <BitePattern>[];
    final last = ref.watch(lastBiteReportProvider).value;
    final now = ref.watch(clockProvider)();
    final answered = last != null && now.difference(last) < biteAskPause;
    final ask = widget.ask && !answered;
    final total = (summary?.bites ?? 0) + (summary?.misses ?? 0);
    final best = _bestPattern(patterns);
    if (!ask && total == 0 && best == null) return const SizedBox.shrink();
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.sm,
            children: [
              if (ask) ...[
                Text(context.l10n.bite_question, style: context.text.title),
                Row(
                  spacing: AppSpacing.sm,
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _sending ? null : () => unawaited(_answer(true)),
                        icon: const Icon(Icons.thumb_up_alt_rounded),
                        label: Text(context.l10n.bite_yes),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sending ? null : () => unawaited(_answer(false)),
                        icon: const Icon(Icons.thumb_down_alt_outlined),
                        label: Text(context.l10n.bite_no),
                      ),
                    ),
                  ],
                ),
              ],
              if (total > 0 && summary != null)
                _Line(
                  icon: Icons.groups_rounded,
                  color: c.fishGood,
                  text: context.l10n.bite_summary(summary.bites, summary.misses),
                )
              else if (ask)
                Text(context.l10n.bite_first, style: context.text.caption),
              if (best != null)
                _Line(
                  icon: Icons.insights_rounded,
                  color: c.primary,
                  text: context.l10n.bite_pattern(
                    _stateName(context, best.tideState),
                    (best.bites * 100 / (best.bites + best.misses)).round(),
                  ),
                ),
              Text(context.l10n.bite_note, style: context.text.caption),
            ],
          ),
        ),
      ),
    );
  }

  /// The water state with the highest bite rate, once there is enough data.
  static BitePattern? _bestPattern(List<BitePattern> ps) {
    final enough = ps.where((p) => p.bites + p.misses >= bitePatternMin && p.bites > 0);
    return enough.sortedBy<num>((p) => -p.bites / (p.bites + p.misses)).firstOrNull;
  }

  static String _stateName(BuildContext context, String s) => switch (s) {
    'rising' => context.l10n.bite_rising,
    'falling' => context.l10n.bite_falling,
    _ => context.l10n.bite_slack,
  };
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.sm,
    children: [
      Icon(icon, color: color, size: AppIconSize.sm),
      Expanded(child: Text(text, style: context.text.body)),
    ],
  );
}
