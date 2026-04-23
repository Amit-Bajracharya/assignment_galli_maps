/// Direct interface to Hive local database.
/// Handles CRUD operations for EntryModel objects.

import 'package:galli_maps_assignment/core/constants/app_constants.dart';
import 'package:galli_maps_assignment/features/entry/data/models/entry_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EntryLocalDatasource {
  // Hive box is opened in main.dart, accessed here by name
  Box<EntryModel> get _box => Hive.box<EntryModel>(AppConstants.entriesBoxName);

  /// Returns all saved entries as a list
  Future<List<EntryModel>> getAll() async => _box.values.toList();

  /// Saves entry to Hive using its ID as the key
  Future<void> add(EntryModel model) async => _box.put(model.id, model);

  /// Removes entry from Hive by ID
  Future<void> delete(String id) async => _box.delete(id);
}