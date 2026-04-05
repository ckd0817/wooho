import 'package:freezed_annotation/freezed_annotation.dart';
import 'dance_element.dart';

part 'dance_routine.freezed.dart';
part 'dance_routine.g.dart';

/// 舞段实体
@freezed
class DanceRoutine with _$DanceRoutine {
  const factory DanceRoutine({
    required String id,
    required String name,
    required String category,

    // 视频源数据
    @JsonKey(name: 'video_source_type') required VideoSourceType videoSourceType,
    @JsonKey(name: 'video_uri') required String videoUri,
    @Default(0) @JsonKey(name: 'trim_start') int trimStart, // 毫秒
    @Default(0) @JsonKey(name: 'trim_end') int trimEnd, // 毫秒

    // 训练数据
    @Default(RoutineStatus.new_) RoutineStatus status,
    @JsonKey(name: 'mastery_level') @Default(0) int masteryLevel, // 0-100 熟练度
    @JsonKey(name: 'last_practiced_at') @Default(0) int lastPracticedAt, // Timestamp 上次练习时间

    // 元数据
    @JsonKey(name: 'created_at') @Default(0) int createdAt, // Timestamp
    @JsonKey(name: 'updated_at') int? updatedAt, // Timestamp

    // 可选：备注
    String? notes,
  }) = _DanceRoutine;

  factory DanceRoutine.fromJson(Map<String, dynamic> json) =>
      _$DanceRoutineFromJson(json);
}

/// 舞段状态
enum RoutineStatus {
  @JsonValue('new')
  new_,
  @JsonValue('learning')
  learning,
  @JsonValue('reviewing')
  reviewing,
}
