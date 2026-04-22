// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EntryEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EntryEntityCopyWith<EntryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntryEntityCopyWith<$Res> {
  factory $EntryEntityCopyWith(
          EntryEntity value, $Res Function(EntryEntity) then) =
      _$EntryEntityCopyWithImpl<$Res, EntryEntity>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String categoryId,
      double latitude,
      double longitude,
      DateTime createdAt});
}

/// @nodoc
class _$EntryEntityCopyWithImpl<$Res, $Val extends EntryEntity>
    implements $EntryEntityCopyWith<$Res> {
  _$EntryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? categoryId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EntryEntityImplCopyWith<$Res>
    implements $EntryEntityCopyWith<$Res> {
  factory _$$EntryEntityImplCopyWith(
          _$EntryEntityImpl value, $Res Function(_$EntryEntityImpl) then) =
      __$$EntryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String categoryId,
      double latitude,
      double longitude,
      DateTime createdAt});
}

/// @nodoc
class __$$EntryEntityImplCopyWithImpl<$Res>
    extends _$EntryEntityCopyWithImpl<$Res, _$EntryEntityImpl>
    implements _$$EntryEntityImplCopyWith<$Res> {
  __$$EntryEntityImplCopyWithImpl(
      _$EntryEntityImpl _value, $Res Function(_$EntryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? categoryId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
  }) {
    return _then(_$EntryEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$EntryEntityImpl with DiagnosticableTreeMixin implements _EntryEntity {
  const _$EntryEntityImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.categoryId,
      required this.latitude,
      required this.longitude,
      required this.createdAt});

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String categoryId;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EntryEntity(id: $id, title: $title, description: $description, categoryId: $categoryId, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EntryEntity'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('categoryId', categoryId))
      ..add(DiagnosticsProperty('latitude', latitude))
      ..add(DiagnosticsProperty('longitude', longitude))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, description,
      categoryId, latitude, longitude, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EntryEntityImplCopyWith<_$EntryEntityImpl> get copyWith =>
      __$$EntryEntityImplCopyWithImpl<_$EntryEntityImpl>(this, _$identity);
}

abstract class _EntryEntity implements EntryEntity {
  const factory _EntryEntity(
      {required final String id,
      required final String title,
      required final String description,
      required final String categoryId,
      required final double latitude,
      required final double longitude,
      required final DateTime createdAt}) = _$EntryEntityImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get categoryId;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$EntryEntityImplCopyWith<_$EntryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
