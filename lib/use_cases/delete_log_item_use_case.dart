import '../repositories/potty_training_log_item_repository.dart';

/// Use case for deleting a potty training log item.
class DeleteLogItemUseCase {
  final PottyTrainingLogItemRepository _repository;

  DeleteLogItemUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.delete(id);
  }
}
