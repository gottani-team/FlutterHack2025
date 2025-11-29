// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      currentKarma: (json['current_karma'] as num?)?.toInt() ?? 0,
      createdAt:
          const TimestampConverter().fromJson(json['created_at'] as Object),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'current_karma': instance.currentKarma,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
    };
