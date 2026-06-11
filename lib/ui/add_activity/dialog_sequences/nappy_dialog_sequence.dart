import 'package:flutter/material.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/l10n/app_localizations_en.dart';
import 'package:nappyquit/domain/activity_type.dart';
import 'package:nappyquit/domain/bodily_function.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';

import 'activity_dialog_result.dart';

/// Dialog sequence for nappy activity
class NappyDialogSequence {
  static Future<ActivityDialogResult?> show({
    required BuildContext context,
    required HomePageLogic logic,
  }) async {
    BodilyFunction? bodilyFunction;

    // Step 1: Select bodily function
    if (!context.mounted) return null;
    final result = await showDialog<BodilyFunction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).selectBodilyFunction),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: logic.availableBodilyFunctions(ActivityType.nappy).map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(option);
                  },
                  child: Text(logic.bodilyFunctionName(option)),
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
    bodilyFunction = result;

    return ActivityDialogResult(bodilyFunction: bodilyFunction);
  }
}
