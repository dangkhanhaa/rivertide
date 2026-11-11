import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/theme/app_theme.dart';
import 'package:rivertide/features/more/application/outdoor_mode_provider.dart';
import 'package:rivertide/features/more/application/theme_mode_provider.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';
import 'package:rivertide/router.dart';

class RiverTideApp extends ConsumerStatefulWidget {
  const RiverTideApp({super.key});

  @override
  ConsumerState<RiverTideApp> createState() => _RiverTideAppState();
}

class _RiverTideAppState extends ConsumerState<RiverTideApp> {
  late final GoRouter _router = buildRouter();

  @override
  void initState() {
    super.initState();
    // After the first frame so it never delays opening the app.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(prefetchSavedPlaces(ref)));
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    final outdoor = ref.watch(outdoorModeProvider).value ?? false;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: outdoor ? AppTheme.outdoor() : AppTheme.light(),
      darkTheme: outdoor ? AppTheme.outdoor() : AppTheme.dark(),
      themeMode: outdoor ? ThemeMode.light : mode,
      builder: (context, child) {
        if (!outdoor || child == null) return child ?? const SizedBox.shrink();
        final mq = MediaQuery.of(context);
        final base = mq.textScaler.scale(1);
        // Bigger text, capped so the ×1.6 layout limit still holds.
        final scale = (base * outdoorTextScale).clamp(1.0, 1.6);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(scale)),
          child: child,
        );
      },
      locale: const Locale('vi'),
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
}
