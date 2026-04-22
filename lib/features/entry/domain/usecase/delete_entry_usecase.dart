import 'package:galli_maps_assignment/features/entry/domain/repo/entry_repository.dart';

class DeleteEntryUsecase {
  final EntryRepository repository;
  DeleteEntryUsecase( this.repository);
  Future<void> execute(String id ) => repository.deleteEntity(id);
  }