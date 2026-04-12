import 'package:toot_n_tinkle/repositories/potty_training_log_item_repository.dart';

/// Use case for deleting a potty training log item.
class DeleteLogItemUseCase {
  final PottyTrainingLogItemRepository _repository;

  DeleteLogItemUseCase(this._repository);

  Future<void> call(String id, DateTime timestamp) async {
    await _repository.delete(id, timestamp);
  }
}
