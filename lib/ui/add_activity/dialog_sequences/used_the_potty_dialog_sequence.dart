import 'package:flutter/material.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/l10n/app_localizations_en.dart';
import 'package:nappyquit/domain/activity_type.dart';
import 'package:nappyquit/domain/bodily_function.dart';
import 'package:nappyquit/domain/initiative_type.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';

import 'activity_dialog_result.dart';

/// Dialog sequence for used the potty activity
class UsedThePottyDialogSequence {
  static Future<ActivityDialogResult?> show({
    required BuildContext context,
    required HomePageLogic logic,
  }) async {
    BodilyFunction? bodilyFunction;
    InitiativeType? initiativeType;
    bool? needsClothingChange;

    // Step 1: Select bodily function with clothing change option
    if (!context.mounted) return null;

    final tempResult = BodilyFunctionWithClothingChangeResult(null, false);
    final result = await showDialog<BodilyFunctionWithClothingChangeResult>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              (AppLocalizations.of(context) ?? AppLocalizationsEn()).selectBodilyFunction,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clothing change checkbox
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: tempResult.needsClothingChange,
                        onChanged: (value) {
                          setState(() {
                            tempResult.needsClothingChange = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          (AppLocalizations.of(context) ?? AppLocalizationsEn())
                              .needsClothingChange,
                        ),
                      ),
                    ],
                  ),
                ),
                ...logic.availableBodilyFunctions(ActivityType.usedThePotty).map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          tempResult.bodilyFunction = option;
                          Navigator.of(
                            context,
                          ).pop<BodilyFunctionWithClothingChangeResult>(tempResult);
                        },
                        child: Text(logic.bodilyFunctionName(option)),
                      ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).cancel),
              ),
            ],
          );
        },
      ),
    );

    if (result == null) return null;
    bodilyFunction = result.bodilyFunction;
    needsClothingChange = result.needsClothingChange;

    // Step 2: Select initiative type
    if (!context.mounted) return null;
    final initiativeResult = await showDialog<InitiativeType>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).selectInitiative),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: logic.availableInitiativeTypes(ActivityType.usedThePotty).map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(option);
                  },
                  child: Text(logic.initiativeTypeName(option)),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).cancel),
          ),
        ],
      ),
    );

    if (initiativeResult == null) return null;
    initiativeType = initiativeResult;

    return ActivityDialogResult(
      bodilyFunction: bodilyFunction,
      initiativeType: initiativeType,
      needsClothingChange: needsClothingChange,
    );
  }
}

/// Helper class for bodily function with clothing change result
class BodilyFunctionWithClothingChangeResult {
  BodilyFunction? bodilyFunction;
  bool needsClothingChange;

  BodilyFunctionWithClothingChangeResult(this.bodilyFunction, this.needsClothingChange);
}
