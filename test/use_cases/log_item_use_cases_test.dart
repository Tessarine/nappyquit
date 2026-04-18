import 'package:flutter_test/flutter_test.dart';
import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';
import 'package:toot_n_tinkle/use_cases/add_log_item_use_case.dart';
import 'package:toot_n_tinkle/use_cases/delete_log_item_use_case.dart';
import 'package:toot_n_tinkle/use_cases/get_log_items_use_case.dart';
import 'package:toot_n_tinkle/use_cases/update_log_item_use_case.dart';

import '../in_memory_potty_training_log_item_repository.dart';

void main() {
  late InMemoryPottyTrainingLogItemRepository repository;

  setUp(() {
    repository = InMemoryPottyTrainingLogItemRepository();
  });

  group('AddLogItemUseCase', () {
    test('should add a log item to the repository', () async {
      final addUseCase = AddLogItemUseCase(repository);
      final item = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        initiativeType: InitiativeType.toldParents,
      );

      await addUseCase(item);

      final items = await repository.getAll();
      expect(items.length, 1);
      expect(items.first.id, '1');
      expect(items.first.activityType, ActivityType.usedThePotty);
    });
  });

  group('GetLogItemsUseCase', () {
    test('should return day index sorted descending', () async {
      final addUseCase = AddLogItemUseCase(repository);
      final getUseCase = GetLogItemsUseCase(repository);

      await addUseCase(
        PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.ateFood,
          timestamp: DateTime(2026, 4, 8, 9, 0),
        ),
      );
      await addUseCase(
        PottyTrainingLogItem(
          id: '2',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 9, 10, 0),
        ),
      );

      final dayIndex = await getUseCase.getDayIndex();
      expect(dayIndex, ['2026-04-09', '2026-04-08']);
    });

    test('should return empty day index when no items exist', () async {
      final getUseCase = GetLogItemsUseCase(repository);

      final dayIndex = await getUseCase.getDayIndex();
      expect(dayIndex, isEmpty);
    });

    test('should return log items for specified days', () async {
      final addUseCase = AddLogItemUseCase(repository);
      final getUseCase = GetLogItemsUseCase(repository);

      await addUseCase(
        PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.ateFood,
          timestamp: DateTime(2026, 4, 8, 9, 0),
        ),
      );
      await addUseCase(
        PottyTrainingLogItem(
          id: '2',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
        ),
      );
      await addUseCase(
        PottyTrainingLogItem(
          id: '3',
          activityType: ActivityType.drankWater,
          timestamp: DateTime(2026, 4, 9, 11, 0),
          waterAmount: WaterAmount.lots,
        ),
      );

      final items = await getUseCase.getLogItemsForDays(['2026-04-08']);
      expect(items.length, 1);
      expect(items['2026-04-08']!.length, 2);
      expect(items['2026-04-08']!.first.id, '2'); // More recent first
    });

    test('should return empty map for days with no items', () async {
      final getUseCase = GetLogItemsUseCase(repository);

      final items = await getUseCase.getLogItemsForDays(['2026-04-08']);
      expect(items, isEmpty);
    });
  });

  group('DeleteLogItemUseCase', () {
    test('should delete a log item by ID and timestamp', () async {
      final addUseCase = AddLogItemUseCase(repository);
      final deleteUseCase = DeleteLogItemUseCase(repository);
      final getUseCase = GetLogItemsUseCase(repository);

      final item = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.drankWater,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        waterAmount: WaterAmount.some,
      );

      await addUseCase(item);
      expect((await getUseCase.getLogItemsForDays(['2026-04-08']))['2026-04-08']!.length, 1);

      await deleteUseCase('1', item.timestamp);
      expect(
        (await getUseCase.getLogItemsForDays(['2026-04-08'])).containsKey('2026-04-08'),
        isFalse,
      );
    });

    test('should not throw when deleting non-existent item', () async {
      final deleteUseCase = DeleteLogItemUseCase(repository);

      await deleteUseCase('non-existent', DateTime(2026, 4, 8, 10, 0));
      // Should not throw
    });
  });

  group('UpdateLogItemUseCase', () {
    test('should update an existing log item on the same day', () async {
      final addUseCase = AddLogItemUseCase(repository);
      final updateUseCase = UpdateLogItemUseCase(repository);
      final getUseCase = GetLogItemsUseCase(repository);

      final item = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
      );

      await addUseCase(item);

      final updated = item.copyWith(bodilyFunction: BodilyFunction.both);
      await updateUseCase(updated, item.timestamp);

      final items = await getUseCase.getLogItemsForDays(['2026-04-08']);
      expect(items['2026-04-08']!.length, 1);
      expect(items['2026-04-08']!.first.bodilyFunction, BodilyFunction.both);
    });

    test('should move item to a different day when timestamp changes', () async {
      final addUseCase = AddLogItemUseCase(repository);
      final updateUseCase = UpdateLogItemUseCase(repository);
      final getUseCase = GetLogItemsUseCase(repository);

      final item = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
      );

      await addUseCase(item);

      final updated = item.copyWith(timestamp: DateTime(2026, 4, 9, 10, 0));
      await updateUseCase(updated, item.timestamp);

      // Item should be in the new day
      final day9Items = await getUseCase.getLogItemsForDays(['2026-04-09']);
      expect(day9Items['2026-04-09']!.length, 1);
      expect(day9Items['2026-04-09']!.first.timestamp.day, 9);

      // Item should not be in the old day
      final day8Items = await getUseCase.getLogItemsForDays(['2026-04-08']);
      expect(day8Items.containsKey('2026-04-08'), isFalse);
    });
  });
}
