import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/features/map/presentation/widgets/map_detail_panel.dart';

/// Screens at least this wide show details in a side panel next to the map.
const double wideLayoutMinWidth = 840;

/// Width of the right-hand detail panel on wide screens.
const double sidePanelWidth = 420;

/// Phone detail sheet opens at this share of the screen height.
const double sheetInitialSize = 0.55;

/// Shows station/point details: a draggable half-height sheet on phones, a
/// right-hand panel on wide screens (the map stays usable beside it).
mixin MapDetailPresenter<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Content of the side panel (wide layout only).
  Widget? sidePanel;

  /// True while a phone sheet is open and briefly after it closes. On web the
  /// click that dismisses a sheet also reaches the map underneath; without this
  /// the map would open a new point every time the user closes one.
  bool sheetBusy = false;
  Timer? _releaseTimer;

  static const Duration _tapGrace = Duration(milliseconds: 500);

  /// Also locks the map's own gestures (see BaseMapConfig.gesturesEnabled):
  /// on web a drag on the sheet would otherwise pan the map underneath.
  void _setBusy(bool busy) {
    if (!mounted) {
      sheetBusy = busy;
      return;
    }
    setState(() => sheetBusy = busy);
  }

  bool get isWide => MediaQuery.sizeOf(context).width >= wideLayoutMinWidth;

  /// The map area and the overlay at its top (search bar, notes).
  GlobalKey get mapAreaKey;
  GlobalKey get topOverlayKey;

  /// From the view centre to the centre of the map part the user can still
  /// see once details open: left of the side panel on wide screens, above the
  /// sheet on phones, below the search bar on both. Passed to flyTo so the
  /// chosen point lands in that middle instead of under a panel.
  Offset visibleOffset({required bool detailOpen}) {
    final map = mapAreaKey.currentContext?.findRenderObject();
    if (map is! RenderBox || !map.hasSize) return Offset.zero;
    final origin = map.localToGlobal(Offset.zero);
    final size = map.size;
    var top = 0.0;
    final overlay = topOverlayKey.currentContext?.findRenderObject();
    if (overlay is RenderBox && overlay.hasSize) {
      top = (overlay.localToGlobal(Offset(0, overlay.size.height)).dy - origin.dy).clamp(
        0,
        size.height / 2,
      );
    }
    final right = size.width;
    var bottom = size.height;
    // Wide layout: the map itself shrinks beside the panel (see MapScreen),
    // so only the search bar on top needs an offset.
    if (detailOpen && !isWide) {
      final sheetTop = MediaQuery.sizeOf(context).height * (1 - sheetInitialSize) - origin.dy;
      bottom = sheetTop.clamp(top + 1, size.height);
    }
    final visible = Offset(right / 2, (top + bottom) / 2);
    return Offset(size.width / 2, size.height / 2) - visible;
  }

  /// Called when the detail closes (pin removal etc.).
  void onDetailClosed();

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  void closeSidePanel() {
    setState(() => sidePanel = null);
    onDetailClosed();
  }

  /// A plain sheet (legend, filter, layers) with the same click guard.
  Future<void> showGuardedSheet(WidgetBuilder builder) async {
    _releaseTimer?.cancel();
    _setBusy(true);
    try {
      await showModalBottomSheet<void>(context: context, showDragHandle: true, builder: builder);
    } finally {
      _releaseTimer = Timer(_tapGrace, () => _setBusy(false));
    }
  }

  Future<void> showDetail(Widget child) async {
    if (isWide) {
      setState(() => sidePanel = child);
      return;
    }
    _releaseTimer?.cancel();
    _setBusy(true);
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (ctx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: sheetInitialSize,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (ctx, controller) => MapDetailPanel(
            scrollController: controller,
            onClose: () => Navigator.of(ctx).pop(),
            child: child,
          ),
        ),
      );
    } finally {
      _releaseTimer = Timer(_tapGrace, () => _setBusy(false));
    }
    if (mounted) onDetailClosed();
  }

  /// True when [global] falls on the open side panel.
  bool isOverSidePanel(Offset global) {
    if (sidePanel == null || !isWide) return false;
    final screen = MediaQuery.sizeOf(context);
    return global.dx >= screen.width - sidePanelWidth;
  }

  /// Right-hand panel for the wide layout, or nothing.
  Widget buildSidePanel(BuildContext context) {
    final panel = sidePanel;
    // Positioned even when empty: a non-positioned child would size the Stack.
    if (panel == null || !isWide) {
      return const Positioned(width: 0, height: 0, child: SizedBox.shrink());
    }
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      width: sidePanelWidth,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: MapDetailPanel(onClose: closeSidePanel, child: panel),
        ),
      ),
    );
  }
}
