/// Riverpod providers for dependency injection and state management.
/// Sets up the chain: UI -> Notifier -> UseCase -> Repository -> DataSource -> Hive

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galli_maps_assignment/features/entry/data/datasource/entry_local_datasource.dart';
import 'package:galli_maps_assignment/features/entry/data/repository/entry_repository_impl.dart';
import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/usecases/add_entry_usecase.dart';
import 'package:galli_maps_assignment/features/entry/domain/usecases/delete_entry_usecase.dart';
import 'package:galli_maps_assignment/features/entry/domain/usecases/get_all_entity_usecase.dart';
import 'package:uuid/uuid.dart';

// Data layer providers - single instances throughout app
final datasourceProvider = Provider((ref) => EntryLocalDatasource());
final repositoryProvider = Provider((ref) => EntryRepositoryImpl(ref.read(datasourceProvider)));

// Use case providers - business logic layer
final addUseCaseProvider = Provider((ref) => AddEntryUsecase(ref.read(repositoryProvider)));
final getUseCaseProvider = Provider((ref) => GetAllEntityUsecase(ref.read(repositoryProvider)));
final deleteUseCaseProvider = Provider((ref) => DeleteEntryUsecase(ref.read(repositoryProvider)));

/// Manages the list of entries. UI watches this for changes.
class EntryNotifier extends StateNotifier<List<EntryEntity>> {
  final AddEntryUsecase _add;
  final GetAllEntityUsecase _getAll;
  final DeleteEntryUsecase _delete;

  EntryNotifier(this._add, this._getAll, this._delete) : super([]) {
    // Load saved entries when app starts
    loadEntries();
  }

  /// Fetches all entries from local storage and updates UI
  Future<void> loadEntries() async {
    state = await _getAll.execute();
  }

  /// Creates new entry with unique ID, saves to storage, refreshes list
  Future<void> addEntry({
    required String title,
    required String description,
    required String categoryId,
    required double latitude,
    required double longitude,
  }) async {
    final entry = EntryEntity(
      id: const Uuid().v4(), // unique ID for each entry
      title: title,
      description: description,
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );
    await _add.execute(entry);
    await loadEntries(); // refresh the list so UI updates
  }

  /// Deletes entry by ID and refreshes the list
  Future<void> deleteEntry(String id) async {
    await _delete.execute(id);
    await loadEntries();
  }
}

/// Main provider used by UI to access entries and call methods
final entryProvider = StateNotifierProvider<EntryNotifier, List<EntryEntity>>((ref) {
  return EntryNotifier(
    ref.read(addUseCaseProvider),
    ref.read(getUseCaseProvider),
    ref.read(deleteUseCaseProvider),
  );
});