import 'package:freezed_annotation/freezed_annotation.dart';

part 'dance_element.freezed.dart';
part 'dance_element.g.dart';

/// 元素实体
@freezed
class DanceElement with _$DanceElement {
  const factory DanceElement({
    required String id,
    required String name,
    required String category,

    // 视频源数据
    @JsonKey(name: 'video_source_type') required VideoSourceType videoSourceType,
    @JsonKey(name: 'video_uri') required String videoUri,
    @Default(0) @JsonKey(name: 'trim_start') int trimStart, // 毫秒
    @Default(0) @JsonKey(name: 'trim_end') int trimEnd, // 毫秒

    // 训练数据
    @Default(ElementStatus.new_) ElementStatus status,
    @JsonKey(name: 'mastery_level') @Default(0) int masteryLevel, // 0-100 熟练度
    @JsonKey(name: 'last_practiced_at') @Default(0) int lastPracticedAt, // Timestamp 上次练习时间

    // 元数据
    @JsonKey(name: 'created_at') @Default(0) int createdAt, // Timestamp
    @JsonKey(name: 'updated_at') int? updatedAt, // Timestamp
  }) = _DanceElement;

  factory DanceElement.fromJson(Map<String, dynamic> json) =>
      _$DanceElementFromJson(json);
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

/// 元素状态
enum ElementStatus {
  @JsonValue('new')
  new_,
  @JsonValue('learning')
  learning,
  @JsonValue('reviewing')
  reviewing,
}
