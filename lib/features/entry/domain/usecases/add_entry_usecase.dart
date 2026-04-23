import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/repository/entry_repository.dart';

/// Use case for adding a new entry.
class AddEntryUsecase {
  final EntryRepository repository;
  AddEntryUsecase(this.repository);

  Future<void> execute(EntryEntity entry) => repository.addEntry(entry);
}