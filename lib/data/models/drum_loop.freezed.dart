// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drum_loop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DrumLoop _$DrumLoopFromJson(Map<String, dynamic> json) {
  return _DrumLoop.fromJson(json);
}

/// @nodoc
mixin _$DrumLoop {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get assetPath =>
      throw _privateConstructorUsedError; // assets/audio/xxx.mp3
  int get bpm => throw _privateConstructorUsedError; // 原始 BPM
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this DrumLoop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DrumLoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DrumLoopCopyWith<DrumLoop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DrumLoopCopyWith<$Res> {
  factory $DrumLoopCopyWith(DrumLoop value, $Res Function(DrumLoop) then) =
      _$DrumLoopCopyWithImpl<$Res, DrumLoop>;
  @useResult
  $Res call({
    String id,
    String name,
    String assetPath,
    int bpm,
    bool isDefault,
  });
}

/// @nodoc
class _$DrumLoopCopyWithImpl<$Res, $Val extends DrumLoop>
    implements $DrumLoopCopyWith<$Res> {
  _$DrumLoopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DrumLoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? assetPath = null,
    Object? bpm = null,
    Object? isDefault = null,
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
            assetPath: null == assetPath
                ? _value.assetPath
                : assetPath // ignore: cast_nullable_to_non_nullable
                      as String,
            bpm: null == bpm
                ? _value.bpm
                : bpm // ignore: cast_nullable_to_non_nullable
                      as int,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DrumLoopImplCopyWith<$Res>
    implements $DrumLoopCopyWith<$Res> {
  factory _$$DrumLoopImplCopyWith(
    _$DrumLoopImpl value,
    $Res Function(_$DrumLoopImpl) then,
  ) = __$$DrumLoopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String assetPath,
    int bpm,
    bool isDefault,
  });
}

/// @nodoc
class __$$DrumLoopImplCopyWithImpl<$Res>
    extends _$DrumLoopCopyWithImpl<$Res, _$DrumLoopImpl>
    implements _$$DrumLoopImplCopyWith<$Res> {
  __$$DrumLoopImplCopyWithImpl(
    _$DrumLoopImpl _value,
    $Res Function(_$DrumLoopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DrumLoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? assetPath = null,
    Object? bpm = null,
    Object? isDefault = null,
  }) {
    return _then(
      _$DrumLoopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        assetPath: null == assetPath
            ? _value.assetPath
            : assetPath // ignore: cast_nullable_to_non_nullable
                  as String,
        bpm: null == bpm
            ? _value.bpm
            : bpm // ignore: cast_nullable_to_non_nullable
                  as int,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DrumLoopImpl implements _DrumLoop {
  const _$DrumLoopImpl({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.bpm,
    this.isDefault = true,
  });

  factory _$DrumLoopImpl.fromJson(Map<String, dynamic> json) =>
      _$$DrumLoopImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String assetPath;
  // assets/audio/xxx.mp3
  @override
  final int bpm;
  // 原始 BPM
  @override
  @JsonKey()
  final bool isDefault;

  @override
  String toString() {
    return 'DrumLoop(id: $id, name: $name, assetPath: $assetPath, bpm: $bpm, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DrumLoopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.assetPath, assetPath) ||
                other.assetPath == assetPath) &&
            (identical(other.bpm, bpm) || other.bpm == bpm) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, assetPath, bpm, isDefault);

  /// Create a copy of DrumLoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DrumLoopImplCopyWith<_$DrumLoopImpl> get copyWith =>
      __$$DrumLoopImplCopyWithImpl<_$DrumLoopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DrumLoopImplToJson(this);
  }
}

abstract class _DrumLoop implements DrumLoop {
  const factory _DrumLoop({
    required final String id,
    required final String name,
    required final String assetPath,
    required final int bpm,
    final bool isDefault,
  }) = _$DrumLoopImpl;

  factory _DrumLoop.fromJson(Map<String, dynamic> json) =
      _$DrumLoopImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get assetPath; // assets/audio/xxx.mp3
  @override
  int get bpm; // 原始 BPM
  @override
  bool get isDefault;

  /// Create a copy of DrumLoop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DrumLoopImplCopyWith<_$DrumLoopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
