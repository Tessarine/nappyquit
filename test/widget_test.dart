import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/ui/home/home_page.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

import 'in_memory_potty_training_log_item_repository.dart';

void main() {
  late InMemoryPottyTrainingLogItemRepository repository;
  late HomePageLogic logic;

  setUp(() {
    repository = InMemoryPottyTrainingLogItemRepository();
    logic = HomePageLogic(repository: repository);
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

      expect(find.text('Potty Training'), findsOneWidget);
    });

    testWidgets('should display Record Activity label', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Record Activity'), findsOneWidget);
    });

    testWidgets('should display all 6 activity buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Tried the potty'), findsOneWidget);
      expect(find.text('Used the potty'), findsOneWidget);
      expect(find.text('Accident'), findsOneWidget);
      expect(find.text('Drank water'), findsOneWidget);
      expect(find.text('Ate food'), findsOneWidget);
      expect(find.text('Nappy'), findsOneWidget);
    });

    testWidgets('should display no log entries message when empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('No activities recorded yet'), findsOneWidget);
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

      await tester.tap(find.text('Used the potty'));
      await tester.pumpAndSettle();

      expect(find.text('What happened?'), findsOneWidget);
    });

    testWidgets('should show initiative dialog when tapping Tried the Potty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Tried the potty'));
      await tester.pumpAndSettle();

      expect(find.text('How did it happen?'), findsOneWidget);
    });

    testWidgets('should show water amount dialog when tapping Drank Water', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Drank water'));
      await tester.pumpAndSettle();

      expect(find.text('How much water?'), findsOneWidget);
    });

    testWidgets('should add log item when selecting water amount and cancelling dialog', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Tap Drank water button
      await tester.tap(find.text('Drank water'));
      await tester.pumpAndSettle();

      // Water amount dialog should appear
      expect(find.text('How much water?'), findsOneWidget);

      // Tap "Some water" option
      await tester.tap(find.text('Some water'));
      await tester.pumpAndSettle();

      // Item should be added - no more dialogs
      expect(find.text('How much water?'), findsNothing);
    });

    testWidgets('should show date time picker on long press', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Long press on "Ate food" button
      await tester.longPress(find.text('Ate food'));
      await tester.pumpAndSettle();

      expect(find.text('Select date and time'), findsOneWidget);
    });
  });
}
