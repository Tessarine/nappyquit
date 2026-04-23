import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';
import 'package:toot_n_tinkle/domain/food_amount.dart';

/// Represents a single entry in the potty training log.
class PottyTrainingLogItem {
  final String id;
  final ActivityType activityType;
  final DateTime timestamp;
  final BodilyFunction? bodilyFunction;
  final InitiativeType? initiativeType;
  final WaterAmount? waterAmount;
  final FoodAmount? foodAmount;
  final bool? needsClothingChange;
  final DateTime created;
  final DateTime updated;
  final DateTime? deleted;

  const PottyTrainingLogItem({
    required this.id,
    required this.activityType,
    required this.timestamp,
    this.bodilyFunction,
    this.initiativeType,
    this.waterAmount,
    this.foodAmount,
    this.needsClothingChange,
    required this.created,
    required this.updated,
    this.deleted,
  });

  PottyTrainingLogItem copyWith({
    String? id,
    ActivityType? activityType,
    DateTime? timestamp,
    BodilyFunction? bodilyFunction,
    InitiativeType? initiativeType,
    WaterAmount? waterAmount,
    bool? needsClothingChange,
    DateTime? created,
    DateTime? updated,
    DateTime? deleted,
  }) {
    return PottyTrainingLogItem(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      timestamp: timestamp ?? this.timestamp,
      bodilyFunction: bodilyFunction ?? this.bodilyFunction,
      initiativeType: initiativeType ?? this.initiativeType,
      waterAmount: waterAmount ?? this.waterAmount,
      needsClothingChange: needsClothingChange ?? this.needsClothingChange,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PottyTrainingLogItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          activityType == other.activityType &&
          timestamp == other.timestamp &&
          bodilyFunction == other.bodilyFunction &&
          initiativeType == other.initiativeType &&
          waterAmount == other.waterAmount &&
          needsClothingChange == other.needsClothingChange;

  @override
  int get hashCode =>
      id.hashCode ^
      activityType.hashCode ^
      timestamp.hashCode ^
      bodilyFunction.hashCode ^
      initiativeType.hashCode ^
      waterAmount.hashCode ^
      needsClothingChange.hashCode;

  @override
  String toString() =>
      'PottyTrainingLogItem(id: $id, activityType: $activityType, '
      'timestamp: $timestamp, bodilyFunction: $bodilyFunction, '
      'initiativeType: $initiativeType, waterAmount: $waterAmount)';
}
