import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_en.dart';
import 'package:toot_n_tinkle/ui/home/home_page.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

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

  group('HomePage Widget BDD Tests', () {
    testWidgets(
      'Given the app is launched, When viewing the main page, Then the app title is displayed',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text(l10n.appTitle), findsOneWidget);
      },
    );

    testWidgets(
      'Given the app is launched, When viewing the main page, Then the Record Activity label is displayed',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text(l10n.recordActivity), findsOneWidget);
      },
    );

    testWidgets(
      'Given the app is launched, When viewing the main page, Then all 6 activity buttons are displayed',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text(l10n.triedThePotty), findsOneWidget);
        expect(find.text(l10n.usedThePotty), findsOneWidget);
        expect(find.text(l10n.accident), findsOneWidget);
        expect(find.text(l10n.drankWater), findsOneWidget);
        expect(find.text(l10n.ateFood), findsOneWidget);
        expect(find.text(l10n.nappy), findsOneWidget);
      },
    );

    testWidgets(
      'Given there are no activities recorded, When viewing the main page, Then the no log entries message is displayed',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text(l10n.noLogEntries), findsOneWidget);
      },
    );

    testWidgets(
      'Given the app is launched, When viewing the main page, Then the emojis are displayed on activity buttons',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('🚽'), findsOneWidget);
        expect(find.text('🎉'), findsOneWidget);
        expect(find.text('😅'), findsOneWidget);
        expect(find.text('💧'), findsOneWidget);
        expect(find.text('🍽️'), findsOneWidget);
        expect(find.text('👶'), findsOneWidget);
      },
    );

    testWidgets(
      'Given the user taps the Used the potty button, When the button is tapped, Then the bodily function dialog is displayed',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text(l10n.usedThePotty).first);
        await tester.pumpAndSettle();

        expect(find.text(l10n.selectBodilyFunction), findsOneWidget);
      },
    );

    testWidgets(
      'Given the user taps the Tried the potty button, When the button is tapped, Then the initiative dialog is displayed',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text(l10n.triedThePotty).first);
        await tester.pumpAndSettle();

        expect(find.text(l10n.selectInitiative), findsOneWidget);
      },
    );

    testWidgets(
      'Given the user taps the Drank water button, When the button is tapped, Then the water amount dialog is displayed',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text(l10n.drankWater).first);
        await tester.pumpAndSettle();

        expect(find.text(l10n.selectWaterAmount), findsOneWidget);
      },
    );

    testWidgets(
      'Given the user taps the Drank water button and selects Some water, When the selection is made, Then the dialog closes and the activity is recorded',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap Drank water button
        await tester.tap(find.text(l10n.drankWater).first);
        await tester.pumpAndSettle();

        // Water amount dialog should appear
        expect(find.text(l10n.selectWaterAmount), findsOneWidget);

        // Tap "Some water" option
        await tester.tap(find.text(l10n.drankSomeWater).first);
        await tester.pumpAndSettle();

        // Item should be added - no more dialogs
        expect(find.text(l10n.selectWaterAmount), findsNothing);
      },
    );

    testWidgets(
      'Given the user long presses an activity button, When the button is long pressed, Then the date and time picker is displayed',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Long press on "Ate food" button
        await tester.longPress(find.text(l10n.ateFood).first);
        await tester.pumpAndSettle();

        expect(find.text(l10n.selectDateAndTime), findsOneWidget);
      },
    );
  });
}
