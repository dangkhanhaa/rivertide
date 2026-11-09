import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/fishing/fishing_score.dart';
import 'package:rivertide/core/theme/app_theme.dart';
import 'package:rivertide/features/fishing/presentation/widgets/safety_banner.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';

FishingHourScore _hour(int hourVn, SafetyLevel safety) => FishingHourScore(
  // 00:00 VN = 17:00 UTC of the previous day.
  hourUtc: DateTime.utc(2026, 11, 8, 17).add(Duration(hours: hourVn)),
  score: safety == SafetyLevel.red ? 2 : 8,
  components: const {},
  safety: safety,
  positiveFactors: const [],
);

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('red banner names the unsafe hours (11:00–19:00 VN)', (tester) async {
    final hours = [
      for (var h = 0; h < 24; h++)
        _hour(h, h >= 11 && h <= 18 ? SafetyLevel.red : SafetyLevel.none),
    ];
    await tester.pumpWidget(_wrap(SafetyBanner(hours: hours)));
    expect(find.textContaining('11:00–19:00'), findsOneWidget);
    expect(find.byIcon(Icons.thunderstorm_rounded), findsOneWidget);
  });

  testWidgets('no banner when every hour is safe', (tester) async {
    final hours = [for (var h = 0; h < 24; h++) _hour(h, SafetyLevel.none)];
    await tester.pumpWidget(_wrap(SafetyBanner(hours: hours)));
    expect(find.byType(Container), findsNothing);
  });
}
