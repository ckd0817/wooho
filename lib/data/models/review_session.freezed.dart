// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewSession _$ReviewSessionFromJson(Map<String, dynamic> json) {
  return _ReviewSession.fromJson(json);
}

/// @nodoc
mixin _$ReviewSession {
  String get date => throw _privateConstructorUsedError; // YYYY-MM-DD
  List<DanceElement> get items =>
      throw _privateConstructorUsedError; // 今日需要复习的元素
  List<String> get completedItemIds =>
      throw _privateConstructorUsedError; // 已打分 ID
  bool get isDrillComplete => throw _privateConstructorUsedError; // 是否完成了串联训练
  int get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ReviewSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewSessionCopyWith<ReviewSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewSessionCopyWith<$Res> {
  factory $ReviewSessionCopyWith(
    ReviewSession value,
    $Res Function(ReviewSession) then,
  ) = _$ReviewSessionCopyWithImpl<$Res, ReviewSession>;
  @useResult
  $Res call({
    String date,
    List<DanceElement> items,
    List<String> completedItemIds,
    bool isDrillComplete,
    int createdAt,
  });
}

/// @nodoc
class _$ReviewSessionCopyWithImpl<$Res, $Val extends ReviewSession>
    implements $ReviewSessionCopyWith<$Res> {
  _$ReviewSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? items = null,
    Object? completedItemIds = null,
    Object? isDrillComplete = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<DanceElement>,
            completedItemIds: null == completedItemIds
                ? _value.completedItemIds
                : completedItemIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isDrillComplete: null == isDrillComplete
                ? _value.isDrillComplete
                : isDrillComplete // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewSessionImplCopyWith<$Res>
    implements $ReviewSessionCopyWith<$Res> {
  factory _$$ReviewSessionImplCopyWith(
    _$ReviewSessionImpl value,
    $Res Function(_$ReviewSessionImpl) then,
  ) = __$$ReviewSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    List<DanceElement> items,
    List<String> completedItemIds,
    bool isDrillComplete,
    int createdAt,
  });
}

/// @nodoc
class __$$ReviewSessionImplCopyWithImpl<$Res>
    extends _$ReviewSessionCopyWithImpl<$Res, _$ReviewSessionImpl>
    implements _$$ReviewSessionImplCopyWith<$Res> {
  __$$ReviewSessionImplCopyWithImpl(
    _$ReviewSessionImpl _value,
    $Res Function(_$ReviewSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? items = null,
    Object? completedItemIds = null,
    Object? isDrillComplete = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ReviewSessionImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<DanceElement>,
        completedItemIds: null == completedItemIds
            ? _value._completedItemIds
            : completedItemIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isDrillComplete: null == isDrillComplete
            ? _value.isDrillComplete
            : isDrillComplete // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewSessionImpl implements _ReviewSession {
  const _$ReviewSessionImpl({
    required this.date,
    required final List<DanceElement> items,
    final List<String> completedItemIds = const [],
    this.isDrillComplete = false,
    required this.createdAt,
  }) : _items = items,
       _completedItemIds = completedItemIds;

  factory _$ReviewSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewSessionImplFromJson(json);

  @override
  final String date;
  // YYYY-MM-DD
  final List<DanceElement> _items;
  // YYYY-MM-DD
  @override
  List<DanceElement> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  // 今日需要复习的元素
  final List<String> _completedItemIds;
  // 今日需要复习的元素
  @override
  @JsonKey()
  List<String> get completedItemIds {
    if (_completedItemIds is EqualUnmodifiableListView)
      return _completedItemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedItemIds);
  }

  // 已打分 ID
  @override
  @JsonKey()
  final bool isDrillComplete;
  // 是否完成了串联训练
  @override
  final int createdAt;

  @override
  String toString() {
    return 'ReviewSession(date: $date, items: $items, completedItemIds: $completedItemIds, isDrillComplete: $isDrillComplete, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewSessionImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(
              other._completedItemIds,
              _completedItemIds,
            ) &&
            (identical(other.isDrillComplete, isDrillComplete) ||
                other.isDrillComplete == isDrillComplete) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_completedItemIds),
    isDrillComplete,
    createdAt,
  );

  /// Create a copy of ReviewSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewSessionImplCopyWith<_$ReviewSessionImpl> get copyWith =>
      __$$ReviewSessionImplCopyWithImpl<_$ReviewSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewSessionImplToJson(this);
  }
}

abstract class _ReviewSession implements ReviewSession {
  const factory _ReviewSession({
    required final String date,
    required final List<DanceElement> items,
    final List<String> completedItemIds,
    final bool isDrillComplete,
    required final int createdAt,
  }) = _$ReviewSessionImpl;

  factory _ReviewSession.fromJson(Map<String, dynamic> json) =
      _$ReviewSessionImpl.fromJson;

  @override
  String get date; // YYYY-MM-DD
  @override
  List<DanceElement> get items; // 今日需要复习的元素
  @override
  List<String> get completedItemIds; // 已打分 ID
  @override
  bool get isDrillComplete; // 是否完成了串联训练
  @override
  int get createdAt;

  /// Create a copy of ReviewSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewSessionImplCopyWith<_$ReviewSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
