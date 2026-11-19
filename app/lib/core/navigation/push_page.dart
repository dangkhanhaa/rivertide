import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/navigation/map_focus.dart';

/// Sub-route of every tab that shows a page opened with [pushPage]
/// (P2-44/P2-45/P2-46). `:k` is a key into an in-memory page table, not the
/// page itself: the router cannot keep a widget in browser history (it
/// drops non-JSON `extra`), so going back to an older entry used to find
/// nothing and crashed with "no routes for location: /".
const String pageSubRoute = 'p/:k';

/// Tab roots. Detail screens open inside the current tab, so the floating
/// tab bar stays on screen (P2-46).
const List<String> tabRoots = [mapRoute, pondsRoute, '/watch', fishingRoute, '/more'];

/// Pages kept for back/forward. Older ones are dropped; their history
/// entries then fall back to the home screen.
const int _keepPages = 60;
final LinkedHashMap<String, Widget> _pages = LinkedHashMap<String, Widget>();

/// Random per app start, so history entries left from a previous load of
/// the page never match a page of this one.
final String _session = Random().nextInt(1 << 30).toRadixString(36);
int _counter = 0;

final RegExp _keyPattern = RegExp(r'^[a-z0-9]{1,8}-[0-9]{1,6}$');

/// Opens a full screen inside the current tab. Going through the router
/// gives each page a browser-history entry on the web (Safari's edge swipe
/// and Back return to the previous screen) and keeps the tab bar visible.
Future<T?> pushPage<T>(BuildContext context, Widget page) {
  final key = '$_session-${++_counter}';
  _pages[key] = page;
  while (_pages.length > _keepPages) {
    _pages.remove(_pages.keys.first);
  }
  return pushInTab<T>(context, '/p/$key');
}

/// Pushes [sub] (e.g. `/station/x`, `/where`) under the current tab's root.
/// Sheets and dialogs sit on the root navigator above the tabs: they are
/// closed first, or the new page would open hidden underneath them.
Future<T?> pushInTab<T>(BuildContext context, String sub) {
  final router = GoRouter.of(context);
  final path = router.routerDelegate.currentConfiguration.uri.path;
  final root = tabRoots.firstWhere(
    (r) => path == r || path.startsWith('$r/'),
    orElse: () => mapRoute,
  );
  Navigator.of(context, rootNavigator: true).popUntil((r) => r is! PopupRoute);
  return router.push<T>('$root$sub');
}

/// Page for a `p/:k` location, or null when it is unknown (reload, stale
/// or hand-typed link).
Widget? pageForKey(String? key) => key != null && _keyPattern.hasMatch(key) ? _pages[key] : null;
