import 'package:flutter/material.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_en.dart';

import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

/// Dialog for selecting bodily function for an activity.
class BodilyFunctionDialog extends StatefulWidget {
  final ActivityType activityType;
  final HomePageLogic logic;

  const BodilyFunctionDialog({super.key, required this.activityType, required this.logic});

  @override
  State<BodilyFunctionDialog> createState() => _BodilyFunctionDialogState();
}

class _BodilyFunctionDialogState extends State<BodilyFunctionDialog> {
  bool _needsClothingChange = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final options = widget.logic.availableBodilyFunctions(widget.activityType);

    return AlertDialog(
      title: Text(l10n.selectBodilyFunction),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show clothing change checkbox only for usedThePotty
          if (widget.activityType == ActivityType.usedThePotty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _needsClothingChange,
                    onChanged: (value) {
                      setState(() {
                        _needsClothingChange = value ?? false;
                      });
                    },
                  ),
                  Expanded(child: Text(l10n.needsClothingChange)),
                ],
              ),
            ),
          ...options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(BodilyFunctionDialogResult(option, _needsClothingChange));
                  },
                  child: Text(widget.logic.bodilyFunctionName(option)),
                ),
              ),
            );
          }),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel))],
    );
  }
}

/// Dialog for selecting initiative type for an activity.
class InitiativeTypeDialog extends StatefulWidget {
  final ActivityType activityType;
  final HomePageLogic logic;

  const InitiativeTypeDialog({super.key, required this.activityType, required this.logic});

  @override
  State<InitiativeTypeDialog> createState() => _InitiativeTypeDialogState();
}

class _InitiativeTypeDialogState extends State<InitiativeTypeDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final options = widget.logic.availableInitiativeTypes(widget.activityType);

    return AlertDialog(
      title: Text(l10n.selectInitiative),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(option);
                },
                child: Text(widget.logic.initiativeTypeName(option)),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel))],
    );
  }
}

/// Dialog for selecting water amount for a drank water activity.
class WaterAmountDialog extends StatefulWidget {
  final ActivityType activityType;
  final HomePageLogic logic;

  const WaterAmountDialog({super.key, required this.activityType, required this.logic});

  @override
  State<WaterAmountDialog> createState() => _WaterAmountDialogState();
}

class _WaterAmountDialogState extends State<WaterAmountDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final options = widget.logic.availableWaterAmounts(widget.activityType);

    return AlertDialog(
      title: Text(l10n.selectWaterAmount),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
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
                    Text(widget.logic.waterAmountEmoji(option)),
                    const SizedBox(width: 8),
                    Text(widget.logic.waterAmountName(option)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel))],
    );
  }
}

/// Result of the activity selection flow.
class ActivitySelectionResult {
  final BodilyFunction? bodilyFunction;
  final InitiativeType? initiativeType;
  final WaterAmount? waterAmount;
  final bool? needsClothingChange;

  const ActivitySelectionResult({
    this.bodilyFunction,
    this.initiativeType,
    this.waterAmount,
    this.needsClothingChange,
  });
}

/// Result of the bodily function dialog.
class BodilyFunctionDialogResult {
  final BodilyFunction bodilyFunction;
  final bool needsClothingChange;

  const BodilyFunctionDialogResult(this.bodilyFunction, this.needsClothingChange);
}

/// Shows the activity selection flow as a series of dialogs.
Future<ActivitySelectionResult?> showActivitySelectionFlow({
  required BuildContext context,
  required ActivityType activityType,
  required HomePageLogic logic,
}) async {
  BodilyFunction? bodilyFunction;
  InitiativeType? initiativeType;
  WaterAmount? waterAmount;
  bool? needsClothingChange;

  // Step 1: Select water amount if needed
  if (logic.requiresWaterAmount(activityType)) {
    final result = await showDialog<WaterAmount>(
      context: context,
      builder: (ctx) => WaterAmountDialog(activityType: activityType, logic: logic),
    );
    if (result == null) return null;
    waterAmount = result;
  }

  // Step 2: Select bodily function if needed
  if (logic.requiresBodilyFunction(activityType)) {
    if (!context.mounted) return null;
    final result = await showDialog<BodilyFunctionDialogResult>(
      context: context,
      builder: (ctx) => BodilyFunctionDialog(activityType: activityType, logic: logic),
    );
    if (result == null) return null;
    bodilyFunction = result.bodilyFunction;
    needsClothingChange = result.needsClothingChange;
  }

  // Step 3: Select initiative type if needed
  if (logic.requiresInitiativeType(activityType)) {
    if (!context.mounted) return null;
    final result = await showDialog<InitiativeType>(
      context: context,
      builder: (ctx) => InitiativeTypeDialog(activityType: activityType, logic: logic),
    );
    if (result == null) return null;
    initiativeType = result;
  }

  return ActivitySelectionResult(
    bodilyFunction: bodilyFunction,
    initiativeType: initiativeType,
    waterAmount: waterAmount,
    needsClothingChange: needsClothingChange,
  );
}
