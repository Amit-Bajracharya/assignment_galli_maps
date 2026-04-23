/// Use case for adding a new entry.
/// Part of domain layer - contains pure business logic.

import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/repository/entry_repository.dart';

class AddEntryUsecase {
  final EntryRepository repository;
  AddEntryUsecase(this.repository);

  /// Saves entry to repository
  Future<void> execute(EntryEntity entry) => repository.addEntry(entry);
}