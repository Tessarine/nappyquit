import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/activity_type.dart';
import '../domain/bodily_function.dart';
import '../domain/initiative_type.dart';
import '../domain/potty_training_log_item.dart';
import 'potty_training_log_item_repository.dart';

const _dayIndexKey = 'activity_log_index';
const _dayKeyPrefix = 'activity_log_';
const _legacyStorageKey = 'potty_training_log_items';

/// SharedPreferences-based implementation of the log item repository.
/// Uses day-indexed storage for efficient pagination.
class SharedPrefsPottyTrainingLogItemRepository implements PottyTrainingLogItemRepository {
  final SharedPreferences _prefs;

  SharedPrefsPottyTrainingLogItemRepository(this._prefs);

  @override
  Future<List<String>> getDayIndex() async {
    return _prefs.getStringList(_dayIndexKey) ?? [];
  }

  @override
  Future<Map<String, List<PottyTrainingLogItem>>> getLogItemsForDays(List<String> dayKeys) async {
    final result = <String, List<PottyTrainingLogItem>>{};

    for (final dayKey in dayKeys) {
      final jsonStr = _prefs.getString('$_dayKeyPrefix$dayKey');
      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
        final items = jsonList.map((e) => _fromJson(e as Map<String, dynamic>)).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        result[dayKey] = items;
      }
    }

    return result;
  }

  @override
  Future<void> add(PottyTrainingLogItem item) async {
    final dayKey = _toDayKey(item.timestamp);

    // Add item to the day's list
    final jsonStr = _prefs.getString('$_dayKeyPrefix$dayKey');
    final List<Map<String, dynamic>> jsonList = jsonStr != null
        ? (json.decode(jsonStr) as List<dynamic>).cast<Map<String, dynamic>>()
        : [];
    jsonList.add(_toJson(item));
    await _prefs.setString('$_dayKeyPrefix$dayKey', json.encode(jsonList));

    // Update the day index
    final dayIndex = _prefs.getStringList(_dayIndexKey) ?? [];
    if (!dayIndex.contains(dayKey)) {
      dayIndex.add(dayKey);
      dayIndex.sort((a, b) => b.compareTo(a)); // Descending order
      await _prefs.setStringList(_dayIndexKey, dayIndex);
    }
  }

  @override
  Future<void> update(PottyTrainingLogItem item, DateTime originalTimestamp) async {
    final oldDayKey = _toDayKey(originalTimestamp);
    final newDayKey = _toDayKey(item.timestamp);

    if (oldDayKey == newDayKey) {
      // Same day: just update the item in place
      await _updateItemInDay(item, newDayKey);
    } else {
      // Different day: remove from old day, add to new day
      await _removeItemFromDay(item.id, oldDayKey);
      await _addDayToIndex(newDayKey);
      await _addItemToDay(item, newDayKey);
    }
  }

  @override
  Future<void> delete(String id, DateTime timestamp) async {
    final dayKey = _toDayKey(timestamp);
    await _removeItemFromDay(id, dayKey);
  }

  /// Migrates data from the old single-list format to the new day-indexed format.
  /// Returns true if migration was performed.
  Future<bool> migrateIfNeeded() async {
    // Check if old format data exists
    final legacyJsonStr = _prefs.getString(_legacyStorageKey);
    if (legacyJsonStr == null) return false;

    // Check if new format already exists (already migrated)
    final existingIndex = _prefs.getStringList(_dayIndexKey);
    if (existingIndex != null && existingIndex.isNotEmpty) return false;

    // Parse old format data
    final List<dynamic> jsonList = json.decode(legacyJsonStr) as List<dynamic>;
    final items = jsonList.map((e) => _fromJson(e as Map<String, dynamic>)).toList();

    if (items.isEmpty) {
      // Remove the old key even if empty
      await _prefs.remove(_legacyStorageKey);
      return true;
    }

    // Group items by day
    final itemsByDay = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      final dayKey = _toDayKey(item.timestamp);
      itemsByDay.putIfAbsent(dayKey, () => []).add(_toJson(item));
    }

    // Save each day's items
    for (final entry in itemsByDay.entries) {
      await _prefs.setString('$_dayKeyPrefix${entry.key}', json.encode(entry.value));
    }

    // Save the day index (sorted descending)
    final dayIndex = itemsByDay.keys.toList()..sort((a, b) => b.compareTo(a));
    await _prefs.setStringList(_dayIndexKey, dayIndex);

    // Remove the old key
    await _prefs.remove(_legacyStorageKey);

    return true;
  }

  // --- Private helpers ---

  Future<void> _updateItemInDay(PottyTrainingLogItem item, String dayKey) async {
    final jsonStr = _prefs.getString('$_dayKeyPrefix$dayKey');
    if (jsonStr == null) return;

    final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
    final index = jsonList.indexWhere((e) => (e as Map<String, dynamic>)['id'] == item.id);
    if (index >= 0) {
      jsonList[index] = _toJson(item);
      await _prefs.setString('$_dayKeyPrefix$dayKey', json.encode(jsonList));
    }
  }

  Future<void> _addItemToDay(PottyTrainingLogItem item, String dayKey) async {
    final jsonStr = _prefs.getString('$_dayKeyPrefix$dayKey');
    final List<Map<String, dynamic>> jsonList = jsonStr != null
        ? (json.decode(jsonStr) as List<dynamic>).cast<Map<String, dynamic>>()
        : [];
    jsonList.add(_toJson(item));
    await _prefs.setString('$_dayKeyPrefix$dayKey', json.encode(jsonList));
  }

  Future<void> _removeItemFromDay(String id, String dayKey) async {
    final jsonStr = _prefs.getString('$_dayKeyPrefix$dayKey');
    if (jsonStr == null) return;

    final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
    jsonList.removeWhere((e) => (e as Map<String, dynamic>)['id'] == id);

    if (jsonList.isEmpty) {
      // Remove the day's data and index entry
      await _prefs.remove('$_dayKeyPrefix$dayKey');
      final dayIndex = _prefs.getStringList(_dayIndexKey) ?? [];
      dayIndex.remove(dayKey);
      await _prefs.setStringList(_dayIndexKey, dayIndex);
    } else {
      await _prefs.setString('$_dayKeyPrefix$dayKey', json.encode(jsonList));
    }
  }

  Future<void> _addDayToIndex(String dayKey) async {
    final dayIndex = _prefs.getStringList(_dayIndexKey) ?? [];
    if (!dayIndex.contains(dayKey)) {
      dayIndex.add(dayKey);
      dayIndex.sort((a, b) => b.compareTo(a));
      await _prefs.setStringList(_dayIndexKey, dayIndex);
    }
  }

  String _toDayKey(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _toJson(PottyTrainingLogItem item) {
    return {
      'id': item.id,
      'activityType': item.activityType.name,
      'timestamp': item.timestamp.toIso8601String(),
      'bodilyFunction': item.bodilyFunction?.name,
      'initiativeType': item.initiativeType?.name,
    };
  }

  PottyTrainingLogItem _fromJson(Map<String, dynamic> json) {
    return PottyTrainingLogItem(
      id: json['id'] as String,
      activityType: ActivityType.values.byName(json['activityType'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      bodilyFunction: json['bodilyFunction'] != null
          ? BodilyFunction.values.byName(json['bodilyFunction'] as String)
          : null,
      initiativeType: json['initiativeType'] != null
          ? InitiativeType.values.byName(json['initiativeType'] as String)
          : null,
    );
  }
}
