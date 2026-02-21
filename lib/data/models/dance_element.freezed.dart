// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dance_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DanceElement _$DanceElementFromJson(Map<String, dynamic> json) {
  return _DanceElement.fromJson(json);
}

/// @nodoc
mixin _$DanceElement {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError; // 视频源数据
  @JsonKey(name: 'video_source_type')
  VideoSourceType get videoSourceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_uri')
  String get videoUri => throw _privateConstructorUsedError;
  @JsonKey(name: 'trim_start')
  int get trimStart => throw _privateConstructorUsedError; // 毫秒
  @JsonKey(name: 'trim_end')
  int get trimEnd => throw _privateConstructorUsedError; // 毫秒
  // 训练数据
  ElementStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'mastery_level')
  int get masteryLevel => throw _privateConstructorUsedError; // 0-100 熟练度
  @JsonKey(name: 'last_practiced_at')
  int get lastPracticedAt => throw _privateConstructorUsedError; // Timestamp 上次练习时间
  // 元数据
  @JsonKey(name: 'created_at')
  int get createdAt => throw _privateConstructorUsedError; // Timestamp
  @JsonKey(name: 'updated_at')
  int? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DanceElement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DanceElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DanceElementCopyWith<DanceElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DanceElementCopyWith<$Res> {
  factory $DanceElementCopyWith(
    DanceElement value,
    $Res Function(DanceElement) then,
  ) = _$DanceElementCopyWithImpl<$Res, DanceElement>;
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    @JsonKey(name: 'video_source_type') VideoSourceType videoSourceType,
    @JsonKey(name: 'video_uri') String videoUri,
    @JsonKey(name: 'trim_start') int trimStart,
    @JsonKey(name: 'trim_end') int trimEnd,
    ElementStatus status,
    @JsonKey(name: 'mastery_level') int masteryLevel,
    @JsonKey(name: 'last_practiced_at') int lastPracticedAt,
    @JsonKey(name: 'created_at') int createdAt,
    @JsonKey(name: 'updated_at') int? updatedAt,
  });
}

/// @nodoc
class _$DanceElementCopyWithImpl<$Res, $Val extends DanceElement>
    implements $DanceElementCopyWith<$Res> {
  _$DanceElementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DanceElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? videoSourceType = null,
    Object? videoUri = null,
    Object? trimStart = null,
    Object? trimEnd = null,
    Object? status = null,
    Object? masteryLevel = null,
    Object? lastPracticedAt = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            videoSourceType: null == videoSourceType
                ? _value.videoSourceType
                : videoSourceType // ignore: cast_nullable_to_non_nullable
                      as VideoSourceType,
            videoUri: null == videoUri
                ? _value.videoUri
                : videoUri // ignore: cast_nullable_to_non_nullable
                      as String,
            trimStart: null == trimStart
                ? _value.trimStart
                : trimStart // ignore: cast_nullable_to_non_nullable
                      as int,
            trimEnd: null == trimEnd
                ? _value.trimEnd
                : trimEnd // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ElementStatus,
            masteryLevel: null == masteryLevel
                ? _value.masteryLevel
                : masteryLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            lastPracticedAt: null == lastPracticedAt
                ? _value.lastPracticedAt
                : lastPracticedAt // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as int,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DanceElementImplCopyWith<$Res>
    implements $DanceElementCopyWith<$Res> {
  factory _$$DanceElementImplCopyWith(
    _$DanceElementImpl value,
    $Res Function(_$DanceElementImpl) then,
  ) = __$$DanceElementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    @JsonKey(name: 'video_source_type') VideoSourceType videoSourceType,
    @JsonKey(name: 'video_uri') String videoUri,
    @JsonKey(name: 'trim_start') int trimStart,
    @JsonKey(name: 'trim_end') int trimEnd,
    ElementStatus status,
    @JsonKey(name: 'mastery_level') int masteryLevel,
    @JsonKey(name: 'last_practiced_at') int lastPracticedAt,
    @JsonKey(name: 'created_at') int createdAt,
    @JsonKey(name: 'updated_at') int? updatedAt,
  });
}

/// @nodoc
class __$$DanceElementImplCopyWithImpl<$Res>
    extends _$DanceElementCopyWithImpl<$Res, _$DanceElementImpl>
    implements _$$DanceElementImplCopyWith<$Res> {
  __$$DanceElementImplCopyWithImpl(
    _$DanceElementImpl _value,
    $Res Function(_$DanceElementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DanceElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? videoSourceType = null,
    Object? videoUri = null,
    Object? trimStart = null,
    Object? trimEnd = null,
    Object? status = null,
    Object? masteryLevel = null,
    Object? lastPracticedAt = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DanceElementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        videoSourceType: null == videoSourceType
            ? _value.videoSourceType
            : videoSourceType // ignore: cast_nullable_to_non_nullable
                  as VideoSourceType,
        videoUri: null == videoUri
            ? _value.videoUri
            : videoUri // ignore: cast_nullable_to_non_nullable
                  as String,
        trimStart: null == trimStart
            ? _value.trimStart
            : trimStart // ignore: cast_nullable_to_non_nullable
                  as int,
        trimEnd: null == trimEnd
            ? _value.trimEnd
            : trimEnd // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ElementStatus,
        masteryLevel: null == masteryLevel
            ? _value.masteryLevel
            : masteryLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        lastPracticedAt: null == lastPracticedAt
            ? _value.lastPracticedAt
            : lastPracticedAt // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as int,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DanceElementImpl implements _DanceElement {
  const _$DanceElementImpl({
    required this.id,
    required this.name,
    required this.category,
    @JsonKey(name: 'video_source_type') required this.videoSourceType,
    @JsonKey(name: 'video_uri') required this.videoUri,
    @JsonKey(name: 'trim_start') this.trimStart = 0,
    @JsonKey(name: 'trim_end') this.trimEnd = 0,
    this.status = ElementStatus.new_,
    @JsonKey(name: 'mastery_level') this.masteryLevel = 0,
    @JsonKey(name: 'last_practiced_at') this.lastPracticedAt = 0,
    @JsonKey(name: 'created_at') this.createdAt = 0,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$DanceElementImpl.fromJson(Map<String, dynamic> json) =>
      _$$DanceElementImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;
  // 视频源数据
  @override
  @JsonKey(name: 'video_source_type')
  final VideoSourceType videoSourceType;
  @override
  @JsonKey(name: 'video_uri')
  final String videoUri;
  @override
  @JsonKey(name: 'trim_start')
  final int trimStart;
  // 毫秒
  @override
  @JsonKey(name: 'trim_end')
  final int trimEnd;
  // 毫秒
  // 训练数据
  @override
  @JsonKey()
  final ElementStatus status;
  @override
  @JsonKey(name: 'mastery_level')
  final int masteryLevel;
  // 0-100 熟练度
  @override
  @JsonKey(name: 'last_practiced_at')
  final int lastPracticedAt;
  // Timestamp 上次练习时间
  // 元数据
  @override
  @JsonKey(name: 'created_at')
  final int createdAt;
  // Timestamp
  @override
  @JsonKey(name: 'updated_at')
  final int? updatedAt;

  @override
  String toString() {
    return 'DanceElement(id: $id, name: $name, category: $category, videoSourceType: $videoSourceType, videoUri: $videoUri, trimStart: $trimStart, trimEnd: $trimEnd, status: $status, masteryLevel: $masteryLevel, lastPracticedAt: $lastPracticedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DanceElementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.videoSourceType, videoSourceType) ||
                other.videoSourceType == videoSourceType) &&
            (identical(other.videoUri, videoUri) ||
                other.videoUri == videoUri) &&
            (identical(other.trimStart, trimStart) ||
                other.trimStart == trimStart) &&
            (identical(other.trimEnd, trimEnd) || other.trimEnd == trimEnd) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.masteryLevel, masteryLevel) ||
                other.masteryLevel == masteryLevel) &&
            (identical(other.lastPracticedAt, lastPracticedAt) ||
                other.lastPracticedAt == lastPracticedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    category,
    videoSourceType,
    videoUri,
    trimStart,
    trimEnd,
    status,
    masteryLevel,
    lastPracticedAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of DanceElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DanceElementImplCopyWith<_$DanceElementImpl> get copyWith =>
      __$$DanceElementImplCopyWithImpl<_$DanceElementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DanceElementImplToJson(this);
  }
}

abstract class _DanceElement implements DanceElement {
  const factory _DanceElement({
    required final String id,
    required final String name,
    required final String category,
    @JsonKey(name: 'video_source_type')
    required final VideoSourceType videoSourceType,
    @JsonKey(name: 'video_uri') required final String videoUri,
    @JsonKey(name: 'trim_start') final int trimStart,
    @JsonKey(name: 'trim_end') final int trimEnd,
    final ElementStatus status,
    @JsonKey(name: 'mastery_level') final int masteryLevel,
    @JsonKey(name: 'last_practiced_at') final int lastPracticedAt,
    @JsonKey(name: 'created_at') final int createdAt,
    @JsonKey(name: 'updated_at') final int? updatedAt,
  }) = _$DanceElementImpl;

  factory _DanceElement.fromJson(Map<String, dynamic> json) =
      _$DanceElementImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get category; // 视频源数据
  @override
  @JsonKey(name: 'video_source_type')
  VideoSourceType get videoSourceType;
  @override
  @JsonKey(name: 'video_uri')
  String get videoUri;
  @override
  @JsonKey(name: 'trim_start')
  int get trimStart; // 毫秒
  @override
  @JsonKey(name: 'trim_end')
  int get trimEnd; // 毫秒
  // 训练数据
  @override
  ElementStatus get status;
  @override
  @JsonKey(name: 'mastery_level')
  int get masteryLevel; // 0-100 熟练度
  @override
  @JsonKey(name: 'last_practiced_at')
  int get lastPracticedAt; // Timestamp 上次练习时间
  // 元数据
  @override
  @JsonKey(name: 'created_at')
  int get createdAt; // Timestamp
  @override
  @JsonKey(name: 'updated_at')
  int? get updatedAt;

  /// Create a copy of DanceElement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DanceElementImplCopyWith<_$DanceElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
