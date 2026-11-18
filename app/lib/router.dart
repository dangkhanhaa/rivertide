import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/navigation/map_focus.dart';
import 'package:rivertide/core/widgets/state_views.dart';
import 'package:rivertide/features/fishing/presentation/fishing_screen.dart';
import 'package:rivertide/features/fishing/presentation/where_to_go_screen.dart';
import 'package:rivertide/features/map/presentation/map_screen.dart';
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
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _Shell(shell: shell),
      branches: [
        _branch(Routes.map, const MapScreen()),
        _branch(Routes.ponds, const PondsScreen()),
        _branch(Routes.watch, const WatchScreen()),
        _branch(Routes.fishing, const FishingScreen()),
        _branch(Routes.more, const MoreScreen()),
      ],
    ),
    GoRoute(path: whereRoute, builder: (_, _) => const WhereToGoScreen()),
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
class _Shell extends StatefulWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
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
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map_rounded),
              label: l10n.nav_map,
            ),
            NavigationDestination(
              icon: const Icon(Icons.waves_outlined),
              selectedIcon: const Icon(Icons.waves_rounded),
              label: l10n.nav_ponds,
            ),
            NavigationDestination(
              icon: const Icon(Icons.star_outline_rounded),
              selectedIcon: const Icon(Icons.star_rounded),
              label: l10n.nav_watch,
            ),
            NavigationDestination(
              icon: const Icon(Icons.phishing_rounded),
              label: l10n.nav_fishing,
            ),
            NavigationDestination(icon: const Icon(Icons.menu_rounded), label: l10n.nav_more),
          ],
        ),
      ),
    );
  }
}
