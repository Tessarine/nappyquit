import 'package:flutter/material.dart';
import 'package:potty_train/l10n/app_localizations.dart';

/// Dialog for displaying help information about the app.
class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n!.helpTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, l10n.helpMainPage, l10n.helpMainPageDescription),
            const SizedBox(height: 16),
            _buildSection(context, l10n.helpButtons, l10n.helpButtonsDescription),
            const SizedBox(height: 16),
            _buildSection(context, l10n.helpActivityTypes, l10n.helpTriedThePotty),
            const SizedBox(height: 4),
            Text(l10n.helpUsedThePotty),
            const SizedBox(height: 4),
            Text(l10n.helpAccident),
            const SizedBox(height: 4),
            Text(l10n.helpDrankSomeWater),
            const SizedBox(height: 4),
            Text(l10n.helpDrankLotsOfWater),
            const SizedBox(height: 4),
            Text(l10n.helpAteFood),
            const SizedBox(height: 4),
            Text(l10n.helpNappy),
            const SizedBox(height: 16),
            _buildSection(context, l10n.helpSelections, l10n.helpSelectionsDescription),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel))],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }
}
