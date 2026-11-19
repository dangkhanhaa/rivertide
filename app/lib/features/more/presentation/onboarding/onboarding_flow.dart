import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/features/more/application/onboarding_provider.dart';
import 'package:rivertide/features/more/application/profile_defaults.dart';
import 'package:rivertide/features/more/domain/display_name_rules.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_bars.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_intro.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_kind.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_look.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_name.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_prefs.dart';

/// The welcome flow (P2-53): six short steps, each applied as soon as it is
/// chosen, so leaving at any point (Bỏ qua, app killed, page reloaded) keeps
/// what was picked and everything else stays at the app defaults.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({
    required this.initialStep,
    required this.onDone,
    this.resumable = true,
    super.key,
  });

  final int initialStep;
  final Future<void> Function() onDone;

  /// First launch: the step is saved for resuming and system Back walks
  /// back through the steps. False when replayed from Settings.
  final bool resumable;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> with WidgetsBindingObserver {
  static const int _nameStep = 2;
  static const Duration _slide = Duration(milliseconds: 420);

  late final PageController _pages = PageController(initialPage: widget.initialStep);
  late int _step = widget.initialStep;
  final TextEditingController _name = TextEditingController();

  /// Typed by the user (only then is the name saved on "Bỏ qua").
  bool _nameDirty = false;

  /// "Too short" is shown only after a try to move on, not while typing.
  bool _nameTried = false;
  NameIssue? _issue;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadName());
  }

  Future<void> _loadName() async {
    final saved = await ref.read(displayNameProvider.future);
    if (mounted && !_nameDirty) _name.text = saved;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  /// First launch has no router yet, so Android Back arrives here.
  @override
  Future<bool> didPopRoute() async {
    if (!widget.resumable || _step == 0 || !mounted) return false;
    _go(_step - 1);
    return true;
  }

  void _go(int step) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(step);
      return;
    }
    _pages.animateToPage(step, duration: _slide, curve: Curves.easeOutCubic);
  }

  NameIssue? _shownIssue(String text) {
    final issue = checkDisplayName(text);
    return issue == NameIssue.tooShort && !_nameTried ? null : issue;
  }

  void _onNameChanged(String text) {
    _nameDirty = true;
    final issue = _shownIssue(text);
    if (issue != _issue) setState(() => _issue = issue);
  }

  /// Saves a valid name; false (with the reason shown) otherwise.
  Future<bool> _commitName() async {
    final issue = checkDisplayName(_name.text);
    setState(() {
      _nameTried = true;
      _issue = issue;
    });
    if (issue != null) return false;
    if (_nameDirty) {
      await ref.read(displayNameProvider.notifier).save(normalizeDisplayName(_name.text));
    }
    return true;
  }

  Future<void> _next() async {
    if (_busy) return;
    if (_step == _nameStep && !await _commitName()) return;
    if (_step < onboardingSteps - 1) {
      _go(_step + 1);
    } else {
      await _finish();
    }
  }

  void _onPage(int page) {
    final from = _step;
    setState(() => _step = page);
    if (widget.resumable) {
      unawaited(ref.read(onboardingProgressProvider.notifier).saveStep(page));
    }
    // Swiped past the name: same check as the button.
    if (from == _nameStep && page > from) unawaited(_leaveName());
  }

  Future<void> _leaveName() async {
    if (!await _commitName() && mounted) _go(_nameStep);
  }

  /// "Xong" or "Bỏ qua": keeps what was chosen, applies the profile's
  /// defaults, then hands over to the app.
  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    FocusManager.instance.primaryFocus?.unfocus();
    if (_nameDirty && checkDisplayName(_name.text) == null) {
      await ref.read(displayNameProvider.notifier).save(normalizeDisplayName(_name.text));
    }
    await applyProfileDefaults(ref, await ref.read(userProfileSettingsProvider.future));
    await widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    // An invalid name blocks the swipe (the message says why); Back still works.
    final locked = _step == _nameStep && _issue != null;
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _go(_step - 1);
      },
      child: Scaffold(
        backgroundColor: c.surfaceAlt,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Color.alphaBlend(c.primary.withValues(alpha: 0.16), c.surfaceAlt),
                c.surfaceAlt,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                OnbTopBar(
                  step: _step,
                  onBack: _step == 0 ? null : () => _go(_step - 1),
                  onSkip: _busy ? null : () => unawaited(_finish()),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: _onPage,
                    physics: locked ? const NeverScrollableScrollPhysics() : null,
                    children: [
                      const WelcomeStep(),
                      const LanguageStep(),
                      NameStep(
                        controller: _name,
                        issue: _issue,
                        onChanged: _onNameChanged,
                        onSubmitted: () => unawaited(_next()),
                      ),
                      const KindStep(),
                      const PrefsStep(),
                      const LookStep(),
                    ],
                  ),
                ),
                OnbBottomBar(
                  label: _step == 0
                      ? l10n.onb_start
                      : (_step == onboardingSteps - 1 ? l10n.onb_finish : l10n.onb_next),
                  busy: _busy,
                  onPressed: () => unawaited(_next()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
