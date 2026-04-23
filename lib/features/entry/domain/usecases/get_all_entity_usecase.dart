/// Use case for fetching all saved entries.

import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/repository/entry_repository.dart';

class GetAllEntityUsecase {
  final EntryRepository repository;
  GetAllEntityUsecase(this.repository);

  /// Returns list of all entries from repository
  Future<List<EntryEntity>> execute() => repository.getAllEntries();
}