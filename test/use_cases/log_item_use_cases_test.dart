import 'package:flutter_test/flutter_test.dart';
import 'package:potty_train/domain/activity_type.dart';
import 'package:potty_train/domain/bodily_function.dart';
import 'package:potty_train/domain/initiative_type.dart';
import 'package:potty_train/domain/potty_training_log_item.dart';
import 'package:potty_train/use_cases/add_log_item_use_case.dart';
import 'package:potty_train/use_cases/delete_log_item_use_case.dart';
import 'package:potty_train/use_cases/get_log_items_use_case.dart';
import 'package:potty_train/use_cases/update_log_item_use_case.dart';

import '../in_memory_potty_training_log_item_repository.dart';

void main() {
  late InMemoryPottyTrainingLogItemRepository repository;

  setUp(() {
    repository = InMemoryPottyTrainingLogItemRepository();
  });

  group('AddLogItemUseCase', () {
    test('should add a log item to the repository', () async {
      final useCase = AddLogItemUseCase(repository);
      final item = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        initiativeType: InitiativeType.toldParents,
      );

      await useCase(item);

      final items = await repository.getAll();
      expect(items.length, 1);
      expect(items.first.id, '1');
      expect(items.first.activityType, ActivityType.usedThePotty);
    });
  });

  group('GetLogItemsUseCase', () {
    test('should return all log items sorted by timestamp descending', () async {
      final addUseCase = AddLogItemUseCase(repository);
      final getUseCase = GetLogItemsUseCase(repository);

      final item1 = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 9, 0),
      );
      final item2 = PottyTrainingLogItem(
        id: '2',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
      );

      await addUseCase(item1);
      await addUseCase(item2);

      final items = await getUseCase();
      expect(items.length, 2);
      expect(items.first.id, '2'); // More recent first
      expect(items.last.id, '1');
    });

    test('should return empty list when no items exist', () async {
      final getUseCase = GetLogItemsUseCase(repository);

      final items = await getUseCase();
      expect(items, isEmpty);
    });
  });

  group('DeleteLogItemUseCase', () {
    test('should delete a log item by ID', () async {
      final addUseCase = AddLogItemUseCase(repository);
      final deleteUseCase = DeleteLogItemUseCase(repository);
      final getUseCase = GetLogItemsUseCase(repository);

      final item = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.drankSomeWater,
        timestamp: DateTime(2026, 4, 8, 10, 0),
      );

      await addUseCase(item);
      expect((await getUseCase()).length, 1);

      await deleteUseCase('1');
      expect((await getUseCase()).length, 0);
    });

    test('should not throw when deleting non-existent item', () async {
      final deleteUseCase = DeleteLogItemUseCase(repository);

      await deleteUseCase('non-existent');
      // Should not throw
    });
  });

  group('UpdateLogItemUseCase', () {
    test('should update an existing log item', () async {
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
      await updateUseCase(updated);

      final items = await getUseCase();
      expect(items.length, 1);
      expect(items.first.bodilyFunction, BodilyFunction.both);
    });
  });
}
