// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crystal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrystalModel _$CrystalModelFromJson(Map<String, dynamic> json) => CrystalModel(
      id: json['id'] as String,
      status: json['status'] as String,
      karmaValue: (json['karma_value'] as num).toInt(),
      imageUrl: json['image_url'] as String,
      aiMetadata:
          AIMetadataModel.fromJson(json['ai_metadata'] as Map<String, dynamic>),
      createdAt:
          const TimestampConverter().fromJson(json['created_at'] as Object),
      secretText: json['secret_text'] as String,
      createdBy: json['created_by'] as String,
      creatorNickname: json['creator_nickname'] as String,
      decipheredBy: json['deciphered_by'] as String?,
      decipheredAt: _$JsonConverterFromJson<Object, Timestamp>(
          json['deciphered_at'], const TimestampConverter().fromJson),
    );

Map<String, dynamic> _$CrystalModelToJson(CrystalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'karma_value': instance.karmaValue,
      'image_url': instance.imageUrl,
      'ai_metadata': instance.aiMetadata.toJson(),
      'created_at': const TimestampConverter().toJson(instance.createdAt),
      'secret_text': instance.secretText,
      'created_by': instance.createdBy,
      'creator_nickname': instance.creatorNickname,
      'deciphered_by': instance.decipheredBy,
      'deciphered_at': _$JsonConverterToJson<Object, Timestamp>(
          instance.decipheredAt, const TimestampConverter().toJson),
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
