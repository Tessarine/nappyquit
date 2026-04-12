import 'package:flutter/material.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_en.dart';

import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/ui/add_activity/activity_selection_dialog.dart';
import 'package:toot_n_tinkle/ui/add_activity/date_time_picker_dialog.dart';
import 'package:toot_n_tinkle/ui/edit_activity/edit_log_item_dialog.dart';
import 'package:toot_n_tinkle/ui/help/help_dialog.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

class HomePage extends StatefulWidget {
  final HomePageLogic logic;

  const HomePage({super.key, required this.logic});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadLogItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    widget.logic.updateLocalizations(l10n);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        widget.logic.hasMoreDays &&
        !_isLoadingMore) {
      _loadMoreDays();
    }
  }

  Future<void> _loadLogItems() async {
    await widget.logic.loadLogItems();
    if (mounted) setState(() {});
  }

  Future<void> _loadMoreDays() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    await widget.logic.loadMoreDays();
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
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
      await widget.logic.updateLogItem(item, updated);
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
      await widget.logic.deleteLogItem(item.id, item.timestamp);
      if (mounted) setState(() {});
    }
  }

  Future<void> _showHelpDialog() async {
    await showDialog<void>(context: context, builder: (ctx) => const HelpDialog());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: l10n.help,
          ),
        ],
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
    final loadedDays = widget.logic.loadedDays;
    final itemsByDay = widget.logic.itemsByDay;

    if (loadedDays.isEmpty) {
      return Center(child: Text(l10n.noLogEntries, style: Theme.of(context).textTheme.bodyLarge));
    }

    // Build the list of widgets: date separator + items for each day
    final List<_LogEntry> entries = [];
    for (final dayKey in loadedDays) {
      final items = itemsByDay[dayKey];
      if (items == null || items.isEmpty) continue;
      entries.add(_LogEntry.daySeparator(dayKey));
      for (final item in items) {
        entries.add(_LogEntry.item(item));
      }
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: entries.length + (widget.logic.hasMoreDays || _isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= entries.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final entry = entries[index];
        if (entry.isDaySeparator) {
          return _buildDateSeparator(entry.dayKey!, l10n);
        } else {
          return _buildLogItemRow(entry.item!, l10n);
        }
      },
    );
  }

  Widget _buildDateSeparator(String dayKey, AppLocalizations l10n) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    String dateText;
    if (dayKey == todayKey) {
      dateText = l10n.today;
    } else if (dayKey == yesterdayKey) {
      dateText = l10n.yesterday;
    } else {
      dateText = dayKey;
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
              _buildActivityButton(ActivityType.nappy, l10n),
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
            children: [_buildActivityButton(ActivityType.usedThePotty, l10n)],
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

/// Helper class to represent entries in the log list.
/// Can be either a day separator or a log item.
class _LogEntry {
  final String? dayKey;
  final PottyTrainingLogItem? item;

  bool get isDaySeparator => dayKey != null;

  _LogEntry.daySeparator(this.dayKey) : item = null;
  _LogEntry.item(this.item) : dayKey = null;
}
