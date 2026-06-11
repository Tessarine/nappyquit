import 'package:flutter/material.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/l10n/app_localizations_en.dart';
import 'package:nappyquit/domain/food_amount.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';

import 'activity_dialog_result.dart';

/// Dialog sequence for ate food activity
class AteFoodDialogSequence {
  static Future<ActivityDialogResult?> show({
    required BuildContext context,
    required HomePageLogic logic,
  }) async {
    FoodAmount? foodAmount;

    // Step 1: Select food amount
    if (!context.mounted) return null;
    final result = await showDialog<FoodAmount>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).selectFoodAmount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(FoodAmount.some);
                  },
                  child: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).ateSomeFood),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(FoodAmount.lots);
                  },
                  child: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).ateLotsOfFood),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).cancel),
          ),
        ],
      ),
    );

    if (result == null) return null;
    foodAmount = result;

    return ActivityDialogResult(foodAmount: foodAmount);
  }
}
