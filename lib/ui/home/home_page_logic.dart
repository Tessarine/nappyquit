import '../../domain/activity_type.dart';
import '../../domain/bodily_function.dart';
import '../../domain/initiative_type.dart';
import '../../domain/potty_training_log_item.dart';
import '../../repositories/potty_training_log_item_repository.dart';
import '../../use_cases/add_log_item_use_case.dart';
import '../../use_cases/delete_log_item_use_case.dart';
import '../../use_cases/get_log_items_use_case.dart';
import '../../use_cases/update_log_item_use_case.dart';
import 'package:potty_train/l10n/app_localizations.dart';

/// Logic class for the home page, handling all business logic
/// separately from the UI.
class HomePageLogic {
  final AddLogItemUseCase _addLogItemUseCase;
  final GetLogItemsUseCase _getLogItemsUseCase;
  final DeleteLogItemUseCase _deleteLogItemUseCase;
  final UpdateLogItemUseCase _updateLogItemUseCase;

  List<PottyTrainingLogItem> _logItems = [];
  AppLocalizations? _l10n;

  HomePageLogic({required PottyTrainingLogItemRepository repository})
    : _addLogItemUseCase = AddLogItemUseCase(repository),
      _getLogItemsUseCase = GetLogItemsUseCase(repository),
      _deleteLogItemUseCase = DeleteLogItemUseCase(repository),
      _updateLogItemUseCase = UpdateLogItemUseCase(repository);

  List<PottyTrainingLogItem> get logItems => _logItems;

  void updateLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Loads all log items from the repository.
  Future<void> loadLogItems() async {
    _logItems = await _getLogItemsUseCase();
  }

  /// Creates a new log item with the given parameters.
  Future<PottyTrainingLogItem> createLogItem({
    required ActivityType activityType,
    required DateTime timestamp,
    BodilyFunction? bodilyFunction,
    InitiativeType? initiativeType,
  }) async {
    final item = PottyTrainingLogItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      activityType: activityType,
      timestamp: timestamp,
      bodilyFunction: bodilyFunction,
      initiativeType: initiativeType,
    );
    await _addLogItemUseCase(item);
    _logItems.add(item);
    _sortLogItems();
    return item;
  }

  /// Deletes a log item by ID.
  Future<void> deleteLogItem(String id) async {
    await _deleteLogItemUseCase(id);
    _logItems.removeWhere((item) => item.id == id);
  }

  /// Updates an existing log item.
  Future<void> updateLogItem(PottyTrainingLogItem item) async {
    await _updateLogItemUseCase(item);
    final index = _logItems.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _logItems[index] = item;
    }
    _sortLogItems();
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
      case ActivityType.drankSomeWater:
        return _l10n!.drankSomeWater;
      case ActivityType.drankLotsOfWater:
        return _l10n!.drankLotsOfWater;
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
      case ActivityType.drankSomeWater:
        return '💧';
      case ActivityType.drankLotsOfWater:
        return '💦';
      case ActivityType.ateFood:
        return '🍽️';
      case ActivityType.nappy:
        return '👶';
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

  void _sortLogItems() {
    _logItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
