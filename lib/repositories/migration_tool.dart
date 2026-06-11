import 'package:nappyquit/repositories/potty_training_log_item_repository.dart';

/// Tool for migrating data from one repository to another.
/// Takes the latest update if there's a conflict (same ID with different timestamps).
class MigrationTool {
  /// Migrates all data from [source] to [destination].
  /// If an item with the same ID exists in both repositories,
  /// the one with the latest [updated] timestamp is kept.
  Future<void> migrateRepositories(
    PottyTrainingLogItemRepository source,
    PottyTrainingLogItemRepository destination,
  ) async {
    // Get all day keys from source
    final sourceDayKeys = await source.getDayIndex();

    // Get all log items from source
    final sourceLogItemsMap = await source.getLogItemsForDays(sourceDayKeys);

    // Get all day keys from destination to check for conflicts
    final destinationDayKeys = await destination.getDayIndex();
    final destinationLogItemsMap = await destination.getLogItemsForDays(destinationDayKeys);

    // Process each item from source
    for (final dayKey in sourceDayKeys) {
      final sourceItems = sourceLogItemsMap[dayKey] ?? [];

      for (final sourceItem in sourceItems) {
        // Check if this item already exists in destination
        bool itemExistsInDestination = false;
        DateTime? latestDestinationUpdate;

        // Search through destination items to find matching ID
        for (final destDayKey in destinationDayKeys) {
          final destItems = destinationLogItemsMap[destDayKey] ?? [];
          for (final destItem in destItems) {
            if (destItem.id == sourceItem.id) {
              itemExistsInDestination = true;
              // Keep track of the latest updated timestamp
              if (latestDestinationUpdate == null ||
                  destItem.updated.isAfter(latestDestinationUpdate)) {
                latestDestinationUpdate = destItem.updated;
              }
            }
          }
        }

        // If item doesn't exist in destination, or source item is newer, add/update it
        if (!itemExistsInDestination ||
            (latestDestinationUpdate != null &&
                sourceItem.updated.isAfter(latestDestinationUpdate))) {
          await destination.add(sourceItem);
        }
        // If item exists and destination is newer or same, do nothing (keep destination)
      }
    }
  }

  /// Alternative migration strategy: completely overwrite destination with source
  Future<void> overwriteMigration(
    PottyTrainingLogItemRepository source,
    PottyTrainingLogItemRepository destination,
  ) async {
    // Clear destination first (by deleting all items)
    final destinationDayKeys = await destination.getDayIndex();
    final destinationLogItemsMap = await destination.getLogItemsForDays(destinationDayKeys);

    for (final dayKey in destinationDayKeys) {
      final destItems = destinationLogItemsMap[dayKey] ?? [];
      for (final destItem in destItems) {
        await destination.delete(destItem.id, destItem.timestamp);
      }
    }

    // Then copy all items from source
    final sourceDayKeys = await source.getDayIndex();
    final sourceLogItemsMap = await source.getLogItemsForDays(sourceDayKeys);

    for (final dayKey in sourceDayKeys) {
      final sourceItems = sourceLogItemsMap[dayKey] ?? [];
      for (final sourceItem in sourceItems) {
        await destination.add(sourceItem);
      }
    }
  }
}
