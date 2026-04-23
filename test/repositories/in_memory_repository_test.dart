import 'package:flutter_test/flutter_test.dart';
import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';

import '../in_memory_potty_training_log_item_repository.dart';

void main() {
  late InMemoryPottyTrainingLogItemRepository repository;

  setUp(() {
    repository = InMemoryPottyTrainingLogItemRepository();
  });

  group('InMemoryPottyTrainingLogItemRepository', () {
    group('getDayIndex', () {
      test('should return empty list when no items exist', () async {
        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, isEmpty);
      });

      test('should return unique days sorted descending', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 9, 0),
            created: DateTime(2026, 4, 8, 9, 0),
            updated: DateTime(2026, 4, 8, 9, 0),
            deleted: null,
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.usedThePotty,
            timestamp: DateTime(2026, 4, 9, 10, 0),
            created: DateTime(2026, 4, 9, 10, 0),
            updated: DateTime(2026, 4, 9, 10, 0),
            deleted: null,
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '3',
            activityType: ActivityType.drankWater,
            timestamp: DateTime(2026, 4, 8, 11, 0),
            waterAmount: WaterAmount.some,
            created: DateTime(2026, 4, 8, 11, 0),
            updated: DateTime(2026, 4, 8, 11, 0),
            deleted: null,
          ),
        );

        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, ['2026-04-09', '2026-04-08']);
      });
    });

    group('getLogItemsForDays', () {
      test('should return empty map for days with no items', () async {
        final items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(items, isEmpty);
      });

      test('should return items for specified days sorted by timestamp descending', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 9, 0),
            created: DateTime(2026, 4, 8, 9, 0),
            updated: DateTime(2026, 4, 8, 9, 0),
            deleted: null,
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.usedThePotty,
            timestamp: DateTime(2026, 4, 8, 10, 0),
            created: DateTime(2026, 4, 8, 10, 0),
            updated: DateTime(2026, 4, 8, 10, 0),
            deleted: null,
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '3',
            activityType: ActivityType.drankWater,
            timestamp: DateTime(2026, 4, 9, 11, 0),
            waterAmount: WaterAmount.lots,
            created: DateTime(2026, 4, 9, 11, 0),
            updated: DateTime(2026, 4, 9, 11, 0),
            deleted: null,
          ),
        );

        final items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(items.length, 1);
        expect(items['2026-04-08']!.length, 2);
        expect(items['2026-04-08']!.first.id, '2'); // More recent first
        expect(items['2026-04-08']!.last.id, '1');
      });

      test('should return items for multiple days', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 9, 0),
            created: DateTime(2026, 4, 8, 9, 0),
            updated: DateTime(2026, 4, 8, 9, 0),
            deleted: null,
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.usedThePotty,
            timestamp: DateTime(2026, 4, 9, 10, 0),
            created: DateTime(2026, 4, 9, 10, 0),
            updated: DateTime(2026, 4, 9, 10, 0),
            deleted: null,
          ),
        );

        final items = await repository.getLogItemsForDays(['2026-04-08', '2026-04-09']);
        expect(items.length, 2);
        expect(items['2026-04-08']!.length, 1);
        expect(items['2026-04-09']!.length, 1);
      });

      test('should not return items for days not requested', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 9, 0),
            created: DateTime(2026, 4, 8, 9, 0),
            updated: DateTime(2026, 4, 8, 9, 0),
            deleted: null,
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.usedThePotty,
            timestamp: DateTime(2026, 4, 9, 10, 0),
            created: DateTime(2026, 4, 9, 10, 0),
            updated: DateTime(2026, 4, 9, 10, 0),
            deleted: null,
          ),
        );

        final items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(items.length, 1);
        expect(items.containsKey('2026-04-09'), isFalse);
      });
    });

    group('add', () {
      test('should add item to repository', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
          bodilyFunction: BodilyFunction.pee,
          created: DateTime(2026, 4, 8, 10, 0),
          updated: DateTime(2026, 4, 8, 10, 0),
          deleted: null,
        );

        await repository.add(item);

        final allItems = await repository.getAll();
        expect(allItems.length, 1);
        expect(allItems.first.id, '1');
      });
    });

    group('update', () {
      test('should update item on the same day', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
          bodilyFunction: BodilyFunction.pee,
          created: DateTime(2026, 4, 8, 10, 0),
          updated: DateTime(2026, 4, 8, 10, 0),
        );

        await repository.add(item);

        final updated = item.copyWith(bodilyFunction: BodilyFunction.both);
        await repository.update(updated, item.timestamp);

        final allItems = await repository.getAll();
        expect(allItems.length, 1);
        expect(allItems.first.bodilyFunction, BodilyFunction.both);
      });

      test('should move item to a different day when timestamp changes', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
          bodilyFunction: BodilyFunction.pee,
          created: DateTime(2026, 4, 8, 10, 0),
          updated: DateTime(2026, 4, 8, 10, 0),
          deleted: null,
        );

        await repository.add(item);

        final updated = item.copyWith(timestamp: DateTime(2026, 4, 9, 10, 0));
        await repository.update(updated, item.timestamp);

        final day8Items = await repository.getLogItemsForDays(['2026-04-08']);
        final day9Items = await repository.getLogItemsForDays(['2026-04-09']);

        expect(day8Items.containsKey('2026-04-08'), isFalse);
        expect(day9Items['2026-04-09']!.length, 1);
        expect(day9Items['2026-04-09']!.first.timestamp.day, 9);
      });
    });

    group('delete', () {
      test('should delete item by ID and timestamp', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
          bodilyFunction: BodilyFunction.pee,
          created: DateTime(2026, 4, 8, 10, 0),
          updated: DateTime(2026, 4, 8, 10, 0),
          deleted: null,
        );

        await repository.add(item);
        await repository.delete('1', item.timestamp);

        final allItems = await repository.getAll();
        expect(allItems, isEmpty);
      });

      test('should not affect items on other days', () async {
        final item1 = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.drankWater,
          timestamp: DateTime(2026, 4, 8, 10, 0),
          waterAmount: WaterAmount.some,
          created: DateTime(2026, 4, 8, 10, 0),
          updated: DateTime(2026, 4, 8, 10, 0),
        );
        final item2 = PottyTrainingLogItem(
          id: '6',
          activityType: ActivityType.drankWater,
          timestamp: DateTime(2026, 4, 8, 12, 0),
          waterAmount: WaterAmount.lots,
          created: DateTime(2026, 4, 8, 12, 0),
          updated: DateTime(2026, 4, 8, 12, 0),
          deleted: null,
        );

        await repository.add(item1);
        await repository.add(item2);

        await repository.delete('1', item1.timestamp);

        final allItems = await repository.getAll();
        expect(allItems.length, 1);
        expect(allItems.first.id, '6');
      });
    });
  });
}
