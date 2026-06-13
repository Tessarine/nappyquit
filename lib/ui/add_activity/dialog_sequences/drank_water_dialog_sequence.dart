import 'package:flutter/material.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/l10n/app_localizations_en.dart';
import 'package:nappyquit/domain/activity_type.dart';
import 'package:nappyquit/domain/water_amount.dart';
import 'package:nappyquit/ui/emoji_text_style.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';

import 'activity_dialog_result.dart';

/// Dialog sequence for drank water activity
class DrankWaterDialogSequence {
  static Future<ActivityDialogResult?> show({
    required BuildContext context,
    required HomePageLogic logic,
  }) async {
    WaterAmount? waterAmount;

    // Step 1: Select water amount
    if (!context.mounted) return null;
    final result = await showDialog<WaterAmount>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).selectWaterAmount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: logic.availableWaterAmounts(ActivityType.drankWater).map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(option);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EmojiText(logic.waterAmountEmoji(option)),
                      const SizedBox(width: 8),
                      Text(logic.waterAmountName(option)),
                    ],
                  ),
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
    waterAmount = result;

    return ActivityDialogResult(waterAmount: waterAmount);
  }
}
