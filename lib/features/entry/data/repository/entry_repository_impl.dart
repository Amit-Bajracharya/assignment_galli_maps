import 'package:galli_maps_assignment/features/entry/data/datasource/entry_local_datasource.dart';
import 'package:galli_maps_assignment/features/entry/data/models/entry_model.dart';
import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/repository/entry_repository.dart';

class EntryRepositoryImpl implements EntryRepository{
  final EntryLocalDatasource datasource;
  EntryRepositoryImpl(this.datasource);



  @override
  Future<void> addEntry(EntryEntity entity)  async {
    await datasource.add(EntryModel.fromEntity(entity));
  }

  @override
  Future<void> deleteEntry(String id) async {
    await datasource.delete(id);
  }

  @override
  Future<List<EntryEntity>> getAllEntries() async {
    final models = await datasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }
}