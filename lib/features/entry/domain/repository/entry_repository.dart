import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';

/// Repository interface for entry data operations.
abstract class EntryRepository {
  Future<List<EntryEntity>> getAllEntries();
  Future<void> addEntry(EntryEntity entity);
  Future<void> deleteEntry(String id);
}