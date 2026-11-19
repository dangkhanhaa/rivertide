import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/theme/app_theme.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/features/alerts/alerts.dart';
import 'package:rivertide/features/more/application/appearance_provider.dart';
import 'package:rivertide/features/more/application/outdoor_mode_provider.dart';
import 'package:rivertide/features/more/application/theme_mode_provider.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/features/watch/watch.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';
import 'package:rivertide/router.dart';

class RiverTideApp extends ConsumerStatefulWidget {
  const RiverTideApp({super.key});

  @override
  ConsumerState<RiverTideApp> createState() => _RiverTideAppState();
}

class _RiverTideAppState extends ConsumerState<RiverTideApp> {
  late final GoRouter _router = buildRouter();
  static const Duration _warmDelay = Duration(seconds: 4);
  Timer? _warmTimer;

  @override
  void initState() {
    super.initState();
    // After the first frame so it never delays opening the app.
    // Start tab right away; the rest a few seconds later so the first screens
    // (map tiles, fishing tab) get the CPU on slow phones.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_openStartTab());
      _warmTimer = Timer(_warmDelay, () => unawaited(_warmUp()));
    });
  }

  @override
  void dispose() {
    _warmTimer?.cancel();
    _router.dispose();
    super.dispose();
  }

  /// Start tab first (feels instant), then saved places cached for offline
  /// use, then alarms rescheduled from them.
  Future<void> _warmUp() async {
    if (!mounted) return;
    await prefetchSavedPlaces(ref);
    await syncHomeWidget(ref);
    await rescheduleAlerts(ref);
  }

  /// "Mở app vào tab" (P2-31); only when the app opened on the default map,
  /// not when a deep link already chose a screen.
  Future<void> _openStartTab() async {
    final tab = (await ref.read(appearanceSettingsProvider.future)).startTab;
    final here = _router.routeInformationProvider.value.uri.path;
    if (!mounted || here != Routes.map) return;
    switch (tab) {
      case StartTab.map:
        return;
      case StartTab.ponds:
        _router.go(Routes.ponds);
      case StartTab.fishing:
        _router.go(Routes.fishing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    final outdoor = ref.watch(outdoorModeProvider).value ?? false;
    final look = ref.watch(appearanceSettingsProvider).value ?? const Appearance();
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: outdoor ? AppTheme.outdoor(look) : AppTheme.light(look),
      darkTheme: outdoor ? AppTheme.outdoor(look) : AppTheme.dark(look),
      themeMode: outdoor ? ThemeMode.light : mode,
      builder: (context, child) => _personalMedia(context, child, look, outdoor: outdoor),
      locale: switch (look.language.code) {
        final code? => Locale(code),
        null => null,
      },
      // Following the phone: English phones get English, everything else
      // Vietnamese (the app's home language), never an arbitrary first match.
      localeResolutionCallback: (device, _) =>
          device?.languageCode == 'en' ? const Locale('en') : const Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }

  /// Text size (user step × system × outdoor boost, kept within 0.85–1.6 so
  /// layouts still fit) and "giảm chuyển động".
  static Widget _personalMedia(
    BuildContext context,
    Widget? child,
    Appearance look, {
    required bool outdoor,
  }) {
    if (child == null) return const SizedBox.shrink();
    final mq = MediaQuery.of(context);
    final base = mq.textScaler.scale(1);
    final scale = (base * look.textSize.factor * (outdoor ? outdoorTextScale : 1)).clamp(0.85, 1.6);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(scale),
        disableAnimations: mq.disableAnimations || look.reduceMotion,
      ),
      child: child,
    );
  }
}
