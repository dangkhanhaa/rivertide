import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/fishing/application/where_to_go.dart';
import 'package:rivertide/features/fishing/presentation/widgets/where_row.dart';
import 'package:rivertide/features/map/map.dart';
import 'package:rivertide/features/stations/stations.dart';

/// "Hôm nay đi đâu?" (P2-21): the best places to fish near the user in the
/// next 24 hours, ranked by their best golden window.
class WhereToGoScreen extends ConsumerStatefulWidget {
  const WhereToGoScreen({super.key});

  @override
  ConsumerState<WhereToGoScreen> createState() => _WhereToGoScreenState();
}

class _WhereToGoScreenState extends ConsumerState<WhereToGoScreen> {
  ({double lat, double lon})? _origin;

  /// Origin is the last saved position, not a fresh fix.
  bool _approx = false;
  bool _locating = true;
  int _radiusKm = whereRadiiKm[1];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_quietOrigin()));
  }

  /// Without asking: a fresh fix when allowed, else the last known position.
  Future<void> _quietOrigin() async {
    final service = ref.read(locationServiceProvider);
    if (await service.hasPermission()) {
      if (await service.locate() case Located(:final lat, :final lon)) {
        return _set((lat: lat, lon: lon), approx: false);
      }
    }
    final last = await ref.read(lastPositionProvider.future);
    if (!mounted) return;
    if (last != null) return _set(last, approx: true);
    setState(() => _locating = false);
  }

  Future<void> _askLocation() async {
    setState(() => _locating = true);
    final p = await runLocateFlow(context, ref.read(locationServiceProvider));
    if (!mounted) return;
    if (p == null) return setState(() => _locating = false);
    unawaited(ref.read(locationPromptStoreProvider).saveLastPosition(p.lat, p.lon));
    _set(p, approx: false);
  }

  void _set(({double lat, double lon}) p, {required bool approx}) {
    if (!mounted) return;
    setState(() {
      _origin = p;
      _approx = approx;
      _locating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final origin = _origin;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.where_title),
        actions: [
          IconButton(
            tooltip: l10n.where_refresh,
            onPressed: _locating ? null : () => unawaited(_askLocation()),
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: switch (origin) {
        _ when _locating => const LoadingView(),
        null => _NeedLocation(onLocate: () => unawaited(_askLocation())),
        final o => _Ranking(
          query: (lat: o.lat, lon: o.lon, radiusKm: _radiusKm),
          approx: _approx,
          onRadius: (km) => setState(() => _radiusKm = km),
        ),
      },
    );
  }
}

class _NeedLocation extends StatelessWidget {
  const _NeedLocation({required this.onLocate});

  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.lg,
        children: [
          Text(
            context.l10n.where_needLocation,
            style: context.text.body,
            textAlign: TextAlign.center,
          ),
          FilledButton.icon(
            onPressed: onLocate,
            icon: const Icon(Icons.my_location_rounded),
            label: Text(context.l10n.where_useLocation),
          ),
        ],
      ),
    ),
  );
}

class _Ranking extends ConsumerWidget {
  const _Ranking({required this.query, required this.approx, required this.onRadius});

  final WhereQuery query;
  final bool approx;
  final ValueChanged<int> onRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final candidates = ref.watch(whereCandidatesProvider(query));
    final place = adminLine(ref, query.lat, query.lon);
    final around = approx
        ? l10n.where_aroundLast
        : (place == null ? l10n.where_aroundHere : l10n.where_around(place));
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(around, style: context.text.label),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<int>(
          segments: [
            for (final km in whereRadiiKm) ButtonSegment(value: km, label: Text(l10n.where_km(km))),
          ],
          selected: {query.radiusKm},
          onSelectionChanged: (s) => onRadius(s.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: AppSpacing.md),
        switch (candidates) {
          AsyncData(:final value) => RankedList(candidates: value),
          AsyncError(:final error) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(whereCandidatesProvider(query)),
          ),
          _ => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
        const SizedBox(height: AppSpacing.md),
        Text(l10n.where_note, style: context.text.caption),
      ],
    );
  }
}
