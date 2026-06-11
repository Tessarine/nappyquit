import 'package:flutter/material.dart';
import 'package:nappyquit/l10n/app_localizations.dart';
import 'package:nappyquit/l10n/app_localizations_en.dart';

/// Dialog for selecting a custom date and time when long-pressing an activity button.
class DateTimePickerDialog extends StatefulWidget {
  final DateTime initialDateTime;

  const DateTimePickerDialog({super.key, required this.initialDateTime});

  @override
  State<DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.initialDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return AlertDialog(
      title: Text(l10n.selectDateAndTime),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),
          ListTile(
            title: Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _selectedTime);
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () {
            final result = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            Navigator.of(context).pop(result);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Shows the date/time picker dialog and returns the selected DateTime.
Future<DateTime?> showDateTimePickerDialog({
  required BuildContext context,
  required DateTime initialDateTime,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => DateTimePickerDialog(initialDateTime: initialDateTime),
  );
}
