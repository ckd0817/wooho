// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewSessionImpl _$$ReviewSessionImplFromJson(Map<String, dynamic> json) =>
    _$ReviewSessionImpl(
      date: json['date'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => DanceMove.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedItemIds:
          (json['completedItemIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isDrillComplete: json['isDrillComplete'] as bool? ?? false,
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$$ReviewSessionImplToJson(_$ReviewSessionImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'items': instance.items,
      'completedItemIds': instance.completedItemIds,
      'isDrillComplete': instance.isDrillComplete,
      'createdAt': instance.createdAt,
    };
