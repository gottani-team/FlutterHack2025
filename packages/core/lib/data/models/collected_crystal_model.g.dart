// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collected_crystal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectedCrystalModel _$CollectedCrystalModelFromJson(
        Map<String, dynamic> json) =>
    CollectedCrystalModel(
      id: json['id'] as String,
      secretText: json['secret_text'] as String,
      imageUrl: json['image_url'] as String,
      karmaCost: (json['karma_cost'] as num).toInt(),
      aiMetadata:
          AIMetadataModel.fromJson(json['ai_metadata'] as Map<String, dynamic>),
      decipheredAt:
          const TimestampConverter().fromJson(json['deciphered_at'] as Object),
      originalCreatorId: json['original_creator_id'] as String,
      originalCreatorNickname: json['original_creator_nickname'] as String,
    );

Map<String, dynamic> _$CollectedCrystalModelToJson(
        CollectedCrystalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'secret_text': instance.secretText,
      'image_url': instance.imageUrl,
      'karma_cost': instance.karmaCost,
      'ai_metadata': instance.aiMetadata.toJson(),
      'deciphered_at': const TimestampConverter().toJson(instance.decipheredAt),
      'original_creator_id': instance.originalCreatorId,
      'original_creator_nickname': instance.originalCreatorNickname,
    };
