import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';

abstract class EntryRepository {
  Future<List<EntryEntity>> getAllEntities();
  Future<void> addEntity(EntryEntity entity);
  Future<void> deleteEntity(String id);
}