/// Domain entity representing a saved location entry.
/// Contains core business data: coordinates, title, category, etc.
/// Used throughout the domain and presentation layers.

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry_entity.freezed.dart';

@freezed
class EntryEntity with _$EntryEntity {
  const factory EntryEntity({
    required String id,           // Unique identifier (UUID)
    required String title,        // Display name of the location
    required String description,  // Notes about the place
    required String categoryId,   // Icon category (food, home, work, etc.)
    required double latitude,     // GPS latitude
    required double longitude,    // GPS longitude
    required DateTime createdAt,  // When entry was created
  }) = _EntryEntity;
}