/// Repository interface defining data operations contract.
/// Implemented by data layer, used by domain layer use cases.

import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';

abstract class EntryRepository {
  /// Returns all saved entries
  Future<List<EntryEntity>> getAllEntries();

  /// Saves new entry
  Future<void> addEntry(EntryEntity entity);

  /// Removes entry by ID
  Future<void> deleteEntry(String id);
}