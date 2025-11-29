// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_crystal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemoryCrystalModel _$MemoryCrystalModelFromJson(Map<String, dynamic> json) =>
    MemoryCrystalModel(
      id: json['id'] as String,
      location: const GeoPointConverter()
          .fromJson(json['location'] as Map<String, dynamic>),
      geohash: json['geohash'] as String,
      emotion: EmotionType.fromJson(json['emotion'] as String),
      creatorId: json['creator_id'] as String,
      createdAt: const TimestampConverter()
          .fromJson(json['created_at'] as Map<String, dynamic>),
      isExcavated: json['is_excavated'] as bool,
      text: json['text'] as String?,
      excavatedBy: json['excavated_by'] as String?,
      excavatedAt: _$JsonConverterFromJson<Map<String, dynamic>, Timestamp>(
          json['excavated_at'], const TimestampConverter().fromJson),
    );

Map<String, dynamic> _$MemoryCrystalModelToJson(MemoryCrystalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location': const GeoPointConverter().toJson(instance.location),
      'geohash': instance.geohash,
      'emotion': _emotionTypeToJson(instance.emotion),
      'creator_id': instance.creatorId,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
      'is_excavated': instance.isExcavated,
      'text': instance.text,
      'excavated_by': instance.excavatedBy,
      'excavated_at': _$JsonConverterToJson<Map<String, dynamic>, Timestamp>(
          instance.excavatedAt, const TimestampConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
