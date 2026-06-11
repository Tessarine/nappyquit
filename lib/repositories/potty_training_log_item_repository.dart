import 'package:nappyquit/domain/potty_training_log_item.dart';

/// Abstract repository interface for potty training log items.
/// Supports day-indexed storage with pagination.
abstract class PottyTrainingLogItemRepository {
  /// Returns the list of dates (as 'yyyy-MM-dd' strings) that have log items,
  /// sorted in descending order (most recent first).
  Future<List<String>> getDayIndex();

  /// Returns log items for the specified days.
  /// Returns a map of day key -> list of items sorted by timestamp descending.
  Future<Map<String, List<PottyTrainingLogItem>>> getLogItemsForDays(List<String> dayKeys);

  /// Adds a new log item.
  Future<void> add(PottyTrainingLogItem item);

  /// Updates an existing log item.
  /// [originalTimestamp] is needed to locate the item in the day-indexed storage
  /// in case the timestamp changed and the item needs to move to a different day.
  Future<void> update(PottyTrainingLogItem item, DateTime originalTimestamp);

  /// Deletes a log item by its ID.
  /// [timestamp] is needed to locate the item in the day-indexed storage.
  Future<void> delete(String id, DateTime timestamp);
}
