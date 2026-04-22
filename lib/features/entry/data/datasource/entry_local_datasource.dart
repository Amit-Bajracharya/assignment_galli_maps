import 'package:galli_maps_assignment/core/constants/app_constants.dart';
import 'package:galli_maps_assignment/features/entry/data/models/entry_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EntryLocalDatasource {

  Box<EntryModel> get _box => Hive.box<EntryModel> (AppConstants.entriesBoxName);

  Future<List<EntryModel>> getAll() async => _box.values.toList();
  Future<void> add(EntryModel model) async => _box.put(model.id, model);
  Future<void> delete(String id) async => _box.delete(id);
}