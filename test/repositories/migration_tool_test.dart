import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import '../in_memory_potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/repositories/markdown_potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/repositories/migration_tool.dart';

void main() {
  late String testDir;
  late InMemoryPottyTrainingLogItemRepository sourceRepo;
  late MarkdownPottyTrainingLogItemRepository destRepo;
  late MigrationTool migrationTool;

  setUp(() async {
    // Create a temporary directory for testing
    testDir = path.join(Directory.current.path, 'test_markdown_repo');
    final dir = Directory(testDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await dir.create();

    sourceRepo = InMemoryPottyTrainingLogItemRepository();
    destRepo = MarkdownPottyTrainingLogItemRepository(testDir);
    migrationTool = MigrationTool();
  });

  tearDown(() async {
    // Clean up the test directory
    final dir = Directory(testDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  group('MigrationTool', () {
    test('should migrate all items from source to destination', () async {
      // Add items to source repository
      final item1 = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );
      final item2 = PottyTrainingLogItem(
        id: '2',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 9, 0),
        created: DateTime(2026, 4, 8, 9, 0),
        updated: DateTime(2026, 4, 8, 9, 0),
        deleted: null,
      );

      await sourceRepo.add(item1);
      await sourceRepo.add(item2);

      // Perform migration
      await migrationTool.migrateRepositories(sourceRepo, destRepo);

      // Check that items were migrated to destination
      final sourceDayKeys = await sourceRepo.getDayIndex();
      final sourceLogItems = await sourceRepo.getLogItemsForDays(sourceDayKeys);

      final destDayKeys = await destRepo.getDayIndex();
      final destLogItems = await destRepo.getLogItemsForDays(destDayKeys);

      // Source should still have items (migration doesn't remove from source)
      expect(sourceLogItems.values.expand((list) => list).length, 2);

      // Destination should have the same items
      expect(destLogItems.values.expand((list) => list).length, 2);

      // Check specific items
      final allDestItems = destLogItems.values.expand((list) => list).toList();
      expect(allDestItems.any((item) => item.id == '1'), isTrue);
      expect(allDestItems.any((item) => item.id == '2'), isTrue);
    });

    test('should keep latest version when there are conflicts', () async {
      // Add an item to source with older timestamp
      final oldItem = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0), // Older update time
        deleted: null,
      );

      // Add the same item to destination with newer timestamp
      final newItem = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.both, // Different value
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 11, 0), // Newer update time
        deleted: null,
      );

      await sourceRepo.add(oldItem);
      await destRepo.add(newItem);

      // Perform migration
      await migrationTool.migrateRepositories(sourceRepo, destRepo);

      // Check that destination kept the newer version
      final destItems = (await destRepo.getLogItemsForDays(
        await destRepo.getDayIndex(),
      )).values.expand((list) => list).toList();

      expect(destItems.length, 1);
      expect(
        destItems.first.bodilyFunction,
        BodilyFunction.both,
      ); // Should be from destination (newer)
      expect(destItems.first.updated.hour, 11); // Should be the newer time
    });

    test('should overwrite destination with source when using overwriteMigration', () async {
      // Add items to source
      final sourceItem1 = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        bodilyFunction: BodilyFunction.pee,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      // Add different items to destination
      final destItem1 = PottyTrainingLogItem(
        id: '2',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 9, 0),
        created: DateTime(2026, 4, 8, 9, 0),
        updated: DateTime(2026, 4, 8, 9, 0),
        deleted: null,
      );

      await sourceRepo.add(sourceItem1);
      await destRepo.add(destItem1);

      // Perform overwrite migration
      await migrationTool.overwriteMigration(sourceRepo, destRepo);

      // Check that destination now only has source items
      final destItems = (await destRepo.getLogItemsForDays(
        await destRepo.getDayIndex(),
      )).values.expand((list) => list).toList();

      expect(destItems.length, 1);
      expect(destItems.first.id, '1'); // Should be the source item
      expect(destItems.first.activityType, ActivityType.usedThePotty);
    });
  });
}
