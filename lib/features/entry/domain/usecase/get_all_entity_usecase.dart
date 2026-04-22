import 'package:galli_maps_assignment/features/entry/domain/entities/entry_entity.dart';
import 'package:galli_maps_assignment/features/entry/domain/repo/entry_repository.dart';

class GetAllEntityUsecase {
  final EntryRepository repository;
  GetAllEntityUsecase(this.repository);
  Future<List<EntryEntity>> execute() => repository.getAllEntities();
}