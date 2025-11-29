// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_burial_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemoryBurialModel _$MemoryBurialModelFromJson(Map<String, dynamic> json) =>
    MemoryBurialModel(
      id: json['id'] as String,
      memoryText: json['memoryText'] as String,
      location:
          GeoLocationModel.fromJson(json['location'] as Map<String, dynamic>),
      buriedAt: MemoryBurialModel._timestampToDateTime(json['buriedAt']),
      crystalColor: json['crystalColor'] as String?,
      emotionType: json['emotionType'] as String?,
    );

Map<String, dynamic> _$MemoryBurialModelToJson(MemoryBurialModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memoryText': instance.memoryText,
      'location': instance.location,
      'buriedAt': MemoryBurialModel._dateTimeToTimestamp(instance.buriedAt),
      'crystalColor': instance.crystalColor,
      'emotionType': instance.emotionType,
    };
