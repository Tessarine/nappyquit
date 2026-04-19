import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/food_amount.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';

/// Result of an activity dialog sequence
class ActivityDialogResult {
  final BodilyFunction? bodilyFunction;
  final InitiativeType? initiativeType;
  final WaterAmount? waterAmount;
  final FoodAmount? foodAmount;
  final bool? needsClothingChange;

  const ActivityDialogResult({
    this.bodilyFunction,
    this.initiativeType,
    this.waterAmount,
    this.foodAmount,
    this.needsClothingChange,
  });
}
