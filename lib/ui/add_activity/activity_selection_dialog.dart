import 'package:flutter/material.dart';
import 'package:potty_train/l10n/app_localizations.dart';
import 'package:potty_train/l10n/app_localizations_en.dart';

import '../../domain/activity_type.dart';
import '../../domain/bodily_function.dart';
import '../../domain/initiative_type.dart';
import '../home/home_page_logic.dart';

/// Dialog for selecting bodily function for an activity.
class BodilyFunctionDialog extends StatefulWidget {
  final ActivityType activityType;
  final HomePageLogic logic;

  const BodilyFunctionDialog({super.key, required this.activityType, required this.logic});

  @override
  State<BodilyFunctionDialog> createState() => _BodilyFunctionDialogState();
}

class _BodilyFunctionDialogState extends State<BodilyFunctionDialog> {
  BodilyFunction? _selectedBodilyFunction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final options = widget.logic.availableBodilyFunctions(widget.activityType);

    return AlertDialog(
      title: Text(l10n.selectBodilyFunction),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            title: Text(widget.logic.bodilyFunctionName(option)),
            leading: Radio<BodilyFunction>(
              value: option,
              groupValue: _selectedBodilyFunction,
              onChanged: (value) {
                setState(() {
                  _selectedBodilyFunction = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                _selectedBodilyFunction = option;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        TextButton(
          onPressed: _selectedBodilyFunction != null
              ? () => Navigator.of(context).pop(_selectedBodilyFunction)
              : null,
          child: Text(l10n.save),
        ),
      ],
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
  InitiativeType? _selectedInitiativeType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final options = widget.logic.availableInitiativeTypes(widget.activityType);

    return AlertDialog(
      title: Text(l10n.selectInitiative),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            title: Text(widget.logic.initiativeTypeName(option)),
            leading: Radio<InitiativeType>(
              value: option,
              groupValue: _selectedInitiativeType,
              onChanged: (value) {
                setState(() {
                  _selectedInitiativeType = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                _selectedInitiativeType = option;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        TextButton(
          onPressed: _selectedInitiativeType != null
              ? () => Navigator.of(context).pop(_selectedInitiativeType)
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Result of the activity selection flow.
class ActivitySelectionResult {
  final BodilyFunction? bodilyFunction;
  final InitiativeType? initiativeType;

  const ActivitySelectionResult({this.bodilyFunction, this.initiativeType});
}

/// Shows the activity selection flow as a series of dialogs.
Future<ActivitySelectionResult?> showActivitySelectionFlow({
  required BuildContext context,
  required ActivityType activityType,
  required HomePageLogic logic,
}) async {
  BodilyFunction? bodilyFunction;
  InitiativeType? initiativeType;

  // Step 1: Select bodily function if needed
  if (logic.requiresBodilyFunction(activityType)) {
    final result = await showDialog<BodilyFunction>(
      context: context,
      builder: (ctx) => BodilyFunctionDialog(activityType: activityType, logic: logic),
    );
    if (result == null) return null;
    bodilyFunction = result;
  }

  // Step 2: Select initiative type if needed
  if (logic.requiresInitiativeType(activityType)) {
    if (!context.mounted) return null;
    final result = await showDialog<InitiativeType>(
      context: context,
      builder: (ctx) => InitiativeTypeDialog(activityType: activityType, logic: logic),
    );
    if (result == null) return null;
    initiativeType = result;
  }

  return ActivitySelectionResult(bodilyFunction: bodilyFunction, initiativeType: initiativeType);
}
