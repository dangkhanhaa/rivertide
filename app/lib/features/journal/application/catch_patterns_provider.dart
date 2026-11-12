import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/fishing/catch_patterns.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/features/journal/application/journal_providers.dart';

/// Patterns in the whole fishing log (P2-23); recomputed when the log changes.
final FutureProvider<PatternReport> catchPatternsProvider = FutureProvider.autoDispose(
  (ref) async => patternsOf(await ref.watch(catchesProvider.future)),
);

/// Patterns of [log], with each catch's conditions rebuilt from what was saved.
PatternReport patternsOf(List<CatchEntry> log) => findPatterns([
  for (final c in log)
    conditionsAt(
      utc: c.caughtAtUtc,
      lat: c.lat,
      lon: c.lon,
      tideState: c.waterState,
      windKmh: c.windKmh,
      moonPhase: c.moonPhase,
    ),
]);
