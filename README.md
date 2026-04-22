# Galli Maps Assignment - Technical Assessment

A premium Flutter application demonstrating map integration, local data persistence, and clean architecture.

## 🚀 Key Features

- **Interactive Map Engine**: Integrated with `maplibre_gl` and Galli Maps Light Style.
- **Location Intelligence**: Real-time reverse geocoding and current location centering.
- **Persistent Bookmarking**: Save your favorite places locally using Hive.
- **Custom Categorization**: Each place can be categorized (Food, Home, Work, etc.) with custom-rendered map markers.
- **Premium UI/UX**: Responsive design using `flutter_screenutil`, smooth transitions, and high-fidelity bottom sheets.
- **State Management**: Built with **Riverpod** for robust and reactive state handling.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Local Database**: Hive (for high-performance storage)
- **Map Service**: MapLibre GL
- **Navigation**: GoRouter
- **Theming**: Google Fonts (Poppins) & custom design system.

## 🏗️ Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- A Galli Maps API Key (configured in `AppConstants`)

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd galli_maps_assignment
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Models**:
   This project uses `hive_generator` for database adapters. Run the following to generate necessary files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── core/            # App-wide constants, themes, and routers
├── features/        # Feature-based modular structure
│   └── entry/       # Core "Location Entry" feature
│       ├── data/    # Repositories & Data Sources (Hive)
│       ├── domain/  # Entities & Use Cases
│       └── presentation/ # Riverpod Providers & Flutter Screens
└── main.dart        # App entry point
```

## 📝 Assessment Requirements Meta
- [x] Map Rendering (GL-based)
- [x] Custom Style String
- [x] Location Permissions & Centering
- [x] "Add Entry" Workflow (FAB & Form)
- [x] Coordinate Selection (Crosshair)
- [x] Data Persistence (Local Storage)
- [x] Persistent Map Markers
- [x] Detail View (Bottom Sheet)
- [x] Riverpod State Management
