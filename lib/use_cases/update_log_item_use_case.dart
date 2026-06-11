import 'package:nappyquit/domain/potty_training_log_item.dart';
import 'package:nappyquit/repositories/potty_training_log_item_repository.dart';

/// Use case for updating an existing potty training log item.
class UpdateLogItemUseCase {
  final PottyTrainingLogItemRepository _repository;

  UpdateLogItemUseCase(this._repository);

  Future<void> call(PottyTrainingLogItem item, DateTime originalTimestamp) async {
    await _repository.update(item, originalTimestamp);
  }
}
