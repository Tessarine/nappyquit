import 'package:flutter/material.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/l10n/app_localizations_en.dart';
import 'package:nappyquit/domain/activity_type.dart';
import 'package:nappyquit/domain/initiative_type.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';

import 'activity_dialog_result.dart';

/// Dialog sequence for tried the potty activity
class TriedThePottyDialogSequence {
  static Future<ActivityDialogResult?> show({
    required BuildContext context,
    required HomePageLogic logic,
  }) async {
    InitiativeType? initiativeType;

    // Step 1: Select initiative type
    if (!context.mounted) return null;
    final result = await showDialog<InitiativeType>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).selectInitiative),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: logic.availableInitiativeTypes(ActivityType.triedThePotty).map((option) {
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

    if (result == null) return null;
    initiativeType = result;

    return ActivityDialogResult(initiativeType: initiativeType);
  }
}
