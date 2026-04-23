# Galli Maps Flutter Assessment — Complete Build Guide

> **Stack:** Flutter · Clean Architecture · Riverpod (manual) · Freezed · Hive · MapLibre GL  
> **Deadline:** April 29, 2026 at 2:00 PM  
> **Repo:** public GitHub · submit repo link + APK link

---

## What We Are Building

A Flutter map app where users can:
- See a map powered by MapLibre GL using the Galli Maps style URL
- Tap a FAB to enter pin-drop mode and pick a location on the map
- Fill a form with title, description, and category icon
- Save the entry locally using Hive (no backend)
- See saved entries as markers on the map
- Tap a marker to see full details in a bottom sheet

---

## Architecture Overview

Three layers. Each layer only talks to the one below it.

```
PRESENTATION  →  Riverpod providers, screens, widgets
     ↓
  DOMAIN      →  Entities, use cases, repository interface (pure Dart)
     ↓
   DATA        →  Hive models, datasource, repository implementation
```

---

## Tech Stack

| Package | Purpose |
|---|---|
| `maplibre_gl` | Renders the map with Galli Maps style |
| `flutter_riverpod` | State management |
| `freezed_annotation` + `freezed` | Immutable data classes |
| `json_annotation` + `json_serializable` | toJson / fromJson |
| `hive_flutter` + `hive_generator` | Local storage |
| `geolocator` | GPS permission + current location |
| `uuid` | Unique IDs for entries |
| `go_router` | Declarative routing between screens |
| `build_runner` | Runs code generation |

---

## STEP 1 — Project Setup

### 1.1 Create project
```bash
flutter create galli_map_app
cd galli_map_app
```

### 1.2 pubspec.yaml — full dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  maplibre_gl: ^0.21.0
  flutter_riverpod: ^2.5.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  hive_flutter: ^1.1.0
  geolocator: ^13.0.1
  uuid: ^4.4.0
  go_router: ^14.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  hive_generator: ^2.0.1
```

```bash
flutter pub get
```

### 1.3 Android permissions
In `android/app/src/main/AndroidManifest.xml`, add before `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### 1.4 Minimum SDK
In `android/app/build.gradle`:
```groovy
defaultConfig {
    minSdkVersion 21
    targetSdkVersion 34
}
```

---

## STEP 2 — Folder Structure

Create these folders and empty dart files before writing any code.

```
lib/
├── core/
│   └── constants/
│       └── app_constants.dart
│
├── features/
│   └── entry/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── entry_local_datasource.dart
│       │   ├── models/
│       │   │   └── entry_model.dart
│       │   └── repositories/
│       │       └── entry_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── entry_entity.dart
│       │   ├── repositories/
│       │   │   └── entry_repository.dart
│       │   └── usecases/
│       │       ├── add_entry_usecase.dart
│       │       ├── get_entries_usecase.dart
│       │       └── delete_entry_usecase.dart
│       │
│       └── presentation/
│           ├── providers/
│           │   └── entry_provider.dart
│           ├── screens/
│           │   ├── map_screen.dart
│           │   └── add_entry_screen.dart
│           └── widgets/
│               ├── entry_bottom_sheet.dart
│               ├── category_icon_picker.dart
│               └── map_crosshair.dart
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── router/
│       └── app_router.dart          ← go_router lives here
│
└── main.dart
```

---

## STEP 3 — Core Constants

### `lib/core/constants/app_constants.dart`
```dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String mapStyleUrl =
      'https://map-init.gallimap.com/styles/light/style.json';

  static const String entriesBoxName = 'entries_box';

  static const double defaultLat  = 27.7172;
  static const double defaultLng  = 85.3240;
  static const double defaultZoom = 12.0;
}

// Category model
class CategoryIcon {
  final String id;
  final String label;
  final IconData icon;
  const CategoryIcon({required this.id, required this.label, required this.icon});
}

// Predefined category list
const List<CategoryIcon> kCategories = [
  CategoryIcon(id: 'food',   label: 'Food',      icon: Icons.restaurant),
  CategoryIcon(id: 'home',   label: 'Home',      icon: Icons.home),
  CategoryIcon(id: 'work',   label: 'Work',      icon: Icons.work),
  CategoryIcon(id: 'travel', label: 'Travel',    icon: Icons.flight),
  CategoryIcon(id: 'shop',   label: 'Shop',      icon: Icons.shopping_bag),
  CategoryIcon(id: 'health', label: 'Health',    icon: Icons.local_hospital),
  CategoryIcon(id: 'edu',    label: 'Education', icon: Icons.school),
  CategoryIcon(id: 'other',  label: 'Other',     icon: Icons.place),
];
```

---

## STEP 4 — Domain Layer

> Pure Dart only. No Flutter imports. No Hive. No database.

### `lib/features/entry/domain/entities/entry_entity.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry_entity.freezed.dart';

@freezed
class EntryEntity with _$EntryEntity {
  const factory EntryEntity({
    required String id,
    required String title,
    required String description,
    required String categoryId,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
  }) = _EntryEntity;
}
```

### `lib/features/entry/domain/repositories/entry_repository.dart`
```dart
import '../entities/entry_entity.dart';

abstract class EntryRepository {
  Future<List<EntryEntity>> getAllEntries();
  Future<void> addEntry(EntryEntity entry);
  Future<void> deleteEntry(String id);
}
```

### `lib/features/entry/domain/usecases/add_entry_usecase.dart`
```dart
import '../entities/entry_entity.dart';
import '../repositories/entry_repository.dart';

class AddEntryUseCase {
  final EntryRepository repository;
  AddEntryUseCase(this.repository);

  Future<void> execute(EntryEntity entry) => repository.addEntry(entry);
}
```

### `lib/features/entry/domain/usecases/get_entries_usecase.dart`
```dart
import '../entities/entry_entity.dart';
import '../repositories/entry_repository.dart';

class GetEntriesUseCase {
  final EntryRepository repository;
  GetEntriesUseCase(this.repository);

  Future<List<EntryEntity>> execute() => repository.getAllEntries();
}
```

### `lib/features/entry/domain/usecases/delete_entry_usecase.dart`
```dart
import '../repositories/entry_repository.dart';

class DeleteEntryUseCase {
  final EntryRepository repository;
  DeleteEntryUseCase(this.repository);

  Future<void> execute(String id) => repository.deleteEntry(id);
}
```

---

## STEP 5 — Data Layer

### `lib/features/entry/data/models/entry_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/entry_entity.dart';

part 'entry_model.freezed.dart';
part 'entry_model.g.dart';

@freezed
@HiveType(typeId: 0)
class EntryModel with _$EntryModel {
  const EntryModel._(); // required for custom methods with freezed

  const factory EntryModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required String categoryId,
    @HiveField(4) required double latitude,
    @HiveField(5) required double longitude,
    @HiveField(6) required DateTime createdAt,
  }) = _EntryModel;

  factory EntryModel.fromJson(Map<String, dynamic> json) =>
      _$EntryModelFromJson(json);

  // domain → data
  factory EntryModel.fromEntity(EntryEntity e) => EntryModel(
        id:          e.id,
        title:       e.title,
        description: e.description,
        categoryId:  e.categoryId,
        latitude:    e.latitude,
        longitude:   e.longitude,
        createdAt:   e.createdAt,
      );

  // data → domain
  EntryEntity toEntity() => EntryEntity(
        id:          id,
        title:       title,
        description: description,
        categoryId:  categoryId,
        latitude:    latitude,
        longitude:   longitude,
        createdAt:   createdAt,
      );
}
```

> ⚠️ After writing this file, run build_runner (Step 8) before continuing.

### `lib/features/entry/data/datasources/entry_local_datasource.dart`
```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry_model.dart';
import '../../../../core/constants/app_constants.dart';

class EntryLocalDatasource {
  Box<EntryModel> get _box =>
      Hive.box<EntryModel>(AppConstants.entriesBoxName);

  Future<List<EntryModel>> getAll() async => _box.values.toList();

  Future<void> add(EntryModel model) async => _box.put(model.id, model);

  Future<void> delete(String id) async => _box.delete(id);
}
```

### `lib/features/entry/data/repositories/entry_repository_impl.dart`
```dart
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';
import '../datasources/entry_local_datasource.dart';
import '../models/entry_model.dart';

class EntryRepositoryImpl implements EntryRepository {
  final EntryLocalDatasource datasource;
  EntryRepositoryImpl(this.datasource);

  @override
  Future<List<EntryEntity>> getAllEntries() async {
    final models = await datasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addEntry(EntryEntity entry) async =>
      datasource.add(EntryModel.fromEntity(entry));

  @override
  Future<void> deleteEntry(String id) async => datasource.delete(id);
}
```

---

## STEP 6 — Riverpod Providers

### `lib/features/entry/presentation/providers/entry_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/usecases/add_entry_usecase.dart';
import '../../domain/usecases/get_entries_usecase.dart';
import '../../domain/usecases/delete_entry_usecase.dart';
import '../../data/datasources/entry_local_datasource.dart';
import '../../data/repositories/entry_repository_impl.dart';

// Wire up dependencies
final datasourceProvider  = Provider((_) => EntryLocalDatasource());
final repositoryProvider  = Provider((ref) =>
    EntryRepositoryImpl(ref.read(datasourceProvider)));
final addUseCaseProvider    = Provider((ref) =>
    AddEntryUseCase(ref.read(repositoryProvider)));
final getUseCaseProvider    = Provider((ref) =>
    GetEntriesUseCase(ref.read(repositoryProvider)));
final deleteUseCaseProvider = Provider((ref) =>
    DeleteEntryUseCase(ref.read(repositoryProvider)));

// StateNotifier — holds the list of entries and methods to change it
class EntryNotifier extends StateNotifier<List<EntryEntity>> {
  final AddEntryUseCase    _add;
  final GetEntriesUseCase  _getAll;
  final DeleteEntryUseCase _delete;

  EntryNotifier(this._add, this._getAll, this._delete) : super([]) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = await _getAll.execute();
  }

  Future<void> addEntry({
    required String title,
    required String description,
    required String categoryId,
    required double latitude,
    required double longitude,
  }) async {
    final entry = EntryEntity(
      id:          const Uuid().v4(),
      title:       title,
      description: description,
      categoryId:  categoryId,
      latitude:    latitude,
      longitude:   longitude,
      createdAt:   DateTime.now(),
    );
    await _add.execute(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _delete.execute(id);
    await loadEntries();
  }
}

// The provider widgets will watch
final entryProvider =
    StateNotifierProvider<EntryNotifier, List<EntryEntity>>((ref) {
  return EntryNotifier(
    ref.read(addUseCaseProvider),
    ref.read(getUseCaseProvider),
    ref.read(deleteUseCaseProvider),
  );
});
```

---

## STEP 7 — main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'features/entry/data/models/entry_model.dart';
import 'features/entry/presentation/screens/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(EntryModelAdapter()); // generated by build_runner
  await Hive.openBox<EntryModel>(AppConstants.entriesBoxName);

  runApp(
    const ProviderScope( // required root widget for Riverpod
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galli Map App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A73E8),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
```

---

## STEP 8 — Routing with go_router

### Why go_router?
`Navigator.push()` works but gets messy fast. `go_router` gives you named routes, URL-based navigation, and easy passing of parameters — all in one clean file.

### `lib/core/router/app_router.dart`
```dart
import 'package:go_router/go_router.dart';
import '../../features/entry/presentation/screens/map_screen.dart';
import '../../features/entry/presentation/screens/add_entry_screen.dart';

// Route name constants — use these instead of raw strings
class AppRoutes {
  static const String map      = '/';
  static const String addEntry = '/add-entry';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.map,
  routes: [
    GoRoute(
      path: AppRoutes.map,
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: AppRoutes.addEntry,
      builder: (context, state) {
        // Receive lat/lng passed as extra
        final coords = state.extra as Map<String, double>;
        return AddEntryScreen(
          latitude:  coords['lat']!,
          longitude: coords['lng']!,
        );
      },
    ),
  ],
);
```

### Update `main.dart` — use `GoRouter`
Replace `MaterialApp` with `MaterialApp.router`:
```dart
import 'core/router/app_router.dart';

// Inside MyApp.build():
return MaterialApp.router(
  title: 'Galli Map App',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    colorSchemeSeed: const Color(0xFF1A73E8),
    useMaterial3: true,
  ),
  routerConfig: appRouter,  // ← hand over routing to go_router
);
```

### How to navigate — replace Navigator.push calls

**From MapScreen → AddEntryScreen (passing lat/lng):**
```dart
// OLD — do NOT use this anymore
Navigator.push(context, MaterialPageRoute(builder: (_) => AddEntryScreen(...)));

// NEW — use go_router
context.push(
  AppRoutes.addEntry,
  extra: {'lat': lat, 'lng': lng},
);
```

**Go back after saving:**
```dart
// In AddEntryScreen after saving:
if (mounted) context.pop();
```

### Update `map_screen.dart` — swap Navigator for go_router
In `_confirmLocation()`, replace the `Navigator.push` block with:
```dart
await context.push(
  AppRoutes.addEntry,
  extra: {'lat': lat, 'lng': lng},
);
// Refresh markers after returning
final entries = ref.read(entryProvider);
_refreshMarkers(entries);
```

> Add `import 'package:go_router/go_router.dart';` at the top of any file that uses `context.push()` or `context.pop()`.

---

## STEP 9 — Run Code Generation

Run this after writing `entry_entity.dart` and `entry_model.dart`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `entry_entity.freezed.dart` — immutable class implementation
- `entry_model.freezed.dart` — same for model
- `entry_model.g.dart` — toJson/fromJson + `EntryModelAdapter` for Hive

Re-run any time you change a `@freezed` or `@HiveType` file.

---

## STEP 10 — Map Screen

### `lib/features/entry/presentation/screens/map_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/entry_entity.dart';
import '../providers/entry_provider.dart';
import '../widgets/entry_bottom_sheet.dart';
import '../widgets/map_crosshair.dart';
import 'add_entry_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MaplibreMapController? _controller;
  bool _isPinMode = false;

  @override
  void initState() {
    super.initState();
    _requestLocationAndCenter();
  }

  Future<void> _requestLocationAndCenter() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    _controller?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(pos.latitude, pos.longitude),
      14.0,
    ));
  }

  void _onMapCreated(MaplibreMapController controller) {
    _controller = controller;
    // Draw existing markers on first load
    final entries = ref.read(entryProvider);
    _refreshMarkers(entries);
  }

  Future<void> _refreshMarkers(List<EntryEntity> entries) async {
    if (_controller == null) return;
    await _controller!.clearSymbols();
    for (final entry in entries) {
      await _controller!.addSymbol(
        SymbolOptions(
          geometry: LatLng(entry.latitude, entry.longitude),
          iconImage: 'marker-15',
          iconSize: 2.0,
        ),
        {'id': entry.id},
      );
    }
  }

  Future<void> _confirmLocation() async {
    if (_controller == null) return;
    // Get the center of the current map viewport
    final region = await _controller!.getVisibleRegion();
    final lat = (region.northeast.latitude  + region.southwest.latitude)  / 2;
    final lng = (region.northeast.longitude + region.southwest.longitude) / 2;

    setState(() => _isPinMode = false);

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEntryScreen(latitude: lat, longitude: lng),
      ),
    );
    // Refresh markers after returning from add screen
    final entries = ref.read(entryProvider);
    _refreshMarkers(entries);
  }

  void _onSymbolTapped(Symbol symbol) {
    final entries = ref.read(entryProvider);
    final id = symbol.data?['id'] as String?;
    if (id == null) return;
    final entry = entries.firstWhere((e) => e.id == id);
    showModalBottomSheet(
      context: context,
      builder: (_) => EntryBottomSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-draw markers whenever the entry list changes
    ref.listen(entryProvider, (_, entries) => _refreshMarkers(entries));

    return Scaffold(
      body: Stack(
        children: [
          MaplibreMap(
            styleString: AppConstants.mapStyleUrl,
            initialCameraPosition: const CameraPosition(
              target: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
              zoom: AppConstants.defaultZoom,
            ),
            onMapCreated: _onMapCreated,
            onSymbolTapped: _onSymbolTapped,
            myLocationEnabled: true,
          ),
          if (_isPinMode) const MapCrosshair(),
        ],
      ),
      floatingActionButton: _isPinMode
          ? FloatingActionButton.extended(
              onPressed: _confirmLocation,
              label: const Text('Confirm Location'),
              icon: const Icon(Icons.check),
            )
          : FloatingActionButton(
              onPressed: () => setState(() => _isPinMode = true),
              child: const Icon(Icons.add_location_alt),
            ),
    );
  }
}
```

---

## STEP 11 — Widgets

### `lib/features/entry/presentation/widgets/map_crosshair.dart`
```dart
import 'package:flutter/material.dart';

class MapCrosshair extends StatelessWidget {
  const MapCrosshair({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.add_location,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
        shadows: const [Shadow(blurRadius: 8, color: Colors.black45)],
      ),
    );
  }
}
```

### `lib/features/entry/presentation/widgets/category_icon_picker.dart`
```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class CategoryIconPicker extends StatelessWidget {
  final String selectedId;
  final void Function(String id) onSelect;

  const CategoryIconPicker({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: kCategories.map((cat) {
        final isSelected = cat.id == selectedId;
        return GestureDetector(
          onTap: () => onSelect(cat.id),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
                child: Icon(
                  cat.icon,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(cat.label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
```

### `lib/features/entry/presentation/widgets/entry_bottom_sheet.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entry_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/entry_provider.dart';

class EntryBottomSheet extends ConsumerWidget {
  final EntryEntity entry;
  const EntryBottomSheet({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = kCategories.firstWhere(
      (c) => c.id == entry.categoryId,
      orElse: () => kCategories.last,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Icon(cat.icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  ref.read(entryProvider.notifier).deleteEntry(entry.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(entry.description),
          const SizedBox(height: 8),
          Text(
            'Lat: ${entry.latitude.toStringAsFixed(5)},  '
            'Lng: ${entry.longitude.toStringAsFixed(5)}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

---

## STEP 12 — Add Entry Screen

### `lib/features/entry/presentation/screens/add_entry_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/entry_provider.dart';
import '../widgets/category_icon_picker.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  final double latitude;
  final double longitude;

  const AddEntryScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _titleController = TextEditingController();
  final _descController  = TextEditingController();
  String _selectedCategory = 'other';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    await ref.read(entryProvider.notifier).addEntry(
      title:       _titleController.text.trim(),
      description: _descController.text.trim(),
      categoryId:  _selectedCategory,
      latitude:    widget.latitude,
      longitude:   widget.longitude,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            CategoryIconPicker(
              selectedId: _selectedCategory,
              onSelect: (id) => setState(() => _selectedCategory = id),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Entry'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 13 — Release APK

### 12.1 Generate a keystore
```bash
keytool -genkey -v -keystore ~/galli_key.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias galli
```

### 12.2 Configure signing in `android/app/build.gradle`
```groovy
android {
    signingConfigs {
        release {
            storeFile     file("/path/to/galli_key.jks")
            storePassword "yourpassword"
            keyAlias      "galli"
            keyPassword   "yourpassword"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
        }
    }
}
```

### 12.3 Build
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Submission checklist
- [ ] GitHub repo is public
- [ ] README explains how to run
- [ ] APK attached to a GitHub Release
- [ ] Repo link + APK link submitted before Apr 29 2:00 PM

---

## Key Concepts to Ask Your AI Tutor

Paste any of these questions directly to your AI to learn as you build:

### go_router
- "What is the difference between context.push() and context.go() in go_router?"
- "Why do we pass lat/lng as `extra` instead of as query parameters?"
- "What does `state.extra` mean in the GoRoute builder and how does it work?"
- "When should I use go_router instead of Navigator.push?"

### Clean Architecture
- "Why should the domain layer never import Flutter or Hive packages?"
- "Why do we have both EntryEntity and EntryModel? Can we just use one?"
- "Walk me through how data flows from the Hive box to the map marker, step by step."

### Riverpod
- "What is the difference between ref.watch() and ref.read()? When do I use each?"
- "Explain StateNotifier vs ChangeNotifier. Which is better for a list of items?"
- "What happens step by step when I call ref.read(entryProvider.notifier).addEntry()?"
- "Why do we need ProviderScope at the top of the widget tree?"

### Freezed
- "Show me what entry_entity.freezed.dart looks like after code generation and explain each part."
- "Why do we write const EntryModel._() in a Hive + Freezed model?"
- "What does copyWith() do and when would I use it?"

### Hive
- "What is a TypeAdapter in Hive and why does Hive need one?"
- "Why do we call Hive.registerAdapter() before openBox()?"
- "What does @HiveField(0) mean and why do the numbers matter?"

### Debugging
- "My build_runner says 'Could not find a file for part' — what does this mean?"
- "My map shows a blank screen instead of tiles. What should I check?"
- "Markers are not appearing on the map after I save an entry. What could be wrong?"

---

## Common Mistakes to Avoid

- Do NOT use `Navigator.push()` anywhere once you adopt go_router — pick one and stick to it
- Do NOT forget to cast `state.extra` — it comes as `Object?` so you must cast it to your type
- Do NOT put `appRouter` inside a widget's build method — define it at the top level so it is not recreated on rebuilds
- Do NOT forget to run `build_runner` after editing any `@freezed` or `@HiveType` file
- Do NOT register the same Hive adapter twice in `main.dart`
- Do NOT use `ref.watch()` inside event handlers — only inside `build()` — use `ref.read()` in callbacks
- Do NOT forget `const EntryModel._()` — without it, you cannot add custom methods to a Freezed class
- Do NOT forget `WidgetsFlutterBinding.ensureInitialized()` before any async work in `main()`
