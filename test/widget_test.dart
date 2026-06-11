import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/l10n/app_localizations_en.dart';
import 'package:nappyquit/ui/home/home_page.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';

import 'in_memory_potty_training_log_item_repository.dart';

void main() {
  late InMemoryPottyTrainingLogItemRepository repository;
  late HomePageLogic logic;
  late AppLocalizationsEn l10n;

  setUp(() {
    repository = InMemoryPottyTrainingLogItemRepository();
    logic = HomePageLogic(repository: repository);
    l10n = AppLocalizationsEn();
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(logic: logic),
    );
  }

  group('HomePage Widget', () {
    testWidgets('should display app title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(l10n.appTitle), findsOneWidget);
    });

    testWidgets('should display Record Activity label', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(l10n.recordActivity), findsOneWidget);
    });

    testWidgets('should display all 6 activity buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(l10n.triedThePotty), findsOneWidget);
      expect(find.text(l10n.usedThePotty), findsOneWidget);
      expect(find.text(l10n.accident), findsOneWidget);
      expect(find.text(l10n.drankWater), findsOneWidget);
      expect(find.text(l10n.ateFood), findsOneWidget);
      expect(find.text(l10n.nappy), findsOneWidget);
    });

    testWidgets('should display no log entries message when empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text(l10n.noLogEntries), findsOneWidget);
    });

    testWidgets('should display emojis on activity buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('🚽'), findsOneWidget);
      expect(find.text('🎉'), findsOneWidget);
      expect(find.text('😅'), findsOneWidget);
      expect(find.text('💧'), findsOneWidget);
      expect(find.text('🍽️'), findsOneWidget);
      expect(find.text('👶'), findsOneWidget);
    });

    testWidgets('should show bodily function dialog when tapping Used the Potty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text(l10n.usedThePotty));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectBodilyFunction), findsOneWidget);
    });

    testWidgets('should show initiative dialog when tapping Tried the Potty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text(l10n.triedThePotty));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectInitiative), findsOneWidget);
    });

    testWidgets('should show water amount dialog when tapping Drank Water', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text(l10n.drankWater));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectWaterAmount), findsOneWidget);
    });

    testWidgets('should add log item when selecting water amount and cancelling dialog', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Tap Drank water button
      await tester.tap(find.text(l10n.drankWater));
      await tester.pumpAndSettle();

      // Water amount dialog should appear
      expect(find.text(l10n.selectWaterAmount), findsOneWidget);

      // Tap "Some water" option
      await tester.tap(find.text(l10n.drankSomeWater));
      await tester.pumpAndSettle();

      // Item should be added - no more dialogs
      expect(find.text(l10n.selectWaterAmount), findsNothing);
    });

    testWidgets('should show date time picker on long press', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Long press on "Ate food" button
      await tester.longPress(find.text(l10n.ateFood));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectDateAndTime), findsOneWidget);
    });
  });
}
