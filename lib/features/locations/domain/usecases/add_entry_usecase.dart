import 'package:galli_maps_assignment/features/locations/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/locations/domain/repository/entry_repository.dart';

/// Use case for adding a new entry.
class AddEntryUsecase {
  final EntryRepository repository;
  AddEntryUsecase(this.repository);

  Future<void> execute(EntryEntity entry) => repository.addEntry(entry);
}