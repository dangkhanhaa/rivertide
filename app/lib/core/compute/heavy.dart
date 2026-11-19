import 'package:flutter/foundation.dart';

/// Runs CPU-heavy pure work (a week of fishing scores, ~700 hours × 4
/// samples) off the UI thread on phones, so scrolling and the map stay smooth
/// on slow devices. On the web there are no isolates: it runs inline.
///
/// [work] must only capture plain data (no providers, no BuildContext).
Future<T> runHeavy<T>(T Function() work) =>
    kIsWeb ? Future.value(work()) : compute((_) => work(), null, debugLabel: 'heavy');
