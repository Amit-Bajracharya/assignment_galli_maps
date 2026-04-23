/// Repository implementation - bridges domain and data layers.
/// Converts between Entities (domain) and Models (data).

import 'package:galli_maps_assignment/features/entry/data/datasource/entry_local_datasource.dart';
import 'package:galli_maps_assignment/features/entry/data/models/entry_model.dart';
import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/repository/entry_repository.dart';

class EntryRepositoryImpl implements EntryRepository {
  final EntryLocalDatasource datasource;
  EntryRepositoryImpl(this.datasource);

  /// Converts Entity to Model and saves to Hive
  @override
  Future<void> addEntry(EntryEntity entity) async {
    await datasource.add(EntryModel.fromEntity(entity));
  }

  /// Deletes entry by ID from Hive
  @override
  Future<void> deleteEntry(String id) async {
    await datasource.delete(id);
  }

  /// Fetches all models from Hive, converts to Entities for domain layer
  @override
  Future<List<EntryEntity>> getAllEntries() async {
    final models = await datasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }
}