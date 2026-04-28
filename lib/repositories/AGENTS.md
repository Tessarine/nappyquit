# Repositories Directory

This directory contains all data persistence implementations for the potty training app.

## Purpose

Handles storage and retrieval of potty training log items using various persistence strategies:
- SharedPreferences (Android/iOS)
- Markdown files (desktop/Linux)
- Abstract repository interfaces

## Key Responsibilities

- Abstract repository interface defines contract for log item operations
- SharedPreferences implementation provides mobile storage with day-indexed access
- Markdown file implementation provides human-readable desktop storage
- All implementations support day-indexed storage for efficient pagination

## Interface Contract

The `PottyTrainingLogItemRepository` abstract class defines:
- `getDayIndex()`: Returns dates with log items (descending order)
- `getLogItemsForDays()`: Retrieves items for specific days
- `add()`: Inserts new log item
- `update()`: Modifies existing item (handles day changes)
- `delete()`: Removes item by ID and timestamp

## Implementation Patterns

Both concrete implementations:
- Use day keys in 'yyyy-MM-dd' format for grouping
- Maintain descending order for recent-first access
- Handle migration of legacy data formats
- Serialize/deserialize log items with proper null handling
- Manage day index updates when items change days

## Dependencies

- Depends on domain models in `lib/domain/*`
- Uses `shared_preferences` package for mobile storage
- Uses `dart:io` for file system operations
- No dependencies on UI or use case layers

## Coding Principles

- Follows SOLID principles (especially Interface Segregation)
- Separates storage concerns from business logic
- Eliminates duplication through abstract base class
- Maintains testability through interface-based design
- Follows DRY principle with shared utility methods