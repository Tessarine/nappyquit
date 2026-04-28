# Use Cases Directory

This directory contains application-specific business logic that orchestrates interactions between the UI and repositories.

## Purpose

Defines use cases that represent single user interactions with the system:
- Adding a new log item
- Deleting an existing log item
- Retrieving log items for display
- Updating an existing log item

Each use case encapsulates a specific business operation and depends only on the repository interface.

## Key Responsibilities

- **AddLogItemUseCase**: Persists a new potty training log item
- **DeleteLogItemUseCase**: Removes a log item by ID and timestamp
- **GetLogItemsUseCase**: Retrieves log items with day-indexed pagination
- **UpdateLogItemUseCase**: Modifies an existing log item (handles day changes)

## Architecture

Follows Clean Architecture principles:
- Use cases depend only on repository interfaces (inversion of control)
- Contain no UI or framework-specific code
- Orchestrate domain objects through repository abstractions
- Thin layer that translates UI requests to repository operations

## Dependencies

- **Domain Layer**: Uses PottyTrainingLogItem entity from lib/domain/
- **Repositories**: Depends on PottyTrainingLogItemRepository interface from lib/repositories/
- **No dependencies** on UI layer or other use cases
- **No dependencies** on external packages beyond Dart SDK and project modules

## Coding Principles

- **Single Responsibility**: Each use case does exactly one thing
- **Dependency Inversion**: Depends on abstractions (repositories), not concretions
- **Interface Segregation**: Uses focused repository interfaces with minimal methods
- **Separation of Concerns**: Business logic isolated from presentation and data access
- **Testability**: Easy to unit test with mock repositories
- **Pass-through Pattern**: Most use cases simply delegate to repository methods
- **No Business Logic**: Actual business rules reside in domain or logic layers