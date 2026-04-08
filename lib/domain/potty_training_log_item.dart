import 'activity_type.dart';
import 'bodily_function.dart';
import 'initiative_type.dart';

/// Represents a single entry in the potty training log.
class PottyTrainingLogItem {
  final String id;
  final ActivityType activityType;
  final DateTime timestamp;
  final BodilyFunction? bodilyFunction;
  final InitiativeType? initiativeType;

  const PottyTrainingLogItem({
    required this.id,
    required this.activityType,
    required this.timestamp,
    this.bodilyFunction,
    this.initiativeType,
  });

  PottyTrainingLogItem copyWith({
    String? id,
    ActivityType? activityType,
    DateTime? timestamp,
    BodilyFunction? bodilyFunction,
    InitiativeType? initiativeType,
  }) {
    return PottyTrainingLogItem(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      timestamp: timestamp ?? this.timestamp,
      bodilyFunction: bodilyFunction ?? this.bodilyFunction,
      initiativeType: initiativeType ?? this.initiativeType,
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
          initiativeType == other.initiativeType;

  @override
  int get hashCode =>
      id.hashCode ^
      activityType.hashCode ^
      timestamp.hashCode ^
      bodilyFunction.hashCode ^
      initiativeType.hashCode;

  @override
  String toString() =>
      'PottyTrainingLogItem(id: $id, activityType: $activityType, '
      'timestamp: $timestamp, bodilyFunction: $bodilyFunction, '
      'initiativeType: $initiativeType)';
}
