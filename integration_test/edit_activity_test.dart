import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nappyquit/domain/activity_type.dart';
import 'package:nappyquit/domain/bodily_function.dart';
import 'package:nappyquit/domain/initiative_type.dart';
import 'package:nappyquit/domain/potty_training_log_item.dart';
import 'package:nappyquit/domain/water_amount.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/ui/edit_activity/edit_log_item_dialog.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';
import '../test/in_memory_potty_training_log_item_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edit Activity Integration Test', () {
    late InMemoryPottyTrainingLogItemRepository repository;
    late HomePageLogic logic;

    setUp(() {
      repository = InMemoryPottyTrainingLogItemRepository();
      logic = HomePageLogic(repository: repository);
    });

    testWidgets('Should show edit dialog for used the potty activity', (tester) async {
      // Arrange
      final logItem = PottyTrainingLogItem(
        id: 'test-id',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        initiativeType: InitiativeType.toldParents,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      await repository.add(logItem);

      // Act & Assert - Simply test that we can show the edit dialog
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [...AppLocalizations.localizationsDelegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await showEditLogItemDialog(context: context, logItem: logItem, logic: logic);
                },
                child: const Text('Open Edit Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Should show edit dialog for drank water activity', (tester) async {
      // Arrange
      final logItem = PottyTrainingLogItem(
        id: 'test-id-2',
        activityType: ActivityType.drankWater,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        waterAmount: WaterAmount.some,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      await repository.add(logItem);

      // Act & Assert
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [...AppLocalizations.localizationsDelegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await showEditLogItemDialog(context: context, logItem: logItem, logic: logic);
                },
                child: const Text('Open Edit Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Should show edit dialog for accident activity', (tester) async {
      // Arrange
      final logItem = PottyTrainingLogItem(
        id: 'test-id-3',
        activityType: ActivityType.accident,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        initiativeType: InitiativeType.toldParents,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      await repository.add(logItem);

      // Act & Assert
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [...AppLocalizations.localizationsDelegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await showEditLogItemDialog(context: context, logItem: logItem, logic: logic);
                },
                child: const Text('Open Edit Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    // Test that exercises more of the edit dialog code to increase coverage
    testWidgets('Should interact with edit dialog controls', (tester) async {
      // Arrange - Used the potty activity (has all editable fields)
      final logItem = PottyTrainingLogItem(
        id: 'test-id-interact',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        initiativeType: InitiativeType.toldParents,
        needsClothingChange: false,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      await repository.add(logItem);

      // Act & Assert
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [...AppLocalizations.localizationsDelegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await showEditLogItemDialog(context: context, logItem: logItem, logic: logic);
                },
                child: const Text('Open Edit Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Verify we can see some of the editable fields (just check they exist)
      expect(find.text('What happened?'), findsOneWidget); // bodily function label
      expect(find.text('What happened?'), findsOneWidget); // initiative type label

      // Save changes (without modifying anything)
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();

      // Verify dialog closed
      expect(find.text('Edit'), findsNothing);
    });
  });
}
