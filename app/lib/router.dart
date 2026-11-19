import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/navigation/map_focus.dart';
import 'package:rivertide/core/navigation/push_page.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/core/widgets/fade_branches.dart';
import 'package:rivertide/core/widgets/floating_nav_bar.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/fishing/presentation/fishing_screen.dart';
import 'package:rivertide/features/fishing/presentation/where_to_go_screen.dart';
import 'package:rivertide/features/map/presentation/map_screen.dart';
import 'package:rivertide/features/more/application/appearance_provider.dart';
import 'package:rivertide/features/more/presentation/more_screen.dart';
import 'package:rivertide/features/ponds/ponds.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/features/watch/presentation/watch_screen.dart';

abstract final class Routes {
  static const String map = mapRoute;
  static const String ponds = pondsRoute;
  static const watch = '/watch';
  static const fishing = '/fishing';
  static const more = '/more';
  static const station = '/station/:id';
}

/// Route ids must look like our station ids (docs/rules/01 §6).
final _stationId = RegExp(r'^[a-z0-9-]{3,64}$');

GoRouter buildRouter() => GoRouter(
  initialLocation: Routes.map,
  // Going back to the very first browser-history entry lands on "/" (the
  // page as it was loaded): that is the map, not an error page.
  redirect: (_, state) => state.uri.path.isEmpty || state.uri.path == '/' ? Routes.map : null,
  // Any other unknown location (old or hand-typed link): home, never the
  // router's error page.
  onException: (_, _, router) => router.go(Routes.map),
  routes: [
    StatefulShellRoute(
      builder: (context, state, shell) => _Shell(shell: shell),
      navigatorContainerBuilder: (context, shell, children) =>
          FadeBranches(index: shell.currentIndex, children: children),
      branches: [
        _branch(Routes.map, const MapScreen()),
        _branch(Routes.ponds, const PondsScreen()),
        _branch(Routes.watch, const WatchScreen()),
        _branch(Routes.fishing, const FishingScreen()),
        _branch(Routes.more, const MoreScreen()),
      ],
    ),
    GoRoute(path: whereRoute, builder: (_, _) => const WhereToGoScreen()),
    // Web pages opened with pushPage (P2-44): one browser-history entry each.
    GoRoute(
      path: pageRoute,
      redirect: (_, state) => pageForKey(state.pathParameters['k']) == null ? Routes.map : null,
      builder: (_, state) => pageForKey(state.pathParameters['k']) ?? const SizedBox.shrink(),
    ),
    GoRoute(
      path: Routes.station,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        if (!_stationId.hasMatch(id)) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyView(message: context.l10n.error_notFound),
          );
        }
        return StationDetailScreen(stationId: id);
      },
    ),
  ],
);

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => screen)],
);

/// Bottom-tab shell. System back (Android swipe from the edge) on a tab
/// other than the map returns to the map instead of closing the app; on the
/// map a second back within 2 s closes it. Pages pushed inside a tab are
/// popped first by the router, so back still returns to the previous screen.
class _Shell extends ConsumerStatefulWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  static const Duration _exitWindow = Duration(seconds: 2);
  Timer? _armed;

  @override
  void dispose() {
    _armed?.cancel();
    super.dispose();
  }

  void _onBack(bool didPop, Object? _) {
    if (didPop) return;
    final shell = widget.shell;
    if (shell.currentIndex != 0) {
      shell.goBranch(0);
      return;
    }
    setState(
      () => _armed = Timer(_exitWindow, () {
        if (mounted) setState(() => _armed = null);
      }),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.nav_backAgain), duration: _exitWindow));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shell = widget.shell;
    return PopScope(
      canPop: shell.currentIndex == 0 && (_armed?.isActive ?? false),
      onPopInvokedWithResult: _onBack,
      child: Scaffold(
        // The map runs under the floating bar (no grey band); the map screen
        // lifts its own controls by the bar height it gets as padding.
        extendBody: shell.currentIndex == 0,
        body: shell,
        bottomNavigationBar: FloatingNavBar(
          index: shell.currentIndex,
          style: ref.watch(appearanceSettingsProvider).value?.navStyle ?? NavStyle.notch,
          onTap: (i) {
            // Sheets live on the root navigator: close them so a map sheet
            // never stays open over another tab.
            Navigator.of(context, rootNavigator: true).popUntil((r) => r is! PopupRoute);
            shell.goBranch(i, initialLocation: i == shell.currentIndex);
          },
          items: [
            (icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: l10n.nav_map),
            (icon: Icons.waves_outlined, selectedIcon: Icons.waves_rounded, label: l10n.nav_ponds),
            (
              icon: Icons.star_outline_rounded,
              selectedIcon: Icons.star_rounded,
              label: l10n.nav_watch,
            ),
            (
              icon: Icons.phishing_outlined,
              selectedIcon: Icons.phishing_rounded,
              label: l10n.nav_fishing,
            ),
            (icon: Icons.menu_rounded, selectedIcon: Icons.menu_open_rounded, label: l10n.nav_more),
          ],
        ),
      ),
    );
  }
}
