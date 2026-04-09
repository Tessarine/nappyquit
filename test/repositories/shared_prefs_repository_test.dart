import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:potty_train/domain/activity_type.dart';
import 'package:potty_train/domain/bodily_function.dart';
import 'package:potty_train/domain/initiative_type.dart';
import 'package:potty_train/domain/potty_training_log_item.dart';
import 'package:potty_train/repositories/shared_prefs_potty_training_log_item_repository.dart';

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

    group('migrateIfNeeded', () {
      test('should return false when no legacy data exists', () async {
        final migrated = await repository.migrateIfNeeded();
        expect(migrated, isFalse);
      });

      test('should migrate legacy data to day-indexed format', () async {
        // Set up legacy data
        final legacyItems = [
          {
            'id': '1',
            'activityType': 'ateFood',
            'timestamp': DateTime(2026, 4, 8, 9, 0).toIso8601String(),
            'bodilyFunction': null,
            'initiativeType': null,
          },
          {
            'id': '2',
            'activityType': 'usedThePotty',
            'timestamp': DateTime(2026, 4, 8, 10, 0).toIso8601String(),
            'bodilyFunction': 'pee',
            'initiativeType': 'toldParents',
          },
          {
            'id': '3',
            'activityType': 'drankSomeWater',
            'timestamp': DateTime(2026, 4, 9, 11, 0).toIso8601String(),
            'bodilyFunction': null,
            'initiativeType': null,
          },
        ];
        await prefs.setString('potty_training_log_items', json.encode(legacyItems));

        final migrated = await repository.migrateIfNeeded();
        expect(migrated, isTrue);

        // Verify day index
        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, ['2026-04-09', '2026-04-08']);

        // Verify items
        final day8Items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(day8Items['2026-04-08']!.length, 2);

        final day9Items = await repository.getLogItemsForDays(['2026-04-09']);
        expect(day9Items['2026-04-09']!.length, 1);

        // Verify old key is removed
        expect(prefs.containsKey('potty_training_log_items'), isFalse);
      });

      test('should not migrate when new format already exists', () async {
        // Set up new format data
        await prefs.setStringList('activity_log_index', ['2026-04-08']);
        await prefs.setString(
          'activity_log_2026-04-08',
          json.encode([
            {
              'id': '1',
              'activityType': 'ateFood',
              'timestamp': DateTime(2026, 4, 8, 9, 0).toIso8601String(),
              'bodilyFunction': null,
              'initiativeType': null,
            },
          ]),
        );

        // Also set up legacy data (should be ignored)
        await prefs.setString(
          'potty_training_log_items',
          json.encode([
            {
              'id': '2',
              'activityType': 'usedThePotty',
              'timestamp': DateTime(2026, 4, 9, 10, 0).toIso8601String(),
              'bodilyFunction': 'pee',
              'initiativeType': null,
            },
          ]),
        );

        final migrated = await repository.migrateIfNeeded();
        expect(migrated, isFalse);

        // Legacy data should still be there (not migrated)
        expect(prefs.containsKey('potty_training_log_items'), isTrue);
      });

      test('should handle empty legacy data', () async {
        await prefs.setString('potty_training_log_items', json.encode([]));

        final migrated = await repository.migrateIfNeeded();
        expect(migrated, isTrue);

        // Old key should be removed
        expect(prefs.containsKey('potty_training_log_items'), isFalse);

        // Day index should be empty
        final dayIndex = await repository.getDayIndex();
        expect(dayIndex, isEmpty);
      });

      test('should not migrate again after successful migration', () async {
        // Set up legacy data
        final legacyItems = [
          {
            'id': '1',
            'activityType': 'ateFood',
            'timestamp': DateTime(2026, 4, 8, 9, 0).toIso8601String(),
            'bodilyFunction': null,
            'initiativeType': null,
          },
        ];
        await prefs.setString('potty_training_log_items', json.encode(legacyItems));

        final firstMigration = await repository.migrateIfNeeded();
        expect(firstMigration, isTrue);

        final secondMigration = await repository.migrateIfNeeded();
        expect(secondMigration, isFalse);
      });
    });
  });
}
