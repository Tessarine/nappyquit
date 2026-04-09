import 'package:potty_train/domain/potty_training_log_item.dart';
import 'package:potty_train/repositories/potty_training_log_item_repository.dart';

/// In-memory implementation of the repository for testing purposes.
/// Supports day-indexed storage with pagination.
class InMemoryPottyTrainingLogItemRepository implements PottyTrainingLogItemRepository {
  final List<PottyTrainingLogItem> _items = [];

  String _toDayKey(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<String>> getDayIndex() async {
    final days = <String>{};
    for (final item in _items) {
      days.add(_toDayKey(item.timestamp));
    }
    return days.toList()..sort((a, b) => b.compareTo(a));
  }

  @override
  Future<Map<String, List<PottyTrainingLogItem>>> getLogItemsForDays(List<String> dayKeys) async {
    final result = <String, List<PottyTrainingLogItem>>{};

    for (final dayKey in dayKeys) {
      final itemsForDay = _items.where((item) => _toDayKey(item.timestamp) == dayKey).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (itemsForDay.isNotEmpty) {
        result[dayKey] = itemsForDay;
      }
    }

    return result;
  }

  @override
  Future<void> add(PottyTrainingLogItem item) async {
    _items.add(item);
  }

  @override
  Future<void> update(PottyTrainingLogItem item, DateTime originalTimestamp) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    }
  }

  @override
  Future<void> delete(String id, DateTime timestamp) async {
    _items.removeWhere((i) => i.id == id);
  }

  /// Helper to get all items (for testing purposes).
  Future<List<PottyTrainingLogItem>> getAll() async {
    return List.from(_items)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
