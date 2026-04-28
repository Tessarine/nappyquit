# AGENTS.md

This is the root AGENTS.md file providing an overview of the potty training application.
For detailed, directory-specific guidance, see the AGENTS.md files in each subdirectory.

## Overview

This project is a potty training app mainly for Linux & android that follows Domain-Driven Design principles with a clean architecture separating concerns into:
- **Domain layer** (`lib/domain/`): Core business logic and data models
- **Use cases layer** (`lib/use_cases/`): Application-specific business logic orchestration
- **Repositories layer** (`lib/repositories/`): Data persistence implementations
- **UI layer** (`lib/ui/`): User interface components organized by feature

## Directory-Specific Guidance

For detailed information about each directory's purpose, responsibilities, dependencies, and coding principles, refer to:
- `lib/domain/AGENTS.md` - Domain model and entities
- `lib/use_cases/AGENTS.md` - Use cases and business logic orchestration
- `lib/repositories/AGENTS.md` - Data persistence strategies
- `lib/ui/AGENTS.md` - User interface components and architecture

## Key Principles

The application follows these architectural principles:
- **Separation of Concerns**: Clear boundaries between domain, application, and UI layers
- **Dependency Inversion**: Dependencies point inward toward domain objects
- **Testability**: Designed for easy unit and widget testing
- **Localization**: Full internationalization support with proper fallbacks
- **UI Separation**: Zero business logic in UI files

## Standard Processes

- **Commit Messages**: Follow conventional commits format (see `.kilocode/skills/commit/SKILL.md`)
- **Testing**: Run `bash scripts/ci_cd_pipeline.sh` to verify the project
- **Localization**: Use `AppLocalizations.of(context) ?? AppLocalizationsEn()` for all user-facing text

## Getting Started

To work effectively in any directory:
1. Read the corresponding AGENTS.md file for that directory
2. Follow the established patterns and principles documented there
3. Ensure UI remains separate from business logic
4. Write tests before implementing features (TDD)
5. Keep commit messages clean and descriptive