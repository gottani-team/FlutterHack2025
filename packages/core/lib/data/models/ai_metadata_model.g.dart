// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_metadata_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIMetadataModel _$AIMetadataModelFromJson(Map<String, dynamic> json) =>
    AIMetadataModel(
      emotionType: json['emotion_type'] as String,
      score: (json['score'] as num).toInt(),
    );

Map<String, dynamic> _$AIMetadataModelToJson(AIMetadataModel instance) =>
    <String, dynamic>{
      'emotion_type': instance.emotionType,
      'score': instance.score,
    };
