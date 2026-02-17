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
    required VideoSourceType videoSourceType,
    required String videoUri,
    @Default(0) int trimStart, // 毫秒
    @Default(0) int trimEnd, // 毫秒

    // SRS 学习数据
    @Default(MoveStatus.new_) MoveStatus status,
    @Default(1) int interval, // 当前间隔天数
    required int nextReviewDate, // Timestamp (milliseconds since epoch)
    @Default(0) int masteryLevel, // 0-100

    // 元数据
    required int createdAt, // Timestamp
    int? updatedAt, // Timestamp
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
