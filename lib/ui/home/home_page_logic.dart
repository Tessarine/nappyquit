import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';
import 'package:toot_n_tinkle/repositories/potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/use_cases/add_log_item_use_case.dart';
import 'package:toot_n_tinkle/use_cases/delete_log_item_use_case.dart';
import 'package:toot_n_tinkle/use_cases/get_log_items_use_case.dart';
import 'package:toot_n_tinkle/use_cases/update_log_item_use_case.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';

/// Number of days to load per page.
const daysPerPage = 5;

/// Logic class for the home page, handling all business logic
/// separately from the UI. Supports paginated loading by day.
class HomePageLogic {
  final AddLogItemUseCase _addLogItemUseCase;
  final GetLogItemsUseCase _getLogItemsUseCase;
  final DeleteLogItemUseCase _deleteLogItemUseCase;
  final UpdateLogItemUseCase _updateLogItemUseCase;

  /// Full day index from the repository (all days that have activities).
  List<String> _dayIndex = [];

  /// Number of days that have been loaded (for pagination).
  int _loadedDayCount = 0;

  /// Items grouped by day key, sorted by timestamp descending within each day.
  Map<String, List<PottyTrainingLogItem>> _itemsByDay = {};

  AppLocalizations? _l10n;

  HomePageLogic({required PottyTrainingLogItemRepository repository})
    : _addLogItemUseCase = AddLogItemUseCase(repository),
      _getLogItemsUseCase = GetLogItemsUseCase(repository),
      _deleteLogItemUseCase = DeleteLogItemUseCase(repository),
      _updateLogItemUseCase = UpdateLogItemUseCase(repository);

  /// The day index for all loaded days.
  List<String> get loadedDays => _dayIndex.take(_loadedDayCount).toList();

  /// Items grouped by day for all loaded days.
  Map<String, List<PottyTrainingLogItem>> get itemsByDay => _itemsByDay;

  /// Whether there are more days to load.
  bool get hasMoreDays => _loadedDayCount < _dayIndex.length;

  /// Returns a flat list of all loaded log items, sorted by timestamp descending.
  List<PottyTrainingLogItem> get logItems {
    final items = <PottyTrainingLogItem>[];
    for (final dayKey in loadedDays) {
      items.addAll(_itemsByDay[dayKey] ?? []);
    }
    return items;
  }

  void updateLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Loads the first page of log items from the repository.
  Future<void> loadLogItems() async {
    _dayIndex = await _getLogItemsUseCase.getDayIndex();
    _loadedDayCount = 0;
    _itemsByDay = {};
    await _loadNextDays();
  }

  /// Loads the next page of days from the repository.
  Future<void> loadMoreDays() async {
    await _loadNextDays();
  }

  Future<void> _loadNextDays() async {
    if (_loadedDayCount >= _dayIndex.length) return;

    final end = (_loadedDayCount + daysPerPage).clamp(0, _dayIndex.length);
    final daysToLoad = _dayIndex.sublist(_loadedDayCount, end);

    if (daysToLoad.isEmpty) return;

    final newItems = await _getLogItemsUseCase.getLogItemsForDays(daysToLoad);
    _itemsByDay.addAll(newItems);
    _loadedDayCount = end;
  }

  /// Creates a new log item with the given parameters.
  Future<PottyTrainingLogItem> createLogItem({
    required ActivityType activityType,
    required DateTime timestamp,
    BodilyFunction? bodilyFunction,
    InitiativeType? initiativeType,
    WaterAmount? waterAmount,
    bool? needsClothingChange,
  }) async {
    final item = PottyTrainingLogItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      activityType: activityType,
      timestamp: timestamp,
      bodilyFunction: bodilyFunction,
      initiativeType: initiativeType,
      waterAmount: waterAmount,
      needsClothingChange: needsClothingChange,
    );
    await _addLogItemUseCase(item);

    final dayKey = _toDayKey(timestamp);

    // Add to local state
    if (!_dayIndex.contains(dayKey)) {
      // New day: insert at the correct position in the index
      _dayIndex.add(dayKey);
      _dayIndex.sort((a, b) => b.compareTo(a));
      _loadedDayCount++;
    }

    _itemsByDay.putIfAbsent(dayKey, () => []);
    _itemsByDay[dayKey]!.add(item);
    _itemsByDay[dayKey]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return item;
  }

  /// Deletes a log item by ID and timestamp.
  Future<void> deleteLogItem(String id, DateTime timestamp) async {
    await _deleteLogItemUseCase(id, timestamp);

    final dayKey = _toDayKey(timestamp);
    _itemsByDay[dayKey]?.removeWhere((item) => item.id == id);

    // If the day is now empty, remove it from the index
    if (_itemsByDay[dayKey]?.isEmpty ?? false) {
      _itemsByDay.remove(dayKey);
      _dayIndex.remove(dayKey);
      _loadedDayCount = _loadedDayCount.clamp(0, _dayIndex.length);
    }
  }

  /// Updates an existing log item.
  Future<void> updateLogItem(
    PottyTrainingLogItem originalItem,
    PottyTrainingLogItem updatedItem,
  ) async {
    await _updateLogItemUseCase(updatedItem, originalItem.timestamp);

    final oldDayKey = _toDayKey(originalItem.timestamp);
    final newDayKey = _toDayKey(updatedItem.timestamp);

    // Remove from old day
    _itemsByDay[oldDayKey]?.removeWhere((item) => item.id == updatedItem.id);

    // Clean up old day if empty
    if (_itemsByDay[oldDayKey]?.isEmpty ?? false) {
      _itemsByDay.remove(oldDayKey);
      _dayIndex.remove(oldDayKey);
      _loadedDayCount = _loadedDayCount.clamp(0, _dayIndex.length);
    }

    // Add to new day
    if (!_dayIndex.contains(newDayKey)) {
      _dayIndex.add(newDayKey);
      _dayIndex.sort((a, b) => b.compareTo(a));
      _loadedDayCount++;
    }
    _itemsByDay.putIfAbsent(newDayKey, () => []);
    _itemsByDay[newDayKey]!.add(updatedItem);
    _itemsByDay[newDayKey]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Returns whether the given activity type requires a bodily function selection.
  bool requiresBodilyFunction(ActivityType activityType) {
    return activityType == ActivityType.usedThePotty ||
        activityType == ActivityType.accident ||
        activityType == ActivityType.nappy;
  }

  /// Returns whether the given activity type requires an initiative type selection.
  bool requiresInitiativeType(ActivityType activityType) {
    return activityType == ActivityType.triedThePotty ||
        activityType == ActivityType.usedThePotty ||
        activityType == ActivityType.accident;
  }

  /// Returns whether the given activity type requires a water amount selection.
  bool requiresWaterAmount(ActivityType activityType) {
    return activityType == ActivityType.drankWater;
  }

  /// Returns the available bodily functions for the given activity type.
  List<BodilyFunction> availableBodilyFunctions(ActivityType activityType) {
    switch (activityType) {
      case ActivityType.usedThePotty:
      case ActivityType.accident:
        return [BodilyFunction.pee, BodilyFunction.poo, BodilyFunction.both];
      case ActivityType.nappy:
        return [BodilyFunction.pee, BodilyFunction.poo, BodilyFunction.both, BodilyFunction.none];
      default:
        return [];
    }
  }

  /// Returns the available initiative types for the given activity type.
  List<InitiativeType> availableInitiativeTypes(ActivityType activityType) {
    switch (activityType) {
      case ActivityType.triedThePotty:
      case ActivityType.usedThePotty:
      case ActivityType.accident:
        return [
          InitiativeType.toldParents,
          InitiativeType.wentByHimself,
          InitiativeType.askedToSit,
        ];
      default:
        return [];
    }
  }

  /// Returns the available water amounts for the given activity type.
  List<WaterAmount> availableWaterAmounts(ActivityType activityType) {
    switch (activityType) {
      case ActivityType.drankWater:
        return [WaterAmount.some, WaterAmount.lots];
      default:
        return [];
    }
  }

  /// Returns the localized name for an activity type.
  String activityTypeName(ActivityType activityType) {
    if (_l10n == null) return activityType.name;
    switch (activityType) {
      case ActivityType.triedThePotty:
        return _l10n!.triedThePotty;
      case ActivityType.usedThePotty:
        return _l10n!.usedThePotty;
      case ActivityType.accident:
        return _l10n!.accident;
      case ActivityType.drankWater:
        return _l10n!.drankWater;
      case ActivityType.ateFood:
        return _l10n!.ateFood;
      case ActivityType.nappy:
        return _l10n!.nappy;
    }
  }

  /// Returns the emoji for an activity type.
  String activityTypeEmoji(ActivityType activityType) {
    switch (activityType) {
      case ActivityType.triedThePotty:
        return '🚽';
      case ActivityType.usedThePotty:
        return '🎉';
      case ActivityType.accident:
        return '😅';
      case ActivityType.drankWater:
        return '💧';
      case ActivityType.ateFood:
        return '🍽️';
      case ActivityType.nappy:
        return '👶';
    }
  }

  /// Returns the emoji for a bodily function.
  String bodilyFunctionEmoji(BodilyFunction bodilyFunction) {
    switch (bodilyFunction) {
      case BodilyFunction.pee:
        return '💧';
      case BodilyFunction.poo:
        return '💩';
      case BodilyFunction.both:
        return '💧💩';
      case BodilyFunction.none:
        return '';
    }
  }

  /// Returns the localized name for a bodily function.
  String bodilyFunctionName(BodilyFunction bodilyFunction) {
    if (_l10n == null) return bodilyFunction.name;
    switch (bodilyFunction) {
      case BodilyFunction.pee:
        return _l10n!.pee;
      case BodilyFunction.poo:
        return _l10n!.poo;
      case BodilyFunction.both:
        return _l10n!.both;
      case BodilyFunction.none:
        return _l10n!.none;
    }
  }

  /// Returns the localized name for an initiative type.
  String initiativeTypeName(InitiativeType initiativeType) {
    if (_l10n == null) return initiativeType.name;
    switch (initiativeType) {
      case InitiativeType.toldParents:
        return _l10n!.toldParents;
      case InitiativeType.wentByHimself:
        return _l10n!.wentByHimself;
      case InitiativeType.askedToSit:
        return _l10n!.askedToSit;
    }
  }

  /// Returns the localized name for a water amount.
  String waterAmountName(WaterAmount waterAmount) {
    if (_l10n == null) return waterAmount.name;
    switch (waterAmount) {
      case WaterAmount.some:
        return _l10n!.drankSomeWater;
      case WaterAmount.lots:
        return _l10n!.drankLotsOfWater;
    }
  }

  /// Returns the emoji for a water amount.
  String waterAmountEmoji(WaterAmount waterAmount) {
    switch (waterAmount) {
      case WaterAmount.some:
        return '💧';
      case WaterAmount.lots:
        return '💦';
    }
  }

  String _toDayKey(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }
}
