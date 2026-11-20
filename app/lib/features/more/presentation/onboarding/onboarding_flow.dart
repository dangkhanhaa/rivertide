import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/features/more/application/onboarding_provider.dart';
import 'package:rivertide/features/more/application/profile_defaults.dart';
import 'package:rivertide/features/more/application/terms_provider.dart';
import 'package:rivertide/features/more/domain/display_name_rules.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_bars.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_parts.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_intro.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_kind.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_look.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_name.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_prefs.dart';
import 'package:rivertide/features/more/presentation/onboarding/step_terms.dart';

/// The welcome flow (P2-53, P2-57): welcome, language, then the terms, which
/// must be accepted before anything else (no skip, no swipe past); then
/// name, who, preferences (location, notifications) and look, each applied
/// as soon as it is chosen. "Bỏ qua" skips only the current step (its
/// defaults stay); the step is saved, so an app killed or a page reloaded
/// comes back where it left off.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({required this.initialStep, required this.onDone, super.key});

  final int initialStep;
  final Future<void> Function() onDone;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> with WidgetsBindingObserver {
  static const int _termsStep = onboardingTermsStep;
  static const int _nameStep = 3;
  static const int _lastStep = onboardingSteps - 1;
  static const Duration _slide = Duration(milliseconds: 420);

  late final PageController _pages = PageController(initialPage: widget.initialStep);
  late int _step = widget.initialStep;
  final TextEditingController _name = TextEditingController();
  String _savedName = '';

  /// Typed by the user (only then is the name saved).
  bool _nameDirty = false;

  /// "Too short" is shown only after a try to move on, not while typing.
  bool _nameTried = false;

  /// The page is moving on via "Bỏ qua": the name is not checked or saved.
  bool _skipping = false;
  NameIssue? _issue;

  /// Box ticked on the terms step.
  bool _agreed = false;

  /// Terms stored as accepted: only then can the flow go past them.
  bool _accepted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    final saved = await ref.read(displayNameProvider.future);
    final agreed = await ref.read(termsAcceptanceProvider.future);
    if (!mounted) return;
    _savedName = saved;
    if (!_nameDirty) _name.text = saved;
    setState(() => _agreed = _accepted = agreed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  /// There is no router yet on first launch, so Android Back arrives here.
  @override
  Future<bool> didPopRoute() async {
    if (_step == 0 || !mounted) return false;
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

  void _onNameChanged(String text) {
    _nameDirty = true;
    final issue = checkDisplayName(text);
    final shown = issue == NameIssue.tooShort && !_nameTried ? null : issue;
    if (shown != _issue) setState(() => _issue = shown);
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
      _savedName = normalizeDisplayName(_name.text);
      await ref.read(displayNameProvider.notifier).save(_savedName);
    }
    return true;
  }

  Future<void> _next() async {
    if (_busy) return;
    if (_step == _termsStep && !await _accept()) return;
    if (_step == _nameStep && !await _commitName()) return;
    if (_step < _lastStep) {
      _go(_step + 1);
    } else {
      await _finish();
    }
  }

  /// The hard stop (P2-57): nothing after this step (location, notifications,
  /// the app itself) runs before the terms are stored as accepted.
  Future<bool> _accept() async {
    if (!_agreed) return false;
    if (!_accepted) {
      setState(() => _busy = true);
      await ref.read(termsAcceptanceProvider.notifier).accept();
      if (!mounted) return false;
      setState(() {
        _busy = false;
        _accepted = true;
      });
    }
    return true;
  }

  /// Moves on without this step's choice: a typed name is dropped.
  void _skip() {
    if (_step == _termsStep) return;
    if (_step >= _lastStep) {
      unawaited(_finish());
      return;
    }
    if (_step == _nameStep) {
      _name.text = _savedName;
      _nameDirty = false;
      _nameTried = false;
      _issue = null;
    }
    _skipping = true;
    _go(_step + 1);
  }

  void _onPage(int page) {
    final from = _step;
    setState(() => _step = page);
    unawaited(ref.read(onboardingProgressProvider.notifier).saveStep(page));
    // Swiped past the name: same check as the button (not when skipping).
    if (from == _nameStep && page > from && !_skipping) unawaited(_leaveName());
    if (page != from) _skipping = false;
  }

  Future<void> _leaveName() async {
    if (!await _commitName() && mounted) _go(_nameStep);
  }

  /// Applies the profile's defaults, then hands over (terms already accepted).
  Future<void> _finish() async {
    if (_busy || !_accepted) return;
    setState(() => _busy = true);
    await applyProfileDefaults(ref, await ref.read(userProfileSettingsProvider.future));
    await widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onTerms = _step == _termsStep;
    // An invalid name or terms not yet accepted block the swipe forward.
    final locked = (_step == _nameStep && _issue != null) || (onTerms && !_accepted);
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _go(_step - 1);
      },
      child: OnbScaffold(
        top: OnbTopBar(
          step: _step,
          onBack: _step == 0 ? null : () => _go(_step - 1),
          onSkip: onTerms || _busy ? null : _skip,
        ),
        body: PageView(
          controller: _pages,
          onPageChanged: _onPage,
          physics: locked ? const NeverScrollableScrollPhysics() : null,
          children: [
            const WelcomeStep(),
            const LanguageStep(),
            TermsStep(agreed: _agreed, onAgreed: (v) => setState(() => _agreed = v)),
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
        bottom: OnbBottomBar(
          label: switch (_step) {
            0 => l10n.onb_start,
            _termsStep => l10n.onb_termsContinue,
            _lastStep => l10n.onb_finish,
            _ => l10n.onb_next,
          },
          busy: _busy || (onTerms && !_agreed),
          onPressed: () => unawaited(_next()),
        ),
      ),
    );
  }
}
