// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dance_move.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DanceMove _$DanceMoveFromJson(Map<String, dynamic> json) {
  return _DanceMove.fromJson(json);
}

/// @nodoc
mixin _$DanceMove {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError; // 视频源数据
  VideoSourceType get videoSourceType => throw _privateConstructorUsedError;
  String get videoUri => throw _privateConstructorUsedError;
  int get trimStart => throw _privateConstructorUsedError; // 毫秒
  int get trimEnd => throw _privateConstructorUsedError; // 毫秒
  // SRS 学习数据
  MoveStatus get status => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError; // 当前间隔天数
  int get nextReviewDate =>
      throw _privateConstructorUsedError; // Timestamp (milliseconds since epoch)
  int get masteryLevel => throw _privateConstructorUsedError; // 0-100
  // 元数据
  int get createdAt => throw _privateConstructorUsedError; // Timestamp
  int? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DanceMove to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DanceMove
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DanceMoveCopyWith<DanceMove> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DanceMoveCopyWith<$Res> {
  factory $DanceMoveCopyWith(DanceMove value, $Res Function(DanceMove) then) =
      _$DanceMoveCopyWithImpl<$Res, DanceMove>;
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    VideoSourceType videoSourceType,
    String videoUri,
    int trimStart,
    int trimEnd,
    MoveStatus status,
    int interval,
    int nextReviewDate,
    int masteryLevel,
    int createdAt,
    int? updatedAt,
  });
}

/// @nodoc
class _$DanceMoveCopyWithImpl<$Res, $Val extends DanceMove>
    implements $DanceMoveCopyWith<$Res> {
  _$DanceMoveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DanceMove
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
    Object? interval = null,
    Object? nextReviewDate = null,
    Object? masteryLevel = null,
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
                      as MoveStatus,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as int,
            nextReviewDate: null == nextReviewDate
                ? _value.nextReviewDate
                : nextReviewDate // ignore: cast_nullable_to_non_nullable
                      as int,
            masteryLevel: null == masteryLevel
                ? _value.masteryLevel
                : masteryLevel // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DanceMoveImplCopyWith<$Res>
    implements $DanceMoveCopyWith<$Res> {
  factory _$$DanceMoveImplCopyWith(
    _$DanceMoveImpl value,
    $Res Function(_$DanceMoveImpl) then,
  ) = __$$DanceMoveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    VideoSourceType videoSourceType,
    String videoUri,
    int trimStart,
    int trimEnd,
    MoveStatus status,
    int interval,
    int nextReviewDate,
    int masteryLevel,
    int createdAt,
    int? updatedAt,
  });
}

/// @nodoc
class __$$DanceMoveImplCopyWithImpl<$Res>
    extends _$DanceMoveCopyWithImpl<$Res, _$DanceMoveImpl>
    implements _$$DanceMoveImplCopyWith<$Res> {
  __$$DanceMoveImplCopyWithImpl(
    _$DanceMoveImpl _value,
    $Res Function(_$DanceMoveImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DanceMove
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
    Object? interval = null,
    Object? nextReviewDate = null,
    Object? masteryLevel = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DanceMoveImpl(
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
                  as MoveStatus,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as int,
        nextReviewDate: null == nextReviewDate
            ? _value.nextReviewDate
            : nextReviewDate // ignore: cast_nullable_to_non_nullable
                  as int,
        masteryLevel: null == masteryLevel
            ? _value.masteryLevel
            : masteryLevel // ignore: cast_nullable_to_non_nullable
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
class _$DanceMoveImpl implements _DanceMove {
  const _$DanceMoveImpl({
    required this.id,
    required this.name,
    required this.category,
    required this.videoSourceType,
    required this.videoUri,
    this.trimStart = 0,
    this.trimEnd = 0,
    this.status = MoveStatus.new_,
    this.interval = 1,
    required this.nextReviewDate,
    this.masteryLevel = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$DanceMoveImpl.fromJson(Map<String, dynamic> json) =>
      _$$DanceMoveImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;
  // 视频源数据
  @override
  final VideoSourceType videoSourceType;
  @override
  final String videoUri;
  @override
  @JsonKey()
  final int trimStart;
  // 毫秒
  @override
  @JsonKey()
  final int trimEnd;
  // 毫秒
  // SRS 学习数据
  @override
  @JsonKey()
  final MoveStatus status;
  @override
  @JsonKey()
  final int interval;
  // 当前间隔天数
  @override
  final int nextReviewDate;
  // Timestamp (milliseconds since epoch)
  @override
  @JsonKey()
  final int masteryLevel;
  // 0-100
  // 元数据
  @override
  final int createdAt;
  // Timestamp
  @override
  final int? updatedAt;

  @override
  String toString() {
    return 'DanceMove(id: $id, name: $name, category: $category, videoSourceType: $videoSourceType, videoUri: $videoUri, trimStart: $trimStart, trimEnd: $trimEnd, status: $status, interval: $interval, nextReviewDate: $nextReviewDate, masteryLevel: $masteryLevel, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DanceMoveImpl &&
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
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.nextReviewDate, nextReviewDate) ||
                other.nextReviewDate == nextReviewDate) &&
            (identical(other.masteryLevel, masteryLevel) ||
                other.masteryLevel == masteryLevel) &&
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
    interval,
    nextReviewDate,
    masteryLevel,
    createdAt,
    updatedAt,
  );

  /// Create a copy of DanceMove
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DanceMoveImplCopyWith<_$DanceMoveImpl> get copyWith =>
      __$$DanceMoveImplCopyWithImpl<_$DanceMoveImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DanceMoveImplToJson(this);
  }
}

abstract class _DanceMove implements DanceMove {
  const factory _DanceMove({
    required final String id,
    required final String name,
    required final String category,
    required final VideoSourceType videoSourceType,
    required final String videoUri,
    final int trimStart,
    final int trimEnd,
    final MoveStatus status,
    final int interval,
    required final int nextReviewDate,
    final int masteryLevel,
    required final int createdAt,
    final int? updatedAt,
  }) = _$DanceMoveImpl;

  factory _DanceMove.fromJson(Map<String, dynamic> json) =
      _$DanceMoveImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get category; // 视频源数据
  @override
  VideoSourceType get videoSourceType;
  @override
  String get videoUri;
  @override
  int get trimStart; // 毫秒
  @override
  int get trimEnd; // 毫秒
  // SRS 学习数据
  @override
  MoveStatus get status;
  @override
  int get interval; // 当前间隔天数
  @override
  int get nextReviewDate; // Timestamp (milliseconds since epoch)
  @override
  int get masteryLevel; // 0-100
  // 元数据
  @override
  int get createdAt; // Timestamp
  @override
  int? get updatedAt;

  /// Create a copy of DanceMove
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DanceMoveImplCopyWith<_$DanceMoveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
