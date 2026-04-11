import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/repositories/shared_prefs_potty_training_log_item_repository.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPrefsPottyTrainingLogItemRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = SharedPrefsPottyTrainingLogItemRepository(prefs);
  });

  group('SharedPrefsPottyTrainingLogItemRepository', () {
    group('getDayIndex', () {
      test('should return empty list when no items exist', () async {
        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, isEmpty);
      });

      test('should return days sorted descending after adding items', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 9, 0),
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.usedThePotty,
            timestamp: DateTime(2026, 4, 9, 10, 0),
          ),
        );

        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, ['2026-04-09', '2026-04-08']);
      });
    });

    group('getLogItemsForDays', () {
      test('should return items for specified days', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 9, 0),
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.usedThePotty,
            timestamp: DateTime(2026, 4, 8, 10, 0),
          ),
        );

        final items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(items['2026-04-08']!.length, 2);
        expect(items['2026-04-08']!.first.id, '2'); // More recent first
      });
    });

    group('add', () {
      test('should add item and update day index', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
          bodilyFunction: BodilyFunction.pee,
        );

        await repository.add(item);

        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, ['2026-04-08']);

        final items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(items['2026-04-08']!.length, 1);
        expect(items['2026-04-08']!.first.id, '1');
      });

      test('should not duplicate day in index when adding to existing day', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 9, 0),
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.usedThePotty,
            timestamp: DateTime(2026, 4, 8, 10, 0),
          ),
        );

        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, ['2026-04-08']);
      });
    });

    group('update', () {
      test('should update item on the same day', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
          bodilyFunction: BodilyFunction.pee,
        );

        await repository.add(item);

        final updated = item.copyWith(bodilyFunction: BodilyFunction.both);
        await repository.update(updated, item.timestamp);

        final items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(items['2026-04-08']!.first.bodilyFunction, BodilyFunction.both);
      });

      test('should move item to a different day when timestamp changes', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
          bodilyFunction: BodilyFunction.pee,
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

      test('should remove old day from index when it becomes empty after move', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.usedThePotty,
          timestamp: DateTime(2026, 4, 8, 10, 0),
        );

        await repository.add(item);

        final updated = item.copyWith(timestamp: DateTime(2026, 4, 9, 10, 0));
        await repository.update(updated, item.timestamp);

        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, ['2026-04-09']);
      });
    });

    group('delete', () {
      test('should delete item and remove day from index when empty', () async {
        final item = PottyTrainingLogItem(
          id: '1',
          activityType: ActivityType.drankSomeWater,
          timestamp: DateTime(2026, 4, 8, 10, 0),
        );

        await repository.add(item);
        await repository.delete('1', item.timestamp);

        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, isEmpty);
      });

      test('should keep day in index when other items remain', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.drankSomeWater,
            timestamp: DateTime(2026, 4, 8, 10, 0),
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 11, 0),
          ),
        );

        await repository.delete('1', DateTime(2026, 4, 8, 10, 0));

        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, ['2026-04-08']);

        final items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(items['2026-04-08']!.length, 1);
        expect(items['2026-04-08']!.first.id, '2');
      });
    });
  });
}
