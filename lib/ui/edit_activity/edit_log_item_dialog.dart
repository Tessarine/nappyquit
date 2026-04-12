import 'package:flutter/material.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_en.dart';

import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

/// Dialog for editing an existing log item.
class EditLogItemDialog extends StatefulWidget {
  final PottyTrainingLogItem logItem;
  final HomePageLogic logic;

  const EditLogItemDialog({super.key, required this.logItem, required this.logic});

  @override
  State<EditLogItemDialog> createState() => _EditLogItemDialogState();
}

class _EditLogItemDialogState extends State<EditLogItemDialog> {
  late BodilyFunction? _selectedBodilyFunction;
  late InitiativeType? _selectedInitiativeType;
  late DateTime _selectedTimestamp;

  @override
  void initState() {
    super.initState();
    _selectedBodilyFunction = widget.logItem.bodilyFunction;
    _selectedInitiativeType = widget.logItem.initiativeType;
    _selectedTimestamp = widget.logItem.timestamp;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final activityType = widget.logItem.activityType;

    return AlertDialog(
      title: Text(l10n.edit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity type (read-only)
            Text(
              widget.logic.activityTypeName(activityType),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Timestamp
            ListTile(
              title: Text(
                '${_selectedTimestamp.year}-${_selectedTimestamp.month.toString().padLeft(2, '0')}-${_selectedTimestamp.day.toString().padLeft(2, '0')} '
                '${_selectedTimestamp.hour.toString().padLeft(2, '0')}:${_selectedTimestamp.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedTimestamp,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null && context.mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedTimestamp),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTimestamp = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 8),

            // Bodily function selection
            if (widget.logic.requiresBodilyFunction(activityType))
              _buildBodilyFunctionSection(l10n, activityType),

            // Initiative type selection
            if (widget.logic.requiresInitiativeType(activityType))
              _buildInitiativeSection(l10n, activityType),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () {
            final updated = widget.logItem.copyWith(
              timestamp: _selectedTimestamp,
              bodilyFunction: _selectedBodilyFunction,
              initiativeType: _selectedInitiativeType,
            );
            Navigator.of(context).pop(updated);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Widget _buildBodilyFunctionSection(AppLocalizations l10n, ActivityType activityType) {
    final options = widget.logic.availableBodilyFunctions(activityType);
    return RadioGroup<BodilyFunction>(
      groupValue: _selectedBodilyFunction,
      onChanged: (value) {
        setState(() {
          _selectedBodilyFunction = value;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectBodilyFunction, style: Theme.of(context).textTheme.titleSmall),
          ...options.map(
            (option) => RadioListTile<BodilyFunction>(
              title: Text(widget.logic.bodilyFunctionName(option)),
              value: option,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitiativeSection(AppLocalizations l10n, ActivityType activityType) {
    final options = widget.logic.availableInitiativeTypes(activityType);
    return RadioGroup<InitiativeType>(
      groupValue: _selectedInitiativeType,
      onChanged: (value) {
        setState(() {
          _selectedInitiativeType = value;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectInitiative, style: Theme.of(context).textTheme.titleSmall),
          ...options.map(
            (option) => RadioListTile<InitiativeType>(
              title: Text(widget.logic.initiativeTypeName(option)),
              value: option,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the edit dialog and returns the updated log item.
Future<PottyTrainingLogItem?> showEditLogItemDialog({
  required BuildContext context,
  required PottyTrainingLogItem logItem,
  required HomePageLogic logic,
}) {
  return showDialog<PottyTrainingLogItem>(
    context: context,
    builder: (ctx) => EditLogItemDialog(logItem: logItem, logic: logic),
  );
}
