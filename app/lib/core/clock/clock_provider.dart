import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

typedef Clock = DateTime Function();

/// The only place allowed to read the wall clock (docs/rules/02 §6).
@Riverpod(keepAlive: true)
Clock clock(Ref ref) =>
    () => DateTime.now().toUtc();

/// Emits the current UTC time now and then at the start of every minute.
@Riverpod(keepAlive: true)
Stream<DateTime> minuteTicker(Ref ref) {
  final now = ref.watch(clockProvider);
  final controller = StreamController<DateTime>();
  Timer? periodic;
  final first = now();
  controller.add(first);
  final untilNextMinute = Duration(seconds: 60 - first.second, milliseconds: -first.millisecond);
  final align = Timer(untilNextMinute, () {
    controller.add(now());
    periodic = Timer.periodic(const Duration(minutes: 1), (_) => controller.add(now()));
  });
  ref.onDispose(() {
    align.cancel();
    periodic?.cancel();
    unawaited(controller.close());
  });
  return controller.stream;
}
