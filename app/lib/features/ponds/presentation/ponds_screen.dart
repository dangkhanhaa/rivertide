import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/map/map.dart';
import 'package:rivertide/features/ponds/application/ponds_providers.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';
import 'package:rivertide/features/ponds/presentation/pond_detail.dart';
import 'package:rivertide/features/ponds/presentation/pond_form_screen.dart';
import 'package:rivertide/features/ponds/presentation/widgets/pond_card.dart';

enum _Filter { release, verified, followed }

/// Hồ câu tab (P2-28): ponds near the user, upcoming releases first.
class PondsScreen extends ConsumerStatefulWidget {
  const PondsScreen({super.key});

  @override
  ConsumerState<PondsScreen> createState() => _PondsScreenState();
}

class _PondsScreenState extends ConsumerState<PondsScreen> {
  ({double lat, double lon})? _origin;
  bool _locating = true;
  final Set<_Filter> _filters = {};

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
        return _set((lat: lat, lon: lon));
      }
    }
    _set(await ref.read(lastPositionProvider.future));
  }

  Future<void> _ask() async {
    setState(() => _locating = true);
    final p = await runLocateFlow(context, ref.read(locationServiceProvider));
    if (p != null) unawaited(ref.read(locationPromptStoreProvider).saveLastPosition(p.lat, p.lon));
    _set(p ?? _origin);
  }

  void _set(({double lat, double lon})? p) {
    if (!mounted) return;
    setState(() {
      _origin = p;
      _locating = false;
    });
  }

  Future<void> _add() async {
    final at = _origin;
    if (at == null) return unawaited(_ask());
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PondFormScreen(lat: at.lat, lon: at.lon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final origin = _origin;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pond_title),
        actions: [
          IconButton(
            tooltip: l10n.where_refresh,
            onPressed: _locating ? null : () => unawaited(_ask()),
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      floatingActionButton: Env.communityEnabled && origin != null
          ? FloatingActionButton.extended(
              onPressed: () => unawaited(_add()),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: Text(l10n.pond_add),
            )
          : null,
      body: switch (origin) {
        _ when _locating => const LoadingView(),
        null => _NeedLocation(onLocate: () => unawaited(_ask())),
        final o => _PondList(
          areaKey: pondsAreaKey(o.lat, o.lon),
          filters: _filters,
          onFilter: (f) =>
              setState(() => _filters.contains(f) ? _filters.remove(f) : _filters.add(f)),
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
            textAlign: TextAlign.center,
            style: context.text.body,
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

class _PondList extends ConsumerWidget {
  const _PondList({required this.areaKey, required this.filters, required this.onFilter});

  final String areaKey;
  final Set<_Filter> filters;
  final ValueChanged<_Filter> onFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ponds = ref.watch(nearbyPondsProvider(areaKey));
    final followed = ref.watch(followedPondsProvider).value ?? const <String>{};
    final now = ref.watch(clockProvider)();
    bool keep(Pond p) =>
        (!filters.contains(_Filter.release) || p.nextReleaseAt != null) &&
        (!filters.contains(_Filter.verified) || p.verified) &&
        (!filters.contains(_Filter.followed) || followed.contains(p.id));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(nearbyPondsProvider(areaKey)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl * 3,
        ),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final (f, label) in [
                (_Filter.release, l10n.pond_filterRelease),
                (_Filter.verified, l10n.pond_filterVerified),
                (_Filter.followed, l10n.pond_filterFollowed),
              ])
                FilterChip(
                  label: Text(label),
                  selected: filters.contains(f),
                  onSelected: (_) => onFilter(f),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          switch (ponds) {
            AsyncData(:final value) when value.isEmpty => EmptyView(message: l10n.pond_empty),
            AsyncData(:final value) => Column(
              spacing: AppSpacing.sm,
              children: [
                for (final p in _sorted(value.where(keep).toList(), followed, now))
                  PondCard(
                    pond: p,
                    onTap: () =>
                        Navigator.of(context)
                            .push(MaterialPageRoute<void>(builder: (_) => PondPage(pond: p))),
                  ),
              ],
            ),
            AsyncError(:final error) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(nearbyPondsProvider(areaKey)),
            ),
            _ => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: LoadingView()),
          },
        ],
      ),
    );
  }

  /// Followed ponds and releases in the next 3 days first, then nearest.
  static List<Pond> _sorted(List<Pond> ponds, Set<String> followed, DateTime now) {
    int rank(Pond p) {
      final soon = p.nextReleaseAt?.isBefore(now.add(const Duration(days: 3))) ?? false;
      return (followed.contains(p.id) ? 0 : 2) + (soon ? 0 : 1);
    }

    return ponds..sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : (a.distanceKm ?? 1e9).compareTo(b.distanceKm ?? 1e9);
    });
  }
}
