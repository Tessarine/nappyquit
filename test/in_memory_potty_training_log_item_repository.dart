import 'package:potty_train/domain/potty_training_log_item.dart';
import 'package:potty_train/repositories/potty_training_log_item_repository.dart';

/// In-memory implementation of the repository for testing purposes.
class InMemoryPottyTrainingLogItemRepository implements PottyTrainingLogItemRepository {
  final List<PottyTrainingLogItem> _items = [];

  @override
  Future<List<PottyTrainingLogItem>> getAll() async {
    return List.from(_items)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> add(PottyTrainingLogItem item) async {
    _items.add(item);
  }

  @override
  Future<void> update(PottyTrainingLogItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((i) => i.id == id);
  }
}
