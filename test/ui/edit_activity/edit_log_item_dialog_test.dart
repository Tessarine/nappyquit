import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_en.dart';
import 'package:toot_n_tinkle/ui/edit_activity/edit_log_item_dialog.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

class MockHomePageLogic extends Mock implements HomePageLogic {}

void main() {
  late MockHomePageLogic mockLogic;
  late PottyTrainingLogItem testLogItem;

  setUpAll(() {
    registerFallbackValue(ActivityType.usedThePotty);
    registerFallbackValue(BodilyFunction.pee);
    registerFallbackValue(InitiativeType.toldParents);
    registerFallbackValue(WaterAmount.some);
  });

  setUp(() {
    mockLogic = MockHomePageLogic();
    testLogItem = PottyTrainingLogItem(
      id: 'test-id',
      activityType: ActivityType.usedThePotty,
      timestamp: DateTime(2026, 4, 8, 10, 0),
      bodilyFunction: BodilyFunction.pee,
      initiativeType: InitiativeType.toldParents,
      waterAmount: WaterAmount.some,
      needsClothingChange: false,
      created: DateTime(2026, 4, 8, 10, 0),
      updated: DateTime(2026, 4, 8, 10, 0),
      deleted: null,
    );

    // Mock the logic methods
    when(() => mockLogic.activityTypeName(any())).thenReturn('Used the potty');
    when(() => mockLogic.requiresWaterAmount(any())).thenReturn(true);
    when(
      () => mockLogic.availableWaterAmounts(any()),
    ).thenReturn([WaterAmount.some, WaterAmount.lots]);
    when(() => mockLogic.waterAmountName(any())).thenReturn('Some water');
    when(() => mockLogic.waterAmountEmoji(any())).thenReturn('💧');
    when(() => mockLogic.requiresBodilyFunction(any())).thenReturn(true);
    when(
      () => mockLogic.availableBodilyFunctions(any()),
    ).thenReturn([BodilyFunction.pee, BodilyFunction.poo, BodilyFunction.both]);
    when(() => mockLogic.bodilyFunctionName(any())).thenReturn('Pee');
    when(() => mockLogic.requiresInitiativeType(any())).thenReturn(true);
    when(() => mockLogic.availableInitiativeTypes(any())).thenReturn([
      InitiativeType.toldParents,
      InitiativeType.wentByHimself,
      InitiativeType.askedToSit,
    ]);
    when(() => mockLogic.initiativeTypeName(any())).thenReturn('Told parents');
  });

  Widget createTestWidget({Widget? child}) {
    return MaterialApp(
      localizationsDelegates: [...AppLocalizations.localizationsDelegates],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child ?? const SizedBox.shrink()),
    );
  }

  group('EditLogItemDialog', () {
    testWidgets('Should display edit dialog correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: EditLogItemDialog(logItem: testLogItem, logic: mockLogic),
        ),
      );

      // Check that the dialog is present
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check that we have the title
      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.edit), findsOneWidget);

      // Check that we have the action buttons
      expect(find.text(l10n.cancel), findsOneWidget);
      expect(find.text(l10n.save), findsOneWidget);
    });

    testWidgets('Should handle activity types that dont require water amount', (tester) async {
      final logItemNoWater = testLogItem.copyWith(activityType: ActivityType.ateFood);

      await tester.pumpWidget(
        createTestWidget(
          child: EditLogItemDialog(logItem: logItemNoWater, logic: mockLogic),
        ),
      );

      // Check that the dialog is present
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check that we have the title
      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.edit), findsOneWidget);

      // Check that we have the action buttons
      expect(find.text(l10n.cancel), findsOneWidget);
      expect(find.text(l10n.save), findsOneWidget);
    });

    testWidgets('Should handle activity types that dont require bodily function', (tester) async {
      final logItemNoBodily = testLogItem.copyWith(activityType: ActivityType.drankWater);

      await tester.pumpWidget(
        createTestWidget(
          child: EditLogItemDialog(logItem: logItemNoBodily, logic: mockLogic),
        ),
      );

      // Check that the dialog is present
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check that we have the title
      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.edit), findsOneWidget);

      // Check that we have the action buttons
      expect(find.text(l10n.cancel), findsOneWidget);
      expect(find.text(l10n.save), findsOneWidget);
    });
  });
}
