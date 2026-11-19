import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/features/more/application/onboarding_provider.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_flow.dart';

/// Shows the welcome flow instead of the app on first launch (P2-53).
///
/// The app (router) is not built until the flow ends, so the map does not
/// start locating or asking for permissions underneath it, and a link the
/// app was opened with stays in the router until then. A launch from a
/// shared link skips the flow this time (the link is what the user came
/// for); it shows on the next plain launch.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({
    required this.app,
    required this.openedByLink,
    required this.onFinished,
    super.key,
  });

  final Widget app;
  final bool openedByLink;

  /// Called once the flow is done, just before the app is built.
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(onboardingProgressProvider);
    final shown = switch (progress) {
      AsyncData(value: final step?) when !openedByLink => _FirstRun(
        key: const ValueKey('onboarding'),
        step: step,
        onDone: () async {
          // Start tab first, so the router is built straight on it.
          onFinished();
          await ref.read(onboardingProgressProvider.notifier).finish();
        },
      ),
      // A blink while the local database opens; never on an error (the app
      // must stay usable even if the flag cannot be read).
      AsyncLoading() => ColoredBox(key: const ValueKey('wait'), color: context.colors.surfaceAlt),
      _ => KeyedSubtree(key: const ValueKey('app'), child: app),
    };
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduce ? Duration.zero : const Duration(milliseconds: 520),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: shown,
    );
  }
}

/// The flow needs its own navigator: text fields and tooltips need an
/// overlay, and the app's navigator does not exist yet.
class _FirstRun extends StatelessWidget {
  const _FirstRun({required this.step, required this.onDone, super.key});

  final int step;
  final Future<void> Function() onDone;

  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (_) => PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => OnboardingFlow(initialStep: step, onDone: onDone),
    ),
  );
}

/// "Xem lại phần chào mừng" in Thêm: the same flow over the app, closing
/// back to where the user was; progress is not saved.
Future<void> replayOnboarding(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => OnboardingFlow(
          initialStep: 0,
          resumable: false,
          onDone: () async => Navigator.of(ctx).pop(),
        ),
      ),
    );
