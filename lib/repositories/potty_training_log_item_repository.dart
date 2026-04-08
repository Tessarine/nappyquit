import '../domain/potty_training_log_item.dart';

/// Abstract repository interface for potty training log items.
abstract class PottyTrainingLogItemRepository {
  /// Retrieves all log items, sorted by timestamp descending.
  Future<List<PottyTrainingLogItem>> getAll();

  /// Adds a new log item.
  Future<void> add(PottyTrainingLogItem item);

  /// Updates an existing log item.
  Future<void> update(PottyTrainingLogItem item);

  /// Deletes a log item by its ID.
  Future<void> delete(String id);
}
