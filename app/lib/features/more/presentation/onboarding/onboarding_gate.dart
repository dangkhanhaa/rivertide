import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/features/more/application/onboarding_provider.dart';
import 'package:rivertide/features/more/application/terms_provider.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_flow.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_terms.dart';

/// What the app shows before its own screens (P2-53, P2-57):
///  * first plain launch → the welcome flow (ends with the terms);
///  * onboarding done (or opened from a shared link) but the current terms
///    not accepted → the terms screen alone;
///  * otherwise the app.
///
/// The app (router) is not built until then, so the map does not start
/// locating or asking for permissions underneath, and a link the app was
/// opened with waits in the router and opens right after. A launch from a
/// link skips the welcome flow this time (the link is what the user came
/// for; only the terms are asked); the flow shows on the next plain launch.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({
    required this.app,
    required this.openedByLink,
    required this.onFinished,
    super.key,
  });

  final Widget app;
  final bool openedByLink;

  /// Called once the welcome flow is done, just before the app is built.
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(onboardingProgressProvider);
    final terms = ref.watch(termsAcceptanceProvider);
    final shown = switch ((progress, terms)) {
      // A blink while the local database opens.
      (AsyncLoading(), _) || (_, AsyncLoading()) => ColoredBox(
        key: const ValueKey('wait'),
        color: context.colors.surfaceAlt,
      ),
      (AsyncData(value: final step?), AsyncData(value: final accepted)) when !openedByLink => _Own(
        key: const ValueKey('onboarding'),
        child: OnboardingFlow(
          // Never resume past the terms while they are not accepted.
          initialStep: accepted || step <= onboardingTermsStep ? step : onboardingTermsStep,
          onDone: () async {
            // Start tab first, so the router is built straight on it.
            onFinished();
            await ref.read(onboardingProgressProvider.notifier).finish();
          },
        ),
      ),
      // Hard gate (owner, P2-57): no app without the current terms accepted,
      // not even when the flag cannot be read.
      (_, AsyncData(value: true)) => KeyedSubtree(key: const ValueKey('app'), child: app),
      _ => const _Own(key: ValueKey('terms'), child: TermsOnlyScreen()),
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

/// These screens need their own navigator: text fields and tooltips need an
/// overlay, and the app's navigator does not exist yet.
class _Own extends StatelessWidget {
  const _Own({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Navigator(onGenerateRoute: (_) => PageRouteBuilder<void>(pageBuilder: (_, _, _) => child));
}
