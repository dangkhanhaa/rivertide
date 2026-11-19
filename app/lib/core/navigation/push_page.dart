import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route that shows a page opened with [pushPage] (web only, P2-44/P2-45).
/// `:k` is a key into an in-memory page table, not the page itself: the
/// router cannot keep a widget in browser history (it drops non-JSON
/// `extra`), so going back to an older page entry used to find nothing and
/// crashed with "no routes for location: /".
const String pageRoute = '/p/:k';

/// Pages kept for back/forward. Older ones are dropped; their history
/// entries then fall back to the home screen.
const int _keepPages = 60;
final LinkedHashMap<String, Widget> _pages = LinkedHashMap<String, Widget>();

/// Random per app start, so history entries left from a previous load of
/// the page never match a page of this one.
final String _session = Random().nextInt(1 << 30).toRadixString(36);
int _counter = 0;

final RegExp _keyPattern = RegExp(r'^[a-z0-9]{1,8}-[0-9]{1,6}$');

/// Opens a full screen. On the web it goes through the router so the page
/// gets a browser-history entry: Safari's edge swipe and the browser back
/// button then return to the previous screen instead of leaving the app.
/// In the apps it is a plain push (predictive back / iOS swipe handle it).
Future<T?> pushPage<T>(BuildContext context, Widget page) {
  if (!kIsWeb) {
    return Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => page));
  }
  final key = '$_session-${++_counter}';
  _pages[key] = page;
  while (_pages.length > _keepPages) {
    _pages.remove(_pages.keys.first);
  }
  return GoRouter.of(context).push<T>('/p/$key');
}

/// Page for a `/p/:k` location, or null when it is unknown (reload, stale
/// or hand-typed link).
Widget? pageForKey(String? key) => key != null && _keyPattern.hasMatch(key) ? _pages[key] : null;
