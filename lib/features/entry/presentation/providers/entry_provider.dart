import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galli_maps_assignment/features/entry/data/datasource/entry_local_datasource.dart';
import 'package:galli_maps_assignment/features/entry/data/repository/entry_repository_impl.dart';
import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/usecases/add_entry_usecase.dart';
import 'package:galli_maps_assignment/features/entry/domain/usecases/delete_entry_usecase.dart';
import 'package:galli_maps_assignment/features/entry/domain/usecases/get_all_entity_usecase.dart';
import 'package:uuid/uuid.dart';

final datasourceProvider = Provider((ref) => EntryLocalDatasource());
final repositoryProvider = Provider((ref) => EntryRepositoryImpl(ref.read(datasourceProvider)));
final addUseCaseProvider = Provider((ref) => AddEntryUsecase(ref.read(repositoryProvider)));
final getUseCaseProvider = Provider((ref) => GetAllEntityUsecase(ref.read(repositoryProvider)));
final deleteUseCaseProvider = Provider((ref) => DeleteEntryUsecase(ref.read(repositoryProvider)));

/// State notifier for managing location entries.
class EntryNotifier extends StateNotifier<List<EntryEntity>> {
  final AddEntryUsecase _add;
  final GetAllEntityUsecase _getAll;
  final DeleteEntryUsecase _delete;

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
      id: const Uuid().v4(),
      title: title,
      description: description,
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );
    await _add.execute(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _delete.execute(id);
    await loadEntries();
  }
}

final entryProvider = StateNotifierProvider<EntryNotifier, List<EntryEntity>>((ref) {
  return EntryNotifier(
    ref.read(addUseCaseProvider),
    ref.read(getUseCaseProvider),
    ref.read(deleteUseCaseProvider),
  );
});