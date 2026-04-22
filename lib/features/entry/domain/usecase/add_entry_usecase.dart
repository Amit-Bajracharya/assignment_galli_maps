import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/repo/entry_repository.dart';

class AddEntryUsecase {
  final EntryRepository repository;
  AddEntryUsecase(this.repository);
  Future<void> execute(EntryEntity entry) => repository.addEntity(entry);
}