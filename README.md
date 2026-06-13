# NappyQuit

A potty training app for Linux & Android.

![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.11.1-blue)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Description

NappyQuit is a potty training application designed to help parents track their child's progress in potty training. The app allows recording various activities such as trying the potty, using the potty, accidents, drinking water, eating food, and nappy changes. Each activity can be annotated with additional details like bodily function, initiative type, amount of water/food consumed, and whether a clothing change is needed.

## Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version >=3.11.1)
- A code editor (such as Android Studio, VS Code, or IntelliJ)
- An emulator or physical device for testing (Android or Linux)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/nappyquit.git
   cd nappyquit
   ```

2. Get the dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

   This will launch the app on your connected device or emulator.

## Usage

### Recording Activities

The main screen displays a list of recorded activities and six buttons at the bottom for quick activity recording:

1. **Tried the potty** - Records when the child attempted to use the potty.
2. **Used the potty** - Records successful potty usage.
3. **Accident** - Records when the child had an accident.
4. **Drank water** - Records when the child drank water (you'll be prompted to specify the amount: some or lots).
5. **Ate food** - Records when the child ate food (you'll be prompted to specify the amount: some or lots).
6. **Nappy** - Records when the child's nappy was changed.

### Quick Recording vs. Scheduled Recording

- **Quick recording**: Tap a button to record the activity with the current timestamp.
- **Scheduled recording**: Long-press a button to select a specific date and time for the activity.

### Editing and Deleting Entries

Each entry in the list has edit and delete buttons on the right:
- Tap the **edit** button to modify an existing entry.
- Tap the **delete** button to remove an entry (you'll be prompted for confirmation).

### Language Settings

The app supports English and Hungarian. To change the language:
1. Go to the Settings page (accessible via the app bar or menu).
2. Select your preferred language from the dropdown.
3. The app will restart with the new language.

### Repository Type

The app currently uses SharedPreferences for data storage. The repository abstraction allows for other implementations (e.g., SQLite, remote server) to be plugged in by implementing the `PottyTrainingLogItemRepository` interface.

## Architecture

NappyQuit follows an architecture with the following layers:

- **Domain**: Contains the business logic and data models (`PottyTrainingLogItem`, enums for activity types, bodily functions, etc.).
- **Use Cases**: Interact with the repository to perform operations (add, update, delete, retrieve log items).
- **Repositories**: Abstract the data storage layer. The current implementation uses SharedPreferences.
- **UI**: Built with Flutter, organized by feature (home, add activity, edit activity, settings, help).

### Key Components

- `PottyTrainingLogItem`: Represents a single log entry.
- `ActivityType`, `BodilyFunction`, `InitiativeType`, `WaterAmount`, `FoodAmount`: Enums that categorize activities.
- `PottyTrainingLogItemRepository`: Interface for data storage operations.
- `SharedPrefsPottyTrainingLogItemRepository`: SharedPreferences implementation of the repository.
- Use cases: `AddLogItemUseCase`, `DeleteLogItemUseCase`, `GetLogItemsUseCase`, `UpdateLogItemUseCase`.
- UI screens: Home page, activity recording dialogs, edit dialog, settings page, help dialog.

## Configuration

The app can be configured via the Settings page:

- **Language**: Choose between English (en) and Hungarian (hu).
- **Repository Type**: Currently fixed to SharedPreferences, but designed for extensibility.

## Testing

### Running Unit Tests

To run the unit and widget tests:
```bash
flutter test
```

### Running Integration Tests

To run the integration tests:
```bash
flutter test integration_test/edit_activity_test.dart
```

### Running the Full CI/CD Pipeline

The project includes a CI/CD script that checks code formatting, runs tests, verifies coverage, and builds the app for Linux and Android:
```bash
bash scripts/ci_cd_pipeline.sh
```

## Contribution

We welcome contributions to NappyQuit! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes.
4. Ensure your code follows the existing style and passes the lints (`flutter_lints`).
5. Run the tests to ensure nothing is broken.
6. Submit a pull request with a clear description of your changes.

Please make sure to update tests as appropriate and adhere to the project's coding standards.

## License

This project is open source and available under the [Apache 2.0 License](LICENSE).

## Acknowledgments

- The Flutter team for the excellent framework.
- The open-source community for the packages used in this project.
- [Noto Color Emoji (COLRv1)](https://fonts.google.com/noto/specimen/Noto+Color+Emoji) by Google — used for uniform cross-platform emoji rendering. Licensed under the [SIL Open Font License 1.1](https://scripts.sil.org/OFL).

## Contact

For questions or feedback, please open an issue on the GitHub repository.
