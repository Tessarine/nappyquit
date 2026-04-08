import 'package:flutter_test/flutter_test.dart';
import 'package:potty_train/domain/activity_type.dart';
import 'package:potty_train/domain/bodily_function.dart';
import 'package:potty_train/domain/initiative_type.dart';
import 'package:potty_train/domain/potty_training_log_item.dart';

void main() {
  group('PottyTrainingLogItem', () {
    test('should create a log item with required fields', () {
      final item = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
      );

      expect(item.id, '1');
      expect(item.activityType, ActivityType.usedThePotty);
      expect(item.timestamp, DateTime(2026, 4, 8, 10, 0));
      expect(item.bodilyFunction, isNull);
      expect(item.initiativeType, isNull);
    });

    test('should create a log item with all fields', () {
      final item = PottyTrainingLogItem(
        id: '2',
        activityType: ActivityType.accident,
        timestamp: DateTime(2026, 4, 8, 9, 50),
        bodilyFunction: BodilyFunction.both,
        initiativeType: InitiativeType.toldParents,
      );

      expect(item.id, '2');
      expect(item.activityType, ActivityType.accident);
      expect(item.bodilyFunction, BodilyFunction.both);
      expect(item.initiativeType, InitiativeType.toldParents);
    });

    test('should support copyWith', () {
      final item = PottyTrainingLogItem(
        id: '3',
        activityType: ActivityType.triedThePotty,
        timestamp: DateTime(2026, 4, 8, 9, 0),
        initiativeType: InitiativeType.wentByHimself,
      );

      final updated = item.copyWith(
        timestamp: DateTime(2026, 4, 8, 10, 0),
        initiativeType: InitiativeType.askedToSit,
      );

      expect(updated.id, '3');
      expect(updated.activityType, ActivityType.triedThePotty);
      expect(updated.timestamp, DateTime(2026, 4, 8, 10, 0));
      expect(updated.initiativeType, InitiativeType.askedToSit);
    });

    test('should support equality', () {
      final item1 = PottyTrainingLogItem(
        id: '4',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 12, 0),
      );

      final item2 = PottyTrainingLogItem(
        id: '4',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 12, 0),
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('should not be equal when fields differ', () {
      final item1 = PottyTrainingLogItem(
        id: '5',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 12, 0),
      );

      final item2 = PottyTrainingLogItem(
        id: '5',
        activityType: ActivityType.drankSomeWater,
        timestamp: DateTime(2026, 4, 8, 12, 0),
      );

      expect(item1, isNot(equals(item2)));
    });
  });

  group('ActivityType', () {
    test('should have all expected values', () {
      expect(ActivityType.values.length, 7);
      expect(ActivityType.values, contains(ActivityType.triedThePotty));
      expect(ActivityType.values, contains(ActivityType.usedThePotty));
      expect(ActivityType.values, contains(ActivityType.accident));
      expect(ActivityType.values, contains(ActivityType.drankSomeWater));
      expect(ActivityType.values, contains(ActivityType.drankLotsOfWater));
      expect(ActivityType.values, contains(ActivityType.ateFood));
      expect(ActivityType.values, contains(ActivityType.nappy));
    });
  });

  group('BodilyFunction', () {
    test('should have all expected values', () {
      expect(BodilyFunction.values.length, 4);
      expect(BodilyFunction.values, contains(BodilyFunction.pee));
      expect(BodilyFunction.values, contains(BodilyFunction.poo));
      expect(BodilyFunction.values, contains(BodilyFunction.both));
      expect(BodilyFunction.values, contains(BodilyFunction.none));
    });
  });

  group('InitiativeType', () {
    test('should have all expected values', () {
      expect(InitiativeType.values.length, 3);
      expect(InitiativeType.values, contains(InitiativeType.toldParents));
      expect(InitiativeType.values, contains(InitiativeType.wentByHimself));
      expect(InitiativeType.values, contains(InitiativeType.askedToSit));
    });
  });
}
