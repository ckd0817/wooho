// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dance_move.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DanceMoveImpl _$$DanceMoveImplFromJson(Map<String, dynamic> json) =>
    _$DanceMoveImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      videoSourceType: $enumDecode(
        _$VideoSourceTypeEnumMap,
        json['video_source_type'],
      ),
      videoUri: json['video_uri'] as String,
      trimStart: (json['trim_start'] as num?)?.toInt() ?? 0,
      trimEnd: (json['trim_end'] as num?)?.toInt() ?? 0,
      status:
          $enumDecodeNullable(_$MoveStatusEnumMap, json['status']) ??
          MoveStatus.new_,
      masteryLevel: (json['mastery_level'] as num?)?.toInt() ?? 0,
      lastPracticedAt: (json['last_practiced_at'] as num?)?.toInt() ?? 0,
      createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
      updatedAt: (json['updated_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DanceMoveImplToJson(_$DanceMoveImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'video_source_type': _$VideoSourceTypeEnumMap[instance.videoSourceType]!,
      'video_uri': instance.videoUri,
      'trim_start': instance.trimStart,
      'trim_end': instance.trimEnd,
      'status': _$MoveStatusEnumMap[instance.status]!,
      'mastery_level': instance.masteryLevel,
      'last_practiced_at': instance.lastPracticedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

const _$VideoSourceTypeEnumMap = {
  VideoSourceType.localGallery: 'local_gallery',
  VideoSourceType.bundledAsset: 'bundled_asset',
  VideoSourceType.webUrl: 'web_url',
  VideoSourceType.none: 'none',
};

const _$MoveStatusEnumMap = {
  MoveStatus.new_: 'new',
  MoveStatus.learning: 'learning',
  MoveStatus.reviewing: 'reviewing',
};
