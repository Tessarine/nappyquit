import 'package:nappyquit/domain/bodily_function.dart';
import 'package:nappyquit/domain/food_amount.dart';
import 'package:nappyquit/domain/initiative_type.dart';
import 'package:nappyquit/domain/water_amount.dart';

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
