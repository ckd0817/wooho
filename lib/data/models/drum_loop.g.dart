// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drum_loop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DrumLoopImpl _$$DrumLoopImplFromJson(Map<String, dynamic> json) =>
    _$DrumLoopImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      assetPath: json['assetPath'] as String,
      bpm: (json['bpm'] as num).toInt(),
      isDefault: json['isDefault'] as bool? ?? true,
    );

Map<String, dynamic> _$$DrumLoopImplToJson(_$DrumLoopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'assetPath': instance.assetPath,
      'bpm': instance.bpm,
      'isDefault': instance.isDefault,
    };
