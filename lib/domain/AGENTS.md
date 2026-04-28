# Domain Directory

This directory contains the core business logic and data models for the potty training app.

## Purpose

Defines the domain model using Dart enums that represent:
- Types of activities (tried potty, used potty, accident, drank water, ate food, nappy)
- Bodily functions involved (pee, poo, both, none)
- Food consumption amounts (some, lots)
- Child's initiative types (told parents, went by himself, asked to sit)
- Water consumption amounts (some, lots)
- The log item entity that combines all these aspects

## Key Responsibilities

- Provides type-safe enums for all categorical data in the application
- Defines the `PottyTrainingLogItem` class as the central domain entity
- Ensures domain objects are independent of UI, persistence, and use case layers
- Contains no business logic beyond the data structure definitions
- Follows Domain-Driven Design principles by focusing on the core model

## Domain Model

The domain consists of:
1. **ActivityType**: Enumerates the six possible activities tracked
2. **BodilyFunction**: Captures the physiological aspect of activities
3. **InitiativeType**: Records how the child initiated the activity
4. **Consumption enums** (FoodAmount, WaterAmount): Track intake quantities
5. **PottyTrainingLogItem**: The aggregate entity that combines all above properties with metadata (timestamps, IDs, etc.)

## Dependencies

- No dependencies on other layers (UI, use cases, repositories)
- Only depends on the Dart SDK
- Designed to be imported by use cases and repositories without creating circular dependencies

## Coding Principles

- **Pure domain model**: Contains only data and minimal behavior (copyWith, equality)
- **Type safety**: Uses enums instead of strings or integers for all categorical data
- **Immutability**: LogItem uses final fields and copyWith pattern for safe mutations
- **Equality implementation**: Overrides == and hashCode for proper object comparison
- **Separation of concerns**: Zero knowledge of persistence or presentation mechanisms
- **DDD compliance**: Represents the core domain bounded context of potty training tracking