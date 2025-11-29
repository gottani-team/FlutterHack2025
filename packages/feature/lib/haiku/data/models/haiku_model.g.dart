// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haiku_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HaikuModel _$HaikuModelFromJson(Map<String, dynamic> json) => HaikuModel(
      id: json['id'] as String,
      theme: json['theme'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$HaikuModelToJson(HaikuModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'theme': instance.theme,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
