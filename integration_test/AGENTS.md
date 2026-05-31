# Integration Test Directory

This directory contains integration tests for the potty training application. Integration tests verify that different parts of the application work together correctly.

## Purpose

Integration tests in this directory:
- Test the interaction between UI components and business logic
- Verify end-to-end workflows for key features
- Use real implementations where appropriate (though may use in-memory repositories for testing)
- Run on actual devices or emulators to catch platform-specific issues

## Responsibilities

- Create meaningful integration tests that verify user workflows
- Test edge cases and error conditions in real scenarios
- Ensure UI components properly interact with domain models and use cases
- Validate that state management works correctly in integration contexts

## Dependencies

- `flutter_test` and `integration_test` packages for test framework
- `mockito` or similar for mocking dependencies when needed
- In-memory implementations of repositories for isolated testing
- Test-specific implementations that mirror production behavior

## Coding Principles

1. **Realistic Scenarios**: Tests should mimic real user interactions as closely as possible
2. **Isolation**: Each test should be self-contained and not depend on others
3. **Clear Arrangement**: Test setup should be obvious and easy to understand
4. **Meaningful Assertions**: Tests should verify actual behavior, not just that code runs
5. **Platform Awareness**: Consider differences between platforms when writing tests
6. **Performance Conscious**: Avoid overly complex setups that slow down test execution

## Standard Processes

- Write integration tests for new user-facing features
- Run integration tests before releasing to catch regressions
- Use `flutter drive` or equivalent to run tests on devices/emulators
- Keep tests focused on specific user workflows
- Update tests when changing user interaction patterns

## Example

See `edit_activity_test.dart` for examples of:
- Setting up test data with in-memory repositories
- Creating test widgets that mimic real UI
- Simulating user interactions (taps, scrolls, etc.)
- Verifying expected outcomes and UI states
- Testing different activity types (used potty, drank water, accident)

## Getting Started

To work with integration tests in this directory:
1. Read the existing test files to understand patterns
2. Follow the established structure for new tests
3. Ensure tests run successfully on both Android and Linux (if applicable)
4. Keep tests focused on user workflows rather than internal implementation details