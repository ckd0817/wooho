import 'package:freezed_annotation/freezed_annotation.dart';

part 'dance_move.freezed.dart';
part 'dance_move.g.dart';

/// 动作实体
@freezed
class DanceMove with _$DanceMove {
  const factory DanceMove({
    required String id,
    required String name,
    required String category,

    // 视频源数据
    @JsonKey(name: 'video_source_type') required VideoSourceType videoSourceType,
    @JsonKey(name: 'video_uri') required String videoUri,
    @Default(0) @JsonKey(name: 'trim_start') int trimStart, // 毫秒
    @Default(0) @JsonKey(name: 'trim_end') int trimEnd, // 毫秒

    // 训练数据
    @Default(MoveStatus.new_) MoveStatus status,
    @JsonKey(name: 'mastery_level') @Default(0) int masteryLevel, // 0-100 熟练度
    @JsonKey(name: 'last_practiced_at') @Default(0) int lastPracticedAt, // Timestamp 上次练习时间

    // 元数据
    @JsonKey(name: 'created_at') @Default(0) int createdAt, // Timestamp
    @JsonKey(name: 'updated_at') int? updatedAt, // Timestamp
  }) = _DanceMove;

  factory DanceMove.fromJson(Map<String, dynamic> json) =>
      _$DanceMoveFromJson(json);
}

/// 视频源类型
enum VideoSourceType {
  @JsonValue('local_gallery')
  localGallery,
  @JsonValue('bundled_asset')
  bundledAsset,
  @JsonValue('web_url')
  webUrl,
  @JsonValue('none')
  none, // 无视频源
}

/// 动作状态
enum MoveStatus {
  @JsonValue('new')
  new_,
  @JsonValue('learning')
  learning,
  @JsonValue('reviewing')
  reviewing,
}
