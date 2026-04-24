import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/repositories/markdown_potty_training_log_item_repository.dart';

void main() {
  late String testDir;
  late MarkdownPottyTrainingLogItemRepository repository;

  setUp(() async {
    // Create a temporary directory for testing
    testDir = path.join(Directory.current.path, 'test_markdown_repo');
    final dir = Directory(testDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await dir.create();

    repository = MarkdownPottyTrainingLogItemRepository(testDir);
  });

  tearDown(() async {
    // Clean up the test directory
    final dir = Directory(testDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  group('MarkdownPottyTrainingLogItemRepository', () {
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

        final items = await repository.getLogItemsForDays(['2026-04-08']);
        expect(items['2026-04-08']!.length, 2);
        expect(items['2026-04-08']!.first.id, '2'); // More recent first
      });
    });

    group('add', () {
      test('should add item and create markdown file', () async {
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

        // Check that the markdown file was created
        final file = File(path.join(testDir, '2026-04-08.md'));
        expect(await file.exists(), isTrue);

        final content = await file.readAsString();
        expect(content, contains('# Potty Training Log for 2026-04-08'));
        expect(content, contains('**ID:** 1'));
        expect(content, contains('**Activity Type:** usedThePotty'));
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
          deleted: null,
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
      test('should delete item and remove markdown file when empty', () async {
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

        // Check that the markdown file was deleted
        final file = File(path.join(testDir, '2026-04-08.md'));
        expect(await file.exists(), isFalse);
      });

      test('should keep markdown file when other items remain', () async {
        await repository.add(
          PottyTrainingLogItem(
            id: '1',
            activityType: ActivityType.drankWater,
            timestamp: DateTime(2026, 4, 8, 10, 0),
            created: DateTime(2026, 4, 8, 10, 0),
            updated: DateTime(2026, 4, 8, 10, 0),
            deleted: null,
          ),
        );
        await repository.add(
          PottyTrainingLogItem(
            id: '2',
            activityType: ActivityType.ateFood,
            timestamp: DateTime(2026, 4, 8, 9, 0),
            created: DateTime(2026, 4, 8, 9, 0),
            updated: DateTime(2026, 4, 8, 9, 0),
            deleted: null,
          ),
        );

        await repository.delete('1', DateTime(2026, 4, 8, 10, 0));

        // Check that the markdown file still exists
        final file = File(path.join(testDir, '2026-04-08.md'));
        expect(await file.exists(), isTrue);

        final content = await file.readAsString();
        expect(content, contains('**ID:** 2'));
        expect(content, contains('**Activity Type:** ateFood'));
        expect(content, isNot(contains('**ID:** 1'))); // Should not contain the deleted item
      });
    });
  });
}
