import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/repositories/potty_training_log_item_repository.dart';

/// Use case for retrieving potty training log items with pagination by day.
class GetLogItemsUseCase {
  final PottyTrainingLogItemRepository _repository;

  GetLogItemsUseCase(this._repository);

  /// Returns the day index (list of date strings with activities, descending).
  Future<List<String>> getDayIndex() async {
    return _repository.getDayIndex();
  }

  /// Returns log items for the specified days.
  Future<Map<String, List<PottyTrainingLogItem>>> getLogItemsForDays(List<String> dayKeys) async {
    return _repository.getLogItemsForDays(dayKeys);
  }
}
