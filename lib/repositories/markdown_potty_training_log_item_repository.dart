import 'dart:io';

import 'package:toot_n_tinkle/domain/activity_type.dart';
import 'package:toot_n_tinkle/domain/bodily_function.dart';
import 'package:toot_n_tinkle/domain/initiative_type.dart';
import 'package:toot_n_tinkle/domain/potty_training_log_item.dart';
import 'package:toot_n_tinkle/domain/water_amount.dart';
import 'package:toot_n_tinkle/domain/food_amount.dart';
import 'package:toot_n_tinkle/repositories/potty_training_log_item_repository.dart';

/// Markdown file-based implementation of the log item repository.
/// Stores each day's log items in a separate markdown file.
class MarkdownPottyTrainingLogItemRepository implements PottyTrainingLogItemRepository {
  final String _directoryPath;

  MarkdownPottyTrainingLogItemRepository(this._directoryPath);

  /// Ensures the directory exists
  Future<void> _ensureDirectoryExists() async {
    final directory = Directory(_directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  String _toDayKey(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<String>> getDayIndex() async {
    await _ensureDirectoryExists();
    final directory = Directory(_directoryPath);
    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.md'))
        .toList();

    // Extract dates from filenames (format: yyyy-MM-dd.md)
    final dayKeys = files
        .map((file) {
          final basename = (file as File).uri.pathSegments.last;
          return basename.substring(0, basename.length - 3); // Remove .md
        })
        .where((key) => RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key))
        .toList();

    // Sort in descending order (most recent first)
    dayKeys.sort((a, b) => b.compareTo(a));
    return dayKeys;
  }

  @override
  Future<Map<String, List<PottyTrainingLogItem>>> getLogItemsForDays(List<String> dayKeys) async {
    await _ensureDirectoryExists();
    final result = <String, List<PottyTrainingLogItem>>{};

    for (final dayKey in dayKeys) {
      final filePath = '$_directoryPath/$dayKey.md';
      final file = File(filePath);

      if (await file.exists()) {
        final content = await file.readAsString();
        final items = _parseMarkdown(content, dayKey);
        // Sort by timestamp descending
        items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        result[dayKey] = items;
      }
      // Don't add the key if the file doesn't exist (no items)
    }

    return result;
  }

  @override
  Future<void> add(PottyTrainingLogItem item) async {
    await _ensureDirectoryExists();
    final dayKey = _toDayKey(item.timestamp);
    final filePath = '$_directoryPath/$dayKey.md';
    final file = File(filePath);

    // Read existing content
    String existingContent = '';
    if (await file.exists()) {
      existingContent = await file.readAsString();
    }

    // Append new item as markdown
    final markdownItem = _toMarkdown(item);
    final newContent = existingContent.isEmpty
        ? '# Potty Training Log for $dayKey\n\n$markdownItem'
        : '$existingContent\n\n$markdownItem';

    await file.writeAsString(newContent);
  }

  @override
  Future<void> update(PottyTrainingLogItem item, DateTime originalTimestamp) async {
    await _ensureDirectoryExists();
    final oldDayKey = _toDayKey(originalTimestamp);
    final newDayKey = _toDayKey(item.timestamp);
    final oldFilePath = '$_directoryPath/$oldDayKey.md';
    final newFilePath = '$_directoryPath/$newDayKey.md';

    if (oldDayKey == newDayKey) {
      // Same day: update item in place
      final file = File(oldFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final updatedContent = _updateItemInMarkdown(content, item);
        await file.writeAsString(updatedContent);
      }
    } else {
      // Different day: remove from old day, add to new day
      final oldFile = File(oldFilePath);
      if (await oldFile.exists()) {
        final content = await oldFile.readAsString();
        final updatedContent = _removeItemFromMarkdown(content, item.id);
        if (updatedContent.trim().endsWith('# Potty Training Log for $oldDayKey') ||
            updatedContent.trim().isEmpty) {
          // No items left, remove the file
          await oldFile.delete();
        } else {
          await oldFile.writeAsString(updatedContent);
        }
      }

      // Add to new day
      final newFile = File(newFilePath);
      String existingContent = '';
      if (await newFile.exists()) {
        existingContent = await newFile.readAsString();
      }

      final markdownItem = _toMarkdown(item);
      final newContent = existingContent.isEmpty
          ? '# Potty Training Log for $newDayKey\n\n$markdownItem'
          : '$existingContent\n\n$markdownItem';

      await newFile.writeAsString(newContent);
    }
  }

  @override
  Future<void> delete(String id, DateTime timestamp) async {
    await _ensureDirectoryExists();
    final dayKey = _toDayKey(timestamp);
    final filePath = '$_directoryPath/$dayKey.md';
    final file = File(filePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      final updatedContent = _removeItemFromMarkdown(content, id);
      if (updatedContent.trim().endsWith('# Potty Training Log for $dayKey') ||
          updatedContent.trim().isEmpty) {
        // No items left, remove the file
        await file.delete();
      } else {
        await file.writeAsString(updatedContent);
      }
    }
  }

  // --- Private helpers ---

  List<PottyTrainingLogItem> _parseMarkdown(String content, String dayKey) {
    final List<PottyTrainingLogItem> items = [];

    // Split by lines and process each line
    final lines = content.split('\n');
    PottyTrainingLogItem? currentItem;

    for (final line in lines) {
      if (line.startsWith('# Potty Training Log for')) {
        // Header line, skip
        continue;
      }

      if (line.startsWith('- **ID:**')) {
        // Start of a new item
        if (currentItem != null) {
          items.add(currentItem);
        }

        // Parse ID
        final id = line.substring('- **ID:** '.length).trim();
        // Create placeholder with required fields
        final placeholderTimestamp = DateTime.parse('$dayKey 00:00:00');
        currentItem = PottyTrainingLogItem(
          id: id,
          activityType: ActivityType.triedThePotty,
          timestamp: placeholderTimestamp,
          created: placeholderTimestamp,
          updated: placeholderTimestamp,
        );
      } else if (line.startsWith('- **Activity Type:**') && currentItem != null) {
        final activityTypeName = line.substring('- **Activity Type:** '.length).trim();
        currentItem = currentItem.copyWith(
          activityType: ActivityType.values.byName(activityTypeName),
        );
      } else if (line.startsWith('- **Timestamp:**') && currentItem != null) {
        final timestampStr = line.substring('- **Timestamp:** '.length).trim();
        currentItem = currentItem.copyWith(timestamp: DateTime.parse(timestampStr));
      } else if (line.startsWith('- **Bodily Function:**') && currentItem != null) {
        final bodilyFunctionStr = line.substring('- **Bodily Function:** '.length).trim();
        if (bodilyFunctionStr != 'null') {
          currentItem = currentItem.copyWith(
            bodilyFunction: BodilyFunction.values.byName(bodilyFunctionStr),
          );
        }
      } else if (line.startsWith('- **Initiative Type:**') && currentItem != null) {
        final initiativeTypeStr = line.substring('- **Initiative Type:** '.length).trim();
        if (initiativeTypeStr != 'null') {
          currentItem = currentItem.copyWith(
            initiativeType: InitiativeType.values.byName(initiativeTypeStr),
          );
        }
      } else if (line.startsWith('- **Water Amount:**') && currentItem != null) {
        final waterAmountStr = line.substring('- **Water Amount:** '.length).trim();
        if (waterAmountStr != 'null') {
          currentItem = currentItem.copyWith(
            waterAmount: WaterAmount.values.byName(waterAmountStr),
          );
        }
      } else if (line.startsWith('- **Food Amount:**') && currentItem != null) {
        final foodAmountStr = line.substring('- **Food Amount:** '.length).trim();
        if (foodAmountStr != 'null') {
          currentItem = currentItem.copyWith(foodAmount: FoodAmount.values.byName(foodAmountStr));
        }
      } else if (line.startsWith('- **Needs Clothing Change:**') && currentItem != null) {
        final needsClothingChangeStr = line
            .substring('- **Needs Clothing Change:** '.length)
            .trim();
        final needsClothingChange = needsClothingChangeStr == 'true';
        currentItem = currentItem.copyWith(needsClothingChange: needsClothingChange);
      } else if (line.startsWith('- **Created:**') && currentItem != null) {
        final createdStr = line.substring('- **Created:** '.length).trim();
        currentItem = currentItem.copyWith(created: DateTime.parse(createdStr));
      } else if (line.startsWith('- **Updated:**') && currentItem != null) {
        final updatedStr = line.substring('- **Updated:** '.length).trim();
        currentItem = currentItem.copyWith(updated: DateTime.parse(updatedStr));
      } else if (line.startsWith('- **Deleted:**') && currentItem != null) {
        final deletedStr = line.substring('- **Deleted:** '.length).trim();
        final deleted = deletedStr != 'null' ? DateTime.parse(deletedStr) : null;
        currentItem = currentItem.copyWith(deleted: deleted);
      }
    }

    // Add the last item if exists
    if (currentItem != null) {
      items.add(currentItem);
    }

    return items;
  }

  String _toMarkdown(PottyTrainingLogItem item) {
    return '''
- **ID:** ${item.id}
- **Activity Type:** ${item.activityType.name}
- **Timestamp:** ${item.timestamp.toIso8601String()}
- **Bodily Function:** ${item.bodilyFunction?.name ?? 'null'}
- **Initiative Type:** ${item.initiativeType?.name ?? 'null'}
- **Water Amount:** ${item.waterAmount?.name ?? 'null'}
- **Food Amount:** ${item.foodAmount?.name ?? 'null'}
- **Needs Clothing Change:** ${item.needsClothingChange ?? false}
- **Created:** ${item.created.toIso8601String()}
- **Updated:** ${item.updated.toIso8601String()}
- **Deleted:** ${item.deleted?.toIso8601String() ?? 'null'}''';
  }

  String _updateItemInMarkdown(String content, PottyTrainingLogItem newItem) {
    // This is a simplified implementation - in practice, we'd parse and replace
    // For now, we'll remove the old item and add the new one at the end
    final withoutOldItem = _removeItemFromMarkdown(content, newItem.id);
    final separator = withoutOldItem.isNotEmpty ? '\n\n' : '';
    return '$withoutOldItem$separator${_toMarkdown(newItem)}';
  }

  String _removeItemFromMarkdown(String content, String itemId) {
    final lines = content.split('\n');
    final List<String> newLines = [];
    bool skipItem = false;

    for (final line in lines) {
      if (line.startsWith('- **ID:** $itemId')) {
        skipItem = true;
        continue;
      }

      if (skipItem) {
        // Check if we've reached the end of this item
        if (line.startsWith('- **ID:**') && !line.startsWith('- **ID:** $itemId')) {
          // Start of next item
          skipItem = false;
          newLines.add(line);
        }
        // Skip this line (part of the item we're removing)
        continue;
      }

      newLines.add(line);
    }

    // Join and clean up extra newlines
    var result = newLines.join('\n');
    // Remove multiple consecutive newlines
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    // Remove trailing newlines
    result = result.trimRight();

    return result;
  }
}
