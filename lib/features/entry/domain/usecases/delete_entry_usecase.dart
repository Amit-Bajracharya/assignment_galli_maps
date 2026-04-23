/// Use case for deleting an entry by ID.

import 'package:galli_maps_assignment/features/entry/domain/repository/entry_repository.dart';

class DeleteEntryUsecase {
  final EntryRepository repository;
  DeleteEntryUsecase(this.repository);

  /// Removes entry from repository
  Future<void> execute(String id) => repository.deleteEntry(id);
}