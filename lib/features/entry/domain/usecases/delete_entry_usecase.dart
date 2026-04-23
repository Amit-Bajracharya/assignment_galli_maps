import 'package:galli_maps_assignment/features/entry/domain/repository/entry_repository.dart';

/// Use case for deleting an entry by ID.
class DeleteEntryUsecase {
  final EntryRepository repository;
  DeleteEntryUsecase(this.repository);

  Future<void> execute(String id) => repository.deleteEntry(id);
}