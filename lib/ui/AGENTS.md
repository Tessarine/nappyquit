# UI Directory

This directory contains all user interface components for the potty training app.

## Purpose

Manages the presentation layer including screens, dialogs, and widgets for activity logging, log viewing, and app configuration.

## Key Responsibilities

- Home page displaying log history and activity buttons
- Dialog sequences for logging each activity type (tried potty, used potty, accident, nappy, drank water, ate food)
- Interface for editing existing log entries
- Settings and help screens
- Localization integration for multilingual support

## Architecture

Separates UI concerns from business logic:
- UI files handle presentation and user interactions
- Logic files manage state and business rules
- Communication via callbacks and method calls
- No direct repository access - data flows through logic layer

## Dependencies

- Domain layer: Activity types, log items, enums from lib/domain/
- Logic layer: State management and use case orchestration
- External: Flutter SDK, uuid package, localization packages

## Coding Principles

- UI separation: Zero business logic in UI files
- Localization first: All text uses AppLocalizations with fallbacks
- Stateless preferences: Manage state in logic layer
- Callback patterns: UI-to-logic communication via callbacks
- Resource management: Proper disposal of controllers/listeners