import 'package:flutter/material.dart';
import 'package:potty_train/l10n/app_localizations.dart';
import 'package:potty_train/l10n/app_localizations_en.dart';

import '../../domain/activity_type.dart';
import '../../domain/potty_training_log_item.dart';
import '../add_activity/activity_selection_dialog.dart';
import '../add_activity/date_time_picker_dialog.dart';
import '../edit_activity/edit_log_item_dialog.dart';
import 'home_page_logic.dart';

class HomePage extends StatefulWidget {
  final HomePageLogic logic;

  const HomePage({super.key, required this.logic});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadLogItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    widget.logic.updateLocalizations(l10n);
  }

  Future<void> _loadLogItems() async {
    await widget.logic.loadLogItems();
    if (mounted) setState(() {});
  }

  Future<void> _onActivityButtonTap(ActivityType activityType) async {
    final result = await showActivitySelectionFlow(
      context: context,
      activityType: activityType,
      logic: widget.logic,
    );

    if (result != null && mounted) {
      await widget.logic.createLogItem(
        activityType: activityType,
        timestamp: DateTime.now(),
        bodilyFunction: result.bodilyFunction,
        initiativeType: result.initiativeType,
      );
      if (mounted) setState(() {});
    }
  }

  Future<void> _onActivityButtonLongPress(ActivityType activityType) async {
    final timestamp = await showDateTimePickerDialog(
      context: context,
      initialDateTime: DateTime.now(),
    );

    if (timestamp == null || !mounted) return;

    final result = await showActivitySelectionFlow(
      context: context,
      activityType: activityType,
      logic: widget.logic,
    );

    if (result != null && mounted) {
      await widget.logic.createLogItem(
        activityType: activityType,
        timestamp: timestamp,
        bodilyFunction: result.bodilyFunction,
        initiativeType: result.initiativeType,
      );
      if (mounted) setState(() {});
    }
  }

  Future<void> _onEditLogItem(PottyTrainingLogItem item) async {
    final updated = await showEditLogItemDialog(
      context: context,
      logItem: item,
      logic: widget.logic,
    );

    if (updated != null && mounted) {
      await widget.logic.updateLogItem(updated);
      if (mounted) setState(() {});
    }
  }

  Future<void> _onDeleteLogItem(PottyTrainingLogItem item) async {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete)),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.logic.deleteLogItem(item.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(child: _buildLogList(l10n)),
          const Divider(height: 1),
          _buildActivityButtons(l10n),
        ],
      ),
    );
  }

  Widget _buildLogList(AppLocalizations l10n) {
    final items = widget.logic.logItems;

    if (items.isEmpty) {
      return Center(child: Text(l10n.noLogEntries, style: Theme.of(context).textTheme.bodyLarge));
    }

    return ListView.builder(
      itemCount: items.length + _dateSeparatorCount(items),
      itemBuilder: (context, index) {
        return _buildLogListItem(items, index, l10n);
      },
    );
  }

  int _dateSeparatorCount(List<PottyTrainingLogItem> items) {
    if (items.isEmpty) return 0;
    int count = 1;
    for (int i = 1; i < items.length; i++) {
      if (_differentDay(items[i - 1].timestamp, items[i].timestamp)) {
        count++;
      }
    }
    return count;
  }

  bool _differentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  Widget _buildLogListItem(List<PottyTrainingLogItem> items, int index, AppLocalizations l10n) {
    // Build the list of widgets with date separators interleaved
    final List<Widget> widgets = [];
    DateTime? lastDate;

    for (final item in items) {
      if (lastDate == null || _differentDay(lastDate, item.timestamp)) {
        widgets.add(_buildDateSeparator(item.timestamp, l10n));
      }
      widgets.add(_buildLogItemRow(item, l10n));
      lastDate = item.timestamp;
    }

    if (index >= widgets.length) {
      return const SizedBox.shrink();
    }

    return widgets[index];
  }

  Widget _buildDateSeparator(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    String dateText;

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      dateText = l10n.today;
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      dateText = l10n.yesterday;
    } else {
      dateText =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            dateText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Expanded(child: Divider(indent: 8)),
        ],
      ),
    );
  }

  Widget _buildLogItemRow(PottyTrainingLogItem item, AppLocalizations l10n) {
    final timeText =
        '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';
    final activityName = widget.logic.activityTypeName(item.activityType);
    final emoji = widget.logic.activityTypeEmoji(item.activityType);
    final bodilyEmoji = item.bodilyFunction != null
        ? widget.logic.bodilyFunctionEmoji(item.bodilyFunction!)
        : '';

    return ListTile(
      leading: Text(timeText, style: Theme.of(context).textTheme.bodyMedium),
      title: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Text(activityName)),
          if (bodilyEmoji.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(bodilyEmoji, style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _onEditLogItem(item),
            tooltip: l10n.edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _onDeleteLogItem(item),
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.recordActivity, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildActivityButton(ActivityType.triedThePotty, l10n),
              _buildActivityButton(ActivityType.usedThePotty, l10n),
              _buildActivityButton(ActivityType.accident, l10n),
            ],
          ),
          Row(
            children: [
              _buildActivityButton(ActivityType.drankSomeWater, l10n),
              _buildActivityButton(ActivityType.drankLotsOfWater, l10n),
              _buildActivityButton(ActivityType.ateFood, l10n),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildActivityButton(ActivityType.nappy, l10n)],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityButton(ActivityType type, AppLocalizations l10n) {
    final emoji = widget.logic.activityTypeEmoji(type);
    final label = widget.logic.activityTypeName(type);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onLongPress: () => _onActivityButtonLongPress(type),
          child: ElevatedButton(
            onPressed: () => _onActivityButtonTap(type),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
