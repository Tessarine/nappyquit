import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_en.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_hu.dart';
import 'package:toot_n_tinkle/ui/home/home_page.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

import 'in_memory_potty_training_log_item_repository.dart';

void main() {
  late InMemoryPottyTrainingLogItemRepository repository;
  late HomePageLogic logic;
  late AppLocalizationsEn enLocalizations;
  late AppLocalizationsHu huLocalizations;

  setUp(() {
    repository = InMemoryPottyTrainingLogItemRepository();
    logic = HomePageLogic(repository: repository);
    enLocalizations = AppLocalizationsEn();
    huLocalizations = AppLocalizationsHu();
  });

  Widget createTestWidget({Locale locale = const Locale('en')}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: HomePage(logic: logic),
    );
  }

  group('Simple Localization Tests', () {
    testWidgets('Given English locale, Then UI elements show in English', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: Locale('en')));

      expect(find.text(enLocalizations.appTitle), findsOneWidget);
      expect(find.text(enLocalizations.recordActivity), findsOneWidget);
    });

    testWidgets('Given Hungarian locale, Then UI elements show in Hungarian', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: Locale('hu')));

      expect(find.text(huLocalizations.appTitle), findsOneWidget);
      expect(find.text(huLocalizations.recordActivity), findsOneWidget);
    });

    testWidgets(
      'Given activities recorded, When locale changes to Hungarian, Then static text changes',
      (tester) async {
        // Test with English first
        await tester.pumpWidget(createTestWidget(locale: Locale('en')));
        await tester.pumpAndSettle();

        // Record an activity
        await tester.tap(find.text(enLocalizations.triedThePotty).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(enLocalizations.wentByHimself).first);
        await tester.pumpAndSettle();

        // Now test with Hungarian locale (new widget)
        await tester.pumpWidget(createTestWidget(locale: Locale('hu')));
        await tester.pumpAndSettle();

        // Verify static text is in Hungarian
        expect(find.text(huLocalizations.appTitle), findsOneWidget);
        expect(find.text(huLocalizations.recordActivity), findsOneWidget);

        // The "no activities" message should NOT be visible since we have activities
        expect(find.text(huLocalizations.noLogEntries), findsNothing);
      },
    );
  });
}
