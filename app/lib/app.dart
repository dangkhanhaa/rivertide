import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivertide/core/theme/app_theme.dart';
import 'package:rivertide/features/more/application/theme_mode_provider.dart';
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
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
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
