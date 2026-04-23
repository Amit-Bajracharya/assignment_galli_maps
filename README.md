# Galli Maps

A Flutter map application for saving and managing favorite locations.

## Features

- **Interactive Map**: Displays Galli Maps using MapLibre GL
- **Save Locations**: Tap the + button to save any location on the map
- **Categories**: Organize places by category (Food, Home, Work, Travel, etc.)
- **Local Storage**: All data saved locally using Hive (no internet required after first load)
- **GPS Support**: Get your current location and center the map
- **Entry Management**: View saved places in a list or on the map, delete when needed

## Tech Stack

- Flutter 3.x
- Riverpod (state management)
- Hive (local database)
- MapLibre GL (map rendering)
- GoRouter (navigation)
- Freezed (immutable models)

## How to Run

### Requirements

- Flutter SDK 3.0 or higher
- Android SDK (API 21+)
- Android Studio or VS Code

### Steps

1. Clone the repo:
   ```bash
   git clone https://github.com/yourusername/galli_maps.git
   cd galli_maps
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (for Hive adapters and Freezed):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run on emulator or device:
   ```bash
   flutter run
   ```

## Building APK

```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── router/
│   └── theme/
├── features/
│   └── entry/
│       ├── data/
│       │   ├── datasource/
│       │   ├── models/
│       │   └── repository/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repository/
│       │   └── usecases/
│       └── presentation/
│           ├── providers/
│           ├── screen/
│           └── widgets/
└── main.dart
```

## Assessment Requirements

All requirements from the technical assessment have been implemented:

- [x] Map rendering with MapLibre GL
- [x] Galli Maps custom style URL
- [x] Location permissions and GPS centering
- [x] Pin-drop location selection
- [x] Entry form (title, description, category)
- [x] Local data persistence with Hive
- [x] Custom map markers by category
- [x] Entry detail bottom sheet
- [x] Entry deletion
- [x] Clean Architecture (Domain/Data/Presentation)
- [x] Riverpod state management

## Submission

- **GitHub Repository**: https://github.com/Amit-Bajracharya/assignment_galli_maps
- **APK Download**: [GitHub Releases](https://github.com/Amit-Bajracharya/assignment_galli_maps/releases)
- **Submitted by**: April 23, 2026

---

Built with Flutter for Galli Maps technical assessment.
