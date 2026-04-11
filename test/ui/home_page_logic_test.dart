import 'package:flutter_test/flutter_test.dart';
import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_en.dart';

import '../in_memory_potty_training_log_item_repository.dart';

PottyTrainingLogItem createTestItem({
  required String id,
  required ActivityType activityType,
  DateTime? timestamp,
  BodilyFunction? bodilyFunction,
  InitiativeType? initiativeType,
}) {
  return PottyTrainingLogItem(
    id: id,
    activityType: activityType,
    timestamp: timestamp ?? DateTime(2026, 4, 8, 10, 0),
    bodilyFunction: bodilyFunction,
    initiativeType: initiativeType,
  );
}

void main() {
  late HomePageLogic logic;
  late InMemoryPottyTrainingLogItemRepository repository;

  setUp(() {
    repository = InMemoryPottyTrainingLogItemRepository();
    logic = HomePageLogic(repository: repository);
  });

  group('HomePageLogic', () {
    test('should start with empty log items', () {
      expect(logic.logItems, isEmpty);
      expect(logic.loadedDays, isEmpty);
      expect(logic.hasMoreDays, isFalse);
    });

    test('should load log items from repository', () async {
      await repository.add(createTestItem(id: '1', activityType: ActivityType.ateFood));

      await logic.loadLogItems();

      expect(logic.logItems.length, 1);
      expect(logic.logItems.first.id, '1');
    });

    test('should create a log item and add it to the list', () async {
      final item = await logic.createLogItem(
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        initiativeType: InitiativeType.toldParents,
      );

      expect(item.activityType, ActivityType.usedThePotty);
      expect(item.bodilyFunction, BodilyFunction.pee);
      expect(item.initiativeType, InitiativeType.toldParents);
      expect(logic.logItems.length, 1);
    });

    test('should sort log items by timestamp descending within a day', () async {
      await logic.createLogItem(
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 9, 0),
      );
      await logic.createLogItem(
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
      );

      expect(logic.logItems.first.activityType, ActivityType.usedThePotty);
      expect(logic.logItems.last.activityType, ActivityType.ateFood);
    });

    test('should delete a log item', () async {
      final item = await logic.createLogItem(
        activityType: ActivityType.drankSomeWater,
        timestamp: DateTime(2026, 4, 8, 10, 0),
      );

      expect(logic.logItems.length, 1);

      await logic.deleteLogItem(item.id, item.timestamp);

      expect(logic.logItems, isEmpty);
    });

    test('should update a log item', () async {
      final item = await logic.createLogItem(
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
      );

      final updated = item.copyWith(bodilyFunction: BodilyFunction.both);
      await logic.updateLogItem(item, updated);

      expect(logic.logItems.first.bodilyFunction, BodilyFunction.both);
    });

    test('should update a log item moving it to a different day', () async {
      final item = await logic.createLogItem(
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
      );

      final updated = item.copyWith(timestamp: DateTime(2026, 4, 9, 10, 0));
      await logic.updateLogItem(item, updated);

      expect(logic.logItems.length, 1);
      expect(logic.logItems.first.timestamp.day, 9);
      expect(logic.itemsByDay.containsKey('2026-04-09'), isTrue);
      expect(logic.itemsByDay.containsKey('2026-04-08'), isFalse);
    });

    test('should remove day from index when last item is deleted', () async {
      final item = await logic.createLogItem(
        activityType: ActivityType.drankSomeWater,
        timestamp: DateTime(2026, 4, 8, 10, 0),
      );

      expect(logic.loadedDays, contains('2026-04-08'));

      await logic.deleteLogItem(item.id, item.timestamp);

      expect(logic.loadedDays, isNot(contains('2026-04-08')));
    });

    test('should load first page of days', () async {
      // Add items across 7 days
      for (int i = 0; i < 7; i++) {
        await repository.add(
          createTestItem(
            id: 'item_$i',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 1 + i, 10, 0),
          ),
        );
      }

      await logic.loadLogItems();

      // Should load first 5 days
      expect(logic.loadedDays.length, 5);
      expect(logic.hasMoreDays, isTrue);
    });

    test('should load more days when requested', () async {
      // Add items across 7 days
      for (int i = 0; i < 7; i++) {
        await repository.add(
          createTestItem(
            id: 'item_$i',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 1 + i, 10, 0),
          ),
        );
      }

      await logic.loadLogItems();
      expect(logic.loadedDays.length, 5);
      expect(logic.hasMoreDays, isTrue);

      await logic.loadMoreDays();
      expect(logic.loadedDays.length, 7);
      expect(logic.hasMoreDays, isFalse);
    });

    test('should add new day to index when creating item on new day', () async {
      await logic.createLogItem(
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 10, 0),
      );

      expect(logic.loadedDays, contains('2026-04-08'));

      await logic.createLogItem(
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 9, 10, 0),
      );

      expect(logic.loadedDays, contains('2026-04-09'));
    });

    group('requiresBodilyFunction', () {
      test('should return true for usedThePotty', () {
        expect(logic.requiresBodilyFunction(ActivityType.usedThePotty), isTrue);
      });

      test('should return true for accident', () {
        expect(logic.requiresBodilyFunction(ActivityType.accident), isTrue);
      });

      test('should return true for nappy', () {
        expect(logic.requiresBodilyFunction(ActivityType.nappy), isTrue);
      });

      test('should return false for triedThePotty', () {
        expect(logic.requiresBodilyFunction(ActivityType.triedThePotty), isFalse);
      });

      test('should return false for drankSomeWater', () {
        expect(logic.requiresBodilyFunction(ActivityType.drankSomeWater), isFalse);
      });

      test('should return false for drankLotsOfWater', () {
        expect(logic.requiresBodilyFunction(ActivityType.drankLotsOfWater), isFalse);
      });

      test('should return false for ateFood', () {
        expect(logic.requiresBodilyFunction(ActivityType.ateFood), isFalse);
      });
    });

    group('requiresInitiativeType', () {
      test('should return true for triedThePotty', () {
        expect(logic.requiresInitiativeType(ActivityType.triedThePotty), isTrue);
      });

      test('should return true for usedThePotty', () {
        expect(logic.requiresInitiativeType(ActivityType.usedThePotty), isTrue);
      });

      test('should return true for accident', () {
        expect(logic.requiresInitiativeType(ActivityType.accident), isTrue);
      });

      test('should return false for nappy', () {
        expect(logic.requiresInitiativeType(ActivityType.nappy), isFalse);
      });

      test('should return false for drankSomeWater', () {
        expect(logic.requiresInitiativeType(ActivityType.drankSomeWater), isFalse);
      });
    });

    group('availableBodilyFunctions', () {
      test('should return pee, poo, both for usedThePotty', () {
        final functions = logic.availableBodilyFunctions(ActivityType.usedThePotty);
        expect(functions, [BodilyFunction.pee, BodilyFunction.poo, BodilyFunction.both]);
      });

      test('should return pee, poo, both for accident', () {
        final functions = logic.availableBodilyFunctions(ActivityType.accident);
        expect(functions, [BodilyFunction.pee, BodilyFunction.poo, BodilyFunction.both]);
      });

      test('should return pee, poo, both, none for nappy', () {
        final functions = logic.availableBodilyFunctions(ActivityType.nappy);
        expect(functions, [
          BodilyFunction.pee,
          BodilyFunction.poo,
          BodilyFunction.both,
          BodilyFunction.none,
        ]);
      });

      test('should return empty for drankSomeWater', () {
        final functions = logic.availableBodilyFunctions(ActivityType.drankSomeWater);
        expect(functions, isEmpty);
      });
    });

    group('availableInitiativeTypes', () {
      test('should return all initiative types for triedThePotty', () {
        final types = logic.availableInitiativeTypes(ActivityType.triedThePotty);
        expect(types, [
          InitiativeType.toldParents,
          InitiativeType.wentByHimself,
          InitiativeType.askedToSit,
        ]);
      });

      test('should return empty for nappy', () {
        final types = logic.availableInitiativeTypes(ActivityType.nappy);
        expect(types, isEmpty);
      });
    });

    group('activityTypeEmoji', () {
      test('should return correct emoji for each activity type', () {
        expect(logic.activityTypeEmoji(ActivityType.triedThePotty), '🚽');
        expect(logic.activityTypeEmoji(ActivityType.usedThePotty), '🎉');
        expect(logic.activityTypeEmoji(ActivityType.accident), '😅');
        expect(logic.activityTypeEmoji(ActivityType.drankSomeWater), '💧');
        expect(logic.activityTypeEmoji(ActivityType.drankLotsOfWater), '💦');
        expect(logic.activityTypeEmoji(ActivityType.ateFood), '🍽️');
        expect(logic.activityTypeEmoji(ActivityType.nappy), '👶');
      });
    });

    group('bodilyFunctionEmoji', () {
      test('should return correct emoji for each bodily function', () {
        expect(logic.bodilyFunctionEmoji(BodilyFunction.pee), '💧');
        expect(logic.bodilyFunctionEmoji(BodilyFunction.poo), '💩');
        expect(logic.bodilyFunctionEmoji(BodilyFunction.both), '💧💩');
        expect(logic.bodilyFunctionEmoji(BodilyFunction.none), '');
      });
    });

    group('activityTypeName', () {
      test('should return name from l10n when available', () {
        final l10n = AppLocalizationsEn();
        logic.updateLocalizations(l10n);

        expect(logic.activityTypeName(ActivityType.usedThePotty), 'Used the potty');
        expect(logic.activityTypeName(ActivityType.accident), 'Accident');
        expect(logic.activityTypeName(ActivityType.ateFood), 'Ate food');
      });

      test('should return enum name when l10n is null', () {
        expect(logic.activityTypeName(ActivityType.usedThePotty), 'usedThePotty');
      });
    });

    group('bodilyFunctionName', () {
      test('should return name from l10n when available', () {
        final l10n = AppLocalizationsEn();
        logic.updateLocalizations(l10n);

        expect(logic.bodilyFunctionName(BodilyFunction.pee), 'Pee');
        expect(logic.bodilyFunctionName(BodilyFunction.poo), 'Poo');
        expect(logic.bodilyFunctionName(BodilyFunction.both), 'Both');
        expect(logic.bodilyFunctionName(BodilyFunction.none), 'None');
      });
    });

    group('initiativeTypeName', () {
      test('should return name from l10n when available', () {
        final l10n = AppLocalizationsEn();
        logic.updateLocalizations(l10n);

        expect(logic.initiativeTypeName(InitiativeType.toldParents), 'Told parents');
        expect(logic.initiativeTypeName(InitiativeType.wentByHimself), 'Went by himself');
        expect(logic.initiativeTypeName(InitiativeType.askedToSit), 'Asked to sit');
      });
    });
  });
}
