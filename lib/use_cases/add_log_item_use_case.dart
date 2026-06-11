import 'package:nappyquit/domain/potty_training_log_item.dart';
import 'package:nappyquit/repositories/potty_training_log_item_repository.dart';

/// Use case for adding a new potty training log item.
class AddLogItemUseCase {
  final PottyTrainingLogItemRepository _repository;

  AddLogItemUseCase(this._repository);

  Future<void> call(PottyTrainingLogItem item) async {
    await _repository.add(item);
  }
}
