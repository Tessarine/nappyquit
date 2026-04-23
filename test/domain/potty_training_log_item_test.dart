import 'package:flutter_test/flutter_test.dart';
import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';

void main() {
  group('PottyTrainingLogItem', () {
    test('should create a log item with required fields', () {
      final item = PottyTrainingLogItem(
        id: '1',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      expect(item.id, '1');
      expect(item.activityType, ActivityType.usedThePotty);
      expect(item.timestamp, DateTime(2026, 4, 8, 10, 0));
      expect(item.bodilyFunction, isNull);
      expect(item.initiativeType, isNull);
      expect(item.waterAmount, isNull);
    });

    test('should create a log item with all fields', () {
      final item = PottyTrainingLogItem(
        id: '2',
        activityType: ActivityType.accident,
        timestamp: DateTime(2026, 4, 8, 9, 50),
        bodilyFunction: BodilyFunction.both,
        initiativeType: InitiativeType.toldParents,
        created: DateTime(2026, 4, 8, 9, 50),
        updated: DateTime(2026, 4, 8, 9, 50),
        deleted: null,
      );

      expect(item.id, '2');
      expect(item.activityType, ActivityType.accident);
      expect(item.bodilyFunction, BodilyFunction.both);
      expect(item.initiativeType, InitiativeType.toldParents);
    });

    test('should create a log item with water amount', () {
      final item = PottyTrainingLogItem(
        id: '3',
        activityType: ActivityType.drankWater,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        waterAmount: WaterAmount.lots,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      expect(item.id, '3');
      expect(item.activityType, ActivityType.drankWater);
      expect(item.waterAmount, WaterAmount.lots);
    });

    test('should support copyWith', () {
      final item = PottyTrainingLogItem(
        id: '3',
        activityType: ActivityType.triedThePotty,
        timestamp: DateTime(2026, 4, 8, 9, 0),
        initiativeType: InitiativeType.wentByHimself,
        created: DateTime(2026, 4, 8, 9, 0),
        updated: DateTime(2026, 4, 8, 9, 0),
        deleted: null,
      );

      final updated = item.copyWith(
        timestamp: DateTime(2026, 4, 8, 10, 0),
        initiativeType: InitiativeType.askedToSit,
        updated: DateTime(2026, 4, 8, 10, 0),
      );

      expect(updated.id, '3');
      expect(updated.activityType, ActivityType.triedThePotty);
      expect(updated.timestamp, DateTime(2026, 4, 8, 10, 0));
      expect(updated.initiativeType, InitiativeType.askedToSit);
    });

    test('should support copyWith with water amount', () {
      final item = PottyTrainingLogItem(
        id: '4',
        activityType: ActivityType.drankWater,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        waterAmount: WaterAmount.some,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      final updated = item.copyWith(
        waterAmount: WaterAmount.lots,
        updated: DateTime(2026, 4, 8, 10, 0),
      );

      expect(updated.waterAmount, WaterAmount.lots);
    });

    test('should support equality', () {
      final item1 = PottyTrainingLogItem(
        id: '4',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 12, 0),
        created: DateTime(2026, 4, 8, 12, 0),
        updated: DateTime(2026, 4, 8, 12, 0),
        deleted: null,
      );

      final item2 = PottyTrainingLogItem(
        id: '4',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 12, 0),
        created: DateTime(2026, 4, 8, 12, 0),
        updated: DateTime(2026, 4, 8, 12, 0),
        deleted: null,
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('should not be equal when fields differ', () {
      final item1 = PottyTrainingLogItem(
        id: '5',
        activityType: ActivityType.ateFood,
        timestamp: DateTime(2026, 4, 8, 12, 0),
        created: DateTime(2026, 4, 8, 12, 0),
        updated: DateTime(2026, 4, 8, 12, 0),
        deleted: null,
      );

      final item2 = PottyTrainingLogItem(
        id: '5',
        activityType: ActivityType.drankWater,
        timestamp: DateTime(2026, 4, 8, 12, 0),
        created: DateTime(2026, 4, 8, 12, 0),
        updated: DateTime(2026, 4, 8, 12, 0),
        deleted: null,
      );

      expect(item1, isNot(equals(item2)));
    });

    test('should not be equal when water amount differs', () {
      final item1 = PottyTrainingLogItem(
        id: '6',
        activityType: ActivityType.drankWater,
        timestamp: DateTime(2026, 4, 8, 12, 0),
        waterAmount: WaterAmount.some,
        created: DateTime(2026, 4, 8, 12, 0),
        updated: DateTime(2026, 4, 8, 12, 0),
        deleted: null,
      );

      final item2 = PottyTrainingLogItem(
        id: '6',
        activityType: ActivityType.drankWater,
        timestamp: DateTime(2026, 4, 8, 12, 0),
        waterAmount: WaterAmount.lots,
        created: DateTime(2026, 4, 8, 12, 0),
        updated: DateTime(2026, 4, 8, 12, 0),
        deleted: null,
      );

      expect(item1, isNot(equals(item2)));
    });

    test('should support copyWith with needsClothingChange', () {
      final item = PottyTrainingLogItem(
        id: '7',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 10, 0),
        needsClothingChange: false,
        created: DateTime(2026, 4, 8, 10, 0),
        updated: DateTime(2026, 4, 8, 10, 0),
        deleted: null,
      );

      final updated = item.copyWith(needsClothingChange: true);

      expect(updated.needsClothingChange, true);
    });

    test('should not be equal when needsClothingChange differs', () {
      final item1 = PottyTrainingLogItem(
        id: '8',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 12, 0),
        needsClothingChange: false,
        created: DateTime(2026, 4, 8, 12, 0),
        updated: DateTime(2026, 4, 8, 12, 0),
        deleted: null,
      );

      final item2 = PottyTrainingLogItem(
        id: '8',
        activityType: ActivityType.usedThePotty,
        timestamp: DateTime(2026, 4, 8, 12, 0),
        needsClothingChange: true,
        created: DateTime(2026, 4, 8, 12, 0),
        updated: DateTime(2026, 4, 8, 12, 0),
        deleted: null,
      );

      expect(item1, isNot(equals(item2)));
    });
  });

  group('ActivityType', () {
    test('should have all expected values', () {
      expect(ActivityType.values.length, 6);
      expect(ActivityType.values, contains(ActivityType.triedThePotty));
      expect(ActivityType.values, contains(ActivityType.usedThePotty));
      expect(ActivityType.values, contains(ActivityType.accident));
      expect(ActivityType.values, contains(ActivityType.drankWater));
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

  group('WaterAmount', () {
    test('should have all expected values', () {
      expect(WaterAmount.values.length, 2);
      expect(WaterAmount.values, contains(WaterAmount.some));
      expect(WaterAmount.values, contains(WaterAmount.lots));
    });
  });
}
