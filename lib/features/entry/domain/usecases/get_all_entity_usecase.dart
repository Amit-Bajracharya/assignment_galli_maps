import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/repository/entry_repository.dart';

/// Use case for fetching all saved entries.
class GetAllEntityUsecase {
  final EntryRepository repository;
  GetAllEntityUsecase(this.repository);

  Future<List<EntryEntity>> execute() => repository.getAllEntries();
}