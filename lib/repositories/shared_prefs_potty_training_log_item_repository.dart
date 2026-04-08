import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/activity_type.dart';
import '../domain/bodily_function.dart';
import '../domain/initiative_type.dart';
import '../domain/potty_training_log_item.dart';
import 'potty_training_log_item_repository.dart';

const _storageKey = 'potty_training_log_items';

/// SharedPreferences-based implementation of the log item repository.
class SharedPrefsPottyTrainingLogItemRepository implements PottyTrainingLogItemRepository {
  final SharedPreferences _prefs;

  SharedPrefsPottyTrainingLogItemRepository(this._prefs);

  @override
  Future<List<PottyTrainingLogItem>> getAll() async {
    final jsonStr = _prefs.getString(_storageKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
    return jsonList.map((e) => _fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> add(PottyTrainingLogItem item) async {
    final items = await getAll();
    items.add(item);
    await _saveAll(items);
  }

  @override
  Future<void> update(PottyTrainingLogItem item) async {
    final items = await getAll();
    final index = items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      items[index] = item;
      await _saveAll(items);
    }
  }

  @override
  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((i) => i.id == id);
    await _saveAll(items);
  }

  Future<void> _saveAll(List<PottyTrainingLogItem> items) async {
    final jsonList = items.map(_toJson).toList();
    await _prefs.setString(_storageKey, json.encode(jsonList));
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
