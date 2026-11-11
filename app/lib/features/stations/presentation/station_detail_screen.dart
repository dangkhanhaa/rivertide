import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/widgets/async_value_view.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/stations/application/station_providers.dart';
import 'package:rivertide/features/stations/application/station_view_providers.dart';
import 'package:rivertide/features/stations/domain/station.dart';
import 'package:rivertide/features/stations/presentation/tabs/calendar_tab.dart';
import 'package:rivertide/features/stations/presentation/tabs/hourly_tab.dart';
import 'package:rivertide/features/stations/presentation/tabs/info_tab.dart';
import 'package:rivertide/features/stations/presentation/tabs/overview_tab.dart';
import 'package:rivertide/features/stations/presentation/widgets/share_place.dart';
import 'package:rivertide/features/stations/presentation/widgets/station_sheet.dart';

/// S03 station detail with tabs Tổng quan · Theo giờ · Lịch triều · Thông tin.
class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({required this.stationId, super.key});

  final String stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final station = ref.watch(stationByIdProvider(stationId));
    if (station.value case final s?) return _DetailScaffold(station: s);
    // Loading / error still need a page (back button, Material text style).
    return Scaffold(
      appBar: AppBar(),
      body: AsyncValueView(
        value: station,
        onRetry: () => ref.invalidate(stationByIdProvider(stationId)),
        data: (s) => const SizedBox.shrink(),
      ),
    );
  }
}

class _DetailScaffold extends ConsumerWidget {
  const _DetailScaffold({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = ref.watch(stationViewProvider(station.id));
    final isFavorite = ref.watch(favoriteIdsProvider).value?.contains(station.id) ?? false;
    // No tide here: a tide calendar would only ever be empty.
    final loaded = view.value;
    final calendar = loaded == null || !levelUnknown(loaded.tide.data);
    return DefaultTabController(
      length: calendar ? 4 : 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(station.name),
          actions: [
            SharePlaceButton(stationId: station.id, title: station.name),
            IconButton(
              tooltip: isFavorite ? l10n.station_unfollow : l10n.station_follow,
              icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
              onPressed: () => toggleFavorite(ref, station.id),
            ),
          ],
          // Fixed tabs: all four stay visible on a 360 dp phone (scrollable hid "Thông tin").
          bottom: TabBar(
            labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            tabs: [
              Tab(text: l10n.station_tabOverview),
              Tab(text: l10n.station_tabHourly),
              if (calendar) Tab(text: l10n.station_tabCalendar),
              Tab(text: l10n.station_tabInfo),
            ],
          ),
        ),
        body: AsyncValueView(
          value: view,
          onRetry: () => ref.invalidate(stationTideProvider(station.id)),
          data: (v) => Column(
            children: [
              if (v.tide.isStale) StaleBanner(updatedAtText: TimeFormat.hm(v.tide.fetchedAtUtc)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => refreshStation(ref, station.id),
                  child: TabBarView(
                    children: [
                      OverviewTab(view: v),
                      HourlyTab(view: v),
                      if (calendar) CalendarTab(view: v),
                      InfoTab(view: v),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
