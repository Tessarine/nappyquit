import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/l10n/app_localizations_en.dart';
import 'package:nappyquit/domain/food_amount.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';
import 'package:nappyquit/ui/add_activity/dialog_sequences/ate_food_dialog_sequence.dart';
import 'package:nappyquit/ui/add_activity/dialog_sequences/activity_dialog_result.dart';

import '../../../../test/in_memory_potty_training_log_item_repository.dart';

void main() {
  late InMemoryPottyTrainingLogItemRepository repository;
  late HomePageLogic logic;

  setUp(() {
    repository = InMemoryPottyTrainingLogItemRepository();
    logic = HomePageLogic(repository: repository);
  });

  Widget createTestWidget({Widget? child}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child ?? const SizedBox.shrink()),
    );
  }

  group('AteFoodDialogSequence Tests', () {
    testWidgets('Should show food amount dialog when called', (tester) async {
      // Given
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  await AteFoodDialogSequence.show(context: context, logic: logic);
                },
                child: const Text('Show dialog'),
              );
            },
          ),
        ),
      );

      // When
      await tester.tap(find.text('Show dialog'));
      await tester.pumpAndSettle();

      // Then
      final localizations = AppLocalizationsEn();
      expect(find.text(localizations.selectFoodAmount), findsOneWidget);
      expect(find.text(localizations.ateSomeFood), findsOneWidget);
      expect(find.text(localizations.ateLotsOfFood), findsOneWidget);
    });

    testWidgets('Should return ActivityDialogResult when food amount is selected', (tester) async {
      // Given
      ActivityDialogResult? result;
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await AteFoodDialogSequence.show(context: context, logic: logic);
                },
                child: const Text('Show dialog'),
              );
            },
          ),
        ),
      );

      // When
      await tester.tap(find.text('Show dialog'));
      await tester.pumpAndSettle();

      // Select "Some food" option
      await tester.tap(find.text('Ate some food').first);
      await tester.pumpAndSettle();

      // Then
      expect(result, isNotNull);
      expect(result?.foodAmount, equals(FoodAmount.some));
    });
  });
}
