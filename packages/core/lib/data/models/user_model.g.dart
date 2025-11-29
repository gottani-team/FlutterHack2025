// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      isAnonymous: json['is_anonymous'] as bool,
      createdAt: const TimestampConverter()
          .fromJson(json['created_at'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'is_anonymous': instance.isAnonymous,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
    };
