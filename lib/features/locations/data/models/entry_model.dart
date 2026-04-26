import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/entry_entity.dart';

part 'entry_model.freezed.dart';
part 'entry_model.g.dart';

/// Data layer model for Hive storage.
@freezed
@HiveType(typeId: 0)
class EntryModel with _$EntryModel {
  const EntryModel._();

  const factory EntryModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required String categoryId,
    @HiveField(4) required double latitude,
    @HiveField(5) required double longitude,
    @HiveField(6) required DateTime createdAt,
  }) = _EntryModel;

  factory EntryModel.fromEntity(EntryEntity e) => EntryModel(
        id: e.id,
        title: e.title,
        description: e.description,
        categoryId: e.categoryId,
        latitude: e.latitude,
        longitude: e.longitude,
        createdAt: e.createdAt,
      );

  EntryEntity toEntity() => EntryEntity(
        id: id,
        title: title,
        description: description,
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        createdAt: createdAt,
      );
}
