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

  /// The open phone detail sheet, so a list's "show on map" can replace it.
  BuildContext? _sheetContext;
  Completer<void>? _sheetClosed;

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

  /// Closes whatever detail is open so another place can be shown. Used by
  /// "show on map" from the lists: the old sheet stays open while the user is
  /// on another tab and would otherwise block the new point (and its zoom).
  Future<void> dismissDetail() async {
    if (sidePanel != null) closeSidePanel();
    final sheet = _sheetContext;
    final closed = _sheetClosed;
    if (sheet != null && sheet.mounted) Navigator.of(sheet).pop();
    if (closed != null) await closed.future;
    // Not a click on the map, so no click-through grace is needed.
    _releaseTimer?.cancel();
    if (mounted && sheetBusy) _setBusy(false);
  }

  /// Runs [action] (e.g. a dialog flow) with the map locked like for a sheet:
  /// on web the press on a dialog button also reaches the map, which then
  /// believes a drag started and swallows the next taps.
  Future<R> whileMapLocked<R>(Future<R> Function() action) async {
    _releaseTimer?.cancel();
    _setBusy(true);
    // Let the map apply the lock before the dialog can be pressed.
    await WidgetsBinding.instance.endOfFrame;
    try {
      return await action();
    } finally {
      _releaseTimer = Timer(_tapGrace, () => _setBusy(false));
    }
  }

  /// Ends the lock early when the next step opens details itself (which
  /// takes its own lock), e.g. "Đi câu ngay" right after locating.
  void releaseMapLock() {
    _releaseTimer?.cancel();
    _setBusy(false);
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
    final closed = _sheetClosed = Completer<void>();
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
          builder: (ctx, controller) {
            _sheetContext = ctx;
            return MapDetailPanel(
              scrollController: controller,
              onClose: () => Navigator.of(ctx).pop(),
              child: child,
            );
          },
        ),
      );
    } finally {
      _sheetContext = null;
      _releaseTimer = Timer(_tapGrace, () => _setBusy(false));
    }
    if (mounted) onDetailClosed();
    if (identical(_sheetClosed, closed)) _sheetClosed = null;
    closed.complete();
  }

  /// Opens [child] and moves the camera with [fly] so the place lands in the
  /// middle of the map part left visible. Wide: the panel opens first and the
  /// camera moves once the map has shrunk beside it (measured on web: a move
  /// made before that resize ends up off-centre by the panel's half width).
  /// Phone: the camera moves while the sheet opens.
  Future<void> showDetailAt(Widget child, Future<void> Function(Offset offset) fly) async {
    if (isWide) {
      final resizes = sidePanel == null;
      await showDetail(child);
      if (resizes) {
        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
      if (mounted) await fly(visibleOffset(detailOpen: true));
      return;
    }
    unawaited(fly(visibleOffset(detailOpen: true)));
    await showDetail(child);
  }

  /// Lists set the focus before switching to the map tab. On web a camera move
  /// made while the map is hidden ends up off-centre once it is shown, so wait
  /// until this tab is visible (tickers on) and its new size has settled.
  Future<void> untilMapShown() async {
    for (var i = 0; i < 40 && mounted && !TickerMode.valuesOf(context).enabled; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 150));
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
