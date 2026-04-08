import '../domain/potty_training_log_item.dart';
import '../repositories/potty_training_log_item_repository.dart';

/// Use case for retrieving all potty training log items.
class GetLogItemsUseCase {
  final PottyTrainingLogItemRepository _repository;

  GetLogItemsUseCase(this._repository);

  Future<List<PottyTrainingLogItem>> call() async {
    return _repository.getAll();
  }
}
