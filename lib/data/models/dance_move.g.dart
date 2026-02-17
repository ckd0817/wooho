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
        json['videoSourceType'],
      ),
      videoUri: json['videoUri'] as String,
      trimStart: (json['trimStart'] as num?)?.toInt() ?? 0,
      trimEnd: (json['trimEnd'] as num?)?.toInt() ?? 0,
      status:
          $enumDecodeNullable(_$MoveStatusEnumMap, json['status']) ??
          MoveStatus.new_,
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      nextReviewDate: (json['nextReviewDate'] as num).toInt(),
      masteryLevel: (json['masteryLevel'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] as num).toInt(),
      updatedAt: (json['updatedAt'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DanceMoveImplToJson(_$DanceMoveImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'videoSourceType': _$VideoSourceTypeEnumMap[instance.videoSourceType]!,
      'videoUri': instance.videoUri,
      'trimStart': instance.trimStart,
      'trimEnd': instance.trimEnd,
      'status': _$MoveStatusEnumMap[instance.status]!,
      'interval': instance.interval,
      'nextReviewDate': instance.nextReviewDate,
      'masteryLevel': instance.masteryLevel,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$VideoSourceTypeEnumMap = {
  VideoSourceType.localGallery: 'local_gallery',
  VideoSourceType.bundledAsset: 'bundled_asset',
};

const _$MoveStatusEnumMap = {
  MoveStatus.new_: 'new',
  MoveStatus.learning: 'learning',
  MoveStatus.reviewing: 'reviewing',
};
