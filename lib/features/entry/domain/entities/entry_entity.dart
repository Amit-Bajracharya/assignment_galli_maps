import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';


part 'entry_entity.freezed.dart';
@freezed
class EntryEntity  with _$EntryEntity{

  const factory EntryEntity({
    required String id,
    required String title,
    required String description,
    required String categoryId,
    required double latitude,
    required double longitude,
    required DateTime createdAt
  }) = _EntryEntity;
}