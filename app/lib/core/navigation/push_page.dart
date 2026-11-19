import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route that shows a page handed over as `extra` (web only, P2-44).
const String pageRoute = '/p';

/// Opens a full screen. On the web it goes through the router so the page
/// gets a browser-history entry: Safari's edge swipe and the browser back
/// button then return to the previous screen instead of leaving the app.
/// In the apps it is a plain push (predictive back / iOS swipe handle it).
Future<T?> pushPage<T>(BuildContext context, Widget page) => kIsWeb
    ? GoRouter.of(context).push<T>(pageRoute, extra: page)
    : Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => page));

/// Builder for [pageRoute]. After a browser reload the page object is gone
/// (it cannot be stored in the URL): fall back to the home screen.
Widget pageFromExtra(BuildContext context, Object? extra) {
  if (extra is Widget) return extra;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) GoRouter.of(context).go('/');
  });
  return const SizedBox.shrink();
}
